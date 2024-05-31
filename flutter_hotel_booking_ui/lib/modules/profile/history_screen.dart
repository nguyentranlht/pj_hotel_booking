import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ui/models/my_user.dart';
import 'package:flutter_hotel_booking_ui/widgets/widget_support.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:user_repository/user_repository.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String? userId, wallet;
  num total = 0;
  int note = 0;
  bool isSelected = false;
  final oCcy = NumberFormat("#,##0", "vi_VN");

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
    super.initState();
  }

  Stream? roomStream;

  Future<void> deleteItem(String docId, num perNight, String roomId) async {
    try {
      //await FirebaseUserRepository().deletePaymentFromRoom(userId!, docId);
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('payment')
          .doc(docId)
          .update({'isSelected': false});
      FirebaseFirestore.instance
          .collection('rooms')
          .doc(roomId)
          .collection('dateTime')
          .where('paymentId', isEqualTo: docId)
          .get()
          .then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          // Lấy document đầu tiên vì giả định là paymentId là duy nhất
          var document = querySnapshot.docs.first;
          document.reference.delete().then((_) {
            print("Document successfully deleted!");
          }).catchError((error) {
            print("Error removing document: $error");
          });
        } else {
          print("No document found with paymentId: $docId");
        }
      }).catchError((error) {
        print("Error retrieving documents: $error");
      });
      num amount = num.parse(wallet!) + perNight;
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'wallet': amount.toString()});
      setState(() {
        total -= perNight;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã đặt phòng thành công'),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete payment: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
              endActionPane: ActionPane(
                motion: ScrollMotion(),
                children: [
                  ds["isSelected"] == false
                      ? Container()
                      : SlidableAction(
                          onPressed: (context) async {
                            bool confirmDelete = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Xác nhận huỷ phòng"),
                                  content: Text("Bạn có chắc muốn huỷ?"),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                      },
                                      child: Text("Thoát"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(true);
                                      },
                                      child: Text("Huỷ"),
                                    ),
                                  ],
                                );
                              },
                            );
                            if (confirmDelete == true) {
                              await deleteItem(ds.id, ds["PerNight"],ds["RoomId"]);
                            }
                          },
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Huỷ',
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
                                Text(
                                  "Trạng thái: ",
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 108, 135, 85),
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                Text(
                                  ds["isSelected"] ? "Thành công" : "Thất bại",
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
        "Trạng thái thanh toán",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
    );
  }
}
