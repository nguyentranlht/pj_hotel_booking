import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hotel_booking_ui/futures/sign_in_bloc/sign_in_bloc.dart';
import 'package:flutter_hotel_booking_ui/providers/firebase/firebase_authentication.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_hotel_booking_ui/widgets/common_button.dart';

class FacebookGoogleButtonView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _fTButtonUI(context);
  }

  Widget _fTButtonUI(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 24,
          ),
          Expanded(
            child: CommonButton(
              padding: EdgeInsets.zero,
              backgroundColor: Color(0x0FF3C5799),
              buttonTextWidget: _buttonTextUI(),
            ),
          ),
          SizedBox(
            width: 16,
          ),
          Expanded(
            child: CommonButton(
              padding: EdgeInsets.zero,
              backgroundColor: Colors.blueGrey,
              buttonTextWidget: _buttonTextUI(isFacebook: false),
              onTap: () {
                context.read<SignInBloc>().add(SignInWithGoogleRequested());
              },
            ),
          ),
          SizedBox(
            width: 24,
          )
        ],
      ),
    );
  }

  Widget _buttonTextUI({bool isFacebook = true}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Icon(isFacebook ? FontAwesomeIcons.facebookF : FontAwesomeIcons.google,
            size: 20, color: Colors.white),
        SizedBox(
          width: 4,
        ),
        Text(
          isFacebook ? "Facebook" : "Google",
          style: TextStyle(
              fontWeight: FontWeight.w500, fontSize: 16, color: Colors.white),
        ),
      ],
    );
  }
}
