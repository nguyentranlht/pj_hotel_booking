class DateTextEntity {
  int startDate;
  int endDate;

  DateTextEntity({
    required this.startDate,
    required this.endDate,
  });

  Map<String, Object?> toDocument() {
    return {
      'startDate': startDate,
      'endDate': endDate,
    };
  }

  static DateTextEntity fromDocument(Map<String, dynamic> doc) {
    return DateTextEntity(
      startDate: doc['startDate'],
      endDate: doc['endDate'],
    );
  }
}
