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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  String? luuStart;
  String? luuEnd;

  final TimeOfDay _selectedStartTime = const TimeOfDay(hour: 14, minute: 0);
  final TimeOfDay _selectedEndTime = const TimeOfDay(hour: 12, minute: 0);

  var pageController = PageController(initialPage: 0);
  final oCcy = NumberFormat("#,##0", "vi_VN");
  String? id;
  List<DateTime> bookedDates = [];

  String? formatDate(DateTime? date) {
    if (date == null) return null;
    return DateFormat('yyyy-MM-dd').format(date);
  }

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

  // Hàm truy vấn Firebase
  void getBookedDates() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.room.roomId)
        .collection('dateTime')
        .get();
    List<DateTime> dates = [];
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    for (var doc in querySnapshot.docs) {
      // Parse và lưu trữ các ngày đã đặt từ dữ liệu Firestore
      String startDateString = doc['StartDate'];
      String endDateString = doc['EndDate'];

      DateTime startDate = dateFormat.parse(startDateString);
      DateTime endDate = dateFormat.parse(endDateString);
      // Thêm các ngày đã đặt vào danh sách bookedDates
      while (startDate.isBefore(endDate.add(const Duration(days: 1)))) {
        dates.add(startDate);
        startDate = startDate.add(const Duration(days: 1));
      }
    }
    setState(() {
      bookedDates = dates;
    });
  }

  bool isDateRangeBooked(DateTime start, DateTime end) {
    for (DateTime date = start;
        date.isBefore(end.add(const Duration(days: 1)));
        date = date.add(const Duration(days: 1))) {
      if (bookedDates.contains(date)) {
        return true;
      }
    }
    return false;
  }

  void showBookingAlert() {
    if (_selectedStartDate != null &&
        _selectedEndDate != null &&
        isDateRangeBooked(_selectedStartDate!, _selectedEndDate!)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Thông báo'),
          content: Text(
              "Ngày bắt đầu (${formatDate(_selectedStartDate)}) và ngày kết thúc (${formatDate(_selectedEndDate)}) đã được đặt. Vui lòng chọn ngày khác."),
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
                                      await FirebaseUserRepository()
                                          .deleteDateTimeWithIsSelectedFalse(
                                              widget.room.roomId);
                                      if (_selectedStartDate == null &&
                                          _selectedEndDate == null) {
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
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Thông báo'),
                                            content: Text(
                                                "Ngày bắt đầu (${formatDate(_selectedStartDate)}) và ngày kết thúc (${formatDate(_selectedEndDate)}) đã được đặt. Vui lòng chọn ngày khác."),
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
                                        setState(() {
                                          luuStart =
                                              formatDate(_selectedStartDate);
                                          luuEnd = formatDate(_selectedEndDate);
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
