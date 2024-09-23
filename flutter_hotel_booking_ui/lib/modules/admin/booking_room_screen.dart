import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hotel_booking_ui/modules/admin/book_room_view.dart';
import 'package:flutter_hotel_booking_ui/modules/hotel_detailes/room_book_view.dart';
import 'package:flutter_hotel_booking_ui/utils/text_styles.dart';
import 'package:room_repository/room_repository.dart';
import '../../futures/get_room_bloc/get_room_bloc.dart';

class BookingRoomScreen extends StatefulWidget {
  const BookingRoomScreen({Key? key}) : super(key: key);

  @override
  _BookingRoomScreenState createState() => _BookingRoomScreenState();
}

class _BookingRoomScreenState extends State<BookingRoomScreen>
    with TickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    // Chuyển việc kích hoạt animation vào đây nếu chỉ cần thực hiện một lần
    animationController.forward();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetRoomBloc(FirebaseRoomRepo())..add(GetRooms()),
      child: BlocBuilder<GetRoomBloc, GetRoomState>(
        builder: (context, state) {
          if (state is GetRoomLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is RoomLoaded) {
            return Scaffold(
                body: Column(
              children: <Widget>[
                const SizedBox(height: 80.0),
                Expanded(
                  child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: state.rooms.length,
                      itemBuilder: (context, index) {
                        Stream? streamDateTime = FirebaseFirestore.instance
                            .collection('rooms')
                            .doc(state.rooms[index].roomId)
                            .collection('dateTime')
                            .snapshots();
                        var count =
                            state.rooms.length > 10 ? 10 : state.rooms.length;
                        var animation = Tween(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                            parent: animationController,
                            curve: Interval((1 / count) * index, 1.0,
                                curve: Curves.fastOutSlowIn),
                          ),
                        );
                        return StreamBuilder(
                            stream: streamDateTime,
                            builder: (context, AsyncSnapshot snapshot) {
                              if (!snapshot.hasData) {
                                return const SizedBox(
                                  height:
                                      100, // Giới hạn kích thước của CircularProgressIndicator
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                );
                              }
                              return ListView.builder(
                                  padding: EdgeInsets.zero,
                                  itemCount: snapshot.data.docs.length,
                                  shrinkWrap: true,
                                  physics:
                                      const NeverScrollableScrollPhysics(), // Ngăn cuộn ListView trong
                                  itemBuilder: (context, index1) {
                                    return BookRoomView(
                                      room: state.rooms[index],
                                      ds: snapshot.data.docs[index1],
                                      animation: animation,
                                      animationController: animationController,
                                    );
                                  });
                            });
                      }),
                ),
              ],
            ));
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
