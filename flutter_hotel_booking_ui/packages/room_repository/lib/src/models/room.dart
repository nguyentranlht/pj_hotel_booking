import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../entities/entities.dart';
import 'models.dart';

class Room {
  String roomId;
  String imagePath;
  String titleTxt;
  String hotelId;
  Timestamp date;
  String dataTxt;
  RoomData roomData;
  int perNight;
  bool isSelected;
  // PeopleSleeps peopleSleeps;

  Room({
    required this.roomId,
    required this.imagePath,
    required this.titleTxt,
    required this.hotelId,
    required this.date,
    required this.dataTxt,
    required this.roomData,
    required this.perNight,
    required this.isSelected,
    // required this.peopleSleeps,
  });

  static var empty = Room(
      roomId: const Uuid().v1(),
      imagePath: '',
      titleTxt: '',
      hotelId: '',
      date: Timestamp.now(),
      dataTxt: '',
      roomData: RoomData.empty,
      // peopleSleeps: PeopleSleeps.empty,
      perNight: 0,
      isSelected: false);

  RoomEntity toEntity() {
    return RoomEntity(
      roomId: roomId,
      imagePath: imagePath,
      titleTxt: titleTxt,
      hotelId: hotelId,
      date: date,
      dataTxt: dataTxt,
      roomData: roomData,
      perNight: perNight,
      isSelected: isSelected,
      // peopleSleeps: peopleSleeps,
    );
  }

  static Room fromEntity(RoomEntity entity) {
    return Room(
      roomId: entity.roomId,
      imagePath: entity.imagePath,
      titleTxt: entity.titleTxt,
      hotelId: entity.hotelId,
      date: entity.date,
      dataTxt: entity.dataTxt,
      roomData: entity.roomData,
      perNight: entity.perNight,
      isSelected: entity.isSelected,
      // peopleSleeps: entity.peopleSleeps,
    );
  }

  // peopleSleeps: $peopleSleeps,
   
  @override
  String toString() {
    return '''
    roomId: $roomId,
    imagePath: $imagePath,
    titleTxt: $titleTxt,
    hotelId: $hotelId,
    date: $date,
    perNight: $perNight,
    isSelected: $isSelected,
    dataTxt: $dataTxt,
    roomData: $roomData,
    ''';
  }
}
