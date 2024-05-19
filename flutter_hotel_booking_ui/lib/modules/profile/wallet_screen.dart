import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ui/language/appLocalizations.dart';
import 'package:flutter_hotel_booking_ui/routes/route_names.dart';
import 'package:flutter_hotel_booking_ui/utils/text_styles.dart';
import 'package:flutter_hotel_booking_ui/utils/themes.dart';
import 'package:flutter_hotel_booking_ui/widgets/app_constant.dart';
import 'package:flutter_hotel_booking_ui/widgets/common_appbar_view.dart';
import 'package:flutter_hotel_booking_ui/widgets/common_card.dart';
import 'package:flutter_hotel_booking_ui/widgets/common_search_bar.dart';
import 'package:flutter_hotel_booking_ui/widgets/remove_focuse.dart';
import 'package:flutter_hotel_booking_ui/widgets/widget_support.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/setting_list_data.dart';
import 'package:http/http.dart' as http;


class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  
   Map<String, dynamic>? paymentIntent;



@override
  Widget build(BuildContext context) {
    List<SettingsListData> helpSearchList = SettingsListData.helpSearchList;
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(top: 20.0),
        child: Column(          
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Material(            
            elevation: 2.0,
            child: 
            Container(
              padding: EdgeInsets.only(bottom: 5.0),
              child:  appBar(),
              ),),
              SizedBox(height: 20.0,),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(color: Color(0xFFF2F2F2)),
                child: Row(children: [
                  Image.asset("assets/images/wallet.png", height:60, width: 60, fit: BoxFit.cover,),
                  SizedBox(width: 40.0,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text("Your Wallet", style: AppWidget.LightTextFeildStyle(),),
                    SizedBox(height: 5.0,),
                    Text("\$"+"100", style: AppWidget.boldTextFeildStyle(),),
                  ],)
                ],),
              ),
              SizedBox(height: 20.0,),
              Padding(
                padding: const EdgeInsets.only(left: 20.0,),
                child: Text("Add money", style: AppWidget.boldTextFeildStyle(),),
              ),
               SizedBox(height: 20.0,),
               Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap:(){
                      makePayment('100');
                    },
                child: Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color.fromARGB(255, 80, 75, 75)),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text("\$"+"100",
                  style: AppWidget.boldTextFeildStyle(),
                  ),
                ),
                ),
                 GestureDetector(
                    onTap:(){
                      makePayment('250');
                    },
                  child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Color.fromARGB(255, 80, 75, 75)),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text("\$"+"250",
                    style: AppWidget.boldTextFeildStyle(),)
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color.fromARGB(255, 80, 75, 75)),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text("\$"+"500",
                  style: AppWidget.boldTextFeildStyle(),)
                ),
                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color.fromARGB(255, 80, 75, 75)),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text("\$"+"1000",
                  style: AppWidget.boldTextFeildStyle(),)
                ),
                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color.fromARGB(255, 80, 75, 75)),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text("\$"+"2000",
                  style: AppWidget.boldTextFeildStyle(),)
                ),
               ],),
               SizedBox(height: 50.0,),
               Container(
                margin: EdgeInsets.symmetric(horizontal: 20.0,),
                padding: EdgeInsets.symmetric(vertical:12.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color(0xFF008080)
                ),
                child: Center(child: Text("Add Money", style: TextStyle(color: Colors.white, fontSize: 16.0, fontFamily: 'Poppins', fontWeight: FontWeight.bold )),)              ),         
        ],
        ),
        ),  
    );
    
  }

  Future<void> makePayment(String amount) async{
    try{
      paymentIntent = await createPaymentIntent(amount, 'USD');
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret: paymentIntent!['client_secret'],
                  style: ThemeMode.dark,
                  merchantDisplayName: 'Adnan'))
          .then((value) {});

      //now finally display payment sheeet             
     displayPaymentSheet(amount);
    } catch (e, s) {
      print('exception:$e$s');
    }
  }
  displayPaymentSheet(String amount) async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) async {
        // add = int.parse(wallet!) + int.parse(amount);
        // await SharedPreferenceHelper().saveUserWallet(add.toString());
        // await DatabaseMethods().UpdateUserwallet(id!, add.toString());
        // ignore: use_build_context_synchronously
        showDialog(
            context: context,
            builder: (_) =>  const AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          Text("Payment Successfull"),
                        ],
                      ),
                    ],
                  ),
                ));

        paymentIntent = null;
      }).onError((error, stackTrace) {
        print('Error is:--->$error $stackTrace');
      });
    } on StripeException catch (e) {
      print('Error is:---> $e');
      showDialog(
          context: context,
          builder: (_) => const AlertDialog(
                content: Text("Cancelled "),
              ));
    } catch (e) {
      print('$e');
    }
  }
    //  Future<Map<String, dynamic>>
  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card'
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      // ignore: avoid_print
      print('Payment Intent Body->>> ${response.body.toString()}');
      return jsonDecode(response.body);
    } catch (err) {
      // ignore: avoid_print
      print('err charging user: ${err.toString()}');
    }
  }

  calculateAmount(String amount) {
    final calculatedAmout = (int.parse(amount)) * 100;

    return calculatedAmout.toString();
  }

  Widget appBar() {
    return Column(
      
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CommonAppbarView(
          onBackClick: () {
            Navigator.pop(context);},
            iconData: Icons.arrow_back,

        ),
        Center(
          child: 
          Text("WALLET", style: AppWidget.HeadlineTextFeildStyle().copyWith(fontSize: 34)),
        ),
        Padding(padding: const EdgeInsets.only(left: 24, right: 24, top: 10),
        child: CommonCard(color: AppTheme.backgroundColor, radius: 36,)),
      ],
    );
  }
}

  