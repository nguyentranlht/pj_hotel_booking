import 'dart:io';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ui/models/input_textfield.dart';
import 'package:flutter_hotel_booking_ui/routes/route_names.dart';
import 'package:flutter_hotel_booking_ui/utils/themes.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class ProfileController extends ChangeNotifier {
  TextEditingController _fnameController = TextEditingController();
  TextEditingController _lnameController = TextEditingController();
  final fnameFocusNode = FocusNode();
  final lnameFocusNode = FocusNode();
  TextEditingController _numberController = TextEditingController();
  TextEditingController _birthdayController = TextEditingController();
  final numberFocusNode = FocusNode();
  final birthdayFocusNode = FocusNode();
  final picker = ImagePicker();
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  final usersCollection = FirebaseFirestore.instance.collection('users');
  XFile? _image;
  XFile? get image => _image;

  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future pickGalleryImage(BuildContext context, String userId) async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 100);
    if (pickedFile != null) {
      _image = XFile(pickedFile.path);
      uploadImage(context, userId);
      notifyListeners();
    }
  }

  Future pickCameraImage(BuildContext context, String userId) async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 100);
    if (pickedFile != null) {
      _image = XFile(pickedFile.path);
      uploadImage(context, userId);
      notifyListeners();
    }
  }

  void pickeImage(context, String userId) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
              height: 120,
              child: Column(children: [
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    pickCameraImage(context, userId);
                  },
                  leading: Icon(Icons.camera, color: AppTheme.primaryColor),
                  title: Text('Camera'),
                ),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    pickGalleryImage(context, userId);
                  },
                  leading: Icon(Icons.image, color: AppTheme.primaryColor),
                  title: Text('Gallery'),
                )
              ]),
            ),
          );
        });
  }

  void uploadImage(BuildContext context, String userId) async {
    setLoading(true);
    try {
      firebase_storage.Reference storageRef = firebase_storage
          .FirebaseStorage.instance
          .ref('$userId/PP/${userId}_lead');
      firebase_storage.UploadTask uploadTask =
          storageRef.putFile(File(image!.path).absolute);
      await Future.value(uploadTask);
      final newUrl = await storageRef.getDownloadURL();
      usersCollection.doc(userId).update({'picture': newUrl});
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> showUserNameDialogAlert(
      BuildContext context, String name, String userId) async {
    _fnameController.text = name;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Center(child: Text('Cập nhật họ')),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  InputTextField(
                    myController: _fnameController,
                    focusNode: fnameFocusNode,
                    onFiledSubmittedValue: (value) {},
                    keyBoardType: TextInputType.text,
                    obscureText: false,
                    hint: 'Nhập Ho',
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
                    usersCollection.doc(userId).update({
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

  Future<void> showUserBirthDayDialogAlert(
      BuildContext context, String name, String userId) async {
    _birthdayController.text = name;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Center(child: Text('Cập nhật ngày sinh')),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  InputTextField(
                    myController: _birthdayController,
                    focusNode: birthdayFocusNode,
                    onFiledSubmittedValue: (value) {},
                    keyBoardType: TextInputType.text,
                    obscureText: false,
                    hint: 'Nhập ngày sinh',
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
                    usersCollection.doc(userId).update({
                      'birthday': _birthdayController.text.toString()
                    }).then((value) {
                      _birthdayController.clear();
                    });
                    Navigator.pop(context);
                  },
                  child: Text('OK'))
            ],
          );
        });
  }

  Future<void> showUserLastNameDialogAlert(
      BuildContext context, String name, String userId) async {
    _lnameController.text = name;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Center(child: Text('Cập nhật tên')),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  InputTextField(
                    myController: _lnameController,
                    focusNode: lnameFocusNode,
                    onFiledSubmittedValue: (value) {},
                    keyBoardType: TextInputType.text,
                    obscureText: false,
                    hint: 'Nhập tên',
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
                    usersCollection.doc(userId).update({
                      'lastname': _lnameController.text.toString()
                    }).then((value) {
                      _lnameController.clear();
                    });
                    Navigator.pop(context);
                  },
                  child: Text('OK'))
            ],
          );
        });
  }

  Future<void> showUserNumberDialogAlert(
      BuildContext context, String name, String userId) async {
    _numberController.text = name;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Center(child: Text('Cập nhật số điện thoại')),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  InputTextField(
                    myController: _numberController,
                    focusNode: numberFocusNode,
                    onFiledSubmittedValue: (value) {},
                    keyBoardType: TextInputType.text,
                    obscureText: false,
                    hint: 'Nhập số điện thoại',
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
                    usersCollection.doc(userId).update({
                      'number': _numberController.text.toString()
                    }).then((value) {
                      _numberController.clear();
                    });
                    Navigator.pop(context);
                  },
                  child: Text('OK'))
            ],
          );
        });
  }

  Future<void> showConformDialogAlert(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Center(child: Text('Khởi động lại ứng dụng')),
            actions: [
              TextButton(
                  onPressed: () {
                    NavigationServices(context)
                                    .gotoLoginApp();
                  },
                  child: Text('Ok')),
            ],
          );
        });
  }
}
