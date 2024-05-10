part of 'create_hotel_bloc.dart';

sealed class CreateHotelEvent extends Equatable {
  const CreateHotelEvent();

  @override
  List<Object> get props => [];
}

class CreateHotel extends CreateHotelEvent {
  final Hotel hotel;

  const CreateHotel(this.hotel);

  @override
  List<Object> get props => [hotel];
}