class PeopleSleepsEntity {
  int peopleNumber;

  PeopleSleepsEntity({
    required this.peopleNumber,
  });

  Map<String, Object?> toDocument() {
    return {
      'peopleNumber': peopleNumber,
    };
  }

  static PeopleSleepsEntity fromDocument(Map<String, dynamic> doc) {
    return PeopleSleepsEntity(
      peopleNumber: doc['peopleNumber'],
    );
  }
}
