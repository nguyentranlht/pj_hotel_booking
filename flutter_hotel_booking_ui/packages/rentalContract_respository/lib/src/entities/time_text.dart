class TimeTextEntity {
  int timeStart;
  int timeEnd;

  TimeTextEntity({
    required this.timeStart,
    required this.timeEnd,
  });

  Map<String, Object?> toDocument() {
    return {
      'timeStart': timeStart,
      'timeEnd': timeEnd,
    };
  }

  static TimeTextEntity fromDocument(Map<String, dynamic> doc) {
    return TimeTextEntity(
      timeStart: doc['timeStart'],
      timeEnd: doc['timeEnd'],
    );
  }
}
