import 'package:hotel_repository/hotel_repository.dart';
import 'package:hotel_repository/src/entities/room_entity.dart';
import '../models/models.dart';

class HotelEntity {
  String hotelId;
  String imagePath;
  String titleTxt;
  String subTxt;
  DateTime? date;
  String dateTxt;
  String roomSizeTxt;
  double dist;
  double rating;
  int reviews;
  int perNight;
  bool isSelected;
  // PeopleSleeps? peopleSleeps;
  // LatLng? location;
  // Offset? screenMapPin;
  // RoomEntity roomEntity;

  HotelEntity({
    required this.hotelId,
    required this.imagePath,
    required this.titleTxt,
    required this.subTxt,
    this.date,
    required this.dateTxt,
    required this.roomSizeTxt,
    // this.roomData,
    required this.dist,
    required this.rating,
    required this.reviews,
    required this.perNight,
    required this.isSelected,
    // this.peopleSleeps,
    // this.location,
    // this.screenMapPin,
    // required this.roomEntity,
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
      // 'roomData': roomData?.toEntity().toDocument(),
      'dist': dist,
      'rating': rating,
      'reviews': reviews,
      'perNight': perNight,
      'isSelected': isSelected,
      // 'peopleSleeps': peopleSleeps?.toDocument(),
      // 'location': location?.toJson(),
      // 'screenMapPin': screenMapPin?.toJson(),
      // 'roomEntity': roomEntity.toEntity().toDocument(),
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
      // roomData: RoomData.fromEntity(RoomDataEntity.fromDocument(doc['roomData'])),
      dist: doc['dist'],
      rating: doc['rating'],
      reviews: doc['reviews'],
      perNight: doc['perNight'],
      isSelected: doc['isSelected'],
      // peopleSleeps: PeopleSleeps.fromDocument(doc['peopleSleeps']),
      // location: LatLng.fromJson(doc['location']),
      // screenMapPin: Offset.fromJson(doc['screenMapPin']),
      
    );
  }
}
