import 'package:bike_repository/bike_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hotel_booking_ui/modules/create_motorcycle/bloc/create_motorcycle_dart_event.dart';
import 'package:flutter_hotel_booking_ui/modules/create_motorcycle/bloc/create_motorcycle_dart_state.dart';

class CreateMotorcycleDartBloc extends Bloc<CreateMotorcycleDartEvent, CreateMotorcycleDartState> {
  final BikeRepo bikeRepo;

  CreateMotorcycleDartBloc(this.bikeRepo) : super(CreateMotorcycleDartInitial()) {
    on<CreateMotorcycleDart>((event, emit) async {
      emit(CreateMotorcycleDartLoading());
      try {
        // Gọi hàm createBikes với locationId và bike
        await bikeRepo.createBikes(event.locationId, event.bike);
        emit(CreateMotorcycleDartSuccess());
      } catch (e) {
        emit(CreateMotorcycleDartFailure());
      }
    });
  }
}
