import 'dart:async';
import 'dart:math';
import 'package:bike_repository/bike_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ui/utils/themes.dart';
import 'package:flutter_hotel_booking_ui/widgets/widget_support.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:user_repository/user_repository.dart';
import '../../routes/route_names.dart';

class PaymentMotorcycleScreen extends StatefulWidget {
  const PaymentMotorcycleScreen({super.key});

  @override
  State<PaymentMotorcycleScreen> createState() =>
      _PaymentMotorcycleScreenState();
}

class _PaymentMotorcycleScreenState extends State<PaymentMotorcycleScreen> {
  String? userId, wallet, paymentId;
  num total = 0;
  int amount2 = 0, note = 0, amount3 = 0;

  Stream<List<Map<String, dynamic>>>? historySearchStream;
  String? sessionId;

  final oCcy = NumberFormat("#,##0", "vi_VN");

  String? luu, luu2, bikeId;
  int? perNight;
  String? customerEmail;
  String? customerName, nameHotel, paymentIds;

  void startTimer() {
    Timer(const Duration(seconds: 3), () {
      amount2 = int.parse(total.toString());
      setState(() {});
    });
  }

  List<int> delayTimes = [3]; // Danh sách thời gian trễ có thể chọn
  List<int> usedDelayTimes = []; // Danh sách các thời gian đã chọn

// Hàm để lấy giá trị thời gian ngẫu nhiên từ danh sách
  Future<int> getRandomDelayTime() async {
    if (delayTimes.isEmpty) {
      await Future.delayed(const Duration(seconds: 3));

      // Khởi động lại danh sách
      delayTimes = List.from(usedDelayTimes);
      usedDelayTimes = [];
    }

    int randomIndex = Random().nextInt(delayTimes.length);
    int selectedTime = delayTimes[randomIndex];

    usedDelayTimes.add(selectedTime);
    delayTimes.removeAt(randomIndex);
    return selectedTime;
  }

  String? formatDate(DateTime? date) {
    if (date == null) return null;
    return DateFormat('dd-MM-yyyy').format(date);
  }

  getthesharedpref() async {
    userId = await FirebaseUserRepository().getUserId();
    wallet = await FirebaseUserRepository().getUserWallet();
    sessionId = await FirebaseBikeRepo().getLatestSessionId(userId!);
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

    historySearchStream =
        FirebaseBikeRepo().getHistorySearchWithSessionId(userId!, sessionId!);

    setState(() {});
  }

  @override
  void initState() {
    ontheload();
    startTimer();
    super.initState();
  }

  void calculateTotal(List<Map<String, dynamic>> bikes) {
    total = 0;
    amount2 = 0;

    for (var bike in bikes) {
      if (bike.containsKey("bikeStatus") && bike["bikeStatus"] == "Có sẵn") {
        total += bike["bikeRentPricePerDay"].toInt();
      }
    }

    amount2 = total.toInt();
  }

  Widget motorcycleHistorySearch() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: historySearchStream,
      builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          calculateTotal(snapshot.data!);
          setState(() {});
        });

        List<Map<String, dynamic>> bikes = snapshot.data!;

        if (bikes.isEmpty) {
          return const Center(child: Text("No bikes found in history"));
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: bikes.length,
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            Map<String, dynamic> bike = bikes[index];

            // Ensure the bike data is not null
            if (bike.isEmpty) {
              return Container(); // Fallback UI if bike data is null
            }
            String bikeStatus =
                bike['bikeStatus'] ?? "Trạng thái không xác định";
            String bikeName = bike['bikeName'] ?? "Không có tên";
            String bikeImage = bike['bikeImage'] ?? "";
            int bikeRentPricePerDay = bike['bikeRentPricePerDay'] ?? 0;
            String bikeId = bike['bikeId'];

            // Only display items with 'bikeStatus' not equal to "Có Sẵn"
            return bikeStatus == "Có Sẵn"
                ? Container()
                : Slidable(
                    key: Key(bikeName), // Use bikeName as a unique key
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
                          padding: const EdgeInsets.all(30),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox(
                                  height: 120,
                                  width: 120,
                                  child: bikeImage.isNotEmpty
                                      ? PageView(
                                          controller: PageController(),
                                          pageSnapping: true,
                                          scrollDirection: Axis.horizontal,
                                          children: <Widget>[
                                            for (var image
                                                in bikeImage.split(" "))
                                              Image.network(
                                                image,
                                                fit: BoxFit.cover,
                                              ),
                                          ],
                                        )
                                      : const Icon(
                                          Icons.image_not_supported,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                ),
                              ),
                              const SizedBox(width: 50.0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(bikeName,
                                      style: TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.fontcolor,
                                      )),
                                  Text(
                                      bikeRentPricePerDay > 0
                                          ? "${oCcy.format(bikeRentPricePerDay)} ₫"
                                          : "Price not available",
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.fontcolor,
                                      )),
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
              height: MediaQuery.of(context).size.height / 1.6,
              child: motorcycleHistorySearch(),
            ),
            const Spacer(),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Tổng tiền",
                    style: AppWidget.boldTextFeildStyle(),
                  ),
                  Text("${oCcy.format(amount2)} ₫",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.fontcolor,
                      ))
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
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.only(
                    left: 25.0, right: 25.0, bottom: 60.0, top: 5.0),
                child: const Center(
                  child: Text(
                    "Chọn phương thức thanh toán",
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
                await Future.delayed(Duration(seconds: randomDelay));
                print("randomDelay: $randomDelay");

                bool isBikeBooked = await FirebaseBikeRepo()
                    .checkIfAnyBikeIsBookedTransaction(userId!, sessionId!);

                // Kiểm tra nếu widget vẫn mounted trước khi tắt dialog
                if (mounted) {
                  // ignore: use_build_context_synchronously
                  Navigator.of(context, rootNavigator: true)
                      .pop(); // Tắt dialog loading
                }

                if (!isBikeBooked) {
                  await FirebaseBikeRepo()
                      .updateBikeStatusAfterPayment(userId!, sessionId!);
                  // Nếu không có xe nào đã được đặt, tiến hành cập nhật ví và thêm vào contracts
                  int amount = int.parse(wallet!) - amount2;
                  await FirebaseUserRepository()
                      .updateUserWallet(userId!, amount.toString());
                  await FirebaseUserRepository()
                      .saveUserWallet(amount.toString());

                  // Gọi hàm thêm dữ liệu vào contracts từ PaymentSearch
                  await FirebaseBikeRepo().addLatestContractFromPaymentSearch(
                      userId!, amount2.toString());

                  if (mounted) {
                    setState(
                        () {}); // Đảm bảo widget vẫn mounted trước khi cập nhật UI
                  }
                  openEdit();
                } else {
                  // Nếu xe đã được đặt, hiển thị dialog thông báo
                  List<Map<String, dynamic>> bookedBikes =
                      await FirebaseBikeRepo()
                          .getBookedBikes(userId!, sessionId!);

                  if (bookedBikes.isNotEmpty && mounted) {
                    String bikeDetails = '';
                    for (var bike in bookedBikes) {
                      String bikeName = bike['bikeName'] ?? 'Không có tên';
                      String bikeLicensePlate =
                          bike['bikeLicensePlate'] ?? 'Không có biển số';
                      bikeDetails +=
                          'Tên xe: $bikeName\nBiển số: $bikeLicensePlate\n';
                    }

                    if (mounted) {
                      showDialog(
                        context: Navigator.of(context, rootNavigator: true)
                            .context, // Sử dụng rootNavigator
                        builder: (BuildContext dialogContext) {
                          return AlertDialog(
                            title: const Text('Thông báo'),
                            content: Text('Xe đã được đặt:\n$bikeDetails'),
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
}
