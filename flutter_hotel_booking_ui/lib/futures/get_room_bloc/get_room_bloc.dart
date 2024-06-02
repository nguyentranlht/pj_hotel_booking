import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:room_repository/room_repository.dart';

part 'get_room_event.dart';
part 'get_room_state.dart';

class GetRoomBloc extends Bloc<GetRoomEvent, GetRoomState> {
  final RoomRepo _roomRepo;

  GetRoomBloc(this._roomRepo) : super(GetRoomInitial()) {
    on<FetchRoomsByHotelId>((event, emit) async {
      emit(GetRoomLoading());
      try {
        List<Room> rooms = await _roomRepo.getRoomsByHotelId(event.hotelId);
        emit(RoomLoaded(
            rooms)); // You might need to convert RoomEntity to your desired Room model if necessary
      } catch (error) {
        emit(RoomError(error.toString()));
      }
    });
     on<GetRooms>((event, emit) async {
      emit(GetRoomLoading());
      try {
        List<Room> rooms = await _roomRepo.getRooms();
        emit(RoomLoaded(rooms));
      } catch (e) {
        emit(GetRoomFailure());
      }
    });
  }
}
