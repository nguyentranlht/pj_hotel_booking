import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:room_repository/room_repository.dart';
import 'package:room_repository/src/entities/entities.dart';
import 'dart:developer';
import 'dart:typed_data';

import 'package:uuid/uuid.dart';
import 'package:uuid/v4.dart';

class FirebaseRoomRepo implements RoomRepo {
  final roomCollection = FirebaseFirestore.instance.collection('rooms');

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Future<List<Room>> getRooms() async {
    try {
      return await roomCollection.get().then((value) => value.docs
          .map((e) => Room.fromEntity(RoomEntity.fromDocument(e.data())))
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
  Future<void> createRooms(Room room) async {
    try {
      return await roomCollection
          .doc(room.roomId)
          .set(room.toEntity().toDocument());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<Room>> getRoomsByHotelId(String hotelId) async {
    try {
      return await roomCollection
          .where('hotelId', isEqualTo: hotelId)
          .get()
          .then((result) => result.docs
              .map(
                  (doc) => Room.fromEntity(RoomEntity.fromDocument(doc.data())))
              .toList());
    } catch (e) {
      print(e.toString());
      throw Exception('Failed to load rooms');
    }
  }

  Future<String?> getRoomId(String userId) async {
    // Giả sử rằng bạn có thông tin về phòng được thanh toán trong user document
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      return userDoc.get('roomId');
    } else {
      throw Exception('User not found.');
    }
  }

  Future<void> updateIsSelected(String userId, String sessionId) async {
    try {
      // Query the collection for the specific sessionId
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('PaymentProcessing')
          .where('sessionId', isEqualTo: sessionId)
          .limit(1)
          .get();

      // Iterate through the documents and update the isSelected field
      for (var doc in querySnapshot.docs) {
        await doc.reference.update({'isSelected': true});
      }
    } catch (error) {
      print('Failed to update room status: $error');
      throw Exception('Failed to update room status: $error');
    }
  }

  Future<void> updateRoomData(String roomId, Map<String, dynamic> data) async {
    try {
      await roomCollection.doc(roomId).update(data);
    } catch (e) {
      print('Error updating room data: $e');
      rethrow;
    }
  }

  Future<void> clearUserPayments(String userId) async {
    try {
      QuerySnapshot paymentCollectionSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('PaymentRoom')
          .where('isSelected', isEqualTo: false)
          .get();

      for (QueryDocumentSnapshot doc in paymentCollectionSnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error clearing user payments: $e');
      rethrow;
    }
  }

  Future<void> addDateToRoom(
      Map<String, dynamic> dateTime, String roomId) async {
    try {
      if (roomId.isEmpty) {
        throw Exception("RoomId không hợp lệ.");
      }

      CollectionReference roomsCollectionRef =
          _firestore.collection('rooms').doc(roomId).collection('dateTime');

      DocumentReference newRoomRef = roomsCollectionRef.doc();
      String paymentId = newRoomRef.id; // Lấy ID tự sinh

      // Thêm document với dữ liệu thanh toán và ID tự sinh
      await newRoomRef.set({
        ...dateTime,
        'dateTimeId': paymentId, // Lưu trữ paymentId trong document (nếu cần)
        'dateTime': Uuid().v4(),
      });
    } catch (e) {
      print('Error adding dateTime room: $e');
    }
  }

  Future<void> addDateToContractRooms(
      Map<String, dynamic> contractRooms) async {
    try {
      CollectionReference roomsCollectionRef =
          _firestore.collection('contractRooms');

      DocumentReference newRoomRef = roomsCollectionRef.doc();
      String paymentId = newRoomRef.id;

      // Add document with contract data and generated ID
      await newRoomRef.set({
        ...contractRooms,
        'dateTimeId': paymentId,
        'ContractRoomId': Uuid().v4(),
      });
    } catch (e) {
      print('Error adding contract room: $e');
      rethrow;
    }
  }

  Future<bool> checkIfAnyRoomIsBookedTransaction(
      String userId, String sessionId) async {
    try {
      // Lấy tài liệu PaymentProcessing của người dùng hiện tại với sessionId tương ứng trước khi vào transaction
      QuerySnapshot<Map<String, dynamic>> currentPaymentSnapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('PaymentProcessing')
              .where('sessionId', isEqualTo: sessionId)
              .limit(1)
              .get();

      if (currentPaymentSnapshot.docs.isEmpty) {
        print('Không tìm thấy PaymentProcessing cho khách hàng này.');
        return false;
      }

      // Lấy DocumentReference của tài liệu
      DocumentReference<Map<String, dynamic>> paymentDocRef =
          currentPaymentSnapshot.docs.first.reference;

      // Bắt đầu transaction
      return await _firestore.runTransaction((transaction) async {
        // Lấy snapshot của tài liệu trong transaction
        DocumentSnapshot<Map<String, dynamic>> currentPaymentDocSnapshot =
            await transaction.get(paymentDocRef);

        if (!currentPaymentDocSnapshot.exists) {
          print('Không tìm thấy tài liệu PaymentProcessing trong transaction.');
          return false;
        }

        var currentPaymentData = currentPaymentDocSnapshot.data();

        if (currentPaymentData == null) {
          return false;
        }

        // Truy vấn tất cả các tài liệu PaymentProcessing có cùng RoomId và đã được chọn
        String currentRoomId = currentPaymentData['RoomId'];
        QuerySnapshot<Map<String, dynamic>> roomQuerySnapshot = await _firestore
            .collectionGroup('PaymentProcessing')
            .where('RoomId', isEqualTo: currentRoomId)
            .where('isSelected', isEqualTo: true)
            .get();

        // Kiểm tra xem có trùng lặp về thời gian không
        for (var doc in roomQuerySnapshot.docs) {
          if (doc.id == paymentDocRef.id) {
            // Bỏ qua tài liệu của người dùng hiện tại
            continue;
          }

          DateTime paymentStartDate = DateTime.parse(doc['StartDate']);

          DateTime paymentEndDate = DateTime.parse(doc['EndDate']);

          TimeOfDay paymentStartTime = TimeOfDay(
            hour: int.parse(doc['StartTime'].split(':')[0]),
            minute: int.parse(doc['StartTime'].split(':')[1]),
          );

          TimeOfDay paymentEndTime = TimeOfDay(
            hour: int.parse(doc['EndTime'].split(':')[0]),
            minute: int.parse(doc['EndTime'].split(':')[1]),
          );

          DateTime currentStartDateSearch =
              DateTime.parse(currentPaymentData['StartDate']);

          DateTime currentEndDateSearch =
              DateTime.parse(currentPaymentData['EndDate']);

          TimeOfDay currentStartTimeSearch = TimeOfDay(
            hour: int.parse(currentPaymentData['StartTime'].split(':')[0]),
            minute: int.parse(currentPaymentData['StartTime'].split(':')[1]),
          );

          TimeOfDay currentEndTimeSearch = TimeOfDay(
            hour: int.parse(currentPaymentData['EndTime'].split(':')[0]),
            minute: int.parse(currentPaymentData['EndTime'].split(':')[1]),
          );

          // Kiểm tra trùng lặp ngày và giờ
          bool dateOverlap =
              !(paymentEndDate.isBefore(currentStartDateSearch) ||
                  paymentStartDate.isAfter(currentEndDateSearch));

          bool timeOverlap = true;

          if (dateOverlap) {
            if (currentStartDateSearch.isAtSameMomentAs(paymentEndDate)) {
              var finalTimeHour =
                  currentStartTimeSearch.hour - paymentEndTime.hour;
              if (finalTimeHour >= 2 &&
                  currentStartTimeSearch.hour >= paymentEndTime.hour) {
                timeOverlap = false;
              }
            } else if (currentEndDateSearch
                .isAtSameMomentAs(paymentStartDate)) {
              var finalEndTimeHour =
                  currentEndTimeSearch.hour - paymentStartTime.hour;
              if (finalEndTimeHour <= -2 &&
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
                      currentEndTimeSearch.minute == paymentEndTime.minute)) {
                timeOverlap = true;
              }
            } else {
              timeOverlap = true;
            }
          }
          print(
              'checkIfAnyBikeIsBooked: dateOverlap, timeOverlap: $dateOverlap, $timeOverlap');
          if (dateOverlap && timeOverlap) {
            // Trùng lặp, trả về true
            return true;
          }
        }
        // Không có trùng lặp
        return false;
      });
    } catch (e) {
      print('Lỗi khi kiểm tra booking: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getBookedRooms(
      String userId, String sessionId) async {
    List<Map<String, dynamic>> bookedRooms = [];

    try {
      // Lấy tài liệu PaymentProcessing của người dùng hiện tại với sessionId tương ứng trước khi vào transaction
      QuerySnapshot<Map<String, dynamic>> currentPaymentSnapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('PaymentProcessing')
              .where('sessionId', isEqualTo: sessionId)
              .limit(1)
              .get();

      if (currentPaymentSnapshot.docs.isEmpty) {
        print('Không tìm thấy PaymentProcessing cho khách hàng này.');
        return bookedRooms;
      }

      // Lấy DocumentReference của tài liệu
      DocumentReference<Map<String, dynamic>> paymentDocRef =
          currentPaymentSnapshot.docs.first.reference;

      // Bắt đầu transaction
      await _firestore.runTransaction((transaction) async {
        // Lấy snapshot của tài liệu trong transaction
        DocumentSnapshot<Map<String, dynamic>> currentPaymentDocSnapshot =
            await transaction.get(paymentDocRef);

        if (!currentPaymentDocSnapshot.exists) {
          print('Không tìm thấy tài liệu PaymentProcessing trong transaction.');
          return;
        }

        var currentPaymentData = currentPaymentDocSnapshot.data();

        if (currentPaymentData == null) {
          return;
        }

        // Truy vấn tất cả các tài liệu PaymentProcessing có cùng RoomId và đã được chọn
        String currentRoomId = currentPaymentData['RoomId'];
        QuerySnapshot<Map<String, dynamic>> roomQuerySnapshot = await _firestore
            .collectionGroup('PaymentProcessing')
            .where('RoomId', isEqualTo: currentRoomId)
            .where('isSelected', isEqualTo: true)
            .get();

        // Kiểm tra xem có trùng lặp về thời gian không
        for (var doc in roomQuerySnapshot.docs) {
          if (doc.id == paymentDocRef.id) {
            // Bỏ qua tài liệu của người dùng hiện tại
            continue;
          }

          DateTime paymentStartDate = DateTime.parse(doc['StartDate']);
          DateTime paymentEndDate = DateTime.parse(doc['EndDate']);
          TimeOfDay paymentStartTime = TimeOfDay(
            hour: int.parse(doc['StartTime'].split(':')[0]),
            minute: int.parse(doc['StartTime'].split(':')[1]),
          );
          TimeOfDay paymentEndTime = TimeOfDay(
            hour: int.parse(doc['EndTime'].split(':')[0]),
            minute: int.parse(doc['EndTime'].split(':')[1]),
          );

          DateTime currentStartDateSearch =
              DateTime.parse(currentPaymentData['StartDate']);
          DateTime currentEndDateSearch =
              DateTime.parse(currentPaymentData['EndDate']);
          TimeOfDay currentStartTimeSearch = TimeOfDay(
            hour: int.parse(currentPaymentData['StartTime'].split(':')[0]),
            minute: int.parse(currentPaymentData['StartTime'].split(':')[1]),
          );
          TimeOfDay currentEndTimeSearch = TimeOfDay(
            hour: int.parse(currentPaymentData['EndTime'].split(':')[0]),
            minute: int.parse(currentPaymentData['EndTime'].split(':')[1]),
          );

          // Kiểm tra trùng lặp ngày và giờ
          bool dateOverlap =
              !(paymentEndDate.isBefore(currentStartDateSearch) ||
                  paymentStartDate.isAfter(currentEndDateSearch));

          bool timeOverlap = true;

          if (dateOverlap) {
            if (currentStartDateSearch.isAtSameMomentAs(paymentEndDate)) {
              var finalTimeHour =
                  currentStartTimeSearch.hour - paymentEndTime.hour;
              if (finalTimeHour >= 2 &&
                  currentStartTimeSearch.hour >= paymentEndTime.hour) {
                timeOverlap = false;
              }
            } else if (currentEndDateSearch
                .isAtSameMomentAs(paymentStartDate)) {
              var finalEndTimeHour =
                  currentEndTimeSearch.hour - paymentStartTime.hour;
              if (finalEndTimeHour <= -2 &&
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
                      currentEndTimeSearch.minute == paymentEndTime.minute)) {
                timeOverlap = true;
              }
            } else {
              timeOverlap = true;
            }
          }

          if (dateOverlap && timeOverlap) {
            bool roomExists =
                bookedRooms.any((b) => b['RoomId'] == doc['RoomId']);
            if (!roomExists) {
              bookedRooms.add(doc.data());
            }
          }
        }
      });
    } catch (e) {
      print('Lỗi khi lấy danh sách phòng đã đặt: $e');
    }

    return bookedRooms;
  }

  Future<void> updateIsSelectedForUserPayments(
      String userId, String sessionId) async {
    try {
      // Lấy tài liệu PaymentProcessing của người dùng hiện tại với sessionId tương ứng trước khi vào transaction
      QuerySnapshot<Map<String, dynamic>> currentPaymentSnapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('PaymentProcessing')
              .where('sessionId', isEqualTo: sessionId)
              .limit(1)
              .get();

      if (currentPaymentSnapshot.docs.isEmpty) {
        print('Không tìm thấy PaymentProcessing cho khách hàng này.');
        return;
      }

      // Lấy DocumentReference của tài liệu
      DocumentReference<Map<String, dynamic>> paymentDocRef =
          currentPaymentSnapshot.docs.first.reference;

      // Bắt đầu transaction
      await _firestore.runTransaction((transaction) async {
        // Lấy snapshot của tài liệu trong transaction
        DocumentSnapshot<Map<String, dynamic>> currentPaymentDocSnapshot =
            await transaction.get(paymentDocRef);

        if (!currentPaymentDocSnapshot.exists) {
          print('Không tìm thấy tài liệu PaymentProcessing trong transaction.');
          return;
        }

        var currentPaymentData = currentPaymentDocSnapshot.data();

        if (currentPaymentData == null) {
          return;
        }

        // Truy vấn tất cả các tài liệu PaymentProcessing có cùng RoomId
        String currentRoomId = currentPaymentData['RoomId'];
        QuerySnapshot<Map<String, dynamic>> roomQuerySnapshot = await _firestore
            .collectionGroup('PaymentProcessing')
            .where('RoomId', isEqualTo: currentRoomId)
            .get();

        // Kiểm tra xem có trùng lặp về thời gian không
        for (var doc in roomQuerySnapshot.docs) {
          DateTime paymentStartDate = DateTime.parse(doc['StartDate']);
          DateTime paymentEndDate = DateTime.parse(doc['EndDate']);

          TimeOfDay paymentStartTime = TimeOfDay(
            hour: int.parse(doc['StartTime'].split(':')[0]),
            minute: int.parse(doc['StartTime'].split(':')[1]),
          );
          TimeOfDay paymentEndTime = TimeOfDay(
            hour: int.parse(doc['EndTime'].split(':')[0]),
            minute: int.parse(doc['EndTime'].split(':')[1]),
          );

          DateTime currentStartDateSearch =
              DateTime.parse(currentPaymentData['StartDate']);
          DateTime currentEndDateSearch =
              DateTime.parse(currentPaymentData['EndDate']);
          TimeOfDay currentStartTimeSearch = TimeOfDay(
            hour: int.parse(currentPaymentData['StartTime'].split(':')[0]),
            minute: int.parse(currentPaymentData['StartTime'].split(':')[1]),
          );
          TimeOfDay currentEndTimeSearch = TimeOfDay(
            hour: int.parse(currentPaymentData['EndTime'].split(':')[0]),
            minute: int.parse(currentPaymentData['EndTime'].split(':')[1]),
          );

          // Kiểm tra trùng lặp ngày và giờ
          bool dateOverlap =
              !(paymentEndDate.isBefore(currentStartDateSearch) ||
                  paymentStartDate.isAfter(currentEndDateSearch));

          bool timeOverlap = true;

          if (dateOverlap) {
            if (currentStartDateSearch.isAtSameMomentAs(paymentEndDate)) {
              var finalTimeHour =
                  currentStartTimeSearch.hour - paymentEndTime.hour;
              if (finalTimeHour >= 2 &&
                  currentStartTimeSearch.hour >= paymentEndTime.hour) {
                timeOverlap = false;
              }
            } else if (currentEndDateSearch
                .isAtSameMomentAs(paymentStartDate)) {
              var finalEndTimeHour =
                  currentEndTimeSearch.hour - paymentStartTime.hour;
              if (finalEndTimeHour <= -2 &&
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
                      currentEndTimeSearch.minute == paymentEndTime.minute)) {
                timeOverlap = true;
              }
            } else {
              timeOverlap = true;
            }
          }

          if (dateOverlap && timeOverlap) {
            // Cập nhật isSelected của tài liệu thành true
            transaction.update(doc.reference, {'isSelected': true});
          }
        }
      });

      print(
          'Cập nhật isSelected thành công cho các PaymentProcessing trùng thời gian.');
    } catch (e) {
      print('Lỗi khi cập nhật isSelected: $e');
    }
  }
}
