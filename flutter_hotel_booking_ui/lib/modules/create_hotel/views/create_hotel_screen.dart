import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hotel_booking_ui/modules/base/views/base_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_hotel_booking_ui/modules/create_hotel/blocs/create_hotel_bloc/create_hotel_bloc.dart';
import 'package:flutter_hotel_booking_ui/modules/create_hotel/blocs/upload_picture_bloc/upload_picture_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
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
        child: BlocProvider(
          create: (context) => UploadPictureBloc(FirebaseHotelRepo()),
          child: BlocListener<UploadPictureBloc, UploadPictureState>(
            listener: (context, state) {
              if (state is UploadPictureLoading) {
              } else if (state is UploadPictureSuccess) {
                setState(() {
                  hotel.imagePath = state.url;
                });
              }
            },
            child: Scaffold(
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
                            final ImagePicker picker = ImagePicker();
                            final XFile? image = await picker.pickImage(
                              source: ImageSource.gallery,
                              maxHeight: 1000,
                              maxWidth: 1000,
                            );
                            if (image != null && context.mounted) {
                              context.read<UploadPictureBloc>().add(
                                  UploadPicture(await image.readAsBytes(),
                                      basename(image.path)));
                            }
                          },
                          child: Center(
                            child: hotel.imagePath != ''
                                ? Container(
                                    width: 150,
                                    height: 150,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.black, width: 1.5),
                                        borderRadius: BorderRadius.circular(20),
                                        image: DecorationImage(
                                            image:
                                                NetworkImage(hotel.imagePath),
                                            fit: BoxFit.cover)))
                                : Container(
                                    width: 150,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.black, width: 1.5),
                                      borderRadius: BorderRadius.circular(20),
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
                                  ),
                          )),
                      // InkWell(
                      //     child: const Text(
                      //   "Add a Picture here...",
                      //   style: TextStyle(fontSize: 18),

                      // )),
                      // const SizedBox(height: 20),
                      // hotel.imagePath == ''
                      //     ? Center(
                      //         child: Material(
                      //           elevation: 4.0,
                      //           borderRadius: BorderRadius.circular(20),
                      //           child: Container(
                      //             width: 150,
                      //             height: 150,
                      //             decoration: BoxDecoration(
                      //               border: Border.all(
                      //                   color: Colors.black, width: 1.5),
                      //               borderRadius: BorderRadius.circular(20),
                      //             ),
                      //             child: ClipRRect(
                      //               borderRadius: BorderRadius.circular(20),
                      //               child: Image.network(
                      //                 hotel.imagePath,
                      //                 fit: BoxFit.cover,
                      //               ),
                      //             ),
                      //           ),
                      //         ),
                      //       )
                      //     : GestureDetector(
                      //         onTap: () async {
                      //           final ImagePicker picker = ImagePicker();
                      //           final XFile? image = await picker.pickImage(
                      //             source: ImageSource.gallery,
                      //             maxHeight: 1000,
                      //             maxWidth: 1000,
                      //           );
                      //           if (image != null && context.mounted) {
                      //             context.read<UploadPictureBloc>().add(
                      //                 UploadPicture(await image.readAsBytes(),
                      //                     basename(image.path)));
                      //           }
                      //         },
                      //         child: Center(
                      //           child: Material(
                      //             elevation: 4.0,
                      //             borderRadius: BorderRadius.circular(20),
                      //             child: Container(
                      //               width: 150,
                      //               height: 150,
                      //               decoration: BoxDecoration(
                      //                 border: Border.all(
                      //                     color: Colors.black, width: 1.5),
                      //                 borderRadius: BorderRadius.circular(20),
                      //               ),
                      //               child: Icon(
                      //                 Icons.camera_alt_outlined,
                      //                 color: Colors.black,
                      //               ),
                      //             ),
                      //           ),
                      //         ),
                      //       ),
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
                                    if (_formKey.currentState!.validate()) {
                                      setState(() {
                                        hotel.titleTxt = nameController.text;
                                        hotel.subTxt = addressController.text;
                                        hotel.perNight =
                                            int.parse(priceController.text);
                                        hotel.dist =
                                            double.parse(distController.text);
                                        hotel.rating =
                                            double.parse(ratingController.text);
                                        hotel.reviews =
                                            int.parse(reviewsController.text);
                                        hotel.roomData.numberRoom = int.parse(
                                            numberRoomController.text);
                                        hotel.roomData.people =
                                            int.parse(peopleController.text);
                                      });
                                      print(hotel.toString());
                                      context
                                          .read<CreateHotelBloc>()
                                          .add(CreateHotel(hotel));
                                    }
                                    Navigator.pop(context);
                                  },
                                  style: TextButton.styleFrom(
                                      elevation: 3.0,
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
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
            ),
          ),
        ),
      ),
    );
  }
}
