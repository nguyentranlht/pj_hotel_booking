import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hotel_repository/hotel_repository.dart';

part 'get_hotel_event.dart';
part 'get_hotel_state.dart';

class GetHotelBloc extends Bloc<GetHotelEvent, GetHotelState> {
  HotelRepo _hotelRepository;

  GetHotelBloc({
		required HotelRepo hotelRepository
	}) : _hotelRepository = hotelRepository,
		super(GetHotelInitial()) {
    on<GetHotels>((event, emit) async {
			emit(GetHotelLoading());
      try {
				List<Hotel> posts = await _hotelRepository.getHotels();
        emit(GetHotelSuccess(posts));
      } catch (e) {
        emit(GetHotelFailure());
      }
    });
  }
}
