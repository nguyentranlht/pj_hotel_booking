// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCKnfirTZVvkXlHJcEu8oV0srOpAxkpOaI',
    appId: '1:144157197167:web:04191a67d35a597c5bde9a',
    messagingSenderId: '144157197167',
    projectId: 'db-hotel-booking',
    authDomain: 'db-hotel-booking.firebaseapp.com',
    storageBucket: 'db-hotel-booking.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA623JD9H1mnIPU6VEhQunZTDbVoyicGnY',
    appId: '1:144157197167:android:aa467ba489f525195bde9a',
    messagingSenderId: '144157197167',
    projectId: 'db-hotel-booking',
    storageBucket: 'db-hotel-booking.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCeZ6c4-JmM6-uHHR0Ufr4KhTz9YRQIfgs',
    appId: '1:144157197167:ios:74d16c924d72d3b45bde9a',
    messagingSenderId: '144157197167',
    projectId: 'db-hotel-booking',
    storageBucket: 'db-hotel-booking.appspot.com',
    iosBundleId: 'com.example.flutterHotelBookingUi',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCeZ6c4-JmM6-uHHR0Ufr4KhTz9YRQIfgs',
    appId: '1:144157197167:ios:74d16c924d72d3b45bde9a',
    messagingSenderId: '144157197167',
    projectId: 'db-hotel-booking',
    storageBucket: 'db-hotel-booking.appspot.com',
    iosBundleId: 'com.example.flutterHotelBookingUi',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCKnfirTZVvkXlHJcEu8oV0srOpAxkpOaI',
    appId: '1:144157197167:web:bc4ba47a98110c565bde9a',
    messagingSenderId: '144157197167',
    projectId: 'db-hotel-booking',
    authDomain: 'db-hotel-booking.firebaseapp.com',
    storageBucket: 'db-hotel-booking.appspot.com',
  );
}
