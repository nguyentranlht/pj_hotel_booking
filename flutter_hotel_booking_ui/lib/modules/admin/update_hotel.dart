import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hotel_booking_ui/futures/update_hotel_controller.dart';
import 'package:flutter_hotel_booking_ui/modules/create_room/views/create_room_screen.dart';
import 'package:flutter_hotel_booking_ui/routes/route_names.dart';
import 'package:flutter_hotel_booking_ui/utils/themes.dart';
import 'package:hotel_repository/hotel_repository.dart';
import 'package:provider/provider.dart';

class UpdateHotelForm extends StatefulWidget {
  final Hotel hotel;

  const UpdateHotelForm({Key? key, required this.hotel}) : super(key: key);

  @override
  _UpdateHotelFormState createState() => _UpdateHotelFormState();
}

class _UpdateHotelFormState extends State<UpdateHotelForm> {
  String? luuTen, diachi, titleTxt, subTxt;
  Timestamp? date;
  int? reviews, perNight, startDate, endDate, numberRoom, people;
  bool? isSelected;

  DatabaseReference ref = FirebaseDatabase.instance.ref().child('hotels');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppTheme.scaffoldBackgroundColor,
        appBar: AppBar(
          leading: GestureDetector(
              onTap: () {
                NavigationServices(context).gotoBaseScreen();
              },
              child: const Icon(
                Icons.arrow_back_ios_new_outlined,
                color: Color(0xFF373866),
              )),
          centerTitle: true,
          title: const Text(
            'Cập Nhật Khách Sạn',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
        ),
        body: ChangeNotifierProvider(
          create: (_) => UpdateHotelController(),
          child: Consumer<UpdateHotelController>(
            builder: (context, provider, child) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  child: ListView(
                    children: [
                      const SizedBox(height: 20),
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () async {
                          provider.pickeImage(context, widget.hotel.hotelId);
                        },
                        child: Center(
                            child: provider.image == null
                                ? widget.hotel.imagePath != ''
                                    ? Container(
                                        width: 150,
                                        height: 150,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.black,
                                                width: 1.5),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            image: DecorationImage(
                                                image: NetworkImage(
                                                    widget.hotel.imagePath),
                                                fit: BoxFit.cover)))
                                    : Container(
                                        width: 150,
                                        height: 150,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black, width: 1.5),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: const Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.camera_alt_outlined,
                                              color: Colors.black,
                                            ),
                                          ],
                                        ),
                                      )
                                : Container(
                                    width: 150,
                                    height: 150,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.black, width: 1.5),
                                        borderRadius: BorderRadius.circular(20),
                                        image: DecorationImage(
                                            image: FileImage(
                                                File(provider.image!.path)
                                                    .absolute),
                                            fit: BoxFit.cover)))),
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      GestureDetector(
                        onTap: () async {
                          String? newValue =
                              await provider.showHotelNameDialogAlert(
                            context,
                            widget.hotel.titleTxt,
                            widget.hotel.hotelId,
                          );

                          if (newValue != null &&
                              newValue.isNotEmpty &&
                              newValue != widget.hotel.titleTxt) {
                            // Cập nhật giá trị mới nếu nó khác giá trị cũ
                            setState(() {
                              widget.hotel.titleTxt = newValue;
                            });
                          }
                        },
                        child: ReusbaleRow(
                          title: 'Tên khách sạn',
                          iconData: Icons.edit,
                          value: widget.hotel.titleTxt,
                        ),
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      GestureDetector(
                        onTap: () async {
                          String? newValue =
                              await provider.showHotelAddressDialogAlert(
                            context,
                            widget.hotel.subTxt,
                            widget.hotel.hotelId,
                          );

                          if (newValue != null &&
                              newValue.isNotEmpty &&
                              newValue != widget.hotel.subTxt) {
                            // Cập nhật giá trị mới nếu nó khác giá trị cũ
                            setState(() {
                              widget.hotel.subTxt = newValue;
                            });
                          }
                        },
                        child: ReusbaleRow(
                          title: 'Địa chỉ',
                          iconData: Icons.edit,
                          value: widget.hotel.subTxt,
                        ),
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      GestureDetector(
                        onTap: () async {
                          int? newPrice =
                              await provider.showHotelPriceDialogAlert(
                            context,
                            widget.hotel.perNight,
                            widget.hotel.hotelId,
                          );

                          if (newPrice != null &&
                              newPrice != widget.hotel.perNight) {
                            setState(() {
                              widget.hotel.perNight = newPrice;
                            });
                          }
                        },
                        child: ReusbaleRow(
                          title: 'Giá',
                          iconData: Icons.edit,
                          value: widget.hotel.perNight.toString(),
                        ),
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      GestureDetector(
                        onTap: () async {
                          double? newDist =
                              await provider.showHotelDistDialogAlert(
                            context,
                            widget.hotel.dist,
                            widget.hotel.hotelId,
                          );

                          if (newDist != null && newDist != widget.hotel.dist) {
                            setState(() {
                              widget.hotel.dist = newDist;
                            });
                          }
                        },
                        child: ReusbaleRow(
                          title: 'Khoảng cách tới thành phố',
                          iconData: Icons.edit,
                          value: widget.hotel.dist.toString(),
                        ),
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      GestureDetector(
                        onTap: () async {
                          double? newRating =
                              await provider.showHotelDistDialogAlert(context,
                                  widget.hotel.rating, widget.hotel.hotelId);

                          if (newRating != null &&
                              newRating != widget.hotel.dist) {
                            setState(() {
                              widget.hotel.rating = newRating;
                            });
                          }
                        },
                        child: ReusbaleRow(
                            title: 'Xếp hạng',
                            iconData: Icons.edit,
                            value: widget.hotel.rating.toString()),
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      GestureDetector(
                        onTap: () async {
                          int? newReviews =
                              await provider.showHotelReviewsDialogAlert(
                                  context,
                                  widget.hotel.reviews,
                                  widget.hotel.hotelId);
                          if (newReviews != null &&
                              newReviews != widget.hotel.dist) {
                            setState(() {
                              widget.hotel.reviews = newReviews;
                            });
                          }
                        },
                        child: ReusbaleRow(
                            title: 'Đánh giá',
                            iconData: Icons.edit,
                            value: widget.hotel.reviews.toString()),
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      GestureDetector(
                        onTap: () async {
                          int? newNumberRoom =
                              await provider.showHotelNumberRoomDialogAlert(
                                  context,
                                  widget.hotel.roomData.numberRoom,
                                  widget.hotel.hotelId);
                          if (newNumberRoom != null &&
                              newNumberRoom != widget.hotel.dist) {
                            setState(() {
                              widget.hotel.roomData.numberRoom = newNumberRoom;
                            });
                          }
                        },
                        child: ReusbaleRow(
                            title: 'Số phòng',
                            iconData: Icons.edit,
                            value: widget.hotel.roomData.numberRoom.toString()),
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      GestureDetector(
                        onTap: () async {
                          int? newRoomPeople =
                              await provider.showHotelPeopleDialogAlert(
                                  context,
                                  widget.hotel.roomData.people,
                                  widget.hotel.hotelId);
                          if (newRoomPeople != null &&
                              newRoomPeople != widget.hotel.dist) {
                            setState(() {
                              widget.hotel.roomData.people = newRoomPeople;
                            });
                          }
                        },
                        child: ReusbaleRow(
                            title: 'Số người',
                            iconData: Icons.edit,
                            value: widget.hotel.roomData.people.toString()),
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      SizedBox(
                        width: 400,
                        height: 50,
                        child: TextButton(
                            onPressed: () {
                              NavigationServices(context)
                                  .gotoCreateRoomScreen(widget.hotel.hotelId);
                            },
                            style: TextButton.styleFrom(
                                elevation: 3.0,
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(60))),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 25, vertical: 5),
                              child: Text(
                                'Tạo phòng',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
                            )),
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      SizedBox(
                        width: 400,
                        height: 50,
                        child: TextButton(
                            onPressed: () {
                              NavigationServices(context).gotoRoomHotelScreen(
                                  widget.hotel.titleTxt, widget.hotel.hotelId);
                            },
                            style: TextButton.styleFrom(
                                elevation: 3.0,
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(60))),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 25, vertical: 5),
                              child: Text(
                                'Phòng của khách sạn',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
                            )),
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      SizedBox(
                        width: 400,
                        height: 50,
                        child: TextButton(
                            onPressed: () {
                              provider.showDeleteHotelDialogAlert(
                                  context, widget.hotel.hotelId);
                            },
                            style: TextButton.styleFrom(
                                elevation: 3.0,
                                backgroundColor:
                                    Theme.of(context).colorScheme.error,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(60))),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 25, vertical: 5),
                              child: Text(
                                'Xoá',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
                            )),
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ));
  }
}

class ReusbaleRow extends StatelessWidget {
  final String title, value;
  final IconData iconData;
  const ReusbaleRow(
      {Key? key,
      required this.title,
      required this.iconData,
      required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          leading: Icon(iconData),
          trailing: Text(value),
        ),
        Divider(
          color: AppTheme.fontcolor,
        )
      ],
    );
  }
}
