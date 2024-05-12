import 'package:flutter/material.dart';
import 'package:hotel_repository/hotel_repository.dart';
import 'package:hotel_repository/src/entities/room_entity.dart';
import 'package:hotel_repository/src/entities/peoplesleeps_entity.dart';
import '../models/models.dart';

class HotelEntity {
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

  HotelEntity({
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

  Map<String, Object?> toDocument() {
    return {
      'hotelId': hotelId,
      'imagePath': imagePath,
      'titleTxt': titleTxt,
      'subTxt': subTxt,
      'date': date,
      'dateTxt': dateTxt,
      'roomSizeTxt': roomSizeTxt,
      'room': room.toEntity().toDocument(),
      'dist': dist,
      'rating': rating,
      'reviews': reviews,
      'perNight': perNight,
      'isSelected': isSelected,
      'peopleSleeps': peopleSleeps.toEntity().toDocument(),
    };
  }

  static HotelEntity fromDocument(Map<String, dynamic> doc) {
    return HotelEntity(
      hotelId: doc['hotelId'],
      imagePath: doc['imagePath'],
      titleTxt: doc['titleTxt'],
      subTxt: doc['subTxt'],
      date: doc['date'],
      dateTxt: doc['dateTxt'],
      roomSizeTxt: doc['roomSizeTxt'],
      room: Room.fromEntity(RoomEntity.fromDocument(doc['room'])),
      dist: doc['dist'],
      rating: doc['rating'],
      reviews: doc['reviews'],
      perNight: doc['perNight'],
      isSelected: doc['isSelected'],
      peopleSleeps: PeopleSleeps.fromEntity(PeopleSleepsEntity.fromDocument(doc['peopleSleeps'])),
      
    );
  }
}
