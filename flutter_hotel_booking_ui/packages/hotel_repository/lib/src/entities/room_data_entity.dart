class RoomDataEntity {
  int numberRoom;
  int people;

  RoomDataEntity({
    required this.numberRoom,
    required this.people,
  });

  Map<String, Object?> toDocument() {
    return {
      'numberRoom': numberRoom,
      'people': people,
    };
  }

  static RoomDataEntity fromDocument(Map<String, dynamic> doc) {
    return RoomDataEntity(
      numberRoom: doc['numberRoom'],
      people: doc['people'],
    );
  }
}
