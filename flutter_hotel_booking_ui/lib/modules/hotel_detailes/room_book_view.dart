import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_hotel_booking_ui/language/appLocalizations.dart';
import 'package:flutter_hotel_booking_ui/routes/route_names.dart';
import 'package:flutter_hotel_booking_ui/utils/text_styles.dart';
import 'package:flutter_hotel_booking_ui/widgets/common_button.dart';
import 'package:room_repository/room_repository.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:user_repository/user_repository.dart';
import 'package:intl/intl.dart';

class RoomeBookView extends StatefulWidget {
  final Room room;

  final AnimationController animationController;
  final Animation<double> animation;
  const RoomeBookView(
      {Key? key,
      required this.room,
      required this.animationController,
      required this.animation})
      : super(key: key);

  @override
  _RoomeBookViewState createState() => _RoomeBookViewState();
}

class _RoomeBookViewState extends State<RoomeBookView> {
  // DateTime _selectedDate = DateTime.now();

  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  String? luuStart, luuEnd, luunew, luunew2;

  final TimeOfDay _selectedStartTime = const TimeOfDay(hour: 14, minute: 0);
  final TimeOfDay _selectedEndTime = const TimeOfDay(hour: 12, minute: 0);

  var pageController = PageController(initialPage: 0);
  final oCcy = NumberFormat("#,##0", "vi_VN");
  String? id;
  List<Map<String, DateTime>> bookedDates = [];

  getthesharedpref() async {
    id = await FirebaseUserRepository().getUserId();
    setState(() {});
  }

  ontheload() async {
    await getthesharedpref();

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getBookedDates();
    getthesharedpref();
    ontheload();
  }

  // Hàm định dạng ngày (formatDate) bạn có thể viết theo format mong muốn
  String? formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

// Hàm truy vấn Firebase để lấy danh sách các khoảng thời gian đã đặt
  void getBookedDates() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.room.roomId)
        .collection('dateTime')
        .get();

    List<Map<String, DateTime>> dates = [];

    for (var doc in querySnapshot.docs) {
      String startDateString = doc['StartDate'];
      String endDateString = doc['EndDate'];

      // Parse ngày giờ từ Firebase và thêm vào danh sách bookedDates
      DateTime startDate = DateTime.parse(startDateString);
      DateTime endDate = DateTime.parse(endDateString);

      // Lưu cả startDate và endDate vào Map
      dates.add({
        'start': startDate,
        'end': endDate,
      });
    }

    setState(() {
      bookedDates = dates;
    });
  }

  bool isDateRangeBooked(DateTime start, DateTime end) {
    // Áp dụng thời gian check-in và check-out mặc định
    DateTime checkInTime =
        DateTime(start.year, start.month, start.day, 14); // 14:00 check-in
    DateTime checkOutTime =
        DateTime(end.year, end.month, end.day, 12); // 12:00 check-out

    for (var bookedRange in bookedDates) {
      DateTime bookedStart = bookedRange['start']!;
      DateTime bookedEnd = bookedRange['end']!;

      // Kiểm tra nếu khoảng thời gian người dùng chọn trùng lặp với khoảng thời gian đã đặt
      bool overlaps =
          checkInTime.isBefore(bookedEnd) && checkOutTime.isAfter(bookedStart);

      if (overlaps) {
        return true; // Trùng ngày giờ
      }
    }

    return false; // Không có trùng lặp
  }

  // Hiển thị thông báo nếu ngày đã được đặt
  void showBookingAlert() {
    if (_selectedStartDate != null && _selectedEndDate != null) {
      // Sử dụng ngày giờ check-in và check-out mặc định
      DateTime checkInTime = DateTime(_selectedStartDate!.year,
          _selectedStartDate!.month, _selectedStartDate!.day, 14);
      DateTime checkOutTime = DateTime(_selectedEndDate!.year,
          _selectedEndDate!.month, _selectedEndDate!.day, 12);

      // Kiểm tra nếu ngày giờ đã được đặt
      if (isDateRangeBooked(checkInTime, checkOutTime)) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Thông báo'),
            content: Text(
                "Phòng đã được đặt từ ${formatDate(checkInTime)} đến ${formatDate(checkOutTime)}. Vui lòng chọn ngày khác."),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }
  }

  // Chọn khoảng thời gian cho đặt phòng
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedStartDate != null && _selectedEndDate != null
          ? DateTimeRange(start: _selectedStartDate!, end: _selectedEndDate!)
          : null,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 15)),
    );

    if (picked != null) {
      setState(() {
        _selectedStartDate = picked.start;
        _selectedEndDate = picked.end;
      });
      showBookingAlert();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> images = widget.room.imagePath.split(" ");
    return AnimatedBuilder(
      animation: widget.animationController,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: widget.animation,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 40 * (1.0 - widget.animation.value), 0.0),
            child: Column(
              children: <Widget>[
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: <Widget>[
                    AspectRatio(
                      aspectRatio: 1.5,
                      child: PageView(
                        controller: pageController,
                        pageSnapping: true,
                        scrollDirection: Axis.horizontal,
                        children: <Widget>[
                          for (var image in images)
                            Image.network(
                              image,
                              fit: BoxFit.cover,
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SmoothPageIndicator(
                        controller: pageController, // PageController
                        count: 3,
                        effect: WormEffect(
                            activeDotColor: Theme.of(context).primaryColor,
                            dotColor: Theme.of(context).colorScheme.surface,
                            dotHeight: 10.0,
                            dotWidth: 10.0,
                            spacing: 5.0), // your preferred effect
                        onDotClicked: (index) {},
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, bottom: 16, top: 16),
                  child: Column(
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            widget.room.titleTxt,
                            maxLines: 2,
                            textAlign: TextAlign.left,
                            style: TextStyles(context)
                                .getBoldStyle()
                                .copyWith(fontSize: 24),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Expanded(child: SizedBox()),
                          widget.room.isSelected == false
                              ? SizedBox(
                                  height: 38,
                                  child: CommonButton(
                                    onTap: () async {
                                      // Hiển thị dialog loading
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
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                            Color>(
                                                        Colors.lightGreen),
                                              ),
                                            ),
                                          );
                                        },
                                      );

                                      // Thực hiện các thao tác bất đồng bộ
                                      await FirebaseUserRepository()
                                          .deleteDateTimeWithIsSelectedFalse(
                                              widget.room.roomId);

                                      if (_selectedStartDate == null &&
                                          _selectedEndDate == null) {
                                        // Tắt dialog loading trước khi hiển thị thông báo
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop();

                                        // Hiển thị thông báo nếu không có ngày bắt đầu và kết thúc
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text("Thông báo"),
                                              content: const Text(
                                                  "Vui lòng chọn cả ngày bắt đầu và ngày kết thúc."),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text("OK"),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      } else if (isDateRangeBooked(
                                          _selectedStartDate!,
                                          _selectedEndDate!)) {
                                        // Tắt dialog loading trước khi hiển thị thông báo
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop();

                                        // Hiển thị thông báo nếu khoảng thời gian đã được đặt
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Thông báo'),
                                            content: Text(
                                                "Ngày bắt đầu (${formatDate(_selectedStartDate!)}) và ngày kết thúc (${formatDate(_selectedEndDate!)}) đã được đặt. Vui lòng chọn ngày khác."),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                                child: const Text("OK"),
                                              ),
                                            ],
                                          ),
                                        );
                                      } else if (_selectedStartDate != null &&
                                          _selectedEndDate != null &&
                                          id != null &&
                                          !widget.room.isSelected) {
                                        // Cập nhật dữ liệu trước khi tiếp tục
                                        setState(() {
                                          formatDate2(DateTime date) {
                                            return DateFormat('yyyy-MM-dd')
                                                .format(date);
                                          }

                                          luuStart =
                                              formatDate2(_selectedStartDate!);
                                          luuEnd =
                                              formatDate2(_selectedEndDate!);
                                        });

                                        Map<String, dynamic> addPaymentToRoom2 =
                                            {
                                          "Name": widget.room.titleTxt,
                                          "RoomId": widget.room.roomId,
                                          "PerNight": widget.room.perNight,
                                          "HotelId": widget.room.hotelId,
                                          "isSelected": widget.room.isSelected,
                                          "People": widget.room.roomData.people,
                                          "NumberRoom":
                                              widget.room.roomData.numberRoom,
                                          "ImagePath": widget.room.imagePath,
                                          "StartDate": luuStart,
                                          "EndDate": luuEnd,
                                          "TitleTxt": widget.room.titleTxt,
                                          "StartTime":
                                              _selectedStartTime.toString(),
                                          "EndTime":
                                              _selectedEndTime.toString(),
                                          "userId": id,
                                        };

                                        print(
                                            "StartDate: $luuStart, EndDate: $luuEnd, UserId: $id");

                                        await FirebaseRoomRepo()
                                            .clearUserPayments(id!);
                                        await FirebaseUserRepository()
                                            .removeUserRoomId(id!);
                                        await FirebaseUserRepository()
                                            .addPaymentToUser(
                                                addPaymentToRoom2, id!);
                                        await FirebaseUserRepository()
                                            .updateUserRoomId(
                                                id!, widget.room.roomId);

                                        // Tắt dialog loading trước khi chuyển trang
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop();

                                        // Điều hướng đến trang thanh toán
                                        NavigationServices(context)
                                            .gotoPayment();
                                      }
                                    },
                                    //
                                    buttonTextWidget: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20.0,
                                          right: 20.0,
                                          top: 5,
                                          bottom: 5),
                                      child: Text(
                                        AppLocalizations(context)
                                            .of("book_now"),
                                        textAlign: TextAlign.center,
                                        style: TextStyles(context)
                                            .getRegularStyle(),
                                        // onlick:
                                      ),
                                    ),
                                  ),
                                )
                              : const Text(
                                  "Đã được đặt!",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "${oCcy.format(widget.room.perNight)} ₫",
                            textAlign: TextAlign.left,
                            style: TextStyles(context)
                                .getBoldStyle()
                                .copyWith(fontSize: 20),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 0),
                            child: Text(
                              AppLocalizations(context).of("per_night"),
                              style: TextStyles(context)
                                  .getRegularStyle()
                                  .copyWith(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          InkWell(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(4.0)),
                            onTap: () {},
                            child: const Padding(
                              padding: EdgeInsets.only(left: 8, right: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                              ),
                            ),
                          ),
                          widget.room.isSelected == false
                              ? GestureDetector(
                                  onTap: () async {
                                    await FirebaseUserRepository()
                                        .deleteDateTimeWithIsSelectedFalse(
                                            widget.room.roomId);
                                    _selectDateRange(context);
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.calendar_today,
                                          color: Colors.black, size: 30.0),
                                      const SizedBox(width: 10.0),
                                      if (_selectedStartDate != null &&
                                          _selectedEndDate != null)
                                        Text(
                                          "Từ: ${_selectedStartTime.format(context)} - "
                                          "${_selectedStartDate!.day}/${_selectedStartDate!.month}/${_selectedStartDate!.year} "
                                          "\n"
                                          "Đến: ${_selectedEndTime.format(context)} - "
                                          "${_selectedEndDate!.day}/${_selectedEndDate!.month}/${_selectedEndDate!.year}",
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 18.5,
                                            fontWeight: FontWeight.w500,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        )
                                      else
                                        const Text(
                                          "Chọn ngày",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.w500,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                    ],
                                  ),
                                )
                              : Container()
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(
                  height: 1,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
