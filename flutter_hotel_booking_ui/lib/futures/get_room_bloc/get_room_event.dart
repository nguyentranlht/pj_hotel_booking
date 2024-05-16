part of 'get_room_bloc.dart';

sealed class GetRoomEvent extends Equatable {
  const GetRoomEvent();

  @override
  List<Object> get props => [];
}

class GetRooms extends GetRoomEvent {}

class FetchRoomsByHotelId extends GetRoomEvent {
  final String hotelId;

  FetchRoomsByHotelId(this.hotelId);

  @override
  List<Object> get props => [hotelId];
}
