import '../entities/room_entity.dart';

class Room {
  String roomId;
  String roomName;
  String hotelId;
  double price;
  int numberOfBeds;
  bool isAvailable;

  Room({
    required this.roomId,
    required this.roomName,
    required this.hotelId,
    required this.price,
    required this.numberOfBeds,
    required this.isAvailable,
  });

  RoomEntity toEntity() {
    return RoomEntity(
      roomId: roomId,
      roomName: roomName,
      hotelId: hotelId,
      price: price,
      numberOfBeds: numberOfBeds,
      isAvailable: isAvailable,
    );
  }

  static Room fromEntity(RoomEntity entity) {
    return Room(
      roomId: entity.roomId,
      roomName: entity.roomName,
      hotelId: entity.hotelId,
      price: entity.price,
      numberOfBeds: entity.numberOfBeds,
      isAvailable: entity.isAvailable,
    );
  }
}
