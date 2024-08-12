import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ui/language/appLocalizations.dart';
import 'package:flutter_hotel_booking_ui/models/constants.dart';
import 'package:flutter_hotel_booking_ui/models/hotel_list_data.dart';
import 'package:flutter_hotel_booking_ui/modules/hotel_detailes/hotel_detailes.dart';
import 'package:flutter_hotel_booking_ui/modules/hotel_detailes/room_book_view.dart';
import 'package:flutter_hotel_booking_ui/modules/hotel_detailes/search_type_list.dart';
import 'package:flutter_hotel_booking_ui/modules/hotel_detailes/search_view.dart';
import 'package:flutter_hotel_booking_ui/utils/themes.dart';
import 'package:flutter_hotel_booking_ui/widgets/common_appbar_view.dart';
import 'package:flutter_hotel_booking_ui/widgets/common_card.dart';
import 'package:flutter_hotel_booking_ui/widgets/common_search_bar.dart';
import 'package:flutter_hotel_booking_ui/widgets/remove_focuse.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hotel_repository/hotel_repository.dart';
import 'room_booking_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}


class _SearchScreenState extends State<SearchScreen> {
  
  late AnimationController animationController;
  Future<QuerySnapshot>? postDocumentLists;
  String hotelNameText = "";

  initSearch(String textEntered){
    String searchText = textEntered.toLowerCase();
    postDocumentLists = FirebaseFirestore.instance
      .collection("hotels")
      .where('titleTxt', isGreaterThanOrEqualTo: textEntered)
      .get();

  setState(() {
    postDocumentLists;
  });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          onChanged: (value) {
            // Khi người dùng nhập vào search bar
            setState(() {
              hotelNameText = value;
            });
            initSearch(value); // Gọi hàm tìm kiếm
          },
          decoration: InputDecoration(
            hintText: 'Tìm kiếm...',
          ),
        ),
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance
          .collection("hotels")
          .orderBy("titleTxt")
          .startAt([hotelNameText])
          .endAt([hotelNameText + "\uf8ff"])
          .get(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return ListView(
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  // Hiển thị kết quả tìm kiếm
                  return ListTile(
                    onTap: () {
                        // Truyền dữ liệu hotelData khi người dùng nhấp vào ListTile
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RoomBookingScreen(
                              hotelName: document['titleTxt'],
                              hotelId: document['hotelId'] ,
                            ),
                          ),
                        );
                      },
                    title: Text(document['titleTxt']),
                    subtitle: Text(document['subTxt']),
                  );
                }).toList(),
              );
            }
          }
        },
      ),
    );
  }
}
