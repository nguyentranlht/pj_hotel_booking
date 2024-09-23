// import 'dart:io';

// import 'package:bike_repository/bike_repository.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:flutter_hotel_booking_ui/futures/update_room_controller.dart';
// import 'package:flutter_hotel_booking_ui/routes/route_names.dart';
// import 'package:flutter_hotel_booking_ui/utils/themes.dart';
// import 'package:provider/provider.dart';
// import 'package:room_repository/room_repository.dart';

// class UpdateMotorcycleForm extends StatefulWidget {
//   final Bike bike;

//   const UpdateMotorcycleForm({Key? key, required this.bike}) : super(key: key);

//   @override
//   _UpdateMotorcycleFormState createState() => _UpdateMotorcycleFormState();
// }

// class _UpdateMotorcycleFormState extends State<UpdateMotorcycleForm> {
//   DatabaseReference ref = FirebaseDatabase.instance.ref().child('bikes');
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         resizeToAvoidBottomInset: false,
//         backgroundColor: AppTheme.scaffoldBackgroundColor,
//         appBar: AppBar(
//           leading: GestureDetector(
//               onTap: () {
//                 Navigator.pop(context);
//               },
//               child: Icon(
//                 Icons.arrow_back_ios_new_outlined,
//                 color: Color(0xFF373866),
//               )),
//           centerTitle: true,
//           title: Text(
//             'Cập Nhật Xe',
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
//           ),
//         ),
//         body: ChangeNotifierProvider(
//           create: (_) => UpdateRoomController(),
//           child: Consumer<UpdateRoomController>(
//             builder: (context, provider, child) {
//               return Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Form(
//                   child: ListView(
//                     children: [
//                       const SizedBox(height: 20),
//                       InkWell(
//                         borderRadius: BorderRadius.circular(20),
//                         onTap: () async {
//                           provider.pickeImage(context, widget.bike.bikeId);
//                         },
//                         child: Center(
//                             child: provider.image == null
//                                 ? widget.bike.bikeImage != ''
//                                     ? Container(
//                                         width: 150,
//                                         height: 150,
//                                         decoration: BoxDecoration(
//                                             border: Border.all(
//                                                 color: Colors.black,
//                                                 width: 1.5),
//                                             borderRadius:
//                                                 BorderRadius.circular(20),
//                                             image: DecorationImage(
//                                                 image: NetworkImage(
//                                                     widget.bike.bikeImage),
//                                                 fit: BoxFit.cover)))
//                                     : Container(
//                                         width: 150,
//                                         height: 150,
//                                         decoration: BoxDecoration(
//                                           border: Border.all(
//                                               color: Colors.black, width: 1.5),
//                                           borderRadius:
//                                               BorderRadius.circular(20),
//                                         ),
//                                         child: const Column(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.center,
//                                           children: [
//                                             Icon(
//                                               Icons.camera_alt_outlined,
//                                               color: Colors.black,
//                                             ),
//                                           ],
//                                         ),
//                                       )
//                                 : Container(
//                                     width: 150,
//                                     height: 150,
//                                     decoration: BoxDecoration(
//                                         border: Border.all(
//                                             color: Colors.black, width: 1.5),
//                                         borderRadius: BorderRadius.circular(20),
//                                         image: DecorationImage(
//                                             image: FileImage(
//                                                 File(provider.image!.path)
//                                                     .absolute),
//                                             fit: BoxFit.cover)))),
//                       ),
//                       SizedBox(
//                         height: 30.0,
//                       ),
//                       GestureDetector(
//                         onTap: () {
//                           provider.showRoomNameDialogAlert(context,
//                               widget.bike.bikeImage, widget.bike.bikeId);
//                         },
//                         child: ReusbaleRow(
//                             title: 'Tên Xe',
//                             iconData: Icons.edit,
//                             value: widget.bike.bikeName),
//                       ),
//                       SizedBox(
//                         height: 30.0,
//                       ),
//                       GestureDetector(
//                         onTap: () {
//                           provider.showRoomCapacityDialogAlert(
//                               context, widget.room.dataTxt, widget.room.roomId);
//                         },
//                         child: ReusbaleRow(
//                             title: 'Sức chứa',
//                             iconData: Icons.edit,
//                             value: widget.room.dataTxt),
//                       ),
//                       SizedBox(
//                         height: 30.0,
//                       ),
//                       GestureDetector(
//                         onTap: () {
//                           provider.showRoomPriceDialogAlert(context,
//                               widget.room.perNight, widget.room.roomId);
//                         },
//                         child: ReusbaleRow(
//                             title: 'Giá Phòng',
//                             iconData: Icons.edit,
//                             value: widget.room.perNight.toString()),
//                       ),
//                       SizedBox(
//                         height: 30.0,
//                       ),
//                       SizedBox(
//                         width: 400,
//                         height: 50,
//                         child: TextButton(
//                             onPressed: () {
//                               NavigationServices(context).gotoBaseScreen();
//                             },
//                             style: TextButton.styleFrom(
//                                 elevation: 3.0,
//                                 backgroundColor:
//                                     Theme.of(context).colorScheme.primary,
//                                 foregroundColor: Colors.white,
//                                 shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(60))),
//                             child: const Padding(
//                               padding: EdgeInsets.symmetric(
//                                   horizontal: 25, vertical: 5),
//                               child: Text(
//                                 'Cập nhật',
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w600),
//                               ),
//                             )),
//                       ),
//                       SizedBox(
//                         height: 30.0,
//                       ),
//                       SizedBox(
//                         width: 400,
//                         height: 50,
//                         child: TextButton(
//                             onPressed: () {
//                               provider.showDeleteRoomDialogAlert(
//                                   context, widget.room.roomId);
//                             },
//                             style: TextButton.styleFrom(
//                                 elevation: 3.0,
//                                 backgroundColor:
//                                     Theme.of(context).colorScheme.error,
//                                 foregroundColor: Colors.white,
//                                 shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(60))),
//                             child: const Padding(
//                               padding: EdgeInsets.symmetric(
//                                   horizontal: 25, vertical: 5),
//                               child: Text(
//                                 'Xoá',
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w600),
//                               ),
//                             )),
//                       )
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ));
//   }
// }

// class ReusbaleRow extends StatelessWidget {
//   final String title, value;
//   final IconData iconData;
//   const ReusbaleRow(
//       {Key? key,
//       required this.title,
//       required this.iconData,
//       required this.value})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         ListTile(
//           title: Text(
//             title,
//             style: Theme.of(context).textTheme.bodyMedium,
//           ),
//           leading: Icon(iconData),
//           trailing: Text(value),
//         ),
//         Divider(
//           color: AppTheme.fontcolor,
//         )
//       ],
//     );
//   }
// }
