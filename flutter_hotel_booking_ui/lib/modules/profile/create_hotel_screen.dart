import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hotel_booking_ui/futures/hotel_bloc/get_hotel_bloc.dart';
import 'package:path/path.dart';
import 'package:flutter_hotel_booking_ui/modules/create_hotel/blocs/create_hotel_bloc/create_hotel_bloc.dart';
import 'package:hotel_repository/hotel_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class CreateHotelScreen extends StatefulWidget {
  const CreateHotelScreen({Key? key}) : super(key: key);

  @override
  State<CreateHotelScreen> createState() => _CreateHotelScreenState();
}

class _CreateHotelScreenState extends State<CreateHotelScreen> {
  final TextEditingController hotelIdController = TextEditingController();
  final TextEditingController imagePathController = TextEditingController();
  final TextEditingController titleTxtController = TextEditingController();
  final TextEditingController subTxtController = TextEditingController();
  final TextEditingController dateTxtController = TextEditingController();
  final TextEditingController roomSizeTxtController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
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
              context.go('/');
            });
            context.go('/');
          } else if (state is CreateHotelLoading) {
            setState(() {
              creationRequired = true;
            });
          }
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 150),
                  const Text(
                    'Create a New Hotel !',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                  const SizedBox(height: 40),
                  // Input fields for hotel information
                  // You can customize these fields according to your requirements
                  // Example: TextFields, DatePickers, Dropdowns, etc.
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: hotelIdController,
                          decoration: InputDecoration(
                            hintText: 'Hotel ID',
                            errorText: _errorMsg,
                          ),
                          keyboardType: TextInputType.text,
                          validator: (val) {
                            if (val!.isEmpty) {
                              return 'Please fill in this field';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: imagePathController,
                          decoration: InputDecoration(
                            hintText: 'Image Path',
                            errorText: _errorMsg,
                          ),
                          keyboardType: TextInputType.text,
                          validator: (val) {
                            if (val!.isEmpty) {
                              return 'Please fill in this field';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: titleTxtController,
                          decoration: InputDecoration(
                            hintText: 'Title',
                            errorText: _errorMsg,
                          ),
                          keyboardType: TextInputType.text,
                          validator: (val) {
                            if (val!.isEmpty) {
                              return 'Please fill in this field';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: subTxtController,
                          decoration: InputDecoration(
                            hintText: 'Subtitle',
                            errorText: _errorMsg,
                          ),
                          keyboardType: TextInputType.text,
                          validator: (val) {
                            if (val!.isEmpty) {
                              return 'Please fill in this field';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: dateTxtController,
                          decoration: InputDecoration(
                            hintText: 'Date',
                            errorText: _errorMsg,
                          ),
                          keyboardType: TextInputType.text,
                          validator: (val) {
                            if (val!.isEmpty) {
                              return 'Please fill in this field';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: roomSizeTxtController,
                          decoration: InputDecoration(
                            hintText: 'Room Size',
                            errorText: _errorMsg,
                          ),
                          keyboardType: TextInputType.text,
                          validator: (val) {
                            if (val!.isEmpty) {
                              return 'Please fill in this field';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        // Add more text fields for other information
                        // Example: Distance, Rating, Reviews, Price, etc.
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  !creationRequired
                      ? SizedBox(
                          width: 400,
                          height: 40,
                          child: TextButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                // Set hotel information from text field controllers
                                setState(() {
                                  hotel.hotelId = hotelIdController.text;
                                  hotel.imagePath = imagePathController.text;
                                  hotel.titleTxt = titleTxtController.text;
                                  hotel.subTxt = subTxtController.text;
                                  hotel.dateTxt = dateTxtController.text;
                                  hotel.roomSizeTxt =
                                      roomSizeTxtController.text;
                                  // Set other hotel information similarly
                                });
                                // Dispatch event to create hotel
                                context
                                    .read<CreateHotelBloc>()
                                    .add(CreateHotel(hotel));
                              }
                            },
                            style: TextButton.styleFrom(
                              elevation: 3.0,
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(60)),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30),
                              child: Text(
                                'Create Hotel',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        )
                      : const CircularProgressIndicator(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
