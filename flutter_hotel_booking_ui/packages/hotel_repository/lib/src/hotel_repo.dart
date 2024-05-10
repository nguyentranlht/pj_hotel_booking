import 'models/models.dart';
import 'dart:typed_data';
import 'models/models.dart';

abstract class HotelRepo {
  Future<List<Hotel>> getHotels();

  Future<String> sendImage(Uint8List file, String name);

  Future<void> createHotels(Hotel hotel);
}