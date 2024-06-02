import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hotel_booking_ui/futures/update_room_controller.dart';
import 'package:flutter_hotel_booking_ui/modules/create_hotel/blocs/create_hotel_bloc/create_hotel_bloc.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter_hotel_booking_ui/modules/create_room/blocs/create_room_bloc/create_room_bloc.dart';
import 'package:provider/provider.dart';
import 'package:hotel_repository/hotel_repository.dart';
import 'package:room_repository/room_repository.dart';
import '../../../routes/route_names.dart';
import '../components/my_text_field.dart';

class CreateRoomScreen extends StatefulWidget {
  final String hotelId;
  const CreateRoomScreen({Key? key, required this.hotelId}) : super(key: key);

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final nameController = TextEditingController();
  final capacityController = TextEditingController();
  final priceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final numberRoomController = TextEditingController();
  final peopleController = TextEditingController();
  bool creationRequired = false;
  String? _errorMsg;
  late Room room;

  @override
  void initState() {
    room = Room.empty;
    print(room.roomId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateRoomBloc(FirebaseRoomRepo()),
      child: BlocListener<CreateRoomBloc, CreateRoomState>(
        listener: (context, state) {
          if (state is CreateRoomSuccess) {
            setState(() {
              creationRequired = false;
            });
          } else if (state is CreateRoomLoading) {
            setState(() {
              creationRequired = true;
              NavigationServices(context).gotoBaseScreen();
            });
          }
        },
        child: ChangeNotifierProvider(
          create: (_) => UpdateRoomController(),
          child: Consumer<UpdateRoomController>(
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
                    'Tạo phòng mới !',
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
                            provider.pickeImage(context, room.roomId);
                          },
                          child: Center(
                              child: provider.image == null
                                  ? room.imagePath != ''
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
                                                      room.imagePath),
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
                                        hintText: 'Tên',
                                        obscureText: false,
                                        keyboardType: TextInputType.text,
                                        errorMsg: _errorMsg,
                                        validator: (val) {
                                          if (val!.isEmpty) {
                                            return 'Làm ơn điền đầy đủ thông tin';
                                          }
                                          return null;
                                        })),
                                const SizedBox(height: 10),
                                SizedBox(
                                    width: 400,
                                    child: MyTextField(
                                        controller: capacityController,
                                        hintText: 'Sức chứa',
                                        obscureText: false,
                                        keyboardType: TextInputType.text,
                                        errorMsg: _errorMsg,
                                        validator: (val) {
                                          if (val!.isEmpty) {
                                            return 'Làm ơn điền đầy đủ thông tin';
                                          }
                                          return null;
                                        })),
                                const SizedBox(height: 10),
                                SizedBox(
                                    width: 400,
                                    child: MyTextField(
                                        controller: priceController,
                                        hintText: 'Giá',
                                        obscureText: false,
                                        keyboardType: TextInputType.text,
                                        errorMsg: _errorMsg,
                                        validator: (val) {
                                          if (val!.isEmpty) {
                                            return 'Làm ơn điền đầy đủ thông tin';
                                          }
                                          return null;
                                        })),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Text('Đã được đặt :'),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Checkbox(
                                        value: room.isSelected,
                                        onChanged: (value) {
                                          setState(() {
                                            room.isSelected = value!;
                                          });
                                        })
                                  ],
                                ),
                                
                                const SizedBox(height: 10),
                                SizedBox(
                                    width: 400,
                                    child: MyTextField(
                                        controller: numberRoomController,
                                        hintText: 'Số phòng',
                                        obscureText: false,
                                        keyboardType: TextInputType.text,
                                        errorMsg: _errorMsg,
                                        validator: (val) {
                                          if (val!.isEmpty) {
                                            return 'Làm ơn điền đầy đủ thông tin';
                                          }
                                          return null;
                                        })),
                                const SizedBox(height: 10),
                                SizedBox(
                                    width: 400,
                                    child: MyTextField(
                                        controller: peopleController,
                                        hintText: 'Số người',
                                        obscureText: false,
                                        keyboardType: TextInputType.text,
                                        errorMsg: _errorMsg,
                                        validator: (val) {
                                          if (val!.isEmpty) {
                                            return 'Làm ơn điền đầy đủ thông tin';
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
                                      firebase_storage.Reference storageRef =
                                          firebase_storage
                                              .FirebaseStorage.instance
                                              .ref('${room.roomId}_lead');
                                      firebase_storage.UploadTask uploadTask =
                                          storageRef.putFile(
                                              File(provider.image!.path)
                                                  .absolute);
                                      Future.value(uploadTask);
                                      if (_formKey.currentState!.validate()) {
                                        setState(() {
                                          room.imagePath =
                                              'https://firebasestorage.googleapis.com/v0/b/db-hotel-booking.appspot.com/o/e36987e0-0e7a-1fe5-a909-09a5195b6bd2_lead?alt=media&token=${room.roomId}_lead';
                                          room.titleTxt = nameController.text;
                                          room.dataTxt = capacityController.text;
                                          room.perNight =
                                              int.parse(priceController.text);
                                          room.hotelId = widget.hotelId;
                                          room.roomData.numberRoom = int.parse(
                                              numberRoomController.text);
                                          room.roomData.people =
                                              int.parse(peopleController.text);
                                        });
                                        print(room.toString());
                                        provider.uploadImage(
                                            context, room.hotelId);
                                        context
                                            .read<CreateRoomBloc>()
                                            .add(CreateRoom(room));
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
                                        'Tạo',
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
