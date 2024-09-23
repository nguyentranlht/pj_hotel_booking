import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'get_location_event.dart';
part 'get_location_state.dart';

class GetLocationBloc extends Bloc<GetLocationEvent, GetLocationState> {
  GetLocationBloc() : super(GetLocationInitial()) {
    on<GetLocationEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
