import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/models.dart';
import 'dart:typed_data';

abstract class HotelRepo {
  Future<List<Hotel>> getHotels();

  Future<String> sendImage(Uint8List file, String name);

  Future<void> createHotels(Hotel hotel);

  Future<String> uploadPicture(String file, String userId);

  Future<QuerySnapshot<Map<String, dynamic>>> getHotelByHotelId(String hotelId);
}