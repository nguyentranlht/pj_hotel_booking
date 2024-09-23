import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ui/models/input_textfield.dart';
import 'package:flutter_hotel_booking_ui/models/session_manager.dart';
import 'package:flutter_hotel_booking_ui/providers/firebase/firestore_db.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../models/my_user.dart';
import '../network_provider.dart';
import 'firebase_authentication.dart';

class FireBaseProvider extends NetworkProvider {
  final TextEditingController _fnameController = TextEditingController();
  final TextEditingController _lnameController = TextEditingController();
  DatabaseReference ref = FirebaseDatabase.instance.ref().child('User');
  final nameFocusNode = FocusNode();
  FireBaseProvider._privateConstructor();
  static final FireBaseProvider instance =
      FireBaseProvider._privateConstructor();

  @override
  Future<MyUser> getMyUserById(String myUserId) async {
    final myuser = (await FireStoreDb.instance.getMyUserById(myUserId))
        .docs
        .map((e) => MyUser.fromSnapshot(e))
        .single;
    return myuser;
  }

  @override
  Future<void> logOut() async {
    FireBaseAuthentication.instance.logOut();
  }

  @override
  Future<void> resetPassword(String email) {
    // TODO: implement resetPassword
    throw UnimplementedError();
  }

  @override
  Future<void> setUserData(MyUser user) {
    // TODO: implement setUserData
    throw UnimplementedError();
  }

  @override
  Future<void> signIn(String email, String password) {
    // TODO: implement signIn
    throw UnimplementedError();
  }

  @override
  Future<MyUser> signUp(MyUser myUser, String password) {
    // TODO: implement signUp
    throw UnimplementedError();
  }

  Future<void> showUserNameDialogAlert(
      BuildContext context, String name) async {
    _fnameController.text = name;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Center(child: Text('Update User Name')),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  InputTextField(
                    myController: _fnameController,
                    focusNode: nameFocusNode,
                    onFiledSubmittedValue: (value) {},
                    keyBoardType: TextInputType.text,
                    obscureText: false,
                    hint: 'Enter Name',
                    onValidator: (value) {
                      return null;
                    },
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () {
                    ref.child(SessionController().userId.toString()).update({
                      'firstname': _fnameController.text.toString()
                    }).then((value) {
                      _fnameController.clear();
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('OK'))
            ],
          );
        });
  }

  @override
  // TODO: implement user
  Stream<User?> get user => throw UnimplementedError();
}
