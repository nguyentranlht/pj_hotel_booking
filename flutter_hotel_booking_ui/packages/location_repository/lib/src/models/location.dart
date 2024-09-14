import 'package:location_repository/src/models/TypeText.dart';
import 'package:location_repository/src/models/locationNhanxe.dart';

import '../entities/entities.dart';
import 'package:uuid/uuid.dart';

class Location {
  String locationId;
  String locationName;
  Locationnhanxe location;
  String locationSub;
  String locationImage;
  TypeText locationType;

  Location({
    required this.locationId,
    required this.locationName,
    required this.location,
    required this.locationSub,
    required this.locationImage,
    required this.locationType,
  });
  static var empty = Location(
    locationId: const Uuid().v1(),
    locationName: '',
    location: Locationnhanxe.empty,
    locationSub: '',
    locationImage: '',
    locationType: TypeText.empty,
  );

  LocationEntity toEntity() {
    return LocationEntity(
      locationId: locationId,
      locationName: locationName,
      location: location,
      locationSub: locationSub,
      locationImage: locationImage,
      locationType: locationType,
    );
  }

  static Location fromEntity(LocationEntity entity) {
    return Location(
      locationId: entity.locationId,
      locationName: entity.locationName,
      location: entity.location,
      locationSub: entity.locationSub,
      locationImage: entity.locationImage,
      locationType: entity.locationType,
    );
  }

  @override
  String toString() {
    return '''
      locationId: $locationId,
      locationName: $locationName,
      location: $location,
      locationSub: $locationSub,
      locationImage: $locationImage,
      locationType: $locationType,
    ''';
  }

  static Location fromMap(Map<String, dynamic> map) {
    return fromEntity(LocationEntity.fromDocument(map));
  }
}
