import 'package:cloud_firestore/cloud_firestore.dart';
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
  Timestamp date;
  DateText dateTxt;
  RoomData roomData;
  double dist;
  double rating;
  int reviews;
  int perNight;
  bool isSelected;
  // PeopleSleeps peopleSleeps;
  

  Hotel({
    required this.hotelId,
    required this.imagePath,
    required this.titleTxt,
    required this.subTxt,
    required this.date,
    required this.dateTxt,
    required this.roomData,
    required this.dist,
    required this.rating,
    required this.reviews,
    required this.perNight,
    required this.isSelected,
    // required this.peopleSleeps,
    
  });

   static var empty = Hotel(
		hotelId: const Uuid().v1(),
    imagePath: '',
    titleTxt: '',
    subTxt: '',
    date: Timestamp.now(),
    dateTxt: DateText.empty,
    roomData: RoomData.empty,
    // peopleSleeps: PeopleSleeps.empty,
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
      roomData: roomData,
      dist: dist,
      rating: rating,
      reviews: reviews,
      perNight: perNight,
      isSelected: isSelected,
      // peopleSleeps: peopleSleeps,
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
      roomData: entity.roomData,
      dist: entity.dist,
      rating: entity.rating,
      reviews: entity.reviews,
      perNight: entity.perNight,
      isSelected: entity.isSelected,
      // peopleSleeps: entity.peopleSleeps,
    );
  }

    
    // peopleSleeps: $peopleSleeps,
  @override
  String toString() {
    return '''
    hotelId: $hotelId,
    imagePath: $imagePath,
    titleTxt: $titleTxt,
    subTxt: $subTxt,
    date: $date,
    dist: $dist,
    rating: $rating,
    reviews: $reviews,
    perNight: $perNight,
    isSelected: $isSelected,
    dateTxt: $dateTxt,
    roomData: $roomData,
    ''';
  }
}
