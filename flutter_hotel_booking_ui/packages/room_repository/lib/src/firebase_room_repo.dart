import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:room_repository/room_repository.dart';
import 'package:room_repository/src/entities/entities.dart';
import 'dart:developer';
import 'dart:typed_data';

class FirebaseRoomRepo implements RoomRepo {
  final roomCollection = FirebaseFirestore.instance.collection('rooms');

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
}
