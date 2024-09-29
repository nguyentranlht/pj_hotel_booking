import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:bike_repository/bike_repository.dart';
import 'package:flutter/material.dart';
import 'dart:developer';
import 'dart:typed_data';

import 'package:uuid/uuid.dart';

class FirebaseBikeRepo implements BikeRepo {
  final bikeCollection = FirebaseFirestore.instance.collection('bikes');
  final CollectionReference bikeCollection2 =
      FirebaseFirestore.instance.collection('bikes');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<Bike>> getBikes() async {
    try {
      return await bikeCollection.get().then((value) => value.docs
          .map((e) => Bike.fromEntity(BikeEntity.fromDocument(e.data())))
          .toList());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<String> sendImage(Uint8List file, String name) async {
    try {
      Reference firebaseStorageRef = FirebaseStorage.instance.ref().child(name);

      await firebaseStorageRef.putData(
          file,
          SettableMetadata(
            contentType: 'image/jpeg',
            // customMetadata: {'picked-file-path': file.path},
          ));
      return await firebaseStorageRef.getDownloadURL();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> createBikes(String locationId, Bike bike) async {
    try {
      // Truy cập đến document của location dựa trên locationId
      final locationDoc =
          FirebaseFirestore.instance.collection('locations').doc(locationId);

      // Thêm bike vào sub-collection 'bikes' trong document của location
      return await locationDoc
          .collection('bikes')
          .doc(bike.bikeId)
          .set(bike.toEntity().toDocument());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<String?> getBikeId(String userId) async {
    // Giả sử rằng bạn có thông tin về phòng được thanh toán trong user document
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      return userDoc.get('roomId');
    } else {
      throw Exception('User not found.');
    }
  }

  Future<void> addHistorySearchToUser(
    List<Map<String, dynamic>> availableBikes, // List<Map<String, dynamic>>
    String userId,
    Map dateSearch,
    Map timeSearch,
  ) async {
    String sessionId = const Uuid().v4(); // Tạo sessionId mới
    try {
      // Lấy giá trị từ Map dateSearch và timeSearch

      List<String> bikeIds = [];
      for (var bike in availableBikes) {
        if (bike.containsKey('bikeId')) {
          bikeIds.add(bike['bikeId']);
        }
      }

      CollectionReference paymentsCollectionRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('HistorySearch');

      DocumentReference newHistoryRef = paymentsCollectionRef.doc();
      String historySearchId = newHistoryRef.id; // Lấy ID tự sinh

      // Thêm document với dữ liệu và ID tự sinh
      await newHistoryRef.set({
        'bikes': availableBikes, // Dùng danh sách dữ liệu xe trực tiếp
        'historySearchId':
            historySearchId, // Lưu trữ historySearchId trong document
        'dateSearch': dateSearch,
        'timeSearch': timeSearch,
        'sessionId': sessionId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Lỗi khi thêm lịch sử tìm kiếm: $e');
    }
  }

  Future<String?> getLocationId(String locationName) async {
    try {
      // Truy vấn Firestore để tìm tài liệu trong collection 'locations' với trường 'name' bằng locationName
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
          .instance
          .collection('locations')
          .where('locationName', isEqualTo: locationName)
          .limit(
              1) // Giới hạn kết quả trả về để lấy ra document đầu tiên phù hợp
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Lấy ID của document đầu tiên trong danh sách kết quả
        return querySnapshot.docs.first.id;
      } else {
        // Không tìm thấy location với tên đã cho
        print('Không tìm thấy địa điểm với tên: $locationName');
        return null;
      }
    } catch (e) {
      // Xử lý lỗi trong quá trình truy vấn Firestore
      print('Lỗi khi lấy locationId: $e');
      return null;
    }
  }

  Future<void> addLatestContractFromPaymentSearch(
      String userId, String amount, String sessionId) async {
    try {
      // Lấy dữ liệu từ HistorySearch, sắp xếp theo createdAt và giới hạn lấy 1 tài liệu mới nhất
      CollectionReference<Map<String, dynamic>> historySearchRef =
          FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('PaymentHistory')
              .withConverter<Map<String, dynamic>>(
                fromFirestore: (snapshot, _) => snapshot.data()!,
                toFirestore: (data, _) => data,
              );

      QuerySnapshot<Map<String, dynamic>> historySearchSnapshot =
          await historySearchRef
              .orderBy('createdAt', descending: true)
              .where('sessionId', isEqualTo: sessionId)
              .limit(1)
              .get();
      // Kiểm tra xem có tài liệu nào không
      if (historySearchSnapshot.docs.isNotEmpty) {
        // Lấy dữ liệu từ tài liệu mới nhất
        DocumentSnapshot<Map<String, dynamic>> historyDoc =
            historySearchSnapshot.docs.first;
        Map<String, dynamic> historyData = historyDoc.data()!;

        // Lọc các xe có bikeStatus == "Có Sẵn"
        List<dynamic> bikes = historyData['bikes'];
        List<dynamic> availableBikes = bikes
            .where((bike) => bike['bikeStatus'] == 'Có sẵn')
            .toList(); // Lọc chỉ các xe có bikeStatus == "Có Sẵn"

        // Nếu không có xe nào có bikeStatus == "Có Sẵn", thì không thêm vào hợp đồng
        if (availableBikes.isEmpty) {
          print('Không có xe nào có trạng thái "Có Sẵn" để thêm vào hợp đồng.');
          return;
        }

        // Duyệt qua từng xe có bikeStatus == "Có Sẵn" và thay đổi bikeStatus thành 'Đã đặt'
        for (var bike in availableBikes) {
          bike['bikeStatus'] = 'Đã đặt';
        }

        // Cập nhật bikeStatus trong HistorySearch
        await historyDoc.reference.update({
          'bikes': bikes, // Cập nhật danh sách bikes trong HistorySearch
        });

        // Thêm xe đã cập nhật vào Contracts
        DocumentReference<Map<String, dynamic>> newContractRef =
            FirebaseFirestore.instance.collection('contracts').doc();
        String contractId = newContractRef.id;

        // Chuẩn bị dữ liệu để thêm vào contracts
        Map<String, dynamic> contractData = {
          'bikes':
              availableBikes, // Thêm danh sách bikes đã cập nhật vào hợp đồng
          'contractId': contractId,
          'price': amount,
          'userId': userId,
          'dateSearch': historyData['dateSearch'],
          'timeSearch': historyData['timeSearch'],
          'locationId': availableBikes.isNotEmpty
              ? availableBikes.first['locationId'].toString()
              : '',
          'locationBike': availableBikes.isNotEmpty
              ? availableBikes.first['locationBike'].toString()
              : '',
          'createdAt': FieldValue.serverTimestamp(),
        };
        // Thêm vào contracts
        await newContractRef.set(contractData);
        print(
            'Dữ liệu từ tài liệu mới nhất đã được thêm vào contracts và bikeStatus đã được cập nhật trong HistorySearch.');
      } else {
        print('Không tìm thấy tài liệu nào trong HistorySearch.');
      }
    } catch (e) {
      print('Lỗi khi thêm dữ liệu vào contracts: $e');
    }
  }

  Future<void> updateBikeStatusAfterPayment(
      String userId, String sessionId) async {
    try {
      // Lấy thông tin PaymentHistory của khách hàng sau khi thanh toán thành công
      QuerySnapshot<Map<String, dynamic>> currentPaymentSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('PaymentHistory')
              .where('sessionId', isEqualTo: sessionId)
              .limit(1)
              .get();
      if (currentPaymentSnapshot.docs.isEmpty) {
        print('Không tìm thấy PaymentHistory cho khách hàng này.');
        return;
      }
      // Lấy document hiện tại
      var currentPaymentDoc = currentPaymentSnapshot.docs.first.data();
      List<dynamic> currentBikes = currentPaymentDoc['bikes'] ?? [];
      List currentBikeIds = currentBikes.map((bike) => bike['bikeId']).toList();
      if (currentBikeIds.isEmpty) {
        print('Không có bikeId trong PaymentHistory hiện tại.');
        return;
      }
      var currentStartDateSearch =
          DateTime.parse(currentPaymentDoc['dateSearch']['startDate']);
      var currentEndDateSearch =
          DateTime.parse(currentPaymentDoc['dateSearch']['endDate']);
      var currentStartTimeSearch = TimeOfDay(
        hour: int.parse(
            currentPaymentDoc['timeSearch']['startTime'].split(':')[0]),
        minute: int.parse(
            currentPaymentDoc['timeSearch']['startTime'].split(':')[1]),
      );
      var currentEndTimeSearch = TimeOfDay(
        hour:
            int.parse(currentPaymentDoc['timeSearch']['endTime'].split(':')[0]),
        minute:
            int.parse(currentPaymentDoc['timeSearch']['endTime'].split(':')[1]),
      );
      // Lấy ngày hiện tại từ currentPaymentDoc 'createdAt'
      var currentCreatedAt =
          (currentPaymentDoc['createdAt'] as Timestamp).toDate();
      var startOfDay = DateTime(currentCreatedAt.year, currentCreatedAt.month,
          currentCreatedAt.day, 0, 0, 0);
      var endOfDay = DateTime(currentCreatedAt.year, currentCreatedAt.month,
          currentCreatedAt.day, 23, 59, 59);
      // Lấy tất cả PaymentHistory của các User khác trong cùng ngày
      QuerySnapshot<Map<String, dynamic>> allPaymentsSnapshot =
          await FirebaseFirestore.instance
              .collectionGroup('PaymentHistory')
              .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
              .where('createdAt', isLessThanOrEqualTo: endOfDay)
              .get();
      // Kiểm tra từng PaymentHistory có trùng bikeId và khoảng thời gian không
      for (var paymentDoc in allPaymentsSnapshot.docs) {
        var paymentData = paymentDoc.data();
        List<dynamic> bikes = paymentData['bikes'] ?? [];
        for (var bike in bikes) {
          // Kiểm tra nếu bikeId trùng khớp
          if (currentBikeIds.contains(bike['bikeId']) &&
              bike['bikeStatus'] == 'Có sẵn') {
            DateTime paymentStartDate =
                DateTime.parse(paymentData['dateSearch']['startDate']);
            DateTime paymentEndDate =
                DateTime.parse(paymentData['dateSearch']['endDate']);
            TimeOfDay paymentStartTime = TimeOfDay(
              hour: int.parse(
                  paymentData['timeSearch']['startTime'].split(':')[0]),
              minute: int.parse(
                  paymentData['timeSearch']['startTime'].split(':')[1]),
            );
            TimeOfDay paymentEndTime = TimeOfDay(
              hour:
                  int.parse(paymentData['timeSearch']['endTime'].split(':')[0]),
              minute:
                  int.parse(paymentData['timeSearch']['endTime'].split(':')[1]),
            );
            // Kiểm tra sự trùng lặp về ngày

            bool dateOverlap =
                !(paymentEndDate.isBefore(currentStartDateSearch) ||
                    paymentStartDate.isAfter(currentEndDateSearch));
            // Kiểm tra sự trùng lặp về thời gian trong ngày trùng lặp
            bool timeOverlap = true;
            if (dateOverlap) {
              // Trường hợp ngày bắt đầu của user trùng với ngày kết thúc của hợp đồng
              if (currentStartDateSearch.isAtSameMomentAs(paymentEndDate)) {
                var finalTimeHour =
                    currentStartTimeSearch.hour - paymentEndTime.hour;
                if (finalTimeHour >= 1 &&
                    currentStartTimeSearch.hour > paymentEndTime.hour) {
                  timeOverlap = false;
                }
              }
              // Trường hợp ngày kết thúc của user trùng với ngày bắt đầu của hợp đồng
              else if (currentEndDateSearch
                  .isAtSameMomentAs(paymentStartDate)) {
                var finalEndTimeHour =
                    currentEndTimeSearch.hour - paymentStartTime.hour;
                if (finalEndTimeHour <= -1) {
                  timeOverlap = false;
                }
              } else if (currentStartDateSearch
                      .isAtSameMomentAs(paymentStartDate) &&
                  currentEndDateSearch.isAtSameMomentAs(paymentEndDate)) {
                if ((currentStartTimeSearch.hour == paymentStartTime.hour &&
                        currentStartTimeSearch.minute ==
                            paymentStartTime.minute) &&
                    (currentEndTimeSearch.hour == paymentEndTime.hour &&
                        currentEndTimeSearch.minute == paymentEndTime.minute)) {
                  timeOverlap = false;
                }
              } else {
                timeOverlap = false;
              }
            }
            print(
                "updateBikeStatusAfterPayment dateOverlap && timeOverlap: $dateOverlap $timeOverlap ");
            if (dateOverlap && timeOverlap) {
              bike['bikeStatus'] = 'Đã đặt';
            }
          }
        }
        // Cập nhật lại PaymentHistory với bikeStatus mới
        await paymentDoc.reference.update({
          'bikes': bikes,
        });
      }
      print(
          'Đã cập nhật trạng thái bike thành "Đã đặt" cho các xe trùng khớp.');
    } catch (e) {
      print('Lỗi khi cập nhật trạng thái xe: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getBookedBikes(
      String userId, String sessionId) async {
    List<Map<String, dynamic>> bookedBikes = [];

    try {
      // Bước 1: Lấy PaymentHistory hiện tại dựa trên userId và sessionId
      QuerySnapshot<Map<String, dynamic>> currentPaymentSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('PaymentHistory')
              .where('sessionId', isEqualTo: sessionId)
              .limit(1)
              .get();

      if (currentPaymentSnapshot.docs.isEmpty) {
        print('Không tìm thấy PaymentHistory cho khách hàng này.');
        return bookedBikes; // Trả về danh sách trống
      }

      // Lấy document hiện tại
      var currentPaymentDoc = currentPaymentSnapshot.docs.first.data();
      List<dynamic> currentBikes = currentPaymentDoc['bikes'] ?? [];
      List<String> currentBikeIds =
          currentBikes.map((bike) => bike['bikeId'].toString()).toList();

      if (currentBikeIds.isEmpty) {
        print('Không có bikeId trong PaymentHistory hiện tại.');
        return bookedBikes; // Trả về danh sách trống
      }

      var currentStartDateSearch =
          DateTime.parse(currentPaymentDoc['dateSearch']['startDate']);
      var currentEndDateSearch =
          DateTime.parse(currentPaymentDoc['dateSearch']['endDate']);

      var currentStartTimeSearch = TimeOfDay(
        hour: int.parse(
            currentPaymentDoc['timeSearch']['startTime'].split(':')[0]),
        minute: int.parse(
            currentPaymentDoc['timeSearch']['startTime'].split(':')[1]),
      );
      var currentEndTimeSearch = TimeOfDay(
        hour:
            int.parse(currentPaymentDoc['timeSearch']['endTime'].split(':')[0]),
        minute:
            int.parse(currentPaymentDoc['timeSearch']['endTime'].split(':')[1]),
      );

      var currentCreatedAt =
          (currentPaymentDoc['createdAt'] as Timestamp).toDate();
      var startOfDay = DateTime(currentCreatedAt.year, currentCreatedAt.month,
          currentCreatedAt.day, 0, 0, 0);
      var endOfDay = DateTime(currentCreatedAt.year, currentCreatedAt.month,
          currentCreatedAt.day, 23, 59, 59);
      // Bước 2: Lấy tất cả PaymentHistory của các user khác
      QuerySnapshot<Map<String, dynamic>> allPaymentsSnapshot =
          await FirebaseFirestore.instance
              .collectionGroup('PaymentHistory')
              .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
              .where('createdAt', isLessThanOrEqualTo: endOfDay)
              .get();

      // Bước 3: Duyệt qua từng PaymentHistory và kiểm tra
      for (var paymentDoc in allPaymentsSnapshot.docs) {
        Map<String, dynamic> paymentData = paymentDoc.data();
        List<dynamic> bikes = paymentData['bikes'] ?? [];

        // Kiểm tra từng bike trong PaymentHistory
        for (var bike in bikes) {
          // Kiểm tra nếu bikeId trùng khớp
          if (currentBikeIds.contains(bike['bikeId']) &&
              bike['bikeStatus'] == 'Đã đặt') {
            DateTime paymentStartDate =
                DateTime.parse(paymentData['dateSearch']['startDate']);
            DateTime paymentEndDate =
                DateTime.parse(paymentData['dateSearch']['endDate']);

            TimeOfDay paymentStartTime = TimeOfDay(
              hour: int.parse(
                  paymentData['timeSearch']['startTime'].split(':')[0]),
              minute: int.parse(
                  paymentData['timeSearch']['startTime'].split(':')[1]),
            );
            TimeOfDay paymentEndTime = TimeOfDay(
              hour:
                  int.parse(paymentData['timeSearch']['endTime'].split(':')[0]),
              minute:
                  int.parse(paymentData['timeSearch']['endTime'].split(':')[1]),
            );

            // Kiểm tra sự trùng lặp về ngày
            bool dateOverlap =
                !(paymentEndDate.isBefore(currentStartDateSearch) ||
                    paymentStartDate.isAfter(currentEndDateSearch));

            // Kiểm tra sự trùng lặp về thời gian trong ngày trùng lặp
            bool timeOverlap = true;

            if (dateOverlap) {
              // Trường hợp ngày bắt đầu của người dùng trùng với ngày kết thúc của hợp đồng
              if (currentStartDateSearch.isAtSameMomentAs(paymentEndDate)) {
                var finalTimeHour =
                    currentStartTimeSearch.hour - paymentEndTime.hour;
                if (finalTimeHour >= 1 &&
                    currentStartTimeSearch.hour >= paymentEndTime.hour) {
                  timeOverlap = false;
                }
              }
              // Trường hợp ngày kết thúc của người dùng trùng với ngày bắt đầu của hợp đồng
              else if (currentEndDateSearch
                  .isAtSameMomentAs(paymentStartDate)) {
                var finalEndTimeHour =
                    currentEndTimeSearch.hour - paymentStartTime.hour;
                if (finalEndTimeHour <= 1 &&
                    currentEndTimeSearch.hour <= paymentStartTime.hour) {
                  timeOverlap = false;
                }
              } else if (currentStartDateSearch
                      .isAtSameMomentAs(paymentStartDate) &&
                  currentEndDateSearch.isAtSameMomentAs(paymentEndDate)) {
                if ((currentStartTimeSearch.hour == paymentStartTime.hour &&
                        currentStartTimeSearch.minute ==
                            paymentStartTime.minute) &&
                    (currentEndTimeSearch.hour == paymentEndTime.hour &&
                        currentEndTimeSearch.minute == paymentEndTime.minute)) {
                  timeOverlap = true;
                }
              } else {
                timeOverlap = true;
              }
            }
            print(
                'getBookdedBikes: dateOverlap, timeOverlap: $dateOverlap, $timeOverlap');
            // Nếu cả dateOverlap và timeOverlap đều trùng thì thêm vào danh sách bookedBikes
            if (dateOverlap && timeOverlap) {
              bool bikeExists =
                  bookedBikes.any((b) => b['bikeId'] == bike['bikeId']);
              if (!bikeExists) {
                bookedBikes.add(bike); // Thêm bike nếu chưa tồn tại
              }
            }
          }
        }
      }
    } catch (e) {
      print('Lỗi khi lấy thông tin xe đã đặt: $e');
    }
    return bookedBikes; // Trả về danh sách các xe đã đặt và trùng ngày giờ
  }

  Future<bool> checkIfAnyBikeIsBookedTransaction(
      String userId, String sessionId) async {
    try {
      return await FirebaseFirestore.instance
          .runTransaction((transaction) async {
        // Bước 1: Lấy PaymentHistory hiện tại dựa trên userId và sessionId
        QuerySnapshot<Map<String, dynamic>> currentPaymentSnapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection('PaymentHistory')
                .where('sessionId', isEqualTo: sessionId)
                .limit(1)
                .get(); // Thực hiện get() trước để lấy snapshot đầu tiên

        if (currentPaymentSnapshot.docs.isEmpty) {
          print('Không tìm thấy PaymentHistory cho khách hàng này.');
          return false;
        }

        // Lấy tài liệu đầu tiên từ snapshot
        var paymentDocRef = currentPaymentSnapshot.docs.first.reference;

        // Sau đó sử dụng transaction.get() với DocumentReference của tài liệu
        DocumentSnapshot<Map<String, dynamic>> currentPaymentDocSnapshot =
            await transaction.get(paymentDocRef);

        var currentPaymentDoc = currentPaymentDocSnapshot.data()!;
        List<dynamic> currentBikes = currentPaymentDoc['bikes'] ?? [];
        List<String> currentBikeIds =
            currentBikes.map((bike) => bike['bikeId'].toString()).toList();

        if (currentBikeIds.isEmpty) {
          print('Không có bikeId trong PaymentHistory hiện tại.');
          return false;
        }

        // Lấy ngày hiện tại từ currentPaymentDoc 'createdAt'
        var currentCreatedAt =
            (currentPaymentDoc['createdAt'] as Timestamp).toDate();
        var startOfDay = DateTime(currentCreatedAt.year, currentCreatedAt.month,
            currentCreatedAt.day, 0, 0, 0);
        var endOfDay = DateTime(currentCreatedAt.year, currentCreatedAt.month,
            currentCreatedAt.day, 23, 59, 59);

        // Bước 2: Lấy tất cả PaymentHistory của các user khác trong giao dịch
        QuerySnapshot<Map<String, dynamic>> allPaymentsSnapshot =
            await FirebaseFirestore.instance
                .collectionGroup('PaymentHistory')
                .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
                .where('createdAt', isLessThanOrEqualTo: endOfDay)
                .get();

        // Bước 3: Duyệt qua từng PaymentHistory và kiểm tra
        for (var paymentDoc in allPaymentsSnapshot.docs) {
          var paymentData = paymentDoc.data();
          List<dynamic> bikes = paymentData['bikes'] ?? [];

          for (var bike in bikes) {
            // Kiểm tra nếu bikeId trùng khớp
            if (currentBikeIds.contains(bike['bikeId']) &&
                bike['bikeStatus'] == 'Đã đặt') {
              DateTime currentStartDateSearch =
                  DateTime.parse(currentPaymentDoc['dateSearch']['startDate']);
              DateTime currentEndDateSearch =
                  DateTime.parse(currentPaymentDoc['dateSearch']['endDate']);

              TimeOfDay currentStartTimeSearch = TimeOfDay(
                hour: int.parse(
                    currentPaymentDoc['timeSearch']['startTime'].split(':')[0]),
                minute: int.parse(
                    currentPaymentDoc['timeSearch']['startTime'].split(':')[1]),
              );
              TimeOfDay currentEndTimeSearch = TimeOfDay(
                hour: int.parse(
                    currentPaymentDoc['timeSearch']['endTime'].split(':')[0]),
                minute: int.parse(
                    currentPaymentDoc['timeSearch']['endTime'].split(':')[1]),
              );

              DateTime paymentStartDate =
                  DateTime.parse(paymentData['dateSearch']['startDate']);
              DateTime paymentEndDate =
                  DateTime.parse(paymentData['dateSearch']['endDate']);

              TimeOfDay paymentStartTime = TimeOfDay(
                hour: int.parse(
                    paymentData['timeSearch']['startTime'].split(':')[0]),
                minute: int.parse(
                    paymentData['timeSearch']['startTime'].split(':')[1]),
              );
              TimeOfDay paymentEndTime = TimeOfDay(
                hour: int.parse(
                    paymentData['timeSearch']['endTime'].split(':')[0]),
                minute: int.parse(
                    paymentData['timeSearch']['endTime'].split(':')[1]),
              );

              // Kiểm tra sự trùng lặp về ngày
              bool dateOverlap =
                  !(paymentEndDate.isBefore(currentStartDateSearch) ||
                      paymentStartDate.isAfter(currentEndDateSearch));

              bool timeOverlap = true;

              if (dateOverlap) {
                if (currentStartDateSearch.isAtSameMomentAs(paymentEndDate)) {
                  var finalTimeHour =
                      currentStartTimeSearch.hour - paymentEndTime.hour;
                  if (finalTimeHour >= 1 &&
                      currentStartTimeSearch.hour >= paymentEndTime.hour) {
                    timeOverlap = false;
                  }
                } else if (currentEndDateSearch
                    .isAtSameMomentAs(paymentStartDate)) {
                  var finalEndTimeHour =
                      currentEndTimeSearch.hour - paymentStartTime.hour;
                  if (finalEndTimeHour <= -1 &&
                      currentStartTimeSearch.hour <= paymentEndTime.hour) {
                    timeOverlap = false;
                  }
                } else if (currentStartDateSearch
                        .isAtSameMomentAs(paymentStartDate) &&
                    currentEndDateSearch.isAtSameMomentAs(paymentEndDate)) {
                  if (((currentStartTimeSearch.hour == paymentStartTime.hour) &&
                          currentStartTimeSearch.minute ==
                              paymentStartTime.minute) &&
                      (currentEndTimeSearch.hour == paymentEndTime.hour &&
                          currentEndTimeSearch.minute ==
                              paymentEndTime.minute)) {
                    timeOverlap = true;
                  }
                } else {
                  timeOverlap = true;
                }
              }

              print(
                  'checkIfAnyBikeIsBooked: dateOverlap, timeOverlap: $dateOverlap, $timeOverlap');
              if (dateOverlap && timeOverlap) {
                return true;
              }
            }
          }
        }

        return false;
      });
    } catch (e) {
      print('Lỗi khi kiểm tra xe đã đặt: $e');
      return false;
    }
  }

  Future<void> createMarketHistoryForAvailableBikes(
      String userId, String sessionId) async {
    try {
      // Lấy danh sách availableBikes dựa trên userId và sessionId
      List<Map<String, dynamic>> availableBikes =
          await getAvailableBikesInMartket(userId, sessionId);

      if (availableBikes.isEmpty) {
        print('Không có xe có sẵn để tạo PaymentHistory');
        return;
      }

      // Lấy dữ liệu từ HistorySearch dựa trên userId và sessionId
      QuerySnapshot<Map<String, dynamic>> historySearchSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('MarketHistory')
              .where('sessionId', isEqualTo: sessionId)
              .limit(1)
              .get();

      if (historySearchSnapshot.docs.isEmpty) {
        print('Không tìm thấy tài liệu HistorySearch cho sessionId này.');
        return;
      }
      // Lấy tài liệu đầu tiên từ HistorySearch
      var historySearchDoc = historySearchSnapshot.docs.first.data();
      // Kiểm tra xem dateSearch và timeSearch có tồn tại không và cung cấp giá trị mặc định nếu không
      var dateSearch = historySearchDoc['dateSearch'] ?? 'defaultDate';
      var timeSearch = historySearchDoc['timeSearch'] ?? 'defaultTime';
      // Tạo danh sách bikeIds từ availableBikes
      List<String> bikeIds = [];
      for (var bike in availableBikes) {
        if (bike.containsKey('bikeId')) {
          bikeIds.add(bike['bikeId']);
        }
      }
      // Kiểm tra nếu bikeIds rỗng
      if (bikeIds.isEmpty) {
        print('Không có bikeId trong availableBikes.');
        return;
      }
      // Tạo mới document trong collection PaymentHistory
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('PaymentHistory')
          .add({
        'sessionId': sessionId,
        'dateSearch': dateSearch,
        'timeSearch': timeSearch,
        'createdAt': FieldValue.serverTimestamp(),
        'bikes': availableBikes,
      });

      print('Đã tạo PaymentHistory thành công với dateSearch và timeSearch.');
    } catch (e) {
      print('Lỗi khi tạo PaymentHistory: $e');
    }
  }

  Future<void> addBikeToMarketHistory(
      String userId, String sessionId, Map<String, dynamic> bike) async {
    try {
      // Tham chiếu tới tài liệu MarketHistory của userId
      DocumentReference marketHistoryRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('MarketHistory')
          .doc(sessionId); // Mỗi session có một giỏ hàng duy nhất

      // Lấy tài liệu MarketHistory
      DocumentSnapshot marketHistorySnapshot = await marketHistoryRef.get();

      if (marketHistorySnapshot.exists) {
        // Nếu tài liệu tồn tại, thêm xe vào mảng bikes
        await marketHistoryRef.update({
          'bikes': FieldValue.arrayUnion([bike]), // Thêm xe vào mảng bikes
        });
      } else {
        // Nếu tài liệu không tồn tại, tạo mới tài liệu với xe đầu tiên
        await marketHistoryRef.set({
          'sessionId': sessionId,
          'createdAt': FieldValue.serverTimestamp(),
          'bikes': [bike], // Tạo mảng bikes với xe đầu tiên
        });
      }

      print('Đã thêm xe vào giỏ hàng thành công.');
    } catch (e) {
      print('Lỗi khi thêm xe vào giỏ hàng: $e');
    }
  }

  Future<void> addDateTimeToMarketHistory(
      String userId, String sessionId) async {
    try {
      // Tham chiếu tới tài liệu HistorySearch của userId
      DocumentReference historySearchRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('HistorySearch')
          .doc();

      // Lấy tài liệu HistorySearch
      DocumentSnapshot historySnapshot = await historySearchRef.get();

      if (historySnapshot.exists) {
        // Nếu tài liệu tồn tại, lấy dateSearch và timeSearch
        Map<String, dynamic>? historyData =
            historySnapshot.data() as Map<String, dynamic>?;
        Map? dateSearch = historyData?['dateSearch'];
        Map? timeSearch = historyData?['timeSearch'];

        // Tham chiếu tới tài liệu MarketHistory của userId
        DocumentReference marketHistoryRef = FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('MarketHistory')
            .doc(sessionId); // Sử dụng cùng sessionId cho MarketHistory

        // Cập nhật MarketHistory với dateSearch và timeSearch
        await marketHistoryRef.set(
            {
              'dateSearch': dateSearch, // Lưu dateSearch
              'timeSearch': timeSearch, // Lưu timeSearch
              'createdAt': FieldValue.serverTimestamp(), // Thêm thời gian tạo
            },
            SetOptions(
                merge: true)); // Sử dụng merge để không ghi đè dữ liệu hiện có

        print('Đã thêm dateSearch và timeSearch vào MarketHistory thành công.');
      } else {
        print(
            'Không tìm thấy tài liệu HistorySearch với sessionId: $sessionId.');
      }
    } catch (e) {
      print('Lỗi khi thêm dateSearch và timeSearch vào MarketHistory: $e');
    }
  }

  Future<void> addBikeAndDateTimeToMarketHistory(
      String userId, String sessionId, Map<String, dynamic> bike) async {
    try {
      // Tham chiếu tới tài liệu HistorySearch của userId
      CollectionReference historySearchRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('HistorySearch');

      // Lấy tài liệu HistorySearch mới nhất dựa trên createdAt
      QuerySnapshot historySearchSnapshot = await historySearchRef
          .orderBy('createdAt', descending: true)
          .where('sessionId', isEqualTo: sessionId)
          .limit(1)
          .get();

      if (historySearchSnapshot.docs.isNotEmpty) {
        // Lấy tài liệu đầu tiên từ kết quả truy vấn
        DocumentSnapshot historyDoc = historySearchSnapshot.docs.first;

        // Lấy dateSearch và timeSearch từ HistorySearch
        Map<String, dynamic>? historyData =
            historyDoc.data() as Map<String, dynamic>?;
        Map? dateSearch = historyData?['dateSearch'];
        Map? timeSearch = historyData?['timeSearch'];

        if (dateSearch != null && timeSearch != null) {
          // Tham chiếu tới tài liệu MarketHistory của userId
          DocumentReference marketHistoryRef = FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('MarketHistory')
              .doc(sessionId); // Mỗi session có một giỏ hàng duy nhất

          // Lấy tài liệu MarketHistory
          DocumentSnapshot marketHistorySnapshot = await marketHistoryRef.get();

          if (marketHistorySnapshot.exists) {
            // Nếu tài liệu tồn tại, thêm xe vào mảng bikes và cập nhật dateSearch, timeSearch
            await marketHistoryRef.update({
              'bikes': FieldValue.arrayUnion([bike]), // Thêm xe vào mảng bikes
              'dateSearch': dateSearch, // Thêm hoặc cập nhật dateSearch
              'timeSearch': timeSearch, // Thêm hoặc cập nhật timeSearch
            });
          } else {
            // Nếu tài liệu không tồn tại, tạo mới tài liệu với xe đầu tiên và thêm dateSearch, timeSearch
            await marketHistoryRef.set({
              'sessionId': sessionId,
              'createdAt': FieldValue.serverTimestamp(),
              'bikes': [bike], // Tạo mảng bikes với xe đầu tiên
              'dateSearch': dateSearch, // Lưu dateSearch
              'timeSearch': timeSearch, // Lưu timeSearch
            });
          }

          print(
              'Đã thêm xe vào giỏ hàng thành công cùng với dateSearch và timeSearch.');
        } else {
          print(
              'Không tìm thấy dateSearch hoặc timeSearch trong HistorySearch.');
        }
      } else {
        print('Không tìm thấy tài liệu HistorySearch.');
      }
    } catch (e) {
      print('Lỗi khi thêm xe vào giỏ hàng: $e');
    }
  }

  Future<void> addBikeAndDateTimeToMarketHistory2(
      String userId, String sessionId) async {
    try {
      // Tham chiếu tới tài liệu HistorySearch của userId
      CollectionReference historySearchRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('HistorySearch');

      // Lấy tài liệu HistorySearch mới nhất dựa trên createdAt
      QuerySnapshot historySearchSnapshot = await historySearchRef
          .orderBy('createdAt', descending: true)
          .where('sessionId', isEqualTo: sessionId)
          .limit(1)
          .get();

      if (historySearchSnapshot.docs.isNotEmpty) {
        // Lấy tài liệu đầu tiên từ kết quả truy vấn
        DocumentSnapshot historyDoc = historySearchSnapshot.docs.first;

        // Lấy dateSearch và timeSearch từ HistorySearch
        Map<String, dynamic>? historyData =
            historyDoc.data() as Map<String, dynamic>?;
        Map? dateSearch = historyData?['dateSearch'];
        Map? timeSearch = historyData?['timeSearch'];

        if (dateSearch != null && timeSearch != null) {
          // Tham chiếu tới tài liệu MarketHistory của userId
          DocumentReference marketHistoryRef = FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('MarketHistory')
              .doc(sessionId); // Mỗi session có một giỏ hàng duy nhất

          // Lấy tài liệu MarketHistory
          DocumentSnapshot marketHistorySnapshot = await marketHistoryRef.get();

          if (marketHistorySnapshot.exists) {
            // Nếu tài liệu tồn tại, thêm xe vào mảng bikes và cập nhật dateSearch, timeSearch
            await marketHistoryRef.update({
              'dateSearch': dateSearch, // Thêm hoặc cập nhật dateSearch
              'timeSearch': timeSearch, // Thêm hoặc cập nhật timeSearch
            });
          }

          print(
              'Đã thêm xe vào giỏ hàng thành công cùng với dateSearch và timeSearch.');
        } else {
          print(
              'Không tìm thấy dateSearch hoặc timeSearch trong HistorySearch.');
        }
      } else {
        print('Không tìm thấy tài liệu HistorySearch.');
      }
    } catch (e) {
      print('Lỗi khi thêm xe vào giỏ hàng: $e');
    }
  }

  Future<bool> checkBikeExistsInMarketHistory(
      String userId, String bikeId) async {
    try {
      // Lấy danh sách MarketHistory
      QuerySnapshot<Map<String, dynamic>> marketHistorySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('MarketHistory')
              .get();

      // Kiểm tra từng tài liệu trong MarketHistory
      for (var doc in marketHistorySnapshot.docs) {
        var data = doc.data();
        List<dynamic> bikesInMarketHistory = data['bikes'] ?? [];

        // Kiểm tra nếu bikeId đã tồn tại
        if (bikesInMarketHistory.any((b) => b['bikeId'] == bikeId)) {
          return true; // Xe đã tồn tại
        }
      }
    } catch (e) {
      print('Lỗi khi kiểm tra bikeId: $e');
    }
    return false; // Xe chưa tồn tại
  }

  Future<void> clearMarketHistory(String userId) async {
    try {
      // 1. Lấy reference của MarketHistory collection
      CollectionReference marketHistoryRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('MarketHistory');

      // 2. Truy vấn để lấy tất cả các tài liệu trong MarketHistory
      QuerySnapshot marketHistorySnapshot = await marketHistoryRef.get();

      // 3. Xoá từng tài liệu trong MarketHistory
      for (QueryDocumentSnapshot doc in marketHistorySnapshot.docs) {
        await doc.reference.delete();
      }
      print('Đã xoá tất cả dữ liệu trong MarketHistory.');
    } catch (e) {
      print('Lỗi khi xoá và thêm dữ liệu vào MarketHistory: $e');
    }
  }

  Future<void> clearPaymentHistoryOne(String userId) async {
    try {
      // 1. Lấy reference của MarketHistory collection
      CollectionReference marketHistoryRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('PaymentHistoryOne');

      // 2. Truy vấn để lấy tất cả các tài liệu trong MarketHistory
      QuerySnapshot marketHistorySnapshot = await marketHistoryRef.get();

      // 3. Xoá từng tài liệu trong MarketHistory
      for (QueryDocumentSnapshot doc in marketHistorySnapshot.docs) {
        await doc.reference.delete();
      }
      print('Đã xoá tất cả dữ liệu trong MarketHistory.');
    } catch (e) {
      print('Lỗi khi xoá và thêm dữ liệu vào MarketHistory: $e');
    }
  }

  Future<void> createPaymentHistoryForAvailableBikes(
      String userId, String sessionId) async {
    try {
      // Lấy danh sách availableBikes dựa trên userId và sessionId
      List<Map<String, dynamic>> availableBikes =
          await getAvailableBikes(userId, sessionId);

      if (availableBikes.isEmpty) {
        print('Không có xe có sẵn để tạo PaymentHistory');
        return;
      }

      // Lấy dữ liệu từ HistorySearch dựa trên userId và sessionId
      QuerySnapshot<Map<String, dynamic>> historySearchSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('HistorySearch')
              .where('sessionId', isEqualTo: sessionId)
              .limit(1)
              .get();

      if (historySearchSnapshot.docs.isEmpty) {
        print('Không tìm thấy tài liệu HistorySearch cho sessionId này.');
        return;
      }
      // Lấy tài liệu đầu tiên từ HistorySearch
      var historySearchDoc = historySearchSnapshot.docs.first.data();
      var dateSearch = historySearchDoc['dateSearch'] ?? 'defaultDate';
      var timeSearch = historySearchDoc['timeSearch'] ?? 'defaultTime';
      // Tạo danh sách bikeIds từ availableBikes
      List<String> bikeIds = [];
      for (var bike in availableBikes) {
        if (bike.containsKey('bikeId')) {
          bikeIds.add(bike['bikeId']);
        }
      }
      // Kiểm tra nếu bikeIds rỗng
      if (bikeIds.isEmpty) {
        print('Không có bikeId trong availableBikes.');
        return;
      }
      // Tạo mới document trong collection PaymentHistory
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('PaymentHistory')
          .add({
        'sessionId': sessionId,
        'dateSearch': dateSearch,
        'timeSearch': timeSearch,
        'createdAt': FieldValue.serverTimestamp(),
        'bikes': availableBikes,
      });

      print('Đã tạo PaymentHistory thành công với dateSearch và timeSearch.');
    } catch (e) {
      print('Lỗi khi tạo PaymentHistory: $e');
    }
  }

  Future<String?> getLatestSessionId(String userId) async {
    // Lấy tài liệu tìm kiếm mới nhất dựa vào thời gian
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('HistorySearch')
            .orderBy('createdAt', descending: true)
            .limit(1) // Giới hạn chỉ lấy 1 tài liệu mới nhất
            .get();

    if (snapshot.docs.isNotEmpty) {
      // Lấy sessionId từ tài liệu mới nhất
      var document = snapshot.docs.first;
      return document.data()['sessionId'] as String?;
    }

    return null; // Trường hợp không có tài liệu nào
  }

  Stream<List<Map<String, dynamic>>> getHistorySearchWithSessionId(
      String userId, String sessionId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('HistorySearch')
        .where('sessionId', isEqualTo: sessionId) // Truy vấn theo sessionId
        .orderBy('createdAt', descending: true) // Sắp xếp theo thời gian tạo
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        var document = snapshot.docs.first;
        List<Map<String, dynamic>> bikes =
            List<Map<String, dynamic>>.from(document.data()['bikes'] ?? []);
        return bikes;
      }
      return [];
    });
  }

  Stream<List<Map<String, dynamic>>> getPaymentHistoryWithSessionId(
      String userId, String sessionId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('PaymentHistory')
        .where('sessionId', isEqualTo: sessionId) // Truy vấn theo sessionId
        .orderBy('createdAt', descending: true) // Sắp xếp theo thời gian tạo
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        var document = snapshot.docs.first;
        List<Map<String, dynamic>> bikes =
            List<Map<String, dynamic>>.from(document.data()['bikes'] ?? []);
        return bikes;
      }
      return [];
    });
  }

  Stream<List<Map<String, dynamic>>> getMarketHistoryWithSessionId(
      String userId, String sessionId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('MarketHistory')
        .where('sessionId', isEqualTo: sessionId) // Truy vấn theo sessionId
        .orderBy('createdAt', descending: true) // Sắp xếp theo thời gian tạo
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        var document = snapshot.docs.first;
        List<Map<String, dynamic>> bikes =
            List<Map<String, dynamic>>.from(document.data()['bikes'] ?? []);
        return bikes;
      }
      return [];
    });
  }

  Future<List<Map<String, dynamic>>> getAvailableBikes(
      String userId, String sessionId) async {
    try {
      // Tham chiếu đến collection HistorySearch của user với sessionId cụ thể
      QuerySnapshot<Map<String, dynamic>> historySearchSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('HistorySearch')
              .where('sessionId', isEqualTo: sessionId)
              .limit(1)
              .get();

      // Nếu tìm thấy tài liệu
      if (historySearchSnapshot.docs.isNotEmpty) {
        var document = historySearchSnapshot.docs.first;
        List<Map<String, dynamic>> bikes =
            List<Map<String, dynamic>>.from(document.data()['bikes'] ?? []);
        return bikes; // Trả về danh sách availableBikes
      } else {
        print('Không tìm thấy dữ liệu cho sessionId: $sessionId');
        return [];
      }
    } catch (e) {
      print('Lỗi khi lấy availableBikes: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAvailableBikesInMartket(
      String userId, String sessionId) async {
    try {
      // Tham chiếu đến collection HistorySearch của user với sessionId cụ thể
      QuerySnapshot<Map<String, dynamic>> historySearchSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('MarketHistory')
              .where('sessionId', isEqualTo: sessionId)
              .limit(1)
              .get();

      // Nếu tìm thấy tài liệu
      if (historySearchSnapshot.docs.isNotEmpty) {
        var document = historySearchSnapshot.docs.first;
        List<Map<String, dynamic>> bikes =
            List<Map<String, dynamic>>.from(document.data()['bikes'] ?? []);
        return bikes; // Trả về danh sách availableBikes
      } else {
        print('Không tìm thấy dữ liệu cho sessionId: $sessionId');
        return [];
      }
    } catch (e) {
      print('Lỗi khi lấy availableBikes: $e');
      return [];
    }
  }

  Future<void> removeBikeFromHistorySearch(
      String userId, String sessionId, String bikeId) async {
    // Truy vấn lấy tài liệu HistorySearch dựa trên userId và sessionId
    QuerySnapshot<Map<String, dynamic>> historySearchSnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('MarketHistory')
            .where('sessionId', isEqualTo: sessionId)
            .orderBy('createdAt', descending: true)
            .get();

    // Nếu có ít nhất một tài liệu được trả về
    if (historySearchSnapshot.docs.isNotEmpty) {
      // Lấy tài liệu đầu tiên
      var document = historySearchSnapshot.docs.first;
      var documentId = document.id; // Lấy id của tài liệu

      // Lấy danh sách bikes từ tài liệu
      List<Map<String, dynamic>> bikes =
          List<Map<String, dynamic>>.from(document.data()['bikes'] ?? []);

      // Tìm và xoá bike dựa trên bikeId
      bikes.removeWhere((bike) => bike['bikeId'] == bikeId);

      // Cập nhật lại tài liệu với danh sách bikes đã xoá
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('MarketHistory')
          .doc(documentId)
          .update({'bikes': bikes});

      print("Bike with bikeId $bikeId has been removed from history search.");
    } else {
      print("No HistorySearch document found for sessionId $sessionId.");
    }
  }
}
