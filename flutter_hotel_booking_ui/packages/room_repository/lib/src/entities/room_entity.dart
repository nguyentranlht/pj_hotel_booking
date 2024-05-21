import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:room_repository/room_repository.dart';
import 'package:room_repository/src/entities/data_text_entity.dart';
import 'package:room_repository/src/entities/room_data_entity.dart';
import 'package:room_repository/src/entities/peoplesleeps_entity.dart';
import '../models/models.dart';

class RoomEntity {
  String roomId;
  String hotelId;
  String imagePath;
  String titleTxt;
  Timestamp date;
  String dataTxt;
 RoomData roomData;
  int perNight;
  bool isSelected;
  // PeopleSleeps peopleSleeps;

  RoomEntity({
    required this.roomId,
    required this.hotelId,
    required this.imagePath,
    required this.titleTxt,
    required this.date,
    required this.dataTxt,
    required this.roomData,
    required this.perNight,
    required this.isSelected,
    // required this.peopleSleeps,
  });

  Map<String, Object?> toDocument() {
    return {
      'roomId': roomId,
      'hotelId': hotelId,
      'imagePath': imagePath,
      'titleTxt': titleTxt,
      'date': date,
      'dataTxt': dataTxt,
      'roomData': roomData.toEntity().toDocument(),
      'perNight': perNight,
      'isSelected': isSelected,
      // 'peopleSleeps': peopleSleeps.toEntity().toDocument(),
    };
  }

  static RoomEntity fromDocument(Map<String, dynamic> doc) {
    return RoomEntity(
      roomId: doc['roomId'],
      hotelId: doc['hotelId'],
      imagePath: doc['imagePath'],
      titleTxt: doc['titleTxt'],
      date: doc['date'],
      dataTxt: doc['dataTxt'],
      roomData:
          RoomData.fromEntity(RoomDataEntity.fromDocument(doc['roomData'])),
      perNight: doc['perNight'],
      isSelected: doc['isSelected'],
      // peopleSleeps: PeopleSleeps.fromEntity(
      //     PeopleSleepsEntity.fromDocument(doc['peopleSleeps'])),
    );
  }
}
