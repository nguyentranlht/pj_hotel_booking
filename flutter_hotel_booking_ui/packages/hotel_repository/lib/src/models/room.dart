import '../entities/room_entity.dart';

class Room {
  int numberRoom;

  int people;

  Room({
    required this.numberRoom,
    required this.people,
  });
  static final empty = Room(
    numberRoom: 0,
    people: 0,
  );
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
