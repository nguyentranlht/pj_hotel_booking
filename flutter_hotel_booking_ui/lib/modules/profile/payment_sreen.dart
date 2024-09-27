import 'dart:async';
import 'dart:math';
import 'package:bike_repository/bike_repository.dart';
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
  int amount2 = 0, note = 0, amount3 = 0;
  Stream? roomStream;
  bool isSelectedRoom = false;
  final oCcy = NumberFormat("#,##0", "vi_VN");
  String? _selectedStartDate;
  String? _selectedEndDate;
  String? luu, luu2;
  int? perNight;
  String? customerEmail;
  String? customerName, nameHotel, paymentIds;
  int? roomNumber;

  List<int> delayTimes = [3, 6]; // Danh sách thời gian trễ có thể chọn
  List<int> usedDelayTimes = []; // Danh sách các thời gian đã chọn

// Hàm để lấy giá trị thời gian ngẫu nhiên từ danh sách
  Future<int> getRandomDelayTime() async {
    if (delayTimes.isEmpty) {
      // Nếu đã chọn hết tất cả các số, đợi 3 giây trước khi khởi động lại danh sách
      await Future.delayed(const Duration(seconds: 3));

      // Khởi động lại danh sách
      delayTimes = List.from(usedDelayTimes);
      usedDelayTimes = [];
    }

    // Chọn ngẫu nhiên một thời gian từ danh sách còn lại
    int randomIndex = Random().nextInt(delayTimes.length);
    int selectedTime = delayTimes[randomIndex];

    // Chuyển số giây đã chọn vào danh sách usedDelayTimes và loại bỏ khỏi delayTimes
    usedDelayTimes.add(selectedTime);
    delayTimes.removeAt(randomIndex);
    return selectedTime;
  }

  void startTimer() {
    Timer(const Duration(seconds: 3), () {
      amount2 = int.parse(total.toString());
      setState(() {});
    });
  }

  getthesharedpref() async {
    userId = await FirebaseUserRepository().getUserId();
    wallet = await FirebaseUserRepository().getUserWallet();
    amount3 = int.parse(wallet!);
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
                _showPaymentMethodSheet(context);
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
        barrierDismissible:
            false, // Ngăn người dùng tắt dialog bằng cách nhấn bên ngoài
        builder: (context) => WillPopScope(
          onWillPop: () async =>
              false, // Ngăn người dùng tắt dialog bằng nút back
          child: AlertDialog(
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
                          // Điều hướng về trang chủ
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
        ),
      );

  Future openError() => showDialog(
        context: context,
        barrierDismissible:
            false, // Ngăn người dùng tắt dialog bằng cách nhấn ra ngoài
        builder: (context) => WillPopScope(
          onWillPop: () async =>
              false, // Ngăn người dùng tắt dialog bằng nút back
          child: AlertDialog(
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

  Widget _buildPaymentOptionGoGPay(
      BuildContext context, IconData icon, String title, String subtitle) {
    return ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title),
        subtitle: subtitle.isNotEmpty
            ? Text(subtitle, style: const TextStyle(color: Colors.red))
            : null,
        trailing: Radio(
          value: title,
          groupValue: null, // Replace with selected value
          onChanged: (value) {},
        ),
        onTap: () async {
          if (int.parse(wallet!) < amount2) {
            // Khi wallet ít tiền hơn hóa đơn
            return openError();
          } else {
            // Hiển thị hộp thoại xác nhận thanh toán
            bool confirmPayment = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Xác nhận thanh toán"),
                  content: const Text(
                      "Bạn có chắc chắn muốn thực hiện thanh toán không?"),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false); // Huỷ bỏ thanh toán
                      },
                      child: const Text("Huỷ"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(true); // Xác nhận thanh toán
                      },
                      child: const Text("Xác nhận"),
                    ),
                  ],
                );
              },
            );

            if (confirmPayment == true) {
              try {
                // Hiển thị loading indicator trước khi thực hiện các hành động async
                showDialog(
                  // ignore: use_build_context_synchronously
                  context: Navigator.of(context, rootNavigator: true)
                      .context, // Sử dụng rootNavigator để đảm bảo lấy đúng context
                  barrierDismissible: false,
                  builder: (BuildContext dialogContext) {
                    // ignore: deprecated_member_use
                    return WillPopScope(
                      onWillPop: () async =>
                          false, // Ngăn người dùng đóng dialog bằng nút back
                      child: const AlertDialog(
                        content: Row(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(width: 20),
                            Text("Đang xử lý thanh toán..."),
                          ],
                        ),
                      ),
                    );
                  },
                );
                // Lấy thời gian delay ngẫu nhiên từ hàm getRandomDelayTime
                int randomDelay = await getRandomDelayTime();

                // Đợi thời gian ngẫu nhiên để giả lập quá trình thanh toán
                await Future.delayed(Duration(seconds: randomDelay));
                print("randomDelay: $randomDelay");

                // Kiểm tra nếu widget vẫn mounted trước khi tắt dialog
                if (mounted) {
                  // ignore: use_build_context_synchronously
                  Navigator.of(context, rootNavigator: true)
                      .pop(); // Tắt dialog loading
                }
                bool isBikeBooked = false;
                if (!isBikeBooked) {
                  print("userId: $userId");
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
                      luu = _selectedStartDate;
                      luu2 = _selectedEndDate;
                      setState(() {});

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
                    } else {
                      print('No paymentIds found.');
                    }
                  } else {
                    // Nếu xe đã được đặt, hiển thị dialog thông báo
                    // List<Map<String, dynamic>> bookedBikes =
                    //     await FirebaseBikeRepo()
                    //         .getBookedBikes(userId!, sessionId!);

                    // if (bookedBikes.isNotEmpty && mounted) {
                    //   String bikeDetails = '';
                    //   for (var bike in bookedBikes) {
                    //     String bikeName = bike['bikeName'] ?? 'Không có tên';
                    //     String bikeLicensePlate =
                    //         bike['bikeLicensePlate'] ?? 'Không có biển số';
                    //     bikeDetails +=
                    //         'Tên xe: $bikeName\nBiển số: $bikeLicensePlate\n';
                    //   }

                    if (mounted) {
                      showDialog(
                        context: Navigator.of(context, rootNavigator: true)
                            .context, // Sử dụng rootNavigator
                        builder: (BuildContext dialogContext) {
                          return AlertDialog(
                            title: const Text('Thông báo'),
                            content: Text('Xe đã được đặt:\n'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(dialogContext).pop();
                                },
                                child: const Text('Đóng'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  }
                }
              } catch (e) {
                print("Lỗi khi xử lý thanh toán: $e");

                // Đảm bảo dialog được đóng nếu có lỗi
                if (mounted) {
                  Navigator.of(context, rootNavigator: true)
                      .pop(); // Tắt dialog loading nếu có lỗi
                }
              }
            }
          }
        });
  }

  void _showPaymentMethodSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Chọn phương thức thanh toán",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              _buildPaymentOptionGoGPay(context, Icons.credit_card, "GoGPay",
                  "Số dư ví: ${oCcy.format(amount3)} ₫"),
              _buildPaymentOption(context, Icons.credit_card, "Thẻ ATM", ""),
              _buildPaymentOption(
                  context, Icons.local_activity, "SHOPEEPAY", ""),
              _buildPaymentOption(context, Icons.payment, "ZALO",
                  "Nhập mã: GIAMSAU giảm 50% tối đa 40k cho bạn mới"),
              _buildPaymentOption(context, Icons.account_balance_wallet, "MOMO",
                  "Nhập mã: GOGMOMO5K giảm 5k cho Bạn Mới đơn từ 300k"),
              _buildPaymentOption(context, Icons.account_balance, "VNPAY",
                  "Nhập mã: VNPAYGOG7 giảm 5k với đơn từ 100k, giảm 15k với đơn từ 450k"),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentOption(
      BuildContext context, IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      subtitle: subtitle.isNotEmpty
          ? Text(subtitle, style: const TextStyle(color: Colors.red))
          : null,
      trailing: Radio(
        value: title,
        groupValue: null, // Replace with selected value
        onChanged: (value) {
          // Handle selection
        },
      ),
      onTap: () {
        // Handle tap
      },
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
