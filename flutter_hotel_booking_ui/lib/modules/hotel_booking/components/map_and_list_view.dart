import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ui/modules/hotel_booking/components/time_date_view.dart';
import 'package:hotel_repository/hotel_repository.dart';

class MapAndListView extends StatelessWidget {
  final List<Hotel> hotelList;
  final Widget searchBarUI;

  const MapAndListView(
      {Key? key, required this.hotelList, required this.searchBarUI})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StatefulBuilder(
        builder: (context, state) {
          return Column(
            children: <Widget>[
              searchBarUI,
              TimeDateView(),
              Expanded(
                child: Stack(
                  children: <Widget>[
                    // GoogleMapUIView(
                    //   hotelList: hotelList,
                    // ),
                    IgnorePointer(
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context)
                                  .scaffoldBackgroundColor
                                  .withOpacity(1.0),
                              Theme.of(context)
                                  .scaffoldBackgroundColor
                                  .withOpacity(0.4),
                              Theme.of(context)
                                  .scaffoldBackgroundColor
                                  .withOpacity(0.0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      left: 0,
                      child: Container(
                        height: 156,
                        // color: Colors.green,
                        // child: ListView.builder(
                        //   itemCount: hotelList.length,
                        //   padding:
                        //       EdgeInsets.only(top: 8, bottom: 8, right: 16),
                        //   scrollDirection: Axis.horizontal,
                        //   itemBuilder: (context, index) {
                        //     return MapHotelListView(
                        //       callback: () {
                        //         NavigationServices(context)
                        //             .gotoRoomBookingScreen(
                        //                 hotelList[index].titleTxt);
                        //       },
                        //       hotelData: hotelList[index],
                        //     );
                        //   },
                        // ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
