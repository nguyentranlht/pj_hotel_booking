import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ui/modules/admin/admin_profile_screen.dart';
import 'package:flutter_hotel_booking_ui/modules/admin/booking_room_screen.dart';
import 'package:flutter_hotel_booking_ui/modules/admin/booking_motorcycle_screen.dart';
import 'package:flutter_hotel_booking_ui/modules/admin/home_screen.dart';
import 'package:flutter_hotel_booking_ui/utils/themes.dart';
import 'package:flutter_hotel_booking_ui/language/appLocalizations.dart';
import 'package:flutter_hotel_booking_ui/providers/theme_provider.dart';
import 'package:flutter_hotel_booking_ui/modules/bottom_tab/components/tab_button_UI.dart';
import 'package:flutter_hotel_booking_ui/widgets/common_card.dart';
import 'package:location_repository/location_repository.dart';

import 'package:provider/provider.dart';

class BaseScreen extends StatefulWidget {
  const BaseScreen({super.key});

  @override
  _BaseScreenState createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  Location? locations;
  bool _isFirstTime = true;
  Widget _indexView = Container();
  BottomBarType bottomBarType = BottomBarType.HomeAdmin;

  @override
  void initState() {
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);
    _indexView = Container();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startLoadScreen());
    _fetchLocationFromFirebase();
    super.initState();
  }

  Future<void> _fetchLocationFromFirebase() async {
    try {
      // Truy vấn dữ liệu từ Firebase
      String? locationId = 'qRhZnj9YYdo2TC6eNOWq'; // Sử dụng đúng ID này
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('locations')
          .doc(locationId)
          .get();
      if (snapshot.exists && snapshot.data() != null) {
        setState(() {
          locations = Location.fromMap(snapshot
              .data()!); // Sử dụng phương thức fromMap để tạo đối tượng Location
        });
      } else {
        print('Location document does not exist.');
      }
    } catch (e) {
      print('Error fetching location: $e');
    }
  }

  Future _startLoadScreen() async {
    await Future.delayed(const Duration(milliseconds: 480));
    setState(() {
      _isFirstTime = false;
      _indexView = HomeAdminScreen(
        animationController: _animationController,
      );
    });
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (_, provider, child) => Container(
        child: Scaffold(
          bottomNavigationBar: SizedBox(
              height: 68 + MediaQuery.of(context).padding.bottom,
              child: getBottomBarUI(bottomBarType)),
          body: _isFirstTime
              ? const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : _indexView,
        ),
      ),
    );
  }

  void tabClick(BottomBarType tabType) {
    if (tabType != bottomBarType) {
      bottomBarType = tabType;
      _animationController.reverse().then((f) {
        setState(() {
          if (tabType == BottomBarType.HomeAdmin) {
            _indexView = HomeAdminScreen(
              animationController: _animationController,
            );
          } else if (tabType == BottomBarType.Booking) {
            _indexView = const BookingRoomScreen();
          } else if (tabType == BottomBarType.Motorcycle) {
            _indexView = const BookingMotorcycleScreen();
          } else if (tabType == BottomBarType.Setting) {
            _indexView = AdminProfileScreen(
              animationController: _animationController,
            );
          }
        });
      });
    }
  }

  Widget getBottomBarUI(BottomBarType tabType) {
    return CommonCard(
      color: AppTheme.backgroundColor,
      radius: 0,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              TabButtonUI(
                icon: Icons.collections_bookmark_outlined,
                isSelected: tabType == BottomBarType.Booking,
                text: AppLocalizations(context).of("booking"),
                onTap: () {
                  tabClick(BottomBarType.Booking);
                },
              ),
              TabButtonUI(
                icon: Icons.local_hotel,
                isSelected: tabType == BottomBarType.HomeAdmin,
                text: AppLocalizations(context).of("hotel"),
                onTap: () {
                  tabClick(BottomBarType.HomeAdmin);
                },
              ),
              TabButtonUI(
                icon: Icons.motorcycle,
                isSelected: tabType == BottomBarType.Motorcycle,
                text: AppLocalizations(context).of("books_motorcycle"),
                onTap: () {
                  tabClick(BottomBarType.Motorcycle);
                },
              ),
              TabButtonUI(
                icon: Icons.settings,
                isSelected: tabType == BottomBarType.Setting,
                text: AppLocalizations(context).of("setting"),
                onTap: () {
                  tabClick(BottomBarType.Setting);
                },
              ),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).padding.bottom,
          )
        ],
      ),
    );
  }
}

// ignore: constant_identifier_names
enum BottomBarType { Booking, HomeAdmin, Motorcycle, Setting }
