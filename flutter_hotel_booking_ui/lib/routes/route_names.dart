import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hotel_booking_ui/login_app.dart';
import 'package:flutter_hotel_booking_ui/modules/admin/booking_room_screen.dart';
import 'package:flutter_hotel_booking_ui/modules/admin/room_hotel_screen.dart';
import 'package:flutter_hotel_booking_ui/modules/admin/update_hotel.dart';
import 'package:flutter_hotel_booking_ui/modules/admin/update_room.dart';
import 'package:flutter_hotel_booking_ui/modules/base/views/base_screen.dart';
import 'package:flutter_hotel_booking_ui/modules/book_motorcycle/payment_motorcycle.dart';
import 'package:flutter_hotel_booking_ui/modules/book_motorcycle/search_motorcycle_sreen.dart';
import 'package:flutter_hotel_booking_ui/modules/bottom_tab/bottom_tab_screen.dart';
import 'package:flutter_hotel_booking_ui/modules/create_hotel/blocs/create_hotel_bloc/create_hotel_bloc.dart';
import 'package:flutter_hotel_booking_ui/modules/create_hotel/views/create_hotel_screen.dart';
import 'package:flutter_hotel_booking_ui/modules/create_motorcycle/views/create_motorcycle_screen.dart';
import 'package:flutter_hotel_booking_ui/modules/create_room/views/create_room_screen.dart';
import 'package:flutter_hotel_booking_ui/modules/hotel_booking/filter_screen/filters_screen.dart';
import 'package:flutter_hotel_booking_ui/modules/hotel_booking/hotel_home_screen.dart';
import 'package:flutter_hotel_booking_ui/modules/hotel_detailes/hotel_detailes.dart';
import 'package:flutter_hotel_booking_ui/modules/hotel_detailes/reviews_list_screen.dart';
import 'package:flutter_hotel_booking_ui/modules/hotel_detailes/room_booking_screen.dart';
import 'package:flutter_hotel_booking_ui/modules/hotel_detailes/search_screen.dart';
import 'package:flutter_hotel_booking_ui/modules/login/change_password.dart';
import 'package:flutter_hotel_booking_ui/modules/login/forgot_password.dart';
import 'package:flutter_hotel_booking_ui/modules/login/login_screen.dart';
import 'package:flutter_hotel_booking_ui/modules/login/sign_up_Screen.dart';
import 'package:flutter_hotel_booking_ui/modules/profile/country_screen.dart';
import 'package:flutter_hotel_booking_ui/modules/profile/currency_screen.dart';
import 'package:flutter_hotel_booking_ui/modules/profile/edit_profile.dart';
import 'package:flutter_hotel_booking_ui/modules/profile/hepl_center_screen.dart';
import 'package:flutter_hotel_booking_ui/modules/profile/history_screen.dart';
import 'package:flutter_hotel_booking_ui/modules/profile/how_do_screen.dart';
import 'package:flutter_hotel_booking_ui/modules/profile/invite_screen.dart';
import 'package:flutter_hotel_booking_ui/modules/profile/payment_sreen.dart';
import 'package:flutter_hotel_booking_ui/routes/routes.dart';
import 'package:hotel_repository/hotel_repository.dart';
import 'package:room_repository/room_repository.dart';
import 'package:user_repository/user_repository.dart';
import '../futures/authentication_bloc/authentication_bloc.dart';
import '../futures/sign_in_bloc/sign_in_bloc.dart';
import '../modules/profile/wallet_screen.dart';

class NavigationServices {
  NavigationServices(this.context);

  final BuildContext context;

