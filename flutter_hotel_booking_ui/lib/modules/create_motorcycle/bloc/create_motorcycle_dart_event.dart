
import 'package:bike_repository/bike_repository.dart';
import 'package:equatable/equatable.dart';

abstract class CreateMotorcycleDartEvent extends Equatable {
  const CreateMotorcycleDartEvent();

  @override
  List<Object> get props => [];
}

class CreateMotorcycleDart extends CreateMotorcycleDartEvent {
  final String locationId;
  final Bike bike;

  const CreateMotorcycleDart({required this.locationId, required this.bike});

  @override
  List<Object> get props => [locationId, bike];
}
