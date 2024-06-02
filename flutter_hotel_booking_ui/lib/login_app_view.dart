import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hotel_booking_ui/futures/get_hotel_bloc/get_hotel_bloc.dart';
import 'package:flutter_hotel_booking_ui/futures/get_room_bloc/get_room_bloc.dart';
import 'package:flutter_hotel_booking_ui/futures/my_user_bloc/my_user_bloc.dart';
import 'package:flutter_hotel_booking_ui/futures/sign_in_bloc/sign_in_bloc.dart';
import 'package:flutter_hotel_booking_ui/futures/update_user_info_bloc/update_user_info_bloc.dart';
import 'package:flutter_hotel_booking_ui/modules/login/welcome_screen.dart';
import 'package:hotel_repository/hotel_repository.dart';
import 'package:room_repository/room_repository.dart';
import 'futures/authentication_bloc/authentication_bloc.dart';
import 'modules/bottom_tab/bottom_tab_screen.dart';


class LoginAppView extends StatelessWidget {
  const LoginAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'flutter_hotel_booking_ui',
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
            background: Color.fromARGB(255, 221, 220, 220),
            onBackground: Colors.black,
            primary: Color.fromARGB(255, 104, 159, 56),
            onPrimary: Colors.black,
            secondary: Color.fromRGBO(26, 19, 27, 1),
            onSecondary: Colors.white,
            tertiary: Color.fromRGBO(255, 204, 128, 1),
            error: Colors.red,
            outline: Color(0xFF424242)),
      ),
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
        if (state.status == AuthenticationStatus.authenticated) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => SignInBloc(
                    userRepository:
                        context.read<AuthenticationBloc>().userRepository),
              ),
              BlocProvider(
                create: (context) => UpdateUserInfoBloc(
                    userRepository:
                        context.read<AuthenticationBloc>().userRepository),
              ),
              BlocProvider(
                create: (context) => MyUserBloc(
                    myUserRepository:
                        context.read<AuthenticationBloc>().userRepository)
                  ..add(GetMyUser(
                      myUserId:
                          context.read<AuthenticationBloc>().state.user!.uid)),
              ),
              BlocProvider(
                  create: (context) =>
                      GetHotelBloc(FirebaseHotelRepo())..add(GetHotel())),
              BlocProvider(
                  create: (context) =>
                      GetRoomBloc(FirebaseRoomRepo())..add(GetRooms()))
            ],
            child: BottomTabScreen(),
          );
        } else {
          return const WelcomeScreen();
        }
      }),
    );
  }
}
