import 'package:location_repository/src/models/TypeText.dart';
import 'package:location_repository/src/models/locationNhanxe.dart';

class LocationEntity {
  String locationId; // ID duy nhất của xe máy
  String locationName; // Tên hoặc model của xe máy
  Locationnhanxe location; // Loại xe máy (tay ga, xe số, xe côn)
  String locationSub; // URL hình ảnh của xe máy
  String locationImage;
  TypeText locationType;
  LocationEntity({
    required this.locationId,
    required this.locationName,
    required this.location,
    required this.locationSub,
    required this.locationImage,
    required this.locationType,
  });
  Map<String, Object?> toDocument() {
    return {
      'locationId': locationId,
      'locationName': locationName,
      'location': location,
      'locationSub': locationSub,
      'locationImage': locationImage,
      'locationType': locationType,
    };
  }

  static LocationEntity fromDocument(Map<String, dynamic> doc) {
    return LocationEntity(
      locationId: doc['locationId'],
      locationName: doc['locationName'],
      location: doc['location'],
      locationSub: doc['locationSub'],
      locationImage: doc['locationImage'],
      locationType: doc['locationType'],
    );
  }
}
