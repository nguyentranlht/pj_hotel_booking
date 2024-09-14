import 'package:flutter_hotel_booking_ui/modules/bottom_tab/bottom_tab_screen.dart';
import 'package:flutter_hotel_booking_ui/motel_app.dart';
import 'package:one_context/one_context.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hotel_booking_ui/common/common.dart';
import 'package:flutter_hotel_booking_ui/language/appLocalizations.dart';
import 'package:flutter_hotel_booking_ui/providers/theme_provider.dart';
import 'package:flutter_hotel_booking_ui/utils/enum.dart';
import 'package:flutter_hotel_booking_ui/modules/splash/introductionScreen.dart';
import 'package:flutter_hotel_booking_ui/modules/splash/splashScreen.dart';
import 'package:flutter_hotel_booking_ui/routes/routes.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

class UiHelper {
  static showAlertDialog(String message, {title = ''}) {
    OneContext().showDialog(
      builder: (ctx) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(2.0))),
          actions: [
            ElevatedButton(
                onPressed: () {
                  OneContext().pop();
                  OnePlatform.app = () => BottomTabScreen();
                },
                child: const Text('Ok'))
          ],
        );
      },
    );
  }
}
