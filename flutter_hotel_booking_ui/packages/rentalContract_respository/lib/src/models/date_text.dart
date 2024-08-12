import '../entities/date_text.dart';

class DateText {
  int startDate;
  int endDate;

  DateText({
    required this.startDate,
    required this.endDate,
  });
  static final empty = DateText(
    startDate: 0,
    endDate: 0,
  );
  DateTextEntity toEntity() {
    return DateTextEntity(
      startDate: startDate,
      endDate: endDate,
    );
  }

  static DateText fromEntity(DateTextEntity entity) {
    return DateText(
      startDate: entity.startDate,
      endDate: entity.endDate,
    );
  }
}
