import '../entities/room_entity.dart';

class RoomData {
  int numberRoom;

  int people;

  RoomData({
    required this.numberRoom,
    required this.people,
  });
  static final empty = RoomData(
    numberRoom: 0,
    people: 0,
  );
  RoomDataEntity toEntity() {
    return RoomDataEntity(
      numberRoom: numberRoom,
      people: people,
    );
  }

  static RoomData fromEntity(RoomDataEntity entity) {
    return RoomData(
      numberRoom: entity.numberRoom,
      people: entity.people,
    );
  }
}
