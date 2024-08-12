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
  //update nhieu nguoi
  Future<void> updateIsSelectedForUserPayments(String userId) async {
    var userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
    
    var paymentCollection = userDoc.collection('payment');

    var querySnapshot =
        await paymentCollection.where('isSelected', isEqualTo: false).get();

    for (var doc in querySnapshot.docs) {
      await doc.reference.update({'isSelected': true});
    }
  }

  //update 1 nguoi
  @override
  Future<void> updateIsSelectedForPayment(String userId, String paymentId) async {
  try {
    // Tham chiếu đến tài liệu user cụ thể
    var userDoc = FirebaseFirestore.instance.collection('users').doc(userId);

    // Tham chiếu đến collection 'payment' của user
    var paymentCollection = userDoc.collection('payment');

    // Truy vấn tài liệu có 'paymentId' trùng khớp
    var querySnapshot = await paymentCollection.where('paymentId', isEqualTo: paymentId).get();

    if (querySnapshot.docs.isNotEmpty) {
      // Cập nhật isSelected cho tài liệu trùng paymentId
      var paymentDoc = querySnapshot.docs.first;
      await paymentDoc.reference.update({'isSelected': true});
    }

    // Cập nhật isSelected cho tài liệu trùng paymentId trong collection 'payments'
    var adminPaymentDoc = FirebaseFirestore.instance.collection('payments').doc(paymentId);
    await adminPaymentDoc.update({'isSelected': true});

  } catch (e) {
    // Xử lý lỗi nếu cần
    print('Error updating isSelected: $e');
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
  Future<void> addPaymentToRoom(Map<String, dynamic> paymentData, String userId) async {
    try {
        // Lấy roomId, startDate và endDate từ paymentData
      String roomId = paymentData['RoomId'];
      String startDate = paymentData['StartDate'];
      String endDate = paymentData['EndDate'];

      // Kiểm tra xem phòng đã được đặt trong khoảng thời gian này chưa
      bool isRoomBooked = await checkIfRoomIsBooked(roomId, startDate, endDate);
      
      if (isRoomBooked) {
        // Nếu phòng đã được đặt, không thêm thanh toán và trả về lỗi hoặc thông báo
        print('Room is already booked in the selected date range.');
        return;
      }
      // 1. Tạo một ID cho payment trong collection 'payments' của admin trước
      CollectionReference adminPaymentsCollectionRef = _firestore.collection('payments');
      DocumentReference adminNewPaymentRef = adminPaymentsCollectionRef.doc();
      String paymentId = adminNewPaymentRef.id; // Lấy ID tự sinh từ admin collection

      // 2. Lưu payment vào collection của user
      CollectionReference userPaymentsCollectionRef = _firestore.collection('users').doc(userId).collection('payment');
      DocumentReference userNewPaymentRef = userPaymentsCollectionRef.doc(paymentId); // Sử dụng paymentId đã tạo
      await userNewPaymentRef.set({
        ...paymentData,
        'paymentId': paymentId, // Lưu trữ paymentId
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 3. Lưu payment vào collection 'payments' của admin
      await adminNewPaymentRef.set({
        ...paymentData,
        'paymentId': paymentId, // Lưu trữ paymentId
        'createdAt': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      // Xử lý lỗi nếu cần
      print('Error adding payment: $e');
    }
  }
  
  @override
  Future<bool> checkIfRoomIsBooked(String roomId, String startDate, String endDate) async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomId)
        .collection('bookings')
        .where('StartDate', isLessThanOrEqualTo: endDate)
        .get();

    // Lọc kết quả trong ứng dụng
    bool isBooked = querySnapshot.docs.any((doc) {
      String bookedStartDate = doc['StartDate'];
      String bookedEndDate = doc['EndDate'];
      
      return bookedEndDate.compareTo(startDate) >= 0;
    });

    return isBooked;
  } catch (e) {
    print('Error checking room availability: $e');
    return false;
  }
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
          .where('isSelected', isEqualTo: false)
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

Future<String?> getLatestPaymentId(String userId) async {
  try {
    CollectionReference paymentsCollectionRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('payment');

    QuerySnapshot paymentSnapshot = await paymentsCollectionRef
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (paymentSnapshot.docs.isNotEmpty) {
      return paymentSnapshot.docs.first.id; // Lấy ID của tài liệu mới nhất
    } else {
      return null; // Không có tài liệu thanh toán nào
    }
  } catch (e) {
    print('Error getting latest paymentId: $e');
    return null;
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

Future<Map<String, dynamic>> getPaymentDetails(String userId, String paymentId) async {
  try {
    DocumentSnapshot paymentDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('payment')
        .doc(paymentId)
        .get();

    if (paymentDoc.exists) {
      String startDateString = paymentDoc.get('StartDate');
      String endDateString = paymentDoc.get('EndDate');
      String? name = paymentDoc.get('Name');
      int? people = paymentDoc.get('People');
      int? numberRoom = paymentDoc.get('NumberRoom');
      int? perNight = paymentDoc.get('PerNight');

      DateTime startDate = DateFormat('dd-MM-yyyy').parse(startDateString);
      DateTime endDate = DateFormat('dd-MM-yyyy').parse(endDateString);

      return {
        'StartDate': startDate,
        'EndDate': endDate,
        'Name': name,
        'People': people,
        'NumberRoom': numberRoom,
        'PerNight': perNight,
      };
    } else {
      print("Không tìm thấy thông tin thanh toán.");
      return {};
    }
  } catch (e) {
    print('Lỗi khi lấy thông tin thanh toán: $e');
    throw e;
  }
}
@override
 Future<void> deleteDateTimeWithIsSelectedFalse(String roomId) async {
    try {
      CollectionReference dateTimeCollectionRef = _firestore
          .collection('rooms')
          .doc(roomId)
          .collection('dateTime');

      QuerySnapshot querySnapshot = await dateTimeCollectionRef
          .where('isSelected', isEqualTo: false)
          .get();

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        await doc.reference.delete();
        print('DateTime with ID ${doc.id} and isSelected: false deleted successfully.');
      }
    } catch (e) {
      print('Error deleting DateTime: $e');
    }
  }
    Future<void> updateIsSelectedForDatime(String roomId) async {
    var userDoc = FirebaseFirestore.instance.collection('rooms').doc(roomId);

    var paymentCollection = userDoc.collection('dateTime');

    var querySnapshot =
        await paymentCollection.where('isSelected', isEqualTo: false).get();

    for (var doc in querySnapshot.docs) {
      await doc.reference.update({'isSelected': true});
    }
  }
}