import 'models/models.dart';
import 'dart:typed_data';
import 'models/models.dart';

abstract class RoomRepo {
  Future<List<Room>> getRooms();

  Future<String> sendImage(Uint8List file, String name);

  Future<void> createRooms(Room room);
}