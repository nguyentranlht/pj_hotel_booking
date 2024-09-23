part of 'get_location_bloc.dart';

sealed class GetLocationState extends Equatable {
  const GetLocationState();
  
  @override
  List<Object> get props => [];
}

final class GetLocationInitial extends GetLocationState {}
