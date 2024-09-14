import 'package:cloud_firestore/cloud_firestore.dart';

import 'dart:typed_data';

abstract class HotelRepo {
  Future<String> sendImage(Uint8List file, String name);

  Future<String> uploadPicture(String file, String userId);

  Future<QuerySnapshot<Map<String, dynamic>>> getHotelByHotelId(String hotelId);
}
