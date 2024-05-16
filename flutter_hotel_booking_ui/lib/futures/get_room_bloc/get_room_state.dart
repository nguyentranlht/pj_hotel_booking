part of 'get_room_bloc.dart';

sealed class GetRoomState extends Equatable {
  const GetRoomState();
  
  @override
  List<Object> get props => [];
}

final class GetRoomInitial extends GetRoomState {}

final class GetRoomFailure extends GetRoomState {}
final class GetRoomLoading extends GetRoomState {}
class RoomLoaded extends GetRoomState {
  final List<Room> rooms;

  RoomLoaded(this.rooms);

  @override
  List<Object> get props => [rooms];
}

class RoomError extends GetRoomState {
  final String message;

  RoomError(this.message);

  @override
  List<Object> get props => [message];
}