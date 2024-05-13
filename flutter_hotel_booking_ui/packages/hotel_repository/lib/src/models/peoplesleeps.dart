import '../entities/peoplesleeps_entity.dart';

class PeopleSleeps {
  int peopleNumber;

  PeopleSleeps({
    required this.peopleNumber,
  });
  static final empty = PeopleSleeps(
    peopleNumber: 1,
  );
  PeopleSleepsEntity toEntity() {
    return PeopleSleepsEntity(
      peopleNumber: peopleNumber,
    );
  }

  static PeopleSleeps fromEntity(PeopleSleepsEntity entity) {
    return PeopleSleeps(
      peopleNumber: entity.peopleNumber,
    );
  }
}
