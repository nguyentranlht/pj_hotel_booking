part of 'create_room_bloc.dart';

sealed class CreateRoomState extends Equatable {
  const CreateRoomState();
  
  @override
  List<Object> get props => [];
}

final class CreateRoomInitial extends CreateRoomState {}

final class CreateRoomFailure extends CreateRoomState {}
final class CreateRoomLoading extends CreateRoomState {}
final class CreateRoomSuccess extends CreateRoomState {}
