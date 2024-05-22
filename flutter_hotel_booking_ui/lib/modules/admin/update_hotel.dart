import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hotel_booking_ui/futures/update_hotel_controller.dart';
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
  DatabaseReference ref = FirebaseDatabase.instance.ref().child('hotels');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppTheme.scaffoldBackgroundColor,
        appBar: AppBar(
          leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back_ios_new_outlined,
                color: Color(0xFF373866),
              )),
          centerTitle: true,
          title: Text(
            'Update Hotel',
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
                      SizedBox(
                        height: 30.0,
                      ),
                      GestureDetector(
                        onTap: () {
                          provider.showHotelNameDialogAlert(context,
                              widget.hotel.titleTxt, widget.hotel.hotelId);
                        },
                        child: ReusbaleRow(
                            title: 'Hotel Name',
                            iconData: Icons.edit,
                            value: widget.hotel.titleTxt),
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
