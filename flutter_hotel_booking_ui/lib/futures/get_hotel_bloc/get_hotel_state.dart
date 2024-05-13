part of 'get_hotel_bloc.dart';

sealed class GetHotelState extends Equatable {
  const GetHotelState();
  
  @override
  List<Object> get props => [];
}

final class GetHotelInitial extends GetHotelState {}

final class GetHotelFailure extends GetHotelState {}
final class GetHotelLoading extends GetHotelState {}
final class GetHotelSuccess extends GetHotelState {
	final List<Hotel> hotels;

	const GetHotelSuccess(this.hotels);
}