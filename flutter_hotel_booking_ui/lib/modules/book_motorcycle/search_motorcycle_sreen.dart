import 'dart:async';
import 'package:bike_repository/bike_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ui/utils/themes.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:user_repository/user_repository.dart';
import '../../routes/route_names.dart';

class SearchMotorcycleScreen extends StatefulWidget {
  const SearchMotorcycleScreen({super.key});

  @override
  State<SearchMotorcycleScreen> createState() => _SearchMotorcycleScreenState();
}

class _SearchMotorcycleScreenState extends State<SearchMotorcycleScreen> {
  String? userId, bikeId, nameHotel, sessionId;
  Stream<List<Map<String, dynamic>>>? historySearchStream;
  final oCcy = NumberFormat("#,##0", "vi_VN");
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  getthesharedpref() async {
    userId = await FirebaseUserRepository().getUserId();
    sessionId = await FirebaseBikeRepo().getLatestSessionId(userId!);
    setState(() {});
  }

  ontheload() async {
    await getthesharedpref();
    historySearchStream =
        FirebaseBikeRepo().getHistorySearchWithSessionId(userId!, sessionId!);
    setState(() {});
  }

  @override
  void initState() {
    ontheload();
    super.initState();
  }

  Widget motorcycleHistorySearch() {
    return StreamBuilder<List<Map<String, dynamic>>>(
        stream: historySearchStream,
        builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          List<Map<String, dynamic>> bikes = snapshot.data!;

          if (bikes.isEmpty) {
            return const Center(
              child: Text(
                "No bikes found in history",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: bikes.length,
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              Map<String, dynamic> bike = bikes[index];

              if (bike.isEmpty) {
                return Container(); // Fallback UI if bike data is null
              }

              String bikeStatus =
                  bike['bikeStatus'] ?? "Trạng thái không xác định";
              String bikeName = bike['bikeName'] ?? "Không có tên";
              String bikeImage = bike['bikeImage'] ?? "";
              int bikeRentPricePerDay = bike['bikeRentPricePerDay'] ?? 0;

              return bikeStatus == "Có Sẵn"
                  ? Container()
                  : Slidable(
                      key: Key(bikeName),
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          const SizedBox(
                            width: 2,
                          ),
                          SlidableAction(
                            onPressed: (context) async {
                              try {
                                // Kiểm tra xe có tồn tại trong MarketHistory không
                                bool exists = await FirebaseBikeRepo()
                                    .checkBikeExistsInMarketHistory(
                                        userId!, bike['bikeId']);

                                if (exists) {
                                  // Hiển thị thông báo nếu xe đã tồn tại
                                  _scaffoldMessengerKey.currentState
                                      ?.showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        'Xe đã tồn tại trong giỏ hàng!',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                      backgroundColor: Colors.red.shade400,
                                      duration: const Duration(seconds: 2),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                  return; // Kết thúc hàm nếu xe đã tồn tại
                                }

                                // Thêm xe vào giỏ hàng
                                await FirebaseBikeRepo().addBikeToMarketHistory(
                                    userId!, sessionId!, bike);

                                // Hiển thị thông báo thành công
                                _scaffoldMessengerKey.currentState
                                    ?.showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Đã thêm xe vào giỏ hàng thành công!',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                    backgroundColor: Colors.green.shade700,
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              } catch (e) {
                                // Hiển thị thông báo lỗi
                                _scaffoldMessengerKey.currentState
                                    ?.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Lỗi khi thêm xe: $e',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                    backgroundColor: Colors.red.shade700,
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              }
                            },
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            icon: Icons.add_shopping_cart,
                            label: 'Thêm xe',
                            borderRadius: BorderRadius.circular(12),
                            padding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 15.0),
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                          SlidableAction(
                            onPressed: (context) async {
                              try {
                                // Sử dụng `context` của `StatefulWidget` thay vì `context` của callback
                                final BuildContext safeContext = this.context;

                                // Xóa dữ liệu trong MarketHistory trước khi thêm xe vào MarketHistory
                                await FirebaseBikeRepo()
                                    .clearMarketHistory(userId!);
                                await FirebaseBikeRepo()
                                    .addBikeAndDateTimeToMarketHistory(
                                        userId!, sessionId!, bike);

                                // Thêm một khoảng trễ để đảm bảo UI ổn định
                                await Future.delayed(
                                    const Duration(milliseconds: 180));

                                // Kiểm tra widget còn mounted không trước khi điều hướng
                                if (mounted) {
                                  // Sử dụng context an toàn từ StatefulWidget
                                  NavigationServices(safeContext)
                                      .gotoPaymentMotorcycle();
                                }
                              } catch (e) {
                                // Hiển thị thông báo lỗi nếu có lỗi xảy ra
                                if (mounted) {
                                  _scaffoldMessengerKey.currentState
                                      ?.showSnackBar(
                                    SnackBar(
                                      content: Text('Lỗi khi đặt xe: $e'),
                                      backgroundColor: Colors.red,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                  print('Lỗi khi đặt xe: $e');
                                }
                              }
                            },
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            icon: Icons.motorcycle,
                            label: 'Đặt xe',
                            borderRadius: BorderRadius.circular(12),
                            padding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 15.0),
                          ),
                        ],
                      ),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Material(
                          elevation: 5.0,
                          shadowColor: Colors.black26,
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.white,
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: SizedBox(
                                    height: 140,
                                    width: 140,
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
                                const SizedBox(width: 30.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        bikeName,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 10.0),
                                      Text(
                                        bikeRentPricePerDay > 0
                                            ? "${oCcy.format(bikeRentPricePerDay)} ₫/ngày"
                                            : "Giá không khả dụng",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(height: 10.0),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0, vertical: 4.0),
                                        decoration: BoxDecoration(
                                          color: bikeStatus == "Đã đặt"
                                              ? Colors.redAccent
                                              : Colors.orangeAccent,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          bikeStatus,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
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
              const SizedBox(height: 5.0),
              SizedBox(
                height: MediaQuery.of(context).size.height / 1.6,
                child: motorcycleHistorySearch(),
              ),
              const Spacer(),
              const Divider(),
              const SizedBox(height: 20.0),
              GestureDetector(
                onTap: () async {
                  showDialog(
                    context: context,
                    barrierDismissible:
                        false, // Ngăn người dùng đóng dialog khi đang load
                    builder: (BuildContext dialogContext) {
                      return WillPopScope(
                        onWillPop: () async =>
                            false, // Ngăn nút back đóng dialog
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
                  await FirebaseBikeRepo()
                      .addBikeAndDateTimeToMarketHistory2(userId!, sessionId!);

                  NavigationServices(context).gotoMarketMotorcycle();
                  if (mounted) {
                    // ignore: use_build_context_synchronously
                    Navigator.of(context, rootNavigator: true)
                        .pop(); // Tắt dialog loading
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.only(
                      left: 25.0, right: 25.0, bottom: 60.0, top: 5.0),
                  child: const Center(
                    child: Text(
                      "Di chuyển sang giỏ hàng",
                      style: TextStyle(
                        color: Colors.white,
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
      ),
    );
  }

  _appBar() {
    return AppBar(
      leading: GestureDetector(
        onTap: () async {
          await FirebaseBikeRepo().clearMarketHistory(userId!);
          Navigator.pop(context);
        },
        child: const Icon(
          Icons.arrow_back_ios_new_outlined,
          color: Color(0xFF373866),
        ),
      ),
      centerTitle: true,
      title: const Text(
        "Tìm kiếm theo yêu cầu",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
    );
  }
}
