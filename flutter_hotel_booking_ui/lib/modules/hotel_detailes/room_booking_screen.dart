import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hotel_booking_ui/modules/hotel_detailes/room_book_view.dart';
import 'package:flutter_hotel_booking_ui/utils/text_styles.dart';
import 'package:room_repository/room_repository.dart';
import '../../futures/get_room_bloc/get_room_bloc.dart';

class RoomBookingScreen extends StatefulWidget {
  final String hotelName;
  final String hotelId;
  const RoomBookingScreen(
      {Key? key, required this.hotelName, required this.hotelId})
      : super(key: key);
  @override
  _RoomBookingScreenState createState() => _RoomBookingScreenState();
}

class _RoomBookingScreenState extends State<RoomBookingScreen>
    with TickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetRoomBloc(FirebaseRoomRepo())
        ..add(FetchRoomsByHotelId(widget.hotelId)),
      child: BlocBuilder<GetRoomBloc, GetRoomState>(
        builder: (context, state) {
          if (state is GetRoomLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is RoomLoaded) {
            return Scaffold(
              body: Column(
                children: <Widget>[
                  getAppBarUI(),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(0.0),
                      itemCount: state.rooms.length,
                      itemBuilder: (context, index) {
                        var count =
                            state.rooms.length > 10 ? 10 : state.rooms.length;
                        var animation = Tween(begin: 0.0, end: 1.0).animate(
                            CurvedAnimation(
                                parent: animationController,
                                curve: Interval((1 / count) * index, 1.0,
                                    curve: Curves.fastOutSlowIn)));
                        animationController.forward();
                        //room book view and room data
                        return RoomeBookView(
                          room: state.rooms[index],
                          animation: animation,
                          animationController: animationController,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          } else if (state is RoomError) {
            return Center(child: Text(state.message));
          } else {
            return const Center(child: Text('Start Searching Rooms'));
          }
        },
      ),
    );
  }

  Widget getAppBarUI() {
    return Padding(
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
          left: 16,
          right: 16,
          bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: const BorderRadius.all(
                Radius.circular(32.0),
              ),
              onTap: () {
                Navigator.pop(context);
              },
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.arrow_back),
              ),
            ),
          ),
          //   ),
          Expanded(
            child: Center(
              child: Text(
                widget.hotelName,
                style: TextStyles(context).getTitleStyle(),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: const BorderRadius.all(
                Radius.circular(32.0),
              ),
              onTap: () {},
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.favorite_border),
              ),
            ),
          ),
          //   )
        ],
      ),
    );
    // );
  }
}
