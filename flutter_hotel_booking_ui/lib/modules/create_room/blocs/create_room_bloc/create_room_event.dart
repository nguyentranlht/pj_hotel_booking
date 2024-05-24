part of 'create_room_bloc.dart';

sealed class CreateRoomEvent extends Equatable {
  const CreateRoomEvent();

  @override
  List<Object> get props => [];
}

class CreateRoom extends CreateRoomEvent {
  final Room room;

  const CreateRoom(this.room);

  @override
  List<Object> get props => [room];
}