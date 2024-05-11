class RoomEntity {
  int numberRoom;
  int people;

  RoomEntity({
    required this.numberRoom,
    required this.people,
  });

  Map<String, Object?> toDocument() {
    return {
      'numberRoom': numberRoom,
      'people': people,
    };
  }

  static RoomEntity fromDocument(Map<String, dynamic> doc) {
    return RoomEntity(
      numberRoom: doc['numberRoom'],
      people: doc['people'],
    );
  }
}
