import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hotel_repository/hotel_repository.dart';
import 'dart:developer';
import 'dart:typed_data';

class FirebaseHotelRepo implements HotelRepo {
  final hotelCollection = FirebaseFirestore.instance.collection('hotels');

  @override
  Future<List<Hotel>> getHotels() async {
    try {
      return await hotelCollection.get().then((value) => value.docs
          .map((e) => Hotel.fromEntity(HotelEntity.fromDocument(e.data())))
          .toList());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> getHotelByHotelId(
      String hotelId) async {
    try {
      return await hotelCollection.where('hotelId', isEqualTo: hotelId).get();
    } catch (e) {
      print(e.toString());
      throw Exception('Failed to load hotel');
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
  Future<void> createHotels(Hotel hotel) async {
    try {
      return await hotelCollection
          .doc(hotel.hotelId)
          .set(hotel.toEntity().toDocument());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<String> uploadPicture(String file, String hotelId) async {
    try {
      File imageFile = File(file);
      Reference firebaseStoreRef =
          FirebaseStorage.instance.ref().child('$hotelId/PP/${hotelId}_lead');
      await firebaseStoreRef.putFile(
        imageFile,
      );
      String url = await firebaseStoreRef.getDownloadURL();
      await hotelCollection.doc(hotelId).update({'imagePath': url});
      return url;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
