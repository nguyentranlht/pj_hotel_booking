class PeopleSleepsEntity {
  int startDate;
  int endDate;

  PeopleSleepsEntity({
    required this.startDate,
    required this.endDate,
  });

  Map<String, Object?> toDocument() {
    return {
      'startDate': startDate,
      'endDate': endDate,
    };
  }

  static PeopleSleepsEntity fromDocument(Map<String, dynamic> doc) {
    return PeopleSleepsEntity(
      startDate: doc['startDate'],
      endDate: doc['endDate'],
    );
  }
}
