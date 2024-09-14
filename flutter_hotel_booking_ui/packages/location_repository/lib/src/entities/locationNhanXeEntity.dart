class LocationNhanXeEntity {
  String location1;
  String location2;
  String location3;
  String location4;
  String location5;
  String location6;

  LocationNhanXeEntity({
    required this.location1,
    required this.location2,
    required this.location3,
    required this.location4,
    required this.location5,
    required this.location6,
  });
  static final empty = LocationNhanXeEntity(
    location1: '',
    location2: '',
    location3: '',
    location4: '',
    location5: '',
    location6: '',
  );

  Map<String, Object?> toDocument() {
    return {
      '32 Nguyễn Bỉnh Khiêm, Xương Huân, Nha Trang': location1,
      '61 Hai Tháng Tư, Vĩnh Phước, Nha Trang': location2,
      'location3': location3,
      'location4': location4,
      'location5': location5,
      'location6': location6,
    };
  }

  static LocationNhanXeEntity fromDocument(Map<String, dynamic> doc) {
    return LocationNhanXeEntity(
      location1: doc['32 Nguyễn Bỉnh Khiêm, Xương Huân, Nha Trang'],
      location2: doc['61 Hai Tháng Tư, Vĩnh Phước, Nha Trang'],
      location3: doc['location3'],
      location4: doc['location4'],
      location5: doc['location5'],
      location6: doc['location6'],
    );
  }
}
