import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../models/my_user.dart';

class FireStoreDb {
  FireStoreDb._privateConstructor();
  static final FireStoreDb instance = FireStoreDb._privateConstructor();
  final db = FirebaseFirestore.instance;

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> getMyUserById(
      String myUserId) async {
    return await db
        .collection("users")
        .where("userId", isEqualTo: myUserId)
        .get();
  }

  @override
  Future<void> setUserData(MyUser user) async {
    try {
      await db
          .collection("users")
          .doc("user_${user.userId}")
          .set(user.toDocument());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<String> uploadPicture(String file, String userId) async {
    try {
      File imageFile = File(file);
      Reference firebaseStoreRef =
          FirebaseStorage.instance.ref().child('$userId/PP/${userId}_lead');
      await firebaseStoreRef.putFile(
        imageFile,
      );
      String url = await firebaseStoreRef.getDownloadURL();
      await db
          .collection("users").doc(userId).update({'picture': url});
      return url;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
