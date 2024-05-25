import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ui/widgets/widget_support.dart';
import 'package:room_repository/room_repository.dart';
import 'package:user_repository/user_repository.dart';
import '../../routes/route_names.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? userId, wallet, paymentId, roomId;

  num total = 0;
  int amount2 = 0, note = 0, amount3 = 0;
  Stream? roomStream;
  bool isSelectedRoom = false;
  void startTimer() {
    Timer(Duration(seconds: 3), () {
      amount2 = int.parse(total.toString());
      setState(() {});
    });
  }

  getthesharedpref() async {
    //paymentId = await FirebaseUserRepository().addPaymentToRoom(userId!, paymentId!);
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

            if (ds["isSelected"] == false) {
              total = total + ds["PerNight"];

              return Container(
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
                        GestureDetector(
                          onTap: () async {
                            bool confirmDelete = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Xác nhận xóa"),
                                  content: Text(
                                      "Bạn có chắc muốn xoá?"),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                      },
                                      child: Text("Huỷ"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(true);
                                      },
                                      child: Text("Xoá"),
                                    ),
                                  ],
                                );
                              },
                            );
                            if (confirmDelete == true) {
                              try {
                                if (userId != null && ds.id != null) {
                                  await FirebaseUserRepository()
                                      .deletePaymentFromRoom(userId!, ds.id);

                                  await FirebaseUserRepository()
                                      .removeUserRoomId(userId!);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('Đã xóa thanh toán thành công'),
                                    ),
                                  );
                                  amount2 = amount2 -
                                      int.parse(ds["PerNight"].toString());
                                  print('amonut2 $amount2');

                                  setState(() {});
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('User ID or Payment ID is null'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } catch (error) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Failed to delete payment: $error'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          child: Container(
                            width: 90,
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 194, 9, 3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                "Xoá",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontStyle: FontStyle.normal),
                              ),
                            ),
                          ),
                        ),
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
                          children: [
                            Text(
                              ds["Name"],
                              style: AppWidget.semiBoldTextFeildStyle(),
                            ),
                            Text(
                              "\$" + ds["PerNight"].toString(),
                              style: AppWidget.semiBoldTextFeildStyle(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            // Trả về một Widget rỗng nếu điều kiện không thỏa mãn
            return SizedBox.shrink();
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
                elevation: 4.0,
                child: Container(
                    padding: EdgeInsets.only(bottom: 1.0), child: Center())),
            SizedBox(
              height: 20.0,
            ),
            Container(
                height: MediaQuery.of(context).size.height / 1.7,
                child: roomPayment()),
            Spacer(),
            Divider(),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Tổng số tiền",
                    style: AppWidget.boldTextFeildStyle(),
                  ),
                  Text(
                    "\$" + amount2.toString(),
                    style: AppWidget.semiBoldTextFeildStyle(),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            GestureDetector(
              onTap: () async {
                if (int.parse(wallet!) < amount2) {
                  //khi wallet it tien hon hoa don
                  return openError();
                } else {
                  int amount = int.parse(wallet!) - amount2;
                  await FirebaseUserRepository()
                      .updateUserWallet(userId!, amount.toString());
                  await FirebaseUserRepository()
                      .saveUserWallet(amount.toString());
                  await FirebaseUserRepository()
                      .updateIsSelectedForUserPayments(userId!);

                  roomId = await FirebaseRoomRepo().getRoomId(userId!);
                  if (roomId != null) {
                    await FirebaseRoomRepo().updateIsSelected(roomId!, true);
                  }
                  await FirebaseUserRepository().removeUserRoomId(userId!);

                  setState(() {});
                  openEdit();
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10)),
                margin: EdgeInsets.only(
                    left: 30.0, right: 30.0, bottom: 60.0, top: 0.0),
                child: Center(
                    child: Text(
                  "Thực hiện thanh toán",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold),
                )),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future openEdit() => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            content: SingleChildScrollView(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            NavigationServices(context).gotoLoginApp();
                          },
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(
                          width: 16.0,
                        ),
                        Center(
                          child: Text(
                            "Thanh toán thành công",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.lightGreen.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Text("Cảm ơn",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                        )),
                    SizedBox(
                      height: 10.0,
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          NavigationServices(context).gotoLoginApp();
                        },
                        child: Container(
                          width: 100,
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Color(0xFF008080),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                              child: Text(
                            "Trang chủ",
                            style: TextStyle(color: Colors.white),
                          )),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ));

  Future openError() => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            content: SingleChildScrollView(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            NavigationServices(context)
                                .gotoIntroductionScreen();
                          },
                          child: Icon(
                            Icons.error,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(
                          width: 16.0,
                        ),
                        Center(
                          child: Text(
                            "Lỗi thanh toán",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Text("Insufficient balance",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                        )),
                    SizedBox(
                      height: 10.0,
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          NavigationServices(context).gotoLoginApp();
                        },
                        child: Container(
                          width: 100,
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.lightGreen.shade700,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                              child: Text(
                            "Trang chủ",
                            style: TextStyle(color: Colors.white),
                          )),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ));

  _appBar() {
    return AppBar(
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
        "Thanh Toán",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
      ),
    );
  }
}
