part of 'get_hotel_bloc.dart';

sealed class GetHotelEvent extends Equatable {
  const GetHotelEvent();

  @override
  List<Object> get props => [];
}

class GetHotel extends GetHotelEvent{}