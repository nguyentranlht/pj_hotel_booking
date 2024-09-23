import 'package:room_repository/room_repository.dart';

import 'models/models.dart';
import 'dart:typed_data';

abstract class RoomRepo {
  Future<List<Room>> getRooms();

  Future<String> sendImage(Uint8List file, String name);

  Future<void> createRooms(Room room);

  Future<List<Room>> getRoomsByHotelId(String hotelId);
}
