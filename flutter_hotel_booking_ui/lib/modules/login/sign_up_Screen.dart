import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hotel_booking_ui/service/database.dart';
import 'package:flutter_hotel_booking_ui/service/share_pref.dart';
import 'package:flutter_hotel_booking_ui/utils/text_styles.dart';
import 'package:flutter_hotel_booking_ui/utils/themes.dart';
import 'package:flutter_hotel_booking_ui/language/appLocalizations.dart';
import 'package:flutter_hotel_booking_ui/modules/login/facebook_google_button_view.dart';
import 'package:flutter_hotel_booking_ui/routes/route_names.dart';
import 'package:flutter_hotel_booking_ui/utils/validator.dart';
import 'package:flutter_hotel_booking_ui/widgets/common_appbar_view.dart';
import 'package:flutter_hotel_booking_ui/widgets/common_button.dart';
import 'package:flutter_hotel_booking_ui/widgets/common_text_field_view.dart';
import 'package:flutter_hotel_booking_ui/widgets/remove_focuse.dart';
import 'package:random_string/random_string.dart';
import 'package:user_repository/user_repository.dart';

import '../../futures/sign_up_bloc/sign_up_bloc.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  String email = "", password = "", first_name = "", last_name = " ";

  String _errorEmail = '';
  TextEditingController _emailController = TextEditingController();
  String _errorPassword = '';
  TextEditingController _passwordController = TextEditingController();
  String _errorFName = '';
  TextEditingController _fnameController = TextEditingController();
  String _errorLName = '';
  TextEditingController _lnameController = TextEditingController();
  String _role ='';
  TextEditingController _roleController = TextEditingController();
  bool signUpRequired = false;
    final _formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return BlocListener<SignUpBloc, SignUpState>(
      listener: (context, state) {
        if (state is SignUpSuccess) {
          setState(() {
            signUpRequired = false;
          });
        } else if (state is SignUpProcess) {
          setState(() {
            signUpRequired = true;
          });
        } else if (state is SignUpFailure) {
          return;
        }
      },
      child: Container(
        child: Scaffold(
          body: RemoveFocuse(
            onClick: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                //_appBar(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 32),
                          child: FacebookGoogleButtonView(),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            AppLocalizations(context).of("log_with mail"),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).disabledColor,
                            ),
                          ),
                        ),
                        CommonTextFieldView(
                          controller: _fnameController,
                          errorText: _errorFName,
                          padding: const EdgeInsets.only(
                              bottom: 16, left: 24, right: 24),
                          titleText: AppLocalizations(context).of("first_name"),
                          hintText:
                              AppLocalizations(context).of("enter_first_name"),
                          keyboardType: TextInputType.name,
                          onChanged: (String txt) {},
                        ),
                        CommonTextFieldView(
                          controller: _lnameController,
                          errorText: _errorLName,
                          padding: const EdgeInsets.only(
                              bottom: 16, left: 24, right: 24),
                          titleText: AppLocalizations(context).of("last_name"),
                          hintText:
                              AppLocalizations(context).of("enter_last_name"),
                          keyboardType: TextInputType.name,
                          onChanged: (String txt) {},
                        ),
                        CommonTextFieldView(
                          controller: _emailController,
                          errorText: _errorEmail,
                          titleText: AppLocalizations(context).of("your_mail"),
                          padding: const EdgeInsets.only(
                              left: 24, right: 24, bottom: 16),
                          hintText:
                              AppLocalizations(context).of("enter_your_email"),
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (String txt) {},
                        ),
                        CommonTextFieldView(
                          titleText: AppLocalizations(context).of("password"),
                          padding: const EdgeInsets.only(
                              left: 24, right: 24, bottom: 24),
                          hintText:
                              AppLocalizations(context).of('enter_password'),
                          isObscureText: true,
                          onChanged: (String txt) {},
                          errorText: _errorPassword,
                          controller: _passwordController,
                        ),
                        CommonButton(
                          padding:
                              EdgeInsets.only(left: 24, right: 24, bottom: 8),
                              backgroundColor: Colors.lightGreen.shade700,
                          buttonText: AppLocalizations(context).of("sign_up"),
                          onTap: () async {
                            if (_allValidation()) {
                              MyUser myUser = MyUser.empty;
                              myUser = myUser.copyWith(                                 
                                  email: _emailController.text,
                                  firstname: _fnameController.text,
                                  lastname: _lnameController.text,
                                  wallet: '0',                     
                                  role: "user");
                              setState(() {
                                context.read<SignUpBloc>().add(SignUpRequired(
                                    myUser, _passwordController.text));
                              });
                            };
                            //khi da dang nhap
                          //    String Id = randomAlphaNumeric(10);
                          //    Map<String, dynamic> addUserInfo = {
                          //   "FirstName": _fnameController.text,
                          //   "LastName": _lnameController.text,
                          //   "Email": _emailController.text,
                          //   "wallet": "0",
                          //   "Id": Id,
                          //   "Role": "users",
                          //  };
                          // await DatabaseMethods().addUserDetail(addUserInfo, Id);
                          // await SharedPreferenceHelper().saveFirstUserName(_fnameController.text);
                          // await SharedPreferenceHelper().saveLastUserName(_lnameController.text);
                          // await SharedPreferenceHelper().saveUserEmail(_emailController.text);
                          // await SharedPreferenceHelper().saveUserWallet('0');
                          // await SharedPreferenceHelper().saveUserId(Id);
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            AppLocalizations(context).of("terms_agreed"),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).disabledColor,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              AppLocalizations(context)
                                  .of("already_have_account"),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).disabledColor,
                              ),
                            ),
                            InkWell(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                              onTap: () {
                                NavigationServices(context).gotoLoginScreen();
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  AppLocalizations(context).of("login"),
                                  style: TextStyles(context)
                                      .getRegularStyle()
                                      .copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryColor,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).padding.bottom + 24,
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return CommonAppbarView(
      iconData: Icons.arrow_back,
      titleText: AppLocalizations(context).of("sign_up"),
      onBackClick: () {
        Navigator.pop(context);
      },
    );
  }

  bool _allValidation() {
    bool isValid = true;

    if (_fnameController.text.trim().isEmpty) {
      _errorFName = AppLocalizations(context).of('first_name_cannot_empty');
      isValid = false;
    } else {
      _errorFName = '';
    }

    if (_lnameController.text.trim().isEmpty) {
      _errorLName = AppLocalizations(context).of('last_name_cannot_empty');
      isValid = false;
    } else {
      _errorLName = '';
    }

    if (_emailController.text.trim().isEmpty) {
      _errorEmail = AppLocalizations(context).of('email_cannot_empty');
      isValid = false;
    } else if (!Validator.validateEmail(_emailController.text.trim())) {
      _errorEmail = AppLocalizations(context).of('enter_valid_email');
      isValid = false;
    } else {
      _errorEmail = '';
    }

    if (_passwordController.text.trim().isEmpty) {
      _errorPassword = AppLocalizations(context).of('password_cannot_empty');
      isValid = false;
    } else if (_passwordController.text.trim().length < 6) {
      _errorPassword = AppLocalizations(context).of('valid_password');
      isValid = false;
    } else {
      _errorPassword = '';
    }
    setState(() {});
    return isValid;
  }
}
