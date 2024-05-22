import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hotel_booking_ui/futures/update_hotel_controller.dart';
import 'package:flutter_hotel_booking_ui/modules/base/views/base_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_hotel_booking_ui/modules/create_hotel/blocs/create_hotel_bloc/create_hotel_bloc.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:hotel_repository/hotel_repository.dart';
import '../../../routes/route_names.dart';
import '../components/my_text_field.dart';

class CreateHotelScreen extends StatefulWidget {
  const CreateHotelScreen({super.key});

  @override
  State<CreateHotelScreen> createState() => _CreateHotelScreenState();
}

class _CreateHotelScreenState extends State<CreateHotelScreen> {
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final priceController = TextEditingController();
  final distController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ratingController = TextEditingController();
  final reviewsController = TextEditingController();
  final numberRoomController = TextEditingController();
  final peopleController = TextEditingController();
  bool creationRequired = false;
  String? _errorMsg;
  late Hotel hotel;

  @override
  void initState() {
    hotel = Hotel.empty;
    print(hotel.hotelId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateHotelBloc(FirebaseHotelRepo()),
      child: BlocListener<CreateHotelBloc, CreateHotelState>(
        listener: (context, state) {
          if (state is CreateHotelSuccess) {
            setState(() {
              creationRequired = false;
            });
          } else if (state is CreateHotelLoading) {
            setState(() {
              creationRequired = true;
              NavigationServices(context).gotoBaseScreen();
            });
          }
        },
        child: ChangeNotifierProvider(
          create: (_) => UpdateHotelController(),
          child: Consumer<UpdateHotelController>(
            builder: (context, provider, child) {
              return Scaffold(
                backgroundColor: Theme.of(context).colorScheme.background,
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
                    'Create a New Hotel !',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                ),
                body: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () async {
                            provider.pickeImage(context, hotel.hotelId);
                          },
                          child: Center(
                              child: provider.image == null
                                  ? hotel.imagePath != ''
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
                                                      hotel.imagePath),
                                                  fit: BoxFit.cover)))
                                      : Container(
                                          width: 150,
                                          height: 150,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.black,
                                                width: 1.5),
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
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          image: DecorationImage(
                                              image: FileImage(
                                                  File(provider.image!.path)
                                                      .absolute),
                                              fit: BoxFit.cover)))),
                        ),
                        SizedBox(
                          height: 30.0,
                        ),
                        Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                    width: 400,
                                    child: MyTextField(
                                        controller: nameController,
                                        hintText: 'Name',
                                        obscureText: false,
                                        keyboardType: TextInputType.text,
                                        errorMsg: _errorMsg,
                                        validator: (val) {
                                          if (val!.isEmpty) {
                                            return 'Please fill in this field';
                                          }
                                          return null;
                                        })),
                                const SizedBox(height: 10),
                                SizedBox(
                                    width: 400,
                                    child: MyTextField(
                                        controller: addressController,
                                        hintText: 'Address',
                                        obscureText: false,
                                        keyboardType: TextInputType.text,
                                        errorMsg: _errorMsg,
                                        validator: (val) {
                                          if (val!.isEmpty) {
                                            return 'Please fill in this field';
                                          }
                                          return null;
                                        })),
                                const SizedBox(height: 10),
                                SizedBox(
                                    width: 400,
                                    child: MyTextField(
                                        controller: priceController,
                                        hintText: 'Price',
                                        obscureText: false,
                                        keyboardType: TextInputType.text,
                                        errorMsg: _errorMsg,
                                        validator: (val) {
                                          if (val!.isEmpty) {
                                            return 'Please fill in this field';
                                          }
                                          return null;
                                        })),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Text('Is Select :'),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Checkbox(
                                        value: hotel.isSelected,
                                        onChanged: (value) {
                                          setState(() {
                                            hotel.isSelected = value!;
                                          });
                                        })
                                  ],
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                    width: 400,
                                    child: MyTextField(
                                        controller: distController,
                                        hintText: 'Dist',
                                        obscureText: false,
                                        keyboardType: TextInputType.text,
                                        errorMsg: _errorMsg,
                                        validator: (val) {
                                          if (val!.isEmpty) {
                                            return 'Please fill in this field';
                                          }
                                          return null;
                                        })),
                                const SizedBox(height: 10),
                                SizedBox(
                                    width: 400,
                                    child: MyTextField(
                                        controller: ratingController,
                                        hintText: 'Rating',
                                        obscureText: false,
                                        keyboardType: TextInputType.text,
                                        errorMsg: _errorMsg,
                                        validator: (val) {
                                          if (val!.isEmpty) {
                                            return 'Please fill in this field';
                                          }
                                          return null;
                                        })),
                                const SizedBox(height: 10),
                                SizedBox(
                                    width: 400,
                                    child: MyTextField(
                                        controller: reviewsController,
                                        hintText: 'Reviews',
                                        obscureText: false,
                                        keyboardType: TextInputType.text,
                                        errorMsg: _errorMsg,
                                        validator: (val) {
                                          if (val!.isEmpty) {
                                            return 'Please fill in this field';
                                          }
                                          return null;
                                        })),
                                const SizedBox(height: 10),
                                SizedBox(
                                    width: 400,
                                    child: MyTextField(
                                        controller: numberRoomController,
                                        hintText: 'Number Room',
                                        obscureText: false,
                                        keyboardType: TextInputType.text,
                                        errorMsg: _errorMsg,
                                        validator: (val) {
                                          if (val!.isEmpty) {
                                            return 'Please fill in this field';
                                          }
                                          return null;
                                        })),
                                const SizedBox(height: 10),
                                SizedBox(
                                    width: 400,
                                    child: MyTextField(
                                        controller: peopleController,
                                        hintText: 'People',
                                        obscureText: false,
                                        keyboardType: TextInputType.text,
                                        errorMsg: _errorMsg,
                                        validator: (val) {
                                          if (val!.isEmpty) {
                                            return 'Please fill in this field';
                                          }
                                          return null;
                                        })),
                              ],
                            )),
                        const SizedBox(
                          height: 20,
                        ),
                        !creationRequired
                            ? SizedBox(
                                width: 400,
                                height: 50,
                                child: TextButton(
                                    onPressed: () {
                                      firebase_storage.Reference storageRef = firebase_storage
          .FirebaseStorage.instance
          .ref('${hotel.hotelId}_lead');
      firebase_storage.UploadTask uploadTask =
          storageRef.putFile(File(provider.image!.path)
                                                      .absolute);
       Future.value(uploadTask);
                                      if (_formKey.currentState!.validate()) {
                                        setState(() {
                                          hotel.imagePath = 'https://firebasestorage.googleapis.com/v0/b/db-hotel-booking.appspot.com/o/e36987e0-0e7a-1fe5-a909-09a5195b6bd2_lead?alt=media&token=${hotel.hotelId}_lead';
                                          hotel.titleTxt = nameController.text;
                                          hotel.subTxt = addressController.text;
                                          hotel.perNight =
                                              int.parse(priceController.text);
                                          hotel.dist =
                                              double.parse(distController.text);
                                          hotel.rating = double.parse(
                                              ratingController.text);
                                          hotel.reviews =
                                              int.parse(reviewsController.text);
                                          hotel.roomData.numberRoom = int.parse(
                                              numberRoomController.text);
                                          hotel.roomData.people =
                                              int.parse(peopleController.text);
                                        });
                                        print(hotel.toString());
                                        provider.uploadImage(
                                            context, hotel.hotelId);
                                        context
                                            .read<CreateHotelBloc>()
                                            .add(CreateHotel(hotel));
                                      }
                                      Navigator.pop(context);
                                    },
                                    style: TextButton.styleFrom(
                                        elevation: 3.0,
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(60))),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 25, vertical: 5),
                                      child: Text(
                                        'Create Hotel',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    )),
                              )
                            : const CircularProgressIndicator(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