  Future<dynamic> _pushMaterialPageRoute(Widget widget,
      {bool fullscreenDialog = false}) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => widget, fullscreenDialog: fullscreenDialog),
    );
  }

  void gotoSplashScreen() {
    Navigator.pushNamedAndRemoveUntil(
        context, RoutesName.Splash, (Route<dynamic> route) => false);
  }

  void gotoIntroductionScreen() {
    Navigator.pushNamedAndRemoveUntil(context, RoutesName.IntroductionScreen,
        (Route<dynamic> route) => false);
  }

  void gotoLoginApp() async {
    // ignore: void_checks
    return await _pushMaterialPageRoute(LoginApp(FirebaseUserRepository()));
  }

  void gotoLoginScreen() async {
    BlocProvider<SignInBloc>(
      create: (context) => SignInBloc(
          userRepository: context.read<AuthenticationBloc>().userRepository),
      child: const LoginScreen(),
    );
  }

  Future<dynamic> gotoTabScreen() async {
    return await _pushMaterialPageRoute(BottomTabScreen());
  }

  Future<dynamic> gotoSignScreen() async {
    return await _pushMaterialPageRoute(const SignUpScreen());
  }

  Future<dynamic> gotoBaseScreen() async {
    return await _pushMaterialPageRoute(BaseScreen());
  }

  Future<dynamic> gotoCreateHotelScreen() async {
    return await _pushMaterialPageRoute(
      BlocProvider(
        create: (context) => CreateHotelBloc(FirebaseHotelRepo()),
        child: const CreateHotelScreen(),
      ),
    );
  }

  Future<dynamic> gotoHistory() async {
    return await _pushMaterialPageRoute(const HistoryScreen());
  }

  Future<dynamic> gotoForgotPassword() async {
    return await _pushMaterialPageRoute(const ForgotPassword());
  }

  Future<dynamic> gotoSearchScreen() async {
    return await _pushMaterialPageRoute(SearchScreen());
  }

  Future<dynamic> gotoHotelHomeScreen() async {
    return await _pushMaterialPageRoute(HotelHomeScreen());
  }

  Future<dynamic> gotoFiltersScreen() async {
    return await _pushMaterialPageRoute(FiltersScreen());
  }

  Future<dynamic> gotoWallet() async {
    return await _pushMaterialPageRoute(const WalletScreen());
  }

  Future<dynamic> gotoRoomBookingScreen(String hotelname, String hoteId) async {
    return await _pushMaterialPageRoute(
        RoomBookingScreen(hotelName: hotelname, hotelId: hoteId));
  }

  Future<dynamic> gotoBookingRoomScreen() async {
    return await _pushMaterialPageRoute(const BookingRoomScreen());
  }

  Future<dynamic> gotoRoomHotelScreen(String hotelname, String hoteId) async {
    return await _pushMaterialPageRoute(
        RoomHotelScreen(hotelName: hotelname, hotelId: hoteId));
  }

  Future<dynamic> gotoCreateRoomScreen(String hoteId) async {
    return await _pushMaterialPageRoute(CreateRoomScreen(hotelId: hoteId));
  }

  Future<dynamic> gotoCreateMotorcycleScreen(String locationId) async {
    return await _pushMaterialPageRoute(
        CreateMotorcycleScreen(locationId: locationId));
  }

  Future<dynamic> gotoHotelDetailes(Hotel hotelData) async {
    return await _pushMaterialPageRoute(HotelDetailes(
      hotelData: hotelData,
    ));
  }

  Future<dynamic> gotoUpdateHotel(Hotel hotelData) async {
    return await _pushMaterialPageRoute(UpdateHotelForm(
      hotel: hotelData,
    ));
  }

  Future<dynamic> gotoUpdateRoom(Room room) async {
    return await _pushMaterialPageRoute(UpdateRoomForm(
      room: room,
    ));
  }

  Future<dynamic> gotoReviewsListScreen() async {
    return await _pushMaterialPageRoute(ReviewsListScreen());
  }

  Future<dynamic> gotoEditProfile() async {
    return await _pushMaterialPageRoute(EditProfile());
  }

  Future<dynamic> gotoSettingsScreen() async {
    //return await _pushMaterialPageRoute(AdminProfileScreen());
  }

  Future<dynamic> gotoHeplCenterScreen() async {
    return await _pushMaterialPageRoute(HeplCenterScreen());
  }

  Future<dynamic> gotoChangepasswordScreen() async {
    return await _pushMaterialPageRoute(ChangepasswordScreen());
  }

  Future<dynamic> gotoInviteFriend() async {
    return await _pushMaterialPageRoute(InviteFriend());
  }

  Future<dynamic> gotoCurrencyScreen() async {
    return await _pushMaterialPageRoute(CurrencyScreen(),
        fullscreenDialog: true);
  }

  Future<dynamic> gotoPayment() async {
    return await _pushMaterialPageRoute(const PaymentScreen());
  }

  Future<dynamic> gotoHistorySearch() async {
    return await _pushMaterialPageRoute(const SearchMotorcycleScreen());
  }

  Future<dynamic> gotoPaymentMotorcycle() async {
    return await _pushMaterialPageRoute(const PaymentMotorcycleScreen());
  }

  Future<dynamic> gotoCountryScreen() async {
    return await _pushMaterialPageRoute(CountryScreen(),
        fullscreenDialog: true);
  }

  Future<dynamic> gotoHowDoScreen() async {
    return await _pushMaterialPageRoute(const HowDoScreen());
  }
}
