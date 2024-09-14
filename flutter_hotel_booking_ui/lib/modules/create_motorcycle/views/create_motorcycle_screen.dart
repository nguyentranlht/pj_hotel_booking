import 'dart:io';

import 'package:bike_repository/bike_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hotel_booking_ui/futures/update_room_controller.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter_hotel_booking_ui/modules/create_motorcycle/bloc/create_motorcycle_dart_bloc.dart';
import 'package:flutter_hotel_booking_ui/modules/create_motorcycle/bloc/create_motorcycle_dart_event.dart';
import 'package:flutter_hotel_booking_ui/modules/create_room/blocs/create_room_bloc/create_room_bloc.dart';
import 'package:flutter_hotel_booking_ui/utils/themes.dart';
import 'package:location_repository/location_repository.dart';
import 'package:provider/provider.dart';
import 'package:room_repository/room_repository.dart';
import '../../../routes/route_names.dart';
import '../../create_room/components/my_text_field.dart';

class CreateMotorcycleScreen extends StatefulWidget {
  final String locationId;
  const CreateMotorcycleScreen({Key? key, required this.locationId})
      : super(key: key);

  @override
  State<CreateMotorcycleScreen> createState() => _CreateMotorcycleScreenState();
}

class _CreateMotorcycleScreenState extends State<CreateMotorcycleScreen> {
  late final Location location;
  final _formKey = GlobalKey<FormState>();
  final bikeId = TextEditingController();
  final bikeName = TextEditingController();
  final bikeType = TextEditingController();
  final bikeImage = TextEditingController();
  final bikeLicensePlate = TextEditingController();
  final bikeColor = TextEditingController();
  final bikeStatus = TextEditingController();
  final bikeRentPricePerDay = TextEditingController();
  final bikeFuelType = TextEditingController();
  final locationId = TextEditingController();

  bool creationRequired = false;
  String? _errorMsg;
  String typebike = '';
  String bikeFuelType2 = '';
  final _typeBike = ['Xe Ga', 'Xe Số'];
  final _bikeFuelType2 = ['Xăng', 'Dầu'];
  late Bike bike;

  @override
  void initState() {
    bike = Bike.empty;
    print(bike.bikeId);
    super.initState();
  }

  @override
  Widget _buildTypeBike() {
    return DropdownButtonFormField(
      decoration: InputDecoration(
        labelText: 'Chọn loại xe',
        labelStyle: TextStyle(
          color: AppTheme.fontcolor,
          fontWeight: FontWeight.w600,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      value: typebike.isEmpty ? null : typebike,
      items: _typeBike.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          typebike = value.toString();
        });
      },
    );
  }

  @override
  Widget _buildbikeFuelType() {
    return DropdownButtonFormField(
      decoration: InputDecoration(
        labelText: 'Chọn nhiên liệu xe',
        labelStyle: TextStyle(
          color: AppTheme.fontcolor,
          fontWeight: FontWeight.w600,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      value: typebike.isEmpty ? null : typebike,
      items: _bikeFuelType2.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          typebike = value.toString();
        });
      },
    );
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
                backgroundColor: Theme.of(context).colorScheme.surface,
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
                    'Thêm Xe Mới',
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
                            provider.pickeImage(context, bike.bikeId);
                          },
                          child: Center(
                              child: provider.image == null
                                  ? bike.bikeImage != ''
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
                                                      bike.bikeImage),
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
                        const SizedBox(
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
                                        controller: bikeName,
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
                                _buildTypeBike(),
                                const SizedBox(height: 10.0),
                                SizedBox(
                                    width: 400,
                                    child: MyTextField(
                                        controller: bikeLicensePlate,
                                        hintText: 'Biển số xe',
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
                                        controller: bikeColor,
                                        hintText: 'Màu xe',
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
                                        controller: bikeStatus,
                                        hintText: 'Trạng thái của xe máy',
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
                                        controller: bikeRentPricePerDay,
                                        hintText: 'Giá thuê mỗi ngày',
                                        obscureText: false,
                                        keyboardType: TextInputType.text,
                                        errorMsg: _errorMsg,
                                        validator: (val) {
                                          if (val!.isEmpty) {
                                            return 'Làm ơn điền đầy đủ thông tin';
                                          }
                                          return null;
                                        })),
                                const SizedBox(height: 10.0),
                                _buildbikeFuelType(),
                              ],
                            )),
                        const SizedBox(
                          height: 20,
                        ),
                        !creationRequired
                            ? SizedBox(
                                width: 400,
                                height: 50,
                                // child: TextButton(
                                //     onPressed: () {
                                //       firebase_storage.Reference storageRef =
                                //           firebase_storage
                                //               .FirebaseStorage.instance
                                //               .ref('${bike.bikeId}_lead');
                                //       firebase_storage.UploadTask uploadTask =
                                //           storageRef.putFile(
                                //               File(provider.image!.path)
                                //                   .absolute);
                                //       Future.value(uploadTask);
                                //       if (_formKey.currentState!.validate()) {
                                //         setState(() {
                                //           bike.bikeImage =
                                //               'https://firebasestorage.googleapis.com/v0/b/db-hotel-booking.appspot.com/o/e36987e0-0e7a-1fe5-a909-09a5195b6bd2_lead?alt=media&token=${bike.bikeId}_lead';
                                //           bike.bikeName = bikeName.text;
                                //           bike.bikeType = bikeType.text;
                                //           bike.bikeLicensePlate = bikeLicensePlate.text;
                                //           bike.bikeRentPricePerDay =
                                //               int.parse(bikeLicensePlate.text) as double;
                                //           bike.locationId = widget.locationId;
                                //         });
                                //         print(bike.toString());
                                //         provider.uploadImage(
                                //             context, bike.locationId);
                                //         context
                                //             .read<CreateMotorcycleDartBloc>()
                                //             .add(CreateMotorcycleDart(bike));
                                //       }
                                //       Navigator.pop(context);
                                //     },
                                child: TextButton(
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        // Tải lên hình ảnh lên Firebase Storage và lấy URL
                                        firebase_storage.Reference storageRef =
                                            firebase_storage
                                                .FirebaseStorage.instance
                                                .ref('${bike.bikeId}_lead');
                                        firebase_storage.UploadTask uploadTask =
                                            storageRef.putFile(
                                                File(provider.image!.path)
                                                    .absolute);

                                        // Chờ upload hoàn tất và lấy URL
                                        await uploadTask.whenComplete(() async {
                                          String downloadUrl =
                                              await storageRef.getDownloadURL();
                                          setState(() {
                                            bike.bikeImage =
                                                downloadUrl; // Gán URL tải lên cho bikeImage
                                            bike.bikeName = bikeName.text;
                                            bike.bikeType = bikeType.text;
                                            bike.bikeLicensePlate =
                                                bikeLicensePlate.text;
                                            bike.bikeRentPricePerDay =
                                                double.parse(
                                                    bikeRentPricePerDay.text);
                                            bike.locationId = widget.locationId;
                                          });

                                          // Thêm sự kiện Bloc sau khi hoàn tất cập nhật
                                          context
                                              .read<CreateMotorcycleDartBloc>()
                                              .add(CreateMotorcycleDart(
                                                locationId: widget.locationId,
                                                bike: bike,
                                              ));

                                          // Đóng màn hình sau khi xử lý xong
                                          Navigator.pop(context);
                                        });
                                      }
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
