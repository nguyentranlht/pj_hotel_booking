import 'dart:io';

import 'package:bike_repository/bike_repository.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ui/futures/update_hotel_controller.dart';
import 'package:flutter_hotel_booking_ui/routes/route_names.dart';
import 'package:flutter_hotel_booking_ui/utils/themes.dart';
import 'package:location_repository/location_repository.dart';
import 'package:provider/provider.dart';

class UpdateLocationForm extends StatefulWidget {
  final Location location;
  final Bike bike;
  const UpdateLocationForm(
      {Key? key, required this.location, required this.bike})
      : super(key: key);

  @override
  _UpdateLocationFormState createState() => _UpdateLocationFormState();
}

class _UpdateLocationFormState extends State<UpdateLocationForm> {
  DatabaseReference ref = FirebaseDatabase.instance.ref().child('locations');
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
              child: const Icon(
                Icons.arrow_back_ios_new_outlined,
                color: Color(0xFF373866),
              )),
          centerTitle: true,
          title: const Text(
            'Cập Nhật Địa Điểm',
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
                          provider.pickeImage(
                              context, widget.location.locationId);
                        },
                        child: Center(
                            child: provider.image == null
                                ? widget.location.locationImage != ''
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
                                                image: NetworkImage(widget
                                                    .location.locationImage),
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
                        onTap: () {
                          provider.showHotelNameDialogAlert(
                              context,
                              widget.location.locationName,
                              widget.location.locationId);
                        },
                        child: ReusbaleRow(
                            title: 'Tên Địa Điểm',
                            iconData: Icons.edit,
                            value: widget.location.locationName),
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      GestureDetector(
                        onTap: () {
                          provider.showHotelAddressDialogAlert(
                              context,
                              widget.location.locationSub,
                              widget.location.locationId);
                        },
                        child: ReusbaleRow(
                            title: 'Địa chỉ',
                            iconData: Icons.edit,
                            value: widget.location.locationSub),
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
                                  .gotoCreateMotorcycleScreen(
                                      widget.location.locationId);
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
                                'Thêm Xe',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
                            )),
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
