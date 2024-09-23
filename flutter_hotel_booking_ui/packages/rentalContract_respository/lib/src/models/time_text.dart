import '../entities/time_text.dart';

class TimeText {
  int timeStart;
  int timeEnd;

  TimeText({
    required this.timeStart,
    required this.timeEnd,
  });
  static final empty = TimeText(
    timeStart: 0,
    timeEnd: 0,
  );
  TimeTextEntity toEntity() {
    return TimeTextEntity(
      timeStart: timeStart,
      timeEnd: timeEnd,
    );
  }

  static TimeText fromEntity(TimeTextEntity entity) {
    return TimeText(
      timeStart: entity.timeStart,
      timeEnd: entity.timeEnd,
    );
  }
}
