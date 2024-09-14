import 'package:bike_repository/bike_repository.dart';

import 'models/models.dart';
import 'dart:typed_data';

abstract class BikeRepo {
  Future<List<Bike>> getBikes();

  Future<String> sendImage(Uint8List file, String name);

  Future<void> createBikes(
    String locationId,
    Bike bike,
  );

  Future<List<Bike>> getBikesByLocationId(String locationId);
}
