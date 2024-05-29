import 'dart:async';

import 'package:flutter/material.dart';
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
  var pageController = PageController(initialPage: 0);
  final oCcy = new NumberFormat("#,##0", "vi_VN");
  String? id;

  String? formatDate(DateTime? date) {
    if (date == null) return null;
    return DateFormat('dd-MM-yyyy').format(date);
  }

  @override
  getthesharedpref() async {
    id = await FirebaseUserRepository().getUserId();
    setState(() {});
  }

  @override
  ontheload() async {
    await getthesharedpref();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getthesharedpref();
    ontheload();
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedStartDate != null && _selectedEndDate != null
          ? DateTimeRange(start: _selectedStartDate!, end: _selectedEndDate!)
          : null,
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    );

    if (picked != null) {
      setState(() {
        _selectedStartDate = picked.start;
        _selectedEndDate = picked.end;
      });
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
          child: new Transform(
            transform: new Matrix4.translationValues(
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
                          Expanded(child: SizedBox()),
                          widget.room.isSelected == false
                              ? SizedBox(
                                  height: 38,
                                  child: CommonButton(
                                    onTap: () {
                                      if (_selectedStartDate != null &&
                                          _selectedEndDate != null) {
                                        openEdit();
                                      } else {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text("Thông báo"),
                                              content: Text(
                                                  "Vui lòng chọn cả ngày bắt đầu và ngày kết thúc."),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text("OK"),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    },
                                    //
                                    buttonTextWidget: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 16.0,
                                          right: 16.0,
                                          top: 4,
                                          bottom: 4),
                                      child: Text(
                                        AppLocalizations(context)
                                            .of("book_now"),
                                        textAlign: TextAlign.center,
                                        style: TextStyles(context)
                                            .getRegularStyle(),
                                        // onClick:
                                      ),
                                    ),
                                  ),
                                )
                              : Text(
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
                                .copyWith(fontSize: 22),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          InkWell(
                            borderRadius:
                                BorderRadius.all(Radius.circular(4.0)),
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
                                  onTap: () {
                                    _selectDateRange(context);
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.calendar_today,
                                          color: Colors.black, size: 30.0),
                                      SizedBox(width: 10.0),
                                      if (_selectedStartDate != null &&
                                          _selectedEndDate != null)
                                        Text(
                                          "Từ: ${_selectedStartDate!.day}/${_selectedStartDate!.month}/${_selectedStartDate!.year} "
                                          "   "
                                          "Đến: ${_selectedEndDate!.day}/${_selectedEndDate!.month}/${_selectedEndDate!.year}",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 17.0,
                                            fontWeight: FontWeight.w500,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        )
                                      else
                                        Text(
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
                Divider(
                  height: 1,
                )
              ],
            ),
          ),
        );
      },
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
                              Navigator.pop(context);
                            },
                            child: Icon(Icons.cancel)),
                        SizedBox(
                          width: 60.0,
                        ),
                        Center(
                          child: Text(
                            '',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF008080),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Center(
                      child: Text("Đi đến trang thanh toán hoặc hủy",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                          )),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          if (id != null && !widget.room.isSelected) {
                            Map<String, dynamic> addPaymentToRoom = {
                              "Name": widget.room.titleTxt,
                              "RoomId": widget.room.roomId,
                              "PerNight": widget.room.perNight,
                              "HotelId": widget.room.hotelId,
                              "isSelected": widget.room.isSelected,
                              "People": widget.room.roomData.people,
                              "NumberRoom": widget.room.roomData.numberRoom,
                              "ImagePath": widget.room.imagePath,
                              "StartDate": formatDate(_selectedStartDate),
                              "EndDate": formatDate(_selectedEndDate)
                            };
                            await FirebaseRoomRepo().clearUserPayments(id!);
                            await FirebaseUserRepository().removeUserRoomId(id!);
                            await FirebaseUserRepository()
                                .addPaymentToRoom(addPaymentToRoom, id!);
                            await FirebaseUserRepository()
                                .updateUserRoomId(id!, widget.room.roomId);
                          }

                          NavigationServices(context).gotoPayment();
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
                            "Thanh toán",
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
}
