import 'dart:developer';
import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:user_repository/src/models/my_user.dart';
import 'entities/entities.dart';
import 'user_repo.dart';

import 'package:shared_preferences/shared_preferences.dart';

class FirebaseUserRepository implements UserRepository {
  FirebaseUserRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final usersCollection = FirebaseFirestore.instance.collection('users');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream of [MyUser] which will emit the current user when
  /// the authentication state changes.
  ///
  /// Emits [MyUser.empty] if the user is not authenticated.
  @override
  Stream<User?> get user {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      final user = firebaseUser;
      return user;
    });
  }
  

  @override
  Future<MyUser> signUp(MyUser myUser, String password) async {
    try {
      UserCredential user = await _firebaseAuth.createUserWithEmailAndPassword(
          email: myUser.email, password: password);
       myUser = myUser.copyWith(userId: user.user!.uid);
      
      return myUser;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
  

  @override
  Future<void> signIn(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> signInGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await _firebaseAuth.signInWithCredential(credential);
      }
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> logOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> setUserData(MyUser user) async {
    try {
      await usersCollection.doc(user.userId).set(user.toEntity().toDocument());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<MyUser> getMyUser(String myUserId) async {
    try {
      return usersCollection.doc(myUserId).get().then((value) =>
          MyUser.fromEntity(MyUserEntity.fromDocument(value.data()!)));
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
      await usersCollection.doc(userId).update({'picture': url});
      return url;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
  @override
  Future<String?> getUserId() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        return user.uid;
      } else {
        return null;
      }
    } catch (e) {
      log('Error getting user ID: $e');
      rethrow;
    }
  }
  @override
  Future<String?> getUserWallet() async {
  try {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      // Retrieve the wallet address from the Firestore document
      final snapshot = await _firestore.collection('users').doc(user.uid).get();
      if (snapshot.exists) {
        final userData = snapshot.data();
        if (userData != null && userData.containsKey('wallet')) {
          return userData['wallet'] as String;
        }
      }
    }
    return null;
  } catch (e) {
    log('Error getting user wallet: $e');
    rethrow;
  }
  }
  
  @override
Future<String?> saveUserWallet(String wallet) async {
  try {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      // Update the user's Firestore document with the wallet address
      await _firestore.collection('users').doc(user.uid).update({
        'wallet': wallet,
      });
    } else {
      throw Exception('User is not signed in.');
    }
  } catch (e) {
    log('Error saving user wallet: $e');
    rethrow;
  }
}
  @override
  Future<String?> updateUserWallet(String userId, String wallet) async {
  try {
    // Get the user's Firestore document
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (userDoc.exists) {
      // Parse the wallet string to a double
      final newWallet = wallet;
      if (newWallet != null) {
        // Update the 'wallet' field in the user's document
        await _firestore.collection('users').doc(userId).update({
          'wallet': newWallet,
        });

        print('User wallet updated successfully.');
      } else {
        throw Exception('Invalid wallet format.');
      }
    } else {
      throw Exception('User document not found.');
    }
  } catch (e) {
    log('Error updating user wallet: $e');
    rethrow;
  }
}

  Future<Stream<QuerySnapshot>> GetMyUser(String name) async{
    return await FirebaseFirestore.instance.collection(name).snapshots();
  }

    Future addPaymentToRoom(Map<String, dynamic> userInfoMap, String userId) async {
    return await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection("payment")
                .add(userInfoMap);
  }
    Future<Stream<QuerySnapshot>> getRoomPayment(String id) async{
    return await FirebaseFirestore.instance.collection("users").doc(id).collection("payment").snapshots();
  }
}
