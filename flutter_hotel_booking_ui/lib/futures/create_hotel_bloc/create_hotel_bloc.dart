import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hotel_repository/hotel_repository.dart';

part 'create_hotel_event.dart';
part 'create_hotel_state.dart';

class CreateHotelBloc extends Bloc<CreateHotelEvent, CreateHotelState> {
  HotelRepo hotelRepo;

  CreateHotelBloc(this.hotelRepo) : super(CreateHotelInitial()) {
    on<CreateHotel>((event, emit) async {
      emit(CreateHotelLoading());
      try {
        await hotelRepo.createHotels(event.hotel);
        emit(CreateHotelSuccess());
      } catch (e) {
        emit(CreateHotelFailure());
      }
    });
  }
}
