import 'package:equatable/equatable.dart';

sealed class CreateMotorcycleDartState extends Equatable {
  const CreateMotorcycleDartState();
  
  @override
  List<Object> get props => [];
}

final class CreateMotorcycleDartInitial extends CreateMotorcycleDartState {}
final class CreateMotorcycleDartFailure extends CreateMotorcycleDartState {}
final class CreateMotorcycleDartLoading extends CreateMotorcycleDartState {}
final class CreateMotorcycleDartSuccess extends CreateMotorcycleDartState {}

