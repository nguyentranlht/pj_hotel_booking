import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hotel_booking_ui/futures/authentication_bloc/authentication_bloc.dart';
import 'package:flutter_hotel_booking_ui/futures/my_user_bloc/my_user_bloc.dart';
import 'package:flutter_hotel_booking_ui/routes/route_names.dart';
import 'package:flutter_hotel_booking_ui/utils/themes.dart';
import 'package:flutter_hotel_booking_ui/widgets/app_constant.dart';
import 'package:flutter_hotel_booking_ui/widgets/widget_support.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:user_repository/user_repository.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  String? wallet, userId, flap;
  int? add;
  TextEditingController amountcontroller = TextEditingController();
  final oCcy = NumberFormat("#,##0", "vi_VN");
  getthesharedpref() async {
    wallet = await FirebaseUserRepository().getUserWallet();
    userId = await FirebaseUserRepository().getUserId();

    setState(() {});
  }

  ontheload() async {
    await getthesharedpref();
    setState(() {});
  }

  @override
  void initState() {
    ontheload();
    super.initState();
  }

  Map<String, dynamic>? paymentIntent;

  @override
  Widget build(BuildContext context) {
    //List<SettingsListData> helpSearchList = SettingsListData.helpSearchList;
    return BlocProvider(
        create: (context) => MyUserBloc(
            myUserRepository: context.read<AuthenticationBloc>().userRepository)
          ..add(GetMyUser(
              myUserId: context.read<AuthenticationBloc>().state.user!.uid)),
        child: BlocBuilder<MyUserBloc, MyUserState>(builder: (context, state) {
          if (state.status == MyUserStatus.success) {
            return Scaffold(
              body: wallet == null
                  ? const CircularProgressIndicator()
                  : Container(
                      margin: const EdgeInsets.only(top: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Material(
                            elevation: 4.0,
                            child: Container(
                              padding: const EdgeInsets.only(bottom: 2.0),
                              child: _appBar(),
                            ),
                          ),
                          const SizedBox(
                            height: 50.0,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10.0),
                            width: MediaQuery.of(context).size.width,
                            decoration:
                                const BoxDecoration(color: Color(0xFFF2F2F2)),
                            child: Row(
                              children: [
                                Image.asset(
                                  "assets/images/wallet.png",
                                  height: 60,
                                  width: 60,
                                  fit: BoxFit.cover,
                                ),
                                const SizedBox(
                                  width: 40.0,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Ví của bạn",
                                      style: AppWidget.boldTextFeildStyle(),
                                    ),
                                    const SizedBox(
                                      height: 5.0,
                                    ),
                                    Text(
                                      "${oCcy.format(int.parse((state.user!.wallet).toString()))} ₫",
                                      style: AppWidget.boldTextFeildStyle(),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 20.0,
                            ),
                            child: Text(
                              "Chọn số tiền",
                              style: AppWidget.boldTextFeildStyle(),
                            ),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  makePayment('100000');
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: const Color.fromARGB(
                                            255, 80, 75, 75)),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    "${oCcy.format(100000)} ₫",
                                    style: AppWidget.boldTextFeildStyle(),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  makePayment('200000');
                                },
                                child: Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: const Color.fromARGB(
                                              255, 80, 75, 75)),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      "${oCcy.format(200000)} ₫",
                                      style: AppWidget.boldTextFeildStyle(),
                                    )),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  makePayment('500000');
                                },
                                child: Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: const Color.fromARGB(
                                              255, 80, 75, 75)),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      "${oCcy.format(500000)} ₫",
                                      style: AppWidget.boldTextFeildStyle(),
                                    )),
                              ),
                              GestureDetector(
                                onTap: () {
                                  makePayment('1000000');
                                },
                                child: Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: const Color.fromARGB(
                                              255, 80, 75, 75)),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      "${oCcy.format(1000000)} ₫",
                                      style: AppWidget.boldTextFeildStyle(),
                                    )),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 50.0,
                          ),
                          GestureDetector(
                            onTap: () {
                              openEdit();
                            },
                            child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12.0),
                                width: MediaQuery.of(context).size.width,
                                decoration:
                                    BoxDecoration(color: AppTheme.primaryColor),
                                child: const Center(
                                  child: Text("Thêm tiền vào ví",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18.0,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.bold)),
                                )),
                          ),
                        ],
                      ),
                    ),
            );
          } else {
            return Container();
          }
        }));
  }

  Future<void> makePayment(String amount) async {
    try {
      paymentIntent = await createPaymentIntent(amount, 'VND');
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
        add = int.parse(wallet!) + int.parse(amount);
        await FirebaseUserRepository().saveUserWallet(add.toString()); //
        await FirebaseUserRepository()
            .updateUserWallet(userId!, add.toString());

        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          barrierDismissible:
              false, // Ngăn người dùng tắt dialog bằng cách nhấn bên ngoài
          builder: (context) => WillPopScope(
            onWillPop: () async =>
                false, // Ngăn người dùng tắt dialog bằng nút back
            child: AlertDialog(
              content: SingleChildScrollView(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              NavigationServices(context).gotoLoginApp();
                            },
                            child: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(
                            width: 16.0,
                          ),
                          Center(
                            child: Text(
                              "Nạp tiền thành công",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.lightGreen.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      const Text(
                        "Cảm ơn",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            // Điều hướng về trang chủ
                            NavigationServices(context).gotoLoginApp();
                          },
                          child: Container(
                            width: 100,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF008080),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Text(
                                "Trang chủ",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        await getthesharedpref();
        setState(() {});
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
    final calculatedAmout = (int.parse(amount));

    return calculatedAmout.toString();
  }

  _appBar() {
    return AppBar(
      backgroundColor: const Color(0xFFDDDCDC),
      leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Colors.black87,
            size: 20,
          )),
      centerTitle: true,
      title: const Text(
        "GoG-Pay",
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          shadows: [
            Shadow(
              blurRadius: 10.0,
              color: Colors.black26,
              offset: Offset(0.5, 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Future openEdit() => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            content: SingleChildScrollView(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Icon(Icons.cancel)),
                        const SizedBox(
                          width: 60.0,
                        ),
                        const Center(
                          child: Text(
                            'Thêm',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF008080),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    const Text("Số tiền"),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black38, width: 2.0),
                          borderRadius: BorderRadius.circular(10)),
                      child: TextField(
                        controller: amountcontroller,
                        decoration: const InputDecoration(
                            border: InputBorder.none, hintText: 'Nhập số tiền'),
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          makePayment(amountcontroller.text);
                        },
                        child: Container(
                          width: 100,
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xFF008080),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                              child: Text(
                            "Trả",
                            style: TextStyle(color: Colors.white),
                          )),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ));
}
