import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ui/widgets/widget_support.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:user_repository/user_repository.dart';
import '../../language/appLocalizations.dart';
import '../../routes/route_names.dart';
import '../../widgets/common_appbar_view.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String? userId, wallet;
  num total = 0;
  int amount2 = 0, note = 0;
  bool isSelected = false;
  final oCcy = NumberFormat("#,##0", "vi_VN");
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  void startTimer() {
    Timer(Duration(seconds: 3), () {
      amount2 = int.parse(total.toString());
      setState(() {});
    });
  }

  getthesharedpref() async {
    userId = await FirebaseUserRepository().getUserId();
    wallet = await FirebaseUserRepository().getUserWallet();
    setState(() {});
  }

  ontheload() async {
    await getthesharedpref();
    roomStream = await FirebaseUserRepository().getRoomPayment(userId!);
    setState(() {});
  }

  @override
  void initState() {
    ontheload();
    startTimer();
    super.initState();
  }

  Stream? roomStream;

  Widget roomPayment() {
    return StreamBuilder(
      stream: roomStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: snapshot.data.docs.length,
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data.docs[index];

            return Slidable(
              key: Key(ds.id),
              startActionPane: ActionPane(
                motion: ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (context) {
                      // Xử lý hành động "Sản phẩm tương tự"
                    },
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    //icon: Icons.similar,
                    label: 'Sản phẩm tương tự',
                  ),
                ],
              ),
              endActionPane: ActionPane(
                motion: ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (context) async {
                      bool? confirmed = true;
                      if (confirmed == true) {
                        // Xử lý hành động "Xóa"
                      }
                    },
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Xóa',
                  ),
                ],
              ),
              child: Container(
                margin: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
                child: Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        SizedBox(width: 20.0),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: Image.network(
                            ds["ImagePath"],
                            height: 90,
                            width: 90,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 20.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ds["Name"],
                              style: AppWidget.semiBoldTextFeildStyle(),
                            ),
                            Text(
                              "${oCcy.format(ds["PerNight"])} ₫",
                              style: AppWidget.semiBoldTextFeildStyle(),
                            ),
                            Text(
                              ds["StartDate"].toString() +
                                  " - " +
                                  ds["EndDate"].toString(),
                              style: AppWidget.semiBoldTextFeildStyle(),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(width: 50),
                                Text(
                                  "Status: ",
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 108, 135, 85),
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                Text(
                                  ds["isSelected"]
                                      ? "Payment Success"
                                      : "Payment Error",
                                  style: TextStyle(
                                    color: ds["isSelected"]
                                        ? Color.fromARGB(255, 104, 159, 56)
                                        : Colors.red,
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Future<bool> _showConfirmationDialog(BuildContext context) async {
  //   return showDialog<bool>(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: Text('Xác nhận'),
  //         content: Text('Bạn có chắc chắn muốn xóa sản phẩm này?'),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.of(context).pop(false),
  //             child: Text('Hủy'),
  //           ),
  //           TextButton(
  //             onPressed: () => Navigator.of(context).pop(true),
  //             child: Text('Xóa'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 2.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _appBar(),
            Material(
              elevation: 5.0,
              child: Container(
                padding: EdgeInsets.only(bottom: 2.0),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Container(
              height: MediaQuery.of(context).size.height / 1.5,
              child: roomPayment(),
            ),
            SizedBox(
              height: 20.0,
            ),
          ],
        ),
      ),
    );
  }

  _appBar() {
    return AppBar(
      leading: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Icon(
          Icons.arrow_back_ios_new_outlined,
          color: Color(0xFF373866),
        ),
      ),
      centerTitle: true,
      title: Text(
        "Lịch sử thanh toán",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
    );
  }
}
