import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:bike_repository/bike_repository.dart';
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

  @override
  Future<List<Bike>> getBikesByLocationId(String locationId) async {
    try {
      return await bikeCollection
          .where('hotelId', isEqualTo: locationId)
          .get()
          .then((result) => result.docs
              .map(
                  (doc) => Bike.fromEntity(BikeEntity.fromDocument(doc.data())))
              .toList());
    } catch (e) {
      print(e.toString());
      throw Exception('Failed to load bike');
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

  Future<void> updateBikeData(String bikeId, Map<String, dynamic> data) async {
    try {
      await bikeCollection.doc(bikeId).update(data);
    } catch (e) {
      print('Error updating room data: $e');
      rethrow;
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

  Stream<List<Map<String, dynamic>>> getLatestHistorySearchBikesToUser(
      String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('HistorySearch')
        .orderBy('createdAt',
            descending: true) // Sắp xếp theo thời gian tạo mới nhất trước
        .limit(1) // Giới hạn chỉ lấy 1 tài liệu mới nhất
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        // Lấy tài liệu mới nhất và danh sách 'bikes' từ tài liệu đó
        var document = snapshot.docs.first;
        List<Map<String, dynamic>> bikes =
            List<Map<String, dynamic>>.from(document.data()['bikes'] ?? []);
        return bikes;
      }
      return [];
    });
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

  Future<void> addLatestContractFromHistorySearch(
      String userId, String amount) async {
    try {
      // Lấy dữ liệu từ HistorySearch, sắp xếp theo createdAt và giới hạn lấy 1 tài liệu mới nhất
      CollectionReference<Map<String, dynamic>> historySearchRef =
          FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('HistorySearch')
              .withConverter<Map<String, dynamic>>(
                fromFirestore: (snapshot, _) => snapshot.data()!,
                toFirestore: (data, _) => data,
              );

      QuerySnapshot<Map<String, dynamic>> historySearchSnapshot =
          await historySearchRef
              .orderBy('createdAt', descending: true)
              .limit(1)
              .get();

      // Kiểm tra xem có tài liệu nào không
      if (historySearchSnapshot.docs.isNotEmpty) {
        // Lấy dữ liệu từ tài liệu mới nhất
        Map<String, dynamic> historyData =
            historySearchSnapshot.docs.first.data();

        // Duyệt qua từng xe trong danh sách bikes và thêm dateSearch, timeSearch
        List<dynamic> bikes = historyData['bikes'];

        // Tham chiếu đến bộ sưu tập contracts
        // CollectionReference<Map<String, dynamic>> contractsRef =
        //     FirebaseFirestore.instance.collection('contracts');

        // Tạo một document mới và lấy ID tự sinh

        DocumentReference<Map<String, dynamic>> newContractRef =
            FirebaseFirestore.instance.collection('contracts').doc();
        String contractId = newContractRef.id;
        // Chuẩn bị dữ liệu để thêm vào contracts
        Map<String, dynamic> contractData = {
          'bikes': bikes, // Thêm danh sách bikes đã cập nhật vào hợp đồng
          'contractId': contractId,
          'price': amount,
          'userId': userId,
          'dateSearch': historyData['dateSearch'],
          'timeSearch': historyData['timeSearch'],
          'locationId':
              bikes.isNotEmpty ? bikes.first['locationId'].toString() : '',
          'locationBike':
              bikes.isNotEmpty ? bikes.first['locationBike'].toString() : '',
          'createdAt': FieldValue.serverTimestamp(),
          'historySearchId': historyData['historySearchId'],
        };

        // Thêm vào contracts
        await newContractRef.set(contractData);

        print('Dữ liệu từ tài liệu mới nhất đã được thêm vào contracts.');
      } else {
        print('Không tìm thấy tài liệu nào trong HistorySearch.');
      }
    } catch (e) {
      print('Lỗi khi thêm dữ liệu vào contracts: $e');
    }
  }

  Future<void> printContractsData() async {
    try {
      // Tham chiếu đến bộ sưu tập contracts
      CollectionReference<Map<String, dynamic>> contractsRef =
          FirebaseFirestore.instance.collection('contracts');

      // Lấy tất cả các tài liệu trong bộ sưu tập contracts
      QuerySnapshot<Map<String, dynamic>> contractsSnapshot =
          await contractsRef.get();

      // Duyệt qua từng tài liệu trong contracts
      for (var contractDoc in contractsSnapshot.docs) {
        print('Document ID: ${contractDoc.id}');
        Map<String, dynamic> data = contractDoc.data();

        // In ra từng trường trong tài liệu
        data.forEach((key, value) {
          print('$key: $value');
        });

        print('----------------------------------');
      }
    } catch (e) {
      print('Lỗi khi lấy dữ liệu từ contracts: $e');
    }
  }

  Future<String?> getLatestHistorySearchId(String userId) async {
    try {
      // Truy vấn Firestore để lấy tài liệu gần nhất từ HistorySearch của người dùng
      QuerySnapshot<Map<String, dynamic>> historySearchSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('HistorySearch')
              .orderBy('createdAt', descending: true) // Lấy tài liệu mới nhất
              .limit(1) // Giới hạn kết quả chỉ lấy 1 tài liệu
              .get();

      // Kiểm tra xem có tài liệu nào không
      if (historySearchSnapshot.docs.isNotEmpty) {
        // Lấy ra ID của tài liệu
        String historySearchId = historySearchSnapshot.docs.first.id;
        print('Lấy được historySearchId: $historySearchId');
        return historySearchId;
      } else {
        print('Không tìm thấy lịch sử tìm kiếm.');
        return null;
      }
    } catch (e) {
      print('Lỗi khi lấy historySearchId: $e');
      return null;
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

  Future<void> removeBikeFromHistorySearch(
      String userId, String sessionId, String bikeId) async {
    // Truy vấn lấy tài liệu HistorySearch dựa trên userId và sessionId
    QuerySnapshot<Map<String, dynamic>> historySearchSnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('HistorySearch')
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
          .collection('HistorySearch')
          .doc(documentId)
          .update({'bikes': bikes});

      print("Bike with bikeId $bikeId has been removed from history search.");
    } else {
      print("No HistorySearch document found for sessionId $sessionId.");
    }
  }
}
