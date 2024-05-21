import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import '../user_repository.dart';

abstract class UserRepository {
  Stream<User?> get user;

  Future<void> signIn(String email, String password);

  Future<void> signInGoogle();

  Future<void> signInFacebook();

  Future<void> logOut();

  Future<MyUser> signUp(MyUser myUser, String password);

  Future<void> resetPassword(String email);

  Future<void> setUserData(MyUser user);

  Future<MyUser> getMyUser(String myUserId);

  Future<String> uploadPicture(String file, String userId);

  Future<void> showUserNameDialogAlert(BuildContext context, String name);

  Future<String?> getUserId();

  Future<String?> getUserWallet();

  Future<String?> saveUserWallet(String wallet);


  Future<String?> updateUserWallet(String userId, String amount);

  Future<Stream<QuerySnapshot>> getRoomPayment(String id);
}
