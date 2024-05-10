// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_hotel_booking_ui/models/hotel.dart';

// class HotelService {
//   final CollectionReference _hotelsCollection =
//       FirebaseFirestore.instance.collection('hotels');

//   Future<void> addHotel(Hotel hotel) async {
//     await _hotelsCollection.add(hotel.toDocument());
//   }

//   Future<void> updateHotel(String hotelId, Hotel newHotel) async {
//     await _hotelsCollection.doc(hotelId).update(newHotel.toDocument());
//   }

//   Future<void> deleteHotel(String hotelId) async {
//     await _hotelsCollection.doc(hotelId).delete();
//   }

//   Stream<List<Hotel>> getHotelsStream() {
//     return _hotelsCollection.snapshots().map((snapshot) =>
//         snapshot.docs.map((doc) => Hotel.fromSnapshot(doc)).toList());
//   }
// }
