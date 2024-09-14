import 'package:location_repository/src/entities/locationNhanXeEntity.dart';

class Locationnhanxe {
  String location1;
  String location2;
  String location3;
  String location4;
  String location5;
  String location6;

  Locationnhanxe(
      {required this.location1,
      required this.location2,
      required this.location3,
      required this.location4,
      required this.location5,
      required this.location6});
  static final empty = Locationnhanxe(
    location1: '32 Nguyễn Bỉnh Khiêm, Xương Huân, Nha Trang',
    location2: '61 Hai Tháng Tư, Vĩnh Phước, Nha Trang',
    location3: '',
    location4: '',
    location5: '',
    location6: '',
  );
  LocationNhanXeEntity toEntity() {
    return LocationNhanXeEntity(
      location1: location1,
      location2: location2,
      location3: location3,
      location4: location4,
      location5: location5,
      location6: location6,
    );
  }

  static Locationnhanxe fromEntity(Locationnhanxe entity) {
    return Locationnhanxe(
      location1: entity.location1,
      location2: entity.location2,
      location3: entity.location3,
      location4: entity.location4,
      location5: entity.location5,
      location6: entity.location6,
    );
  }
}
