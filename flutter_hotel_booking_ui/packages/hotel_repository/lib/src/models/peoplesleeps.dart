import '../entities/peoplesleeps_entity.dart';

class PeopleSleeps {
  late int startDate;
  late int endDate;

  PeopleSleeps({
    required this.startDate,
    required this.endDate,
  });

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
