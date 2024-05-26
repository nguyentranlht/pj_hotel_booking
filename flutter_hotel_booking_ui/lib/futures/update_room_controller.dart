import 'dart:io';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ui/models/input_textfield.dart';
import 'package:flutter_hotel_booking_ui/routes/route_names.dart';
import 'package:flutter_hotel_booking_ui/utils/themes.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class UpdateRoomController extends ChangeNotifier {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  final fnameFocusNode = FocusNode();
  final lnameFocusNode = FocusNode();
  TextEditingController _capacityController = TextEditingController();
  TextEditingController _reviewController = TextEditingController();
  TextEditingController _peopleController = TextEditingController();
  TextEditingController _numberRoomController = TextEditingController();

  final numberFocusNode = FocusNode();
  final birthdayFocusNode = FocusNode();
  final picker = ImagePicker();
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  final roomsCollection = FirebaseFirestore.instance.collection('rooms');
  XFile? _image;
  XFile? get image => _image;

  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future pickGalleryImage(BuildContext context, String roomId) async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 100);
    if (pickedFile != null) {
      _image = XFile(pickedFile.path);
      uploadImage(context, roomId);
      notifyListeners();
    }
  }

  Future pickCameraImage(BuildContext context, String roomId) async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 100);
    if (pickedFile != null) {
      _image = XFile(pickedFile.path);
      uploadImage(context, roomId);
      notifyListeners();
    }
  }

  void pickeImage(context, String roomId) {
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
                    pickCameraImage(context, roomId);
                  },
                  leading: Icon(Icons.camera, color: AppTheme.primaryColor),
                  title: Text('Camera'),
                ),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    pickGalleryImage(context, roomId);
                  },
                  leading: Icon(Icons.image, color: AppTheme.primaryColor),
                  title: Text('Gallery'),
                )
              ]),
            ),
          );
        });
  }

  void uploadImage(BuildContext context, String roomId) async {
    setLoading(true);
    try {
      firebase_storage.Reference storageRef = firebase_storage
          .FirebaseStorage.instance
          .ref('$roomId/PP/${roomId}_lead');
      firebase_storage.UploadTask uploadTask =
          storageRef.putFile(File(image!.path).absolute);
      await Future.value(uploadTask);
      final newUrl = await storageRef.getDownloadURL();
      roomsCollection.doc(roomId).update({'imagePath': newUrl});
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> showRoomNameDialogAlert(
      BuildContext context, String name, String roomId) async {
    _nameController.text = name;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Center(child: Text('Cập nhật tên phòng')),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  InputTextField(
                    myController: _nameController,
                    focusNode: fnameFocusNode,
                    onFiledSubmittedValue: (value) {},
                    keyBoardType: TextInputType.text,
                    obscureText: false,
                    hint: 'Nhập tên phòng',
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
                    roomsCollection.doc(roomId).update({
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

  Future<void> showRoomCapacityDialogAlert(
      BuildContext context, String name, String roomId) async {
    _capacityController.text = name;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Center(child: Text('Cập nhật sức chứa')),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  InputTextField(
                    myController: _capacityController,
                    focusNode: birthdayFocusNode,
                    onFiledSubmittedValue: (value) {},
                    keyBoardType: TextInputType.text,
                    obscureText: false,
                    hint: 'Nhập sức chứa',
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
                    roomsCollection.doc(roomId).update({
                      'dataTxt': _capacityController.text.toString()
                    }).then((value) {
                      _capacityController.clear();
                    });
                    Navigator.pop(context);
                  },
                  child: Text('OK'))
            ],
          );
        });
  }

  Future<void> showRoomPriceDialogAlert(
      BuildContext context, int name, String roomId) async {
        _priceController.text = name.toString();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Center(child: Text('Cập nhật giá phòng')),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  InputTextField(
                    myController: _priceController,
                    focusNode: lnameFocusNode,
                    onFiledSubmittedValue: (value) {},
                    keyBoardType: TextInputType.text,
                    obscureText: false,
                    hint: 'Nhập giá phòng',
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
                    roomsCollection.doc(roomId).update({
                      'perNight': int.parse(_priceController.text)
                    }).then((value) {
                      _priceController.clear();
                    });
                    Navigator.pop(context);
                  },
                  child: Text('OK'))
            ],
          );
        });
  }
  
  Future<void> showDeleteRoomDialogAlert(
      BuildContext context, String roomId) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Center(child: Text('Bạn có chắc muốn xoá!!')),
            content: SingleChildScrollView(
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Không')),
              TextButton(
                  onPressed: () {
                    roomsCollection.doc(roomId).delete();
                    NavigationServices(context).gotoBaseScreen();
                  },
                  child: Text('Có'))
            ],
          );
        });
  }

  Future<void> showRoomReviewsDialogAlert(
      BuildContext context, int name, String roomId) async {
    _reviewController.text = name.toString();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Center(child: Text('Cập nhật đánh giá')),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  InputTextField(
                    myController: _reviewController,
                    focusNode: numberFocusNode,
                    onFiledSubmittedValue: (value) {},
                    keyBoardType: TextInputType.text,
                    obscureText: false,
                    hint: 'Nhập đánh giá phòng',
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
                    roomsCollection.doc(roomId).update({
                      'reviews': int.parse(_reviewController.text)
                    }).then((value) {
                      _reviewController.clear();
                    });
                    Navigator.pop(context);
                  },
                  child: Text('OK'))
            ],
          );
        });
  }
  Future<void> showRoomNumberRoomDialogAlert(
      BuildContext context, int name, String roomId) async {
    _numberRoomController.text = name.toString();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Center(child: Text('Cập nhật sô phòng')),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  InputTextField(
                    myController: _numberRoomController,
                    focusNode: numberFocusNode,
                    onFiledSubmittedValue: (value) {},
                    keyBoardType: TextInputType.text,
                    obscureText: false,
                    hint: 'Nhập số phòng',
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
                    roomsCollection.doc(roomId).update({
                      'roomData.numberRoom': int.parse(_numberRoomController.text)
                    }).then((value) {
                      _numberRoomController.clear();
                    });
                    Navigator.pop(context);
                  },
                  child: Text('OK'))
            ],
          );
        });
  }

  Future<void> showRoomPeopleDialogAlert(
      BuildContext context, int name, String roomId) async {
    _peopleController.text = name.toString();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Center(child: Text('Cập nhật số người')),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  InputTextField(
                    myController: _peopleController,
                    focusNode: numberFocusNode,
                    onFiledSubmittedValue: (value) {},
                    keyBoardType: TextInputType.text,
                    obscureText: false,
                    hint: 'Nhập số người',
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
                    roomsCollection.doc(roomId).update({
                      'roomData.people': int.parse(_peopleController.text)
                    }).then((value) {
                      _peopleController.clear();
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
