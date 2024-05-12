import 'package:flutter/material.dart';
import 'package:hotel_repository/src/entities/room_entity.dart';
import 'package:uuid/uuid.dart';
import '../entities/entities.dart';
import 'models.dart';

class Hotel {
  String hotelId;
  String imagePath;
  String titleTxt;
  String subTxt;
  DateTime date;
  String? dateTxt;
  String? roomSizeTxt;
  Room room;
  double dist;
  double rating;
  int reviews;
  int perNight;
  bool isSelected;
  PeopleSleeps peopleSleeps;
  

  Hotel({
    required this.hotelId,
    required this.imagePath,
    required this.titleTxt,
    required this.subTxt,
    required this.date,
    this.dateTxt,
    this.roomSizeTxt,
    required this.room,
    required this.dist,
    required this.rating,
    required this.reviews,
    required this.perNight,
    required this.isSelected,
    required this.peopleSleeps,
    
  });

   static var empty = Hotel(
		hotelId: const Uuid().v1(),
    imagePath: '',
    titleTxt: '',
    subTxt: '',
    date: DateTime.now(),
    dateTxt: '',
    room: Room.empty,
    peopleSleeps: PeopleSleeps.empty,
    roomSizeTxt: '',
    perNight: 0,
    reviews: 0,
    dist: 0,
    rating: 0,
    isSelected: false
	);

  HotelEntity toEntity() {
    return HotelEntity(
      hotelId: hotelId,
      imagePath: imagePath,
      titleTxt: titleTxt,
      subTxt: subTxt,
      date: date,
      dateTxt: dateTxt,
      roomSizeTxt: roomSizeTxt,
      room: room,
      dist: dist,
      rating: rating,
      reviews: reviews,
      perNight: perNight,
      isSelected: isSelected,
      peopleSleeps: peopleSleeps,
    );
  }

  static Hotel fromEntity(HotelEntity entity) {
    return Hotel(
      hotelId: entity.hotelId,
      imagePath: entity.imagePath,
      titleTxt: entity.titleTxt,
      subTxt: entity.subTxt,
      date: entity.date,
      dateTxt: entity.dateTxt,
      roomSizeTxt: entity.roomSizeTxt,
      room: entity.room,
      dist: entity.dist,
      rating: entity.rating,
      reviews: entity.reviews,
      perNight: entity.perNight,
      isSelected: entity.isSelected,
      peopleSleeps: entity.peopleSleeps,
    );
  }

  @override
  String toString() {
    return '''
    hotelId: $hotelId,
    imagePath: $imagePath,
    titleTxt: $titleTxt,
    subTxt: $subTxt,
    date: $date,
    dateTxt: $dateTxt,
    roomSizeTxt: $roomSizeTxt,
    room: $room,
    dist: $dist,
    rating: $rating,
    reviews: $reviews,
    perNight: $perNight,
    isSelected: $isSelected,
    peopleSleeps: $peopleSleeps,
    ''';
  }
}
