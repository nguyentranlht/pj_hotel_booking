import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ui/modules/admin/admin_profile_screen.dart';
import 'package:flutter_hotel_booking_ui/modules/admin/booking_room_screen.dart';
import 'package:flutter_hotel_booking_ui/modules/admin/home_screen.dart';
import 'package:flutter_hotel_booking_ui/modules/explore/home_explore_screen.dart';
import 'package:flutter_hotel_booking_ui/modules/myTrips/my_trips_screen.dart';
import 'package:flutter_hotel_booking_ui/modules/profile/profile_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_hotel_booking_ui/utils/themes.dart';
import 'package:flutter_hotel_booking_ui/language/appLocalizations.dart';
import 'package:flutter_hotel_booking_ui/providers/theme_provider.dart';
import 'package:flutter_hotel_booking_ui/modules/bottom_tab/components/tab_button_UI.dart';
import 'package:flutter_hotel_booking_ui/widgets/common_card.dart';
import 'package:provider/provider.dart';

class BaseScreen extends StatefulWidget {
  @override
  _BaseScreenState createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isFirstTime = true;
  Widget _indexView = Container();
  BottomBarType bottomBarType = BottomBarType.HomeAdmin;

  @override
  void initState() {
    _animationController =
        AnimationController(duration: Duration(milliseconds: 400), vsync: this);
    _indexView = Container();
    WidgetsBinding.instance!.addPostFrameCallback((_) => _startLoadScreen());
    super.initState();
  }

  Future _startLoadScreen() async {
    await Future.delayed(const Duration(milliseconds: 480));
    setState(() {
      _isFirstTime = false;
      _indexView = HomeAdminScreen(
        animationController: _animationController,
      );
    });
    _animationController..forward();
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
          bottomNavigationBar: Container(
              height: 68 + MediaQuery.of(context).padding.bottom,
              child: getBottomBarUI(bottomBarType)),
          body: _isFirstTime
              ? Center(
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
        if (tabType == BottomBarType.HomeAdmin) {
          setState(() {
            _indexView = HomeAdminScreen(
              animationController: _animationController,
            );
          });
        } else if (tabType == BottomBarType.Booking) {
          setState(() {
            _indexView = BookingRoomScreen();
          });
        } else if (tabType == BottomBarType.Setting) {
          setState(() {
            _indexView = AdminProfileScreen(
              animationController: _animationController,
            );
          });
        }
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

enum BottomBarType { Booking, HomeAdmin, Setting }
