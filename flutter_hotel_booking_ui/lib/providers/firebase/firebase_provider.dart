import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_hotel_booking_ui/providers/firebase/firestore_db.dart';

import '../../models/my_user.dart';
import '../network_provider.dart';
import 'firebase_authentication.dart';

class FireBaseProvider extends NetworkProvider{
  FireBaseProvider._privateConstructor();
  static final FireBaseProvider instance = FireBaseProvider._privateConstructor();

  @override
  Future<MyUser> getMyUserById(String myUserId) async {
    final myuser = (await FireStoreDb.instance.getMyUserById(myUserId))
    .docs
    .map((e)=>MyUser.fromSnapshot(e))
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
  
  @override
  // TODO: implement user
  Stream<User?> get user => throw UnimplementedError();

}