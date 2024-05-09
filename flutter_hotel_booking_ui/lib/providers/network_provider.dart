import 'package:firebase_auth/firebase_auth.dart';

import '../models/my_user.dart';

abstract class NetworkProvider{
  Stream<User?> get user;

  Future<void> signIn(String email, String password);

  Future<void> logOut();

  Future<MyUser> signUp(MyUser myUser, String password);

  Future<void> resetPassword(String email);

  Future<void> setUserData(MyUser user);

  Future<MyUser> getMyUserById(String myuserId);
}