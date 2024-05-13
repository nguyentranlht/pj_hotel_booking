import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hotel_repository/hotel_repository.dart';
import 'package:hotel_repository/src/entities/data_text_entity.dart';
import 'package:hotel_repository/src/entities/room_entity.dart';
import 'package:hotel_repository/src/entities/peoplesleeps_entity.dart';
import '../models/models.dart';

class HotelEntity {
  String hotelId;
  String imagePath;
  String titleTxt;
  String subTxt;
  Timestamp date;
  // DateText dateTxt;
  // RoomData roomData;
  double dist;
  double rating;
  int reviews;
  int perNight;
  bool isSelected;
  // PeopleSleeps peopleSleeps;

  HotelEntity({
    required this.hotelId,
    required this.imagePath,
    required this.titleTxt,
    required this.subTxt,
    required this.date,
    // required this.dateTxt,
    // required this.roomData,
    required this.dist,
    required this.rating,
    required this.reviews,
    required this.perNight,
    required this.isSelected,
    // required this.peopleSleeps,
  });

  Map<String, Object?> toDocument() {
    return {
      'hotelId': hotelId,
      'imagePath': imagePath,
      'titleTxt': titleTxt,
      'subTxt': subTxt,
      'date': date,
      // 'dateTxt': dateTxt.toEntity().toDocument(),
      // 'roomData': roomData.toEntity().toDocument(),
      'dist': dist,
      'rating': rating,
      'reviews': reviews,
      'perNight': perNight,
      'isSelected': isSelected,
      // 'peopleSleeps': peopleSleeps.toEntity().toDocument(),
    };
  }

  static HotelEntity fromDocument(Map<String, dynamic> doc) {
    return HotelEntity(
      hotelId: doc['hotelId'],
      imagePath: doc['imagePath'],
      titleTxt: doc['titleTxt'],
      subTxt: doc['subTxt'],
      date: doc['date'],
      // dateTxt:
      //     DateText.fromEntity(DateTextEntity.fromDocument(doc['dateText'])),
      // roomData:
      //     RoomData.fromEntity(RoomDataEntity.fromDocument(doc['roomData'])),
      dist: doc['dist'],
      rating: doc['rating'],
      reviews: doc['reviews'],
      perNight: doc['perNight'],
      isSelected: doc['isSelected'],
      // peopleSleeps: PeopleSleeps.fromEntity(
      //     PeopleSleepsEntity.fromDocument(doc['peopleSleeps'])),
    );
  }
}
