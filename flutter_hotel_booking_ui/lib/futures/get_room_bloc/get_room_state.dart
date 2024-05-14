part of 'get_room_bloc.dart';

sealed class GetRoomState extends Equatable {
  const GetRoomState();
  
  @override
  List<Object> get props => [];
}

final class GetRoomInitial extends GetRoomState {}

final class GetRoomFailure extends GetRoomState {}
final class GetRoomLoading extends GetRoomState {}
final class GetRoomSuccess extends GetRoomState {
	final List<Room> rooms;

	const GetRoomSuccess(this.rooms);
}