import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hotel_repository/hotel_repository.dart';

part 'get_hotel_event.dart';
part 'get_hotel_state.dart';

class GetHotelBloc extends Bloc<GetHotelevent, GetHotelState> {
  final HotelRepo _hotelRepo;

  GetHotelBloc(this._hotelRepo) : super(GetHotelInitial()) {
    on<GetHotel>((event, emit) async {
      emit(GetHotelLoading());
      try {
        List<Hotel> hotels = await _hotelRepo.getHotels();
        emit(GetHotelSuccess(hotels));
      } catch (e) {
        emit(GetHotelFailure());
      }
    });
  }
}