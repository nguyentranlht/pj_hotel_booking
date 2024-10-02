import 'dart:async';
import 'package:bike_repository/bike_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ui/utils/themes.dart';
import 'package:flutter_hotel_booking_ui/widgets/widget_support.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:user_repository/user_repository.dart';
import '../../routes/route_names.dart';

class MotorcycleMarketScreen extends StatefulWidget {
  const MotorcycleMarketScreen({super.key});

  @override
  State<MotorcycleMarketScreen> createState() => _MotorcycleMarketScreenState();
}

class _MotorcycleMarketScreenState extends State<MotorcycleMarketScreen> {
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

  bool flag = false;
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
    sessionId = await FirebaseBikeRepo().getLatestSessionId(userId!);
    amount3 = int.parse(wallet!);
    setState(() {});
  }

  ontheload() async {
    await getthesharedpref();
    var paymentIdsluu =
        await FirebaseUserRepository().getLatestPaymentId(userId!);

    setState(() {
      paymentIds = paymentIdsluu;
    });

    historySearchStream =
        FirebaseBikeRepo().getMarketHistoryWithSessionId(userId!, sessionId!);
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
          return const Center(child: CircularProgressIndicator());
          ;
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          calculateTotal(snapshot.data!);
          setState(() {});
        });

        List<Map<String, dynamic>> bikes = snapshot.data!;

        if (bikes.isEmpty) {
          flag = false;
          return const Center(child: Text("No bikes found in shopping cart"));
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
              flag = false;
              return Container(); // Fallback UI if bike data is null
            } else {
              String bikeStatus =
                  bike['bikeStatus'] ?? "Trạng thái không xác định";
              String bikeName = bike['bikeName'] ?? "Không có tên";
              String bikeImage = bike['bikeImage'] ?? "";
              int bikeRentPricePerDay = bike['bikeRentPricePerDay'] ?? 0;
              String bikeId = bike['bikeId'];
              flag = true;
              // Only display items with 'bikeStatus' not equal to "Có Sẵn"
              return bikeStatus == "Có Sẵn"
                  ? Container()
                  : Slidable(
                      key: Key(bikeName), // Use bikeName as a unique key
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
                                    content:
                                        const Text("Bạn có chắc muốn xoá?"),
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
                                  if (userId!.isNotEmpty &&
                                      bikeName.isNotEmpty) {
                                    await FirebaseBikeRepo()
                                        .removeBikeFromHistorySearch(
                                            userId!, sessionId!, bikeId);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Đã xóa khỏi tìm kiếm thành công'),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'User ID or Payment ID is null'),
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
            }
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
                showDialog(
                  context: context,
                  barrierDismissible:
                      false, // Ngăn người dùng đóng dialog khi đang load
                  builder: (BuildContext dialogContext) {
                    return WillPopScope(
                      onWillPop: () async => false, // Ngăn nút back đóng dialog
                      child: const Center(
                        // Đặt vòng tròn loading ở giữa màn hình
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.lightGreen), // Màu sắc giống hình
                        ),
                      ),
                    );
                  },
                );
                if (flag == true) {
                  await FirebaseBikeRepo().clearPaymentHistory(userId!);
                  // Chuyển đến trang thanh toán nếu điều kiện đúng
                  NavigationServices(context).gotoPaymentMotorcycle();
                  if (mounted) {
                    // ignore: use_build_context_synchronously
                    Navigator.of(context, rootNavigator: true)
                        .pop(); // Tắt dialog loading
                  }
                } else {
                  // Hiển thị dialog nhắc người dùng thêm xe vào giỏ hàng
                  if (mounted) {
                    // ignore: use_build_context_synchronously
                    Navigator.of(context, rootNavigator: true)
                        .pop(); // Tắt dialog loading
                  }
                  showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        title: const Text(
                          'Chưa thêm xe vào giỏ hàng!',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        content: const Text(
                          'Bạn cần thêm xe vào giỏ hàng trước khi tiếp tục thanh toán.',
                          style: TextStyle(fontSize: 16),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text(
                              'Thêm xe',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(dialogContext).pop(); // Đóng dialog
                              Navigator.pop(context);
                            },
                          ),
                          TextButton(
                            child: const Text(
                              'Hủy',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(dialogContext).pop(); // Đóng dialog
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
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
                    "Tiến hành thanh toán",
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
        "Giỏ hàng",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
    );
  }
}
