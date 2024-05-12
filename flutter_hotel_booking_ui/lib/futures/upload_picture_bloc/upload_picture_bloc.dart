import 'dart:html' as html;
import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hotel_repository/hotel_repository.dart';

part 'upload_picture_event.dart';
part 'upload_picture_state.dart';

class UploadPictureBloc extends Bloc<UploadPictureEvent, UploadPictureState> {
  HotelRepo hotelRepo;

  UploadPictureBloc(this.hotelRepo) : super(UploadPictureLoading()) {
    on<UploadPicture>((event, emit) async {
      try {
        String url = await hotelRepo.sendImage(event.file, event.name);
        emit(UploadPictureSuccess(url));
      } catch (e) {
        emit(UploadPictureFailure());
      }
    });
  }
}