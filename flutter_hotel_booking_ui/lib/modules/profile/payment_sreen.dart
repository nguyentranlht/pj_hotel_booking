import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ui/utils/themes.dart';
import 'package:flutter_hotel_booking_ui/widgets/sendGridApi.dart';
import 'package:flutter_hotel_booking_ui/widgets/widget_support.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
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
  int amount2 = 0, note = 0;
  Stream? roomStream;
  bool isSelectedRoom = false;
  final oCcy = NumberFormat("#,##0", "vi_VN");
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  String? luu, luu2;
  int? perNight;
  String? customerEmail;
  String? customerName, nameHotel, paymentIds;
  int? roomNumber;

  void startTimer() {
    Timer(const Duration(seconds: 3), () {
      amount2 = int.parse(total.toString());
      setState(() {});
    });
  }

  String? formatDate(DateTime? date) {
    if (date == null) return null;
    return DateFormat('dd-MM-yyyy').format(date);
  }

  getthesharedpref() async {
    userId = await FirebaseUserRepository().getUserId();
    wallet = await FirebaseUserRepository().getUserWallet();
    setState(() {});
  }

  ontheload() async {
    await getthesharedpref();

    var userInfo = await FirebaseUserRepository().getUserInfo(userId!);
    var paymentIdsluu =
        await FirebaseUserRepository().getLatestPaymentId(userId!);
    String? email = userInfo['email'];
    String? name = userInfo['firstname'];

    setState(() {
      customerEmail = email;
      customerName = name;
      paymentIds = paymentIdsluu;
    });

    roomStream = await FirebaseUserRepository().getRoomPayment(userId!);

    setState(() {});
  }

  @override
  void initState() {
    ontheload();
    startTimer();
    super.initState();
  }

  void calculateTotal(AsyncSnapshot snapshot) {
    total = 0;
    amount2 = 0;
    for (var doc in snapshot.data.docs) {
      if (doc["isSelected"] == false) {
        total += doc["PerNight"];
      }
    }
    amount2 = total.toInt();
  }

  Widget roomPayment() {
    return StreamBuilder(
      stream: roomStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          calculateTotal(snapshot);
          setState(() {});
        });

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: snapshot.data.docs.length,
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data.docs[index];
            return ds["isSelected"] == true
                ? Container()
                : Slidable(
                    key: Key(ds.id),
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) async {
                            bool confirmDelete = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Xác nhận xóa"),
                                  content: const Text("Bạn có chắc muốn xoá?"),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                      },
                                      child: const Text("Huỷ"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(true);
                                      },
                                      child: const Text("Xoá"),
                                    ),
                                  ],
                                );
                              },
                            );
                            if (confirmDelete == true) {
                              try {
                                if (userId != null) {
                                  await FirebaseUserRepository()
                                      .deletePaymentFromRoom(userId!, ds.id);
                                  await FirebaseUserRepository()
                                      .removeUserRoomId(userId!);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Đã xóa khỏi thanh toán thành công'),
                                    ),
                                  );
                                  // Cập nhật lại tổng tiền sau khi xóa
                                  setState(() {
                                    snapshot.data.docs.removeAt(index);
                                    calculateTotal(snapshot);
                                  });
                                  Navigator.pop(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
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
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Xóa',
                        ),
                      ],
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(
                          left: 20.0, right: 20.0, bottom: 10.0),
                      child: Material(
                        elevation: 10.0,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(40),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: SizedBox(
                                  height: 110,
                                  width: 110,
                                  child: PageView(
                                    controller: PageController(),
                                    pageSnapping: true,
                                    scrollDirection: Axis.horizontal,
                                    children: <Widget>[
                                      for (var image
                                          in (ds["ImagePath"] as String)
                                              .split(" "))
                                        Image.network(
                                          image,
                                          fit: BoxFit.cover,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20.0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(ds["Name"],
                                      style: TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.fontcolor,
                                      )),
                                  Text(
                                    "${oCcy.format(ds["PerNight"])} ₫",
                                    style: AppWidget.semiBoldTextFeildStyle(),
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
        padding: const EdgeInsets.only(top: 2.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _appBar(),
            Material(
              elevation: 4.0,
              child: Container(
                padding: const EdgeInsets.only(bottom: 1.0),
                child: const Center(),
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 1.7,
              child: roomPayment(),
            ),
            const Spacer(),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(left: 25.0, right: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Tổng tiền",
                    style: AppWidget.boldTextFeildStyle(),
                  ),
                  Text(
                    "${oCcy.format(amount2)} ₫",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.fontcolor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            GestureDetector(
              onTap: () async {
                if (int.parse(wallet!) < amount2) {
                  //khi wallet ít tiền hơn hóa đơn
                  return openError();
                } else {
                  int amount = int.parse(wallet!) - amount2;
                  await FirebaseUserRepository()
                      .updateUserWallet(userId!, amount.toString());
                  await FirebaseUserRepository()
                      .saveUserWallet(amount.toString());

                  roomId = await FirebaseRoomRepo().getRoomId(userId!);
                  if (roomId != null) {
                    await updateRoomDataWithPayment(userId!, roomId!);

                    await FirebaseUserRepository()
                        .updateIsSelectedForDatime(roomId!);
                    await FirebaseUserRepository()
                        .updateIsSelectedForUserPayments(userId!);
                    if (paymentIds != null) {
                      Map<String, dynamic> latestPaymentDetails =
                          await FirebaseUserRepository()
                              .getPaymentDetails(userId!, paymentIds!);
                      perNight = latestPaymentDetails['PerNight'];
                      roomNumber = latestPaymentDetails['NumberRoom'];
                      _selectedStartDate = latestPaymentDetails['StartDate'];
                      _selectedEndDate = latestPaymentDetails['EndDate'];
                      nameHotel = latestPaymentDetails['Name'];
                      luu = formatDate(_selectedStartDate);
                      luu2 = formatDate(_selectedEndDate);
                      setState(() {});
                    } else {
                      print('No paymentIds found.');
                    }
                  }
                  await FirebaseUserRepository().removeUserRoomId(userId!);
                  await sendConfirmationEmail(
                    customerEmail ?? 'khachhang@example.com',
                    customerName ?? 'Tên Khách Hàng',
                    nameHotel ?? 'Khách sạn của bạn',
                    roomNumber?.toString() ?? 'Số phòng của bạn',
                    luu?.toString() ?? 'N/A',
                    luu2?.toString() ?? 'N/A',
                    "${oCcy.format(perNight)} ₫".toString(),
                  );
                  setState(() {});
                  openEdit();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.only(
                    left: 25.0, right: 25.0, bottom: 60.0, top: 5.0),
                child: const Center(
                  child: Text(
                    "Thực hiện thanh toán",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
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
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(
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
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  const Text(
                    "Cảm ơn",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        NavigationServices(context).gotoLoginApp();
                      },
                      child: Container(
                        width: 100,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF008080),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text(
                            "Trang chủ",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

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
                          NavigationServices(context).gotoIntroductionScreen();
                        },
                        child: const Icon(
                          Icons.error,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(
                        width: 16.0,
                      ),
                      const Center(
                        child: Text(
                          "Lỗi thanh toán",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  const Text(
                    "Số dư không đủ",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        NavigationServices(context).gotoLoginApp();
                      },
                      child: Container(
                        width: 100,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.lightGreen.shade700,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text(
                            "Trang chủ",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  _appBar() {
    return AppBar(
      leading: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: const Icon(
          Icons.arrow_back_ios_new_outlined,
          color: Color(0xFF373866),
        ),
      ),
      centerTitle: true,
      title: const Text(
        "Thanh Toán",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
    );
  }

  Future<void> updateRoomDataWithPayment(String userId, String roomId) async {
    try {
      var paymentData = await FirebaseUserRepository().getPaymentData(userId);

      if (paymentData != null) {
        Map<String, dynamic> addDateToRoom = {
          "StartDate": paymentData['StartDate'],
          "EndDate": paymentData['EndDate'],
          "paymentId": paymentData['paymentId'],
          "isSelected": paymentData['isSelected'],
          "userId": paymentData['userId'],
        };
        await FirebaseRoomRepo().addDateToRoom(addDateToRoom, roomId);
      }
    } catch (e) {
      print('Error updating room data with payment: $e');
      rethrow;
    }
  }
}
