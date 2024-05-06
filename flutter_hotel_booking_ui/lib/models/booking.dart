class Booking {
  final String bookingId;
  final String userId;
  final DateTime startTime;
  final DateTime endTime;
  final String roomName;
  String? notes;

  Booking({
    required this.bookingId,
    required this.userId,
    required this.startTime,
    required this.endTime,
    required this.roomName,
    this.notes,
  });

  static final empty = Booking(
    bookingId: '',
    userId: '',
    startTime: DateTime.now(),
    endTime: DateTime.now(),
    roomName: '',
  );

  Booking copyWith({
    String? bookingId,
    String? userId,
    DateTime? startTime,
    DateTime? endTime,
    String? roomName,
    String? notes,
  }) {
    return Booking(
      bookingId: bookingId ?? this.bookingId,
      userId: userId ?? this.userId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      roomName: roomName ?? this.roomName,
      notes: notes ?? this.notes,
    );
  }

  bool get isEmpty => this == Booking.empty;

  bool get isNotEmpty => this != Booking.empty;

  Map<String, Object?> toDocument() {
    return {
      'bookingId': bookingId,
      'userId': userId,
      'startTime': startTime,
      'endTime': endTime,
      'roomName': roomName,
      'notes': notes,
    };
  }

  static Booking fromDocument(Map<String, dynamic> doc) {
    return Booking(
      bookingId: doc['bookingId'] as String,
      userId: doc['userId'] as String,
      startTime: doc['startTime']?.toDate() ?? DateTime.now(),
      endTime: doc['endTime']?.toDate() ?? DateTime.now(),
      roomName: doc['roomName'] as String,
      notes: doc['notes'] as String?,
    );
  }

  @override
  List<Object?> get props => [bookingId, userId, startTime, endTime, roomName, notes];

  @override
  String toString() {
    return '''Booking: {
      bookingId: $bookingId,
      userId: $userId,
      startTime: $startTime,
      endTime: $endTime,
      roomName: $roomName,
      notes: $notes
    }''';
  }
}
