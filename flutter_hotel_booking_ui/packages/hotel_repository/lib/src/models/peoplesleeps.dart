import '../entities/peoplesleeps_entity.dart';

class PeopleSleeps {
  int startDate;
  int endDate;

  PeopleSleeps({
    required this.startDate,
    required this.endDate,
  });
  static final empty = PeopleSleeps(
    startDate: 0,
    endDate: 0,
  );
  PeopleSleepsEntity toEntity() {
    return PeopleSleepsEntity(
      startDate: startDate,
      endDate: endDate,
    );
  }

  static PeopleSleeps fromEntity(PeopleSleepsEntity entity) {
    return PeopleSleeps(
      startDate: entity.startDate,
      endDate: entity.endDate,
    );
  }
}
