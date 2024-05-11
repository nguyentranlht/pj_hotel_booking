import '../entities/room_entity.dart';

class Room {
  int numberRoom;

  int people;

  Room({
    required this.numberRoom,
    required this.people,
  });

  RoomEntity toEntity() {
    return RoomEntity(
      numberRoom: numberRoom,
      people: people,
    );
  }

  static Room fromEntity(RoomEntity entity) {
    return Room(
      numberRoom: entity.numberRoom,
      people: entity.people,
    );
  }
}
