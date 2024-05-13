import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hotel_booking_ui/futures/hotel_bloc/get_hotel_bloc.dart';
import 'package:flutter_hotel_booking_ui/modules/explore/hotel_list_view_page.dart';
import 'package:flutter_hotel_booking_ui/routes/route_names.dart';
import '../../models/hotel_list_data.dart';

class FavoritesListView extends StatefulWidget {
  final AnimationController animationController;

  const FavoritesListView({Key? key, required this.animationController})
      : super(key: key);
  @override
  _FavoritesListViewState createState() => _FavoritesListViewState();
}

class _FavoritesListViewState extends State<FavoritesListView> {
  @override
  void initState() {
    widget.animationController.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetHotelBloc, GetHotelState>(
      builder: (context, state) {
        if (state is GetHotelSuccess) {
          return Container(
            child: ListView.builder(
              itemCount: state.hotels.length,
              padding: EdgeInsets.only(top: 8, bottom: 8),
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                var count = state.hotels.length > 10 ? 10 : state.hotels.length;
                var animation = Tween(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                        parent: widget.animationController,
                        curve: Interval((1 / count) * index, 1.0,
                            curve: Curves.fastOutSlowIn)));
                widget.animationController.forward();
                //Favorites hotel data list and UI View
                return HotelListViewPage(
                  callback: () {
                    NavigationServices(context)
                        .gotoRoomBookingScreen(state.hotels[index].titleTxt);
                  },
                  hotelData: state.hotels[index],
                  animation: animation,
                  animationController: widget.animationController,
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
    );
  }
}
