part of 'create_hotel_bloc.dart';

sealed class CreateHotelState extends Equatable {
  const CreateHotelState();
  
  @override
  List<Object> get props => [];
}

final class CreateHotelInitial extends CreateHotelState {}

final class CreateHotelFailure extends CreateHotelState {}
final class CreateHotelLoading extends CreateHotelState {}
final class CreateHotelSuccess extends CreateHotelState {}
