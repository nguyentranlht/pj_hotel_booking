class RoomEntity {
  String roomId;
  String roomName;
  String hotelId;
  double price;
  int numberOfBeds;
  bool isAvailable;

  RoomEntity({
    required this.roomId,
    required this.roomName,
    required this.hotelId,
    required this.price,
    required this.numberOfBeds,
    required this.isAvailable,
  });

  Map<String, Object?> toDocument() {
    return {
      'roomId': roomId,
      'roomName': roomName,
      'hotelId': hotelId,
      'price': price,
      'numberOfBeds': numberOfBeds,
      'isAvailable': isAvailable,
    };
  }

  static RoomEntity fromDocument(Map<String, dynamic> doc) {
    return RoomEntity(
      roomId: doc['roomId'],
      roomName: doc['roomName'],
      hotelId: doc['hotelId'],
      price: doc['price'],
      numberOfBeds: doc['numberOfBeds'],
      isAvailable: doc['isAvailable'],
    );
  }
}
