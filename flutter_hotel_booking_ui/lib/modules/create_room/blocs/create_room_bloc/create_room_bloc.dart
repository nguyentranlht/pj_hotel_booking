import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hotel_repository/hotel_repository.dart';
import 'package:room_repository/room_repository.dart';

part 'create_room_event.dart';
part 'create_room_state.dart';

class CreateRoomBloc extends Bloc<CreateRoomEvent, CreateRoomState> {
  RoomRepo roomRepo;

  CreateRoomBloc(this.roomRepo) : super(CreateRoomInitial()) {
    on<CreateRoom>((event, emit) async {
      emit(CreateRoomLoading());
      try {
        await roomRepo.createRooms(event.room);
        emit(CreateRoomSuccess());
      } catch (e) {
        emit(CreateRoomFailure());
      }
    });
  }
}
