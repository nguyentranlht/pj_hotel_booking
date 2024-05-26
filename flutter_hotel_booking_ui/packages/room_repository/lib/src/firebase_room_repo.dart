import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:room_repository/room_repository.dart';
import 'package:room_repository/src/entities/entities.dart';
import 'dart:developer';
import 'dart:typed_data';

class FirebaseRoomRepo implements RoomRepo {
  final roomCollection = FirebaseFirestore.instance.collection('rooms');
  final CollectionReference roomCollection2 = FirebaseFirestore.instance.collection('rooms');
  @override
  Future<List<Room>> getRooms() async {
    try {
      return await roomCollection.where('isSelected', isEqualTo: true).get().then((value) => value.docs
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
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      return userDoc.get('roomId');
    } else {
      throw Exception('User not found.');
    }
  }

  Future<void> updateIsSelected(String roomId, bool isSelected) async {
    try {
      // Cập nhật trạng thái của phòng
      await roomCollection2.doc(roomId).update({'isSelected': isSelected});
    } catch (error) {
      throw Exception('Failed to update room status: $error');
    }
  }

  Future<void> updateRoomData(String roomId, Map<String, dynamic> data) async {
    try {
      await roomCollection.doc(roomId).update(data);
    } catch (e) {
      print('Error updating room data: $e');
      throw e;
    }
  }
}
