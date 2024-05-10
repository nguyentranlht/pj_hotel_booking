import 'package:hotel_repository/src/entities/room_entity.dart';
import 'package:uuid/uuid.dart';
import '../entities/entities.dart';
import 'models.dart';

class Hotel {
  String hotelId;
  String imagePath;
  String titleTxt;
  String subTxt;
  DateTime? date;
  String dateTxt;
  String roomSizeTxt;
  // RoomData? roomData;
  double dist;
  double rating;
  int reviews;
  int perNight;
  bool isSelected;
  // PeopleSleeps? peopleSleeps;
  // LatLng? location;
  // Offset? screenMapPin;
  // RoomEntity roomEntity;

  Hotel({
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

   static var empty = Hotel(
		hotelId: const Uuid().v1(),
    imagePath: '',
    titleTxt: '',
    subTxt: '',
    dateTxt: '',
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
      // roomData: roomData,
      dist: dist,
      rating: rating,
      reviews: reviews,
      perNight: perNight,
      isSelected: isSelected,
      // peopleSleeps: peopleSleeps,
      // location: location,
      // screenMapPin: screenMapPin,
      // roomEntity: roomEntity,
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
      // roomData: entity.roomData,
      dist: entity.dist,
      rating: entity.rating,
      reviews: entity.reviews,
      perNight: entity.perNight,
      isSelected: entity.isSelected,
      // peopleSleeps: entity.peopleSleeps,
      // location: entity.location,
      // screenMapPin: entity.screenMapPin,
      // roomEntity: entity.roomEntity,
    );
  }
}
