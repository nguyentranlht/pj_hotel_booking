import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hotel_booking_ui/futures/get_hotel_bloc/get_hotel_bloc.dart';
import 'package:flutter_hotel_booking_ui/modules/myTrips/hotel_list_view.dart';
import 'package:flutter_hotel_booking_ui/routes/route_names.dart';
import 'package:hotel_repository/hotel_repository.dart';

class UpcomingListView extends StatefulWidget {
  final AnimationController animationController;

  const UpcomingListView({Key? key, required this.animationController})
      : super(key: key);
  @override
  _UpcomingListViewState createState() => _UpcomingListViewState();
}

class _UpcomingListViewState extends State<UpcomingListView> {
  @override
  void initState() {
    widget.animationController.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetHotelBloc(FirebaseHotelRepo())..add(GetHotel()),
      child: BlocBuilder<GetHotelBloc, GetHotelState>(
        builder: (context, state) {
          if (state is GetHotelSuccess) {
            return Container(
              child: ListView.builder(
                itemCount: state.hotels.length,
                padding: EdgeInsets.only(top: 8, bottom: 16),
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  var count =
                      state.hotels.length > 10 ? 10 : state.hotels.length;
                  var animation = Tween(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                          parent: widget.animationController,
                          curve: Interval((1 / count) * index, 1.0,
                              curve: Curves.fastOutSlowIn)));
                  widget.animationController.forward();
                  //Upcoming UI view and hotel list
                  return HotelListView(
                    callback: () {
                      NavigationServices(context).gotoRoomBookingScreen(
                          state.hotels[index].titleTxt,
                          state.hotels[index].hotelId);
                    },
                    hotelData: state.hotels[index],
                    animation: animation,
                    animationController: widget.animationController,
                    isShowDate: true,
                  );
                },
              ),
            );
          } else if (state is GetHotelLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return const Center(
              child: Text("An error has occured"),
            );
          }
        },
      ),
    );
  }
}
