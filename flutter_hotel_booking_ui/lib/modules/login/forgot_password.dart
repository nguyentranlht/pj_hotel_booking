import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hotel_booking_ui/futures/sign_in_bloc/sign_in_bloc.dart';
import 'package:flutter_hotel_booking_ui/language/appLocalizations.dart';
import 'package:flutter_hotel_booking_ui/modules/login/sign_up_Screen.dart';
import 'package:flutter_hotel_booking_ui/utils/validator.dart';
import 'package:flutter_hotel_booking_ui/widgets/common_appbar_view.dart';


class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {

  TextEditingController mailcontroller = new TextEditingController();
  String email = "";
  final _formkey = GlobalKey<FormState>();

  String _errorEmail = '';
  TextEditingController _emailController = TextEditingController();

  resetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        "Email đặt lại mật khẩu đã được gửi !",
        style: TextStyle(fontSize: 18.0),
      )));
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
          "Không tìm thấy người dùng nào cho email đó.",
          style: TextStyle(fontSize: 18.0),
        )));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Column(
          children:<Widget> [
            appBar(),
            SizedBox(
              height: 70.0,
            ),
            Container(
              alignment: Alignment.topCenter,
              child: Text(
                "Khôi phục mật khẩu",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Text(
              "Nhập email của bạn",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
            ),
            Expanded(
                child: Form(
                  key: _formkey,
                    child: Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: ListView(
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 10.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black38, width: 2.0),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextFormField(
                      controller: mailcontroller,
                      validator: (value) {                        
                        if (value == null || value.isEmpty) {
                            return AppLocalizations(context).of("enter_your_email");
                        } 
                        return null;
                      },
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                          hintText: "Email",
                          hintStyle:
                              TextStyle(fontSize: 18.0, color: Color.fromARGB(255, 156, 153, 153)),
                          prefixIcon: Icon(
                            Icons.person,
                            color: Color.fromARGB(255, 121, 118, 118),
                            size: 30.0,
                          ),
                          border: InputBorder.none),
                    ),
                  ),
                  SizedBox(
                    height: 40.0,
                  ),
                  GestureDetector(
                    onTap: (){
                    if(_formkey.currentState!.validate()){
                      setState(() {
                        email= mailcontroller.text;
                      });
                      resetPassword();
                    }
                    },
                    child: Container(
                      width: 140,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.lightGreen.shade700,
                          borderRadius: BorderRadius.circular(10)),
                      child: Center(
                        child: Text("Gửi Email", style: TextStyle(color: Colors.white,fontSize: 18.0,fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 50.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Không có tài khoản?",
                        style: TextStyle(fontSize: 18.0, color: Colors.black),
                      ),
                      SizedBox(
                        width: 5.0,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Tạo",
                          style: TextStyle(
                              color: Color.fromARGB(223, 20, 66, 28),
                              fontSize: 20.0,
                              fontWeight: FontWeight.w500),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ))),
          ],
        ),
      ),
    );
  }

  Widget appBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CommonAppbarView(
          iconData: Icons.arrow_back,
          //titleText: AppLocalizations(context).of("Password Recovery"),
          onBackClick: () {
           
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

   bool _allValidation() {
    bool isValid = true;
    if (_emailController.text.trim().isEmpty) {
      _errorEmail = AppLocalizations(context).of('email_cannot_empty');
      isValid = false;
    } else if (!Validator.validateEmail(_emailController.text.trim())) {
      _errorEmail = AppLocalizations(context).of('enter_valid_email');
      isValid = false;
    } else {
      _errorEmail = '';
    }
      setState(() {});
    return isValid;
 }
}
