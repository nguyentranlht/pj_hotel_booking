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

class UpdateHotelController extends ChangeNotifier {
  TextEditingController _nameController = TextEditingController();
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
  final hotelsCollection = FirebaseFirestore.instance.collection('hotels');
  XFile? _image;
  XFile? get image => _image;

  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future pickGalleryImage(BuildContext context, String hotelId) async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 100);
    if (pickedFile != null) {
      _image = XFile(pickedFile.path);
      uploadImage(context, hotelId);
      notifyListeners();
    }
  }

  Future pickCameraImage(BuildContext context, String hotelId) async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 100);
    if (pickedFile != null) {
      _image = XFile(pickedFile.path);
      uploadImage(context, hotelId);
      notifyListeners();
    }
  }

  void pickeImage(context, String hotelId) {
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
                    pickCameraImage(context, hotelId);
                  },
                  leading: Icon(Icons.camera, color: AppTheme.primaryColor),
                  title: Text('Camera'),
                ),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    pickGalleryImage(context, hotelId);
                  },
                  leading: Icon(Icons.image, color: AppTheme.primaryColor),
                  title: Text('Gallery'),
                )
              ]),
            ),
          );
        });
  }

  void uploadImage(BuildContext context, String hotelId) async {
    setLoading(true);
    try {
      firebase_storage.Reference storageRef = firebase_storage
          .FirebaseStorage.instance
          .ref('$hotelId/PP/${hotelId}_lead');
      firebase_storage.UploadTask uploadTask =
          storageRef.putFile(File(image!.path).absolute);
      await Future.value(uploadTask);
      final newUrl = await storageRef.getDownloadURL();
      hotelsCollection.doc(hotelId).update({'imagePath': newUrl});
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> showHotelNameDialogAlert(
      BuildContext context, String name, String hotelId) async {
    _nameController.text = name;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Center(child: Text('Update Hotel Name')),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  InputTextField(
                    myController: _nameController,
                    focusNode: fnameFocusNode,
                    onFiledSubmittedValue: (value) {},
                    keyBoardType: TextInputType.text,
                    obscureText: false,
                    hint: 'Enter Hotel Name',
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
                    hotelsCollection.doc(hotelId).update({
                      'titleTxt': _nameController.text.toString()
                    }).then((value) {
                      _nameController.clear();
                    });
                    Navigator.pop(context);
                  },
                  child: Text('OK'))
            ],
          );
        });
  }

  Future<void> showUserBirthDayDialogAlert(
      BuildContext context, String name, String hotelId) async {
    _birthdayController.text = name;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Center(child: Text('Update User Birthday')),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  InputTextField(
                    myController: _birthdayController,
                    focusNode: birthdayFocusNode,
                    onFiledSubmittedValue: (value) {},
                    keyBoardType: TextInputType.text,
                    obscureText: false,
                    hint: 'Enter Birthday',
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
                    hotelsCollection.doc(hotelId).update({
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
      BuildContext context, String name, String hotelId) async {
    _lnameController.text = name;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Center(child: Text('Update User Name')),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  InputTextField(
                    myController: _lnameController,
                    focusNode: lnameFocusNode,
                    onFiledSubmittedValue: (value) {},
                    keyBoardType: TextInputType.text,
                    obscureText: false,
                    hint: 'Enter last Name',
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
                    hotelsCollection.doc(hotelId).update({
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
      BuildContext context, String name, String hotelId) async {
    _numberController.text = name;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Center(child: Text('Update User Phone Number')),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  InputTextField(
                    myController: _numberController,
                    focusNode: numberFocusNode,
                    onFiledSubmittedValue: (value) {},
                    keyBoardType: TextInputType.text,
                    obscureText: false,
                    hint: 'Enter Phone Number',
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
                    hotelsCollection.doc(hotelId).update({
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
            title: Center(child: Text('Reset app to see the change')),
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
