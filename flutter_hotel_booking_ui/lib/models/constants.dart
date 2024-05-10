
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ui/utils/ui_helper.dart';
import 'package:one_context/one_context.dart';
import 'package:flutter_paypal/flutter_paypal.dart';


import 'constants.dart';

import 'constants.dart';

class Constants {
  static const String clientId = 'AdY8QgbNrJ3QwoZBhfjiuPR9CHPBH_sHFZHgAOXQd42I7vCczHix3jlAAMHjM0wGT2SmDYGnLyii8HUf';
  static const String secretKey = 'EIjLw4FljRJAxz3fDDt1T52obSPSS1_ysk1t2qYUggQ9UdVL_Vp0RUT_6KeuhTOT5LrholNUe2-okPG8';
  static const String returnURL = 'https://samplesite.com/return';
  static const String cancelURL = 'https://samplesite.com/cancel';
}

class Fornt_payment extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
   
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PayPal Integration Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) => UsePaypal(
                          sandboxMode: true,
                          clientId: "${Constants.clientId}",
                          secretKey: "${Constants.secretKey}",
                          returnURL: "${Constants.returnURL}",
                          cancelURL: "${Constants.cancelURL}",
                          transactions: const [
                            {
                              "amount": {
                                "total": '10.12',
                                "currency": "USD",
                                "details": {
                                  "subtotal": '10.12',
                                  "shipping": '0',
                                  "shipping_discount": 0
                                }
                              },
                              "description":
                                  "The payment transaction description.",
                              // "payment_options": {
                              //   "allowed_payment_method":
                              //       "INSTANT_FUNDING_SOURCE"
                              // },
                              "item_list": {
                                "items": [
                                  {
                                    "name": "A demo product",
                                    "quantity": 1,
                                    "price": '10.12',
                                    "currency": "USD"
                                  }
                                ],

                                // shipping address is not required though
                                "shipping_address": {
                                  "recipient_name": "Jane Foster",
                                  "line1": "Travis County",
                                  "line2": "",
                                  "city": "Austin",
                                  "country_code": "US",
                                  "postal_code": "73301",
                                  "phone": "+00000000",
                                  "state": "Texas"
                                },
                              }
                            }
                          ],
                          note: "Contact us for any questions on your order.",
                          onSuccess: (Map params) async {
                            print("onSuccess: $params");
                            UiHelper.showAlertDialog('Payment Successfully',
                                title: 'Success');
                          },
                          onError: (error) {
                            print("onError: $error");
                            UiHelper.showAlertDialog(
                                'Unable to completet the Payment',
                                title: 'Error');
                          },
                          onCancel: (params) {
                            print('cancelled: $params');
                            UiHelper.showAlertDialog('Payment Cannceled',
                                title: 'Cancel');
                          }),
                    ),
                  );
                },
                child: Text('Pay With PayPal'))

          ],
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  MyApp({super.key}) {
    OneContext().key = GlobalKey<NavigatorState>();
  }

  
  @override
  Widget build(BuildContext context) {
    log('>> MyApp - build()');
    return OneNotification(
      builder: (_, __) => MaterialApp(
        title: 'Flutter Demo',
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
        // dang chu y
        builder: OneContext().builder,
        navigatorKey: OneContext().key,
      ),
    );
  }
}
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => Fornt_payment();
}

