import 'dart:developer';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:user_repository/src/models/my_user.dart';
import 'package:user_repository/src/models/session_manager.dart';
import 'entities/entities.dart';
import 'user_repo.dart';
import 'models/input_textfield.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseUserRepository implements UserRepository {
  TextEditingController _fnameController = TextEditingController();
  TextEditingController _lnameController = TextEditingController();
  final nameFocusNode = FocusNode();
  FirebaseUserRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FacebookLogin? facebookAuth,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _facebookAuth = facebookAuth ?? FacebookLogin();
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FacebookLogin _facebookAuth;
  final usersCollection = FirebaseFirestore.instance.collection('users');
  DatabaseReference ref = FirebaseDatabase.instance.ref().child('User');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
      final DateFormat dateFormat = DateFormat('dd-MM-yyyy');

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
  Future<int?> getAmountFromPayment(String userId, String paymentId) async {
  try {
    DocumentSnapshot paymentDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('payment')
        .doc(paymentId)
        .get();

    if (paymentDoc.exists) {
      int? PerNight = paymentDoc.get('PerNight');
      return PerNight;
    } else {
      print("Không tìm thấy thông tin về gia tien trong payment.");
      return null;
    }
  } catch (e) {
    print('Lỗi khi lấy thông tin gia tien từ payment: $e');
    throw e;
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
  Future<void> signInFacebook() async {
    try {
      final FacebookLoginResult loginResult = await _facebookAuth.logIn();
      if (loginResult.status == FacebookLoginStatus.success) {
        final FacebookAccessToken accessToken = loginResult.accessToken!;
        final credential = FacebookAuthProvider.credential(accessToken.token);
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
      await _facebookAuth.logOut();
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
  Future<void> showUserNameDialogAlert(
      BuildContext context, String name) async {
    _fnameController.text = name;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Center(child: Text('Update User Name')),
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
                    onValidator: (value) {},
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel')),
              TextButton(
                  onPressed: () {
                    ref.child(SessionController().userId.toString()).update({
                      'firstname': _fnameController.text.toString()
                    }).then((value) {
                      _fnameController.clear();
                    });
                    Navigator.pop(context);
                  },
                  child: Text('OK'))
            ],
          );
        });
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
        final snapshot =
            await _firestore.collection('users').doc(user.uid).get();
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

  Future<Stream<QuerySnapshot>> GetMyUser(String name) async {
    return await FirebaseFirestore.instance.collection(name).snapshots();
  }

  Future<Stream<QuerySnapshot>> getRoomPayment(String id) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .collection("payment")
        .snapshots();
  }

  Future<void> updateIsSelectedForUserPayments(String userId) async {
    var userDoc = FirebaseFirestore.instance.collection('users').doc(userId);

    var paymentCollection = userDoc.collection('payment');

    var querySnapshot =
        await paymentCollection.where('isSelected', isEqualTo: false).get();

    for (var doc in querySnapshot.docs) {
      await doc.reference.update({'isSelected': true});
    }
  }

  @override
  Future<Map<String, dynamic>?> getPaymentForUser(
      String userId, String roomId) async {
    try {
      DocumentSnapshot paymentDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('payment')
          .doc(roomId)
          .get();

      if (paymentDoc.exists) {
        // Trả về dữ liệu của document "Payment" nếu tồn tại
        return paymentDoc.data() as Map<String, dynamic>;
      } else {
        // Trả về null nếu document "Payment" không tồn tại
        return null;
      }
    } catch (e) {
      print('Lỗi khi tìm kiếm payment: $e');
      rethrow;
    }
  }

  @override
  Future<void> addPaymentToRoom(
      Map<String, dynamic> paymentData, String userId) async {
    try {
      CollectionReference paymentsCollectionRef =
          _firestore.collection('users').doc(userId).collection('payment');

      DocumentReference newPaymentRef = paymentsCollectionRef.doc();
      String paymentId = newPaymentRef.id; // Lấy ID tự sinh

      // Thêm document với dữ liệu thanh toán và ID tự sinh
      await newPaymentRef.set({
        ...paymentData,
        'paymentId': paymentId // Lưu trữ paymentId trong document (nếu cần)
      });
    } catch (e) {}
  }

  @override
  Future<void> deletePaymentFromRoom(String userId, String paymentId) async {
    try {
      DocumentReference paymentDocRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('payment')
          .doc(paymentId);

      // Xóa document
      await paymentDocRef.delete();

      print('Payment with ID $paymentId deleted successfully.');
    } catch (e) {
      print('Error deleting payment: $e');
    }
  }

  Future<void> updateUserRoomId(String userId, String roomId) async {
    try {
      await userCollection.doc(userId).update({'roomId': roomId});
    } catch (error) {
      throw Exception('Failed to update user room ID: $error');
    }
  }

  Future<void> removeUserRoomId(String userId) async {
    try {
      await userCollection.doc(userId).update({'roomId': FieldValue.delete()});
    } catch (error) {
      throw Exception('Failed to remove user room ID: $error');
    }
  }

  Future<Map<String, dynamic>?> getPaymentData(String userId) async {
    try {
      var paymentQuerySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('payment')
          .where('isSelected', isEqualTo: true)
          .limit(1)
          .get();

      if (paymentQuerySnapshot.docs.isNotEmpty) {
        return paymentQuerySnapshot.docs.first.data();
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting payment data: $e');
      throw e;
    }
  }

  Future<String?> getPaymentId(String userId) async {
    try {
      CollectionReference paymentsCollectionRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('payment');

      QuerySnapshot paymentSnapshot = await paymentsCollectionRef.get();

      if (paymentSnapshot.docs.isNotEmpty) {
        return paymentSnapshot.docs.first
            .id; // Lấy ID của tài liệu đầu tiên (có thể điều chỉnh theo yêu cầu)
      } else {
        return null; // Không có tài liệu thanh toán nào
      }
    } catch (e) {
      print('Error getting paymentId: $e');
      return null;
    }
  }

  Future<DateTime?> getStartDate(String userId, String paymentId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('payment')
          .doc(paymentId)
          .get();

      if (userDoc.exists) {
        String startDateString = userDoc.get('StartDate');
        DateTime startDate = dateFormat.parse(startDateString);
        return startDate;
      } else {
        print("khong thay gia tri StartDate");
        return null;
      }
    } catch (e) {
      print('Error getting StartDate: $e');
      throw e;
    }
  }

  Future<DateTime?> getEndDate(String userId, String paymentId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('payment')
          .doc(paymentId)
          .get();

      if (userDoc.exists) {
        String endDateString = userDoc.get('EndDate');
        DateTime endDate = dateFormat.parse(endDateString);
        return endDate;
      } else {
        print("khong thay gia tri EndDate");
        return null;
      }
    } catch (e) {
      print('Error getting EndDate: $e');
      throw e;
    }
  }

  Future<int?> getRoomNumberFromPayment(String userId, String paymentId) async {
    try {
      DocumentSnapshot paymentDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('payment')
          .doc(paymentId)
          .get();

      if (paymentDoc.exists) {
        int? roomNumber = paymentDoc.get('NumberRoom');
        return roomNumber;
      } else {
        print("Không tìm thấy thông tin về số phòng trong payment.");
        return null;
      }
    } catch (e) {
      print('Lỗi khi lấy thông tin số phòng từ payment: $e');
      throw e;
    }
  }

  Future<Map<String, String?>> getUserInfo(String userId) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userSnapshot.exists) {
        String? email = userSnapshot['email'];
        String? firstname = userSnapshot['firstname'];
        return {'email': email, 'firstname': firstname};
      } else {
        return {'email': null, 'fristname': null};
      }
    } catch (e) {
      print('Error getting user info: $e');
      return {'email': null, 'fristname': null};
    }
  }
}
