import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hotel_booking_ui/models/room_data.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Hotel {
  final String imagePath;
  final String titleTxt;
  final String subTxt;
  final DateTime? date;
  final String dateTxt;
  final String roomSizeTxt;
  final RoomData? roomData;
  final double dist;
  final double rating;
  final int reviews;
  final int perNight;
  final bool isSelected;
  final PeopleSleeps? peopleSleeps;
  final LatLng? location;
  final Offset? screenMapPin;

  Hotel({
    required this.imagePath,
    required this.titleTxt,
    required this.subTxt,
    required this.date,
    required this.dateTxt,
    required this.roomSizeTxt,
    required this.roomData,
    required this.dist,
    required this.rating,
    required this.reviews,
    required this.perNight,
    required this.isSelected,
    required this.peopleSleeps,
    required this.location,
    required this.screenMapPin,
  });

  factory Hotel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    return Hotel(
      imagePath: data?["imagePath"],
      titleTxt: data?["titleTxt"],
      subTxt: data?["subTxt"],
      date: data?["date"],
      dateTxt: data?["dateTxt"],
      roomSizeTxt: data?["roomSizeTxt"],
      roomData: data?["roomData"],
      dist: data?["dist"],
      rating: data?["rating"],
      reviews: data?["reviews"],
      perNight: data?["perNight"],
      isSelected: data?["isSelected"],
      peopleSleeps: data?["peopleSleeps"],
      location: data?["location"],
      screenMapPin: data?["screenMapPin"],
    );
  }

  // Empty hotel which represents an uninitialized hotel.
  static final empty = Hotel(
    imagePath: '',
    titleTxt: '',
    subTxt: '',
    date: null,
    dateTxt: '',
    roomSizeTxt: '',
    roomData: null,
    dist: 0.0,
    rating: 0.0,
    reviews: 0,
    perNight: 0,
    isSelected: false,
    peopleSleeps: null,
    location: null,
    screenMapPin: null,
  );

  /// Convenience getter to determine whether the current hotel is empty.
  bool get isEmpty => this == Hotel.empty;

  /// Convenience getter to determine whether the current hotel is not empty.
  bool get isNotEmpty => this != Hotel.empty;

  Map<String, Object?> toDocument() {
    return {
      'imagePath': imagePath,
      'titleTxt': titleTxt,
      'subTxt': subTxt,
      'date': date,
      'dateTxt': dateTxt,
      'roomSizeTxt': roomSizeTxt,
      'roomData': roomData,
      'dist': dist,
      'rating': rating,
      'reviews': reviews,
      'perNight': perNight,
      'isSelected': isSelected,
      'peopleSleeps': peopleSleeps,
      'location': location,
      'screenMapPin': screenMapPin,
    };
  }

  @override
  List<Object?> get props => [
        imagePath,
        titleTxt,
        subTxt,
        date,
        dateTxt,
        roomSizeTxt,
        roomData,
        dist,
        rating,
        reviews,
        perNight,
        isSelected,
        peopleSleeps,
        location,
        screenMapPin,
      ];

  @override
  String toString() {
    return '''Hotel: {
      imagePath: $imagePath,
      titleTxt: $titleTxt,
      subTxt: $subTxt,
      date: $date,
      dateTxt: $dateTxt,
      roomSizeTxt: $roomSizeTxt,
      roomData: $roomData,
      dist: $dist,
      rating: $rating,
      reviews: $reviews,
      perNight: $perNight,
      isSelected: $isSelected,
      peopleSleeps: $peopleSleeps,
      location: $location,
      screenMapPin: $screenMapPin,
    }''';
  }
}
