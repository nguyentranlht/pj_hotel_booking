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
  TextEditingController _priceController = TextEditingController();
  final fnameFocusNode = FocusNode();
  final lnameFocusNode = FocusNode();
  TextEditingController _distController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _ratingController = TextEditingController();
  TextEditingController _reviewController = TextEditingController();
  TextEditingController _peopleController = TextEditingController();
  TextEditingController _numberRoomController = TextEditingController();

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
            title: Center(child: Text('Cập nhật tên khách sạn')),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  InputTextField(
                    myController: _nameController,
                    focusNode: fnameFocusNode,
                    onFiledSubmittedValue: (value) {},
                    keyBoardType: TextInputType.text,
                    obscureText: false,
                    hint: 'Nhập tên khách sạn',
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

  Future<void> showHotelAddressDialogAlert(
      BuildContext context, String name, String hotelId) async {
    _addressController.text = name;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Center(child: Text('Cập nhật địa chỉ khách sạn')),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  InputTextField(
                    myController: _addressController,
                    focusNode: birthdayFocusNode,
                    onFiledSubmittedValue: (value) {},
                    keyBoardType: TextInputType.text,
                    obscureText: false,
                    hint: 'Nhập địa chỉ',
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
                      'subTxt': _addressController.text.toString()
                    }).then((value) {
                      _addressController.clear();
                    });
                    Navigator.pop(context);
                  },
                  child: Text('OK'))
            ],
          );
        });
  }

  Future<void> showHotelPriceDialogAlert(
      BuildContext context, int name, String hotelId) async {
        _priceController.text = name.toString();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Center(child: Text('Cập nhật giá')),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  InputTextField(
                    myController: _priceController,
                    focusNode: lnameFocusNode,
                    onFiledSubmittedValue: (value) {},
                    keyBoardType: TextInputType.text,
                    obscureText: false,
                    hint: 'Nhập giá',
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

  Future<void> showHotelDistDialogAlert(
      BuildContext context, double name, String hotelId) async {
    _distController.text = name.toString();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Center(child: Text('Cập nhật khoảng cách')),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  InputTextField(
                    myController: _distController,
                    focusNode: numberFocusNode,
                    onFiledSubmittedValue: (value) {},
                    keyBoardType: TextInputType.text,
                    obscureText: false,
                    hint: 'Nhập khoảng cách',
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
                      'dist': double.parse(_distController.text)
                    }).then((value) {
                      _distController.clear();
                    });
                    Navigator.pop(context);
                  },
                  child: Text('OK'))
            ],
          );
        });
  }

  Future<void> showHotelRatingDialogAlert(
      BuildContext context, double name, String hotelId) async {
    _ratingController.text = name.toString();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Center(child: Text('Cập nhật xếp hạng')),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  InputTextField(
                    myController: _ratingController,
                    focusNode: numberFocusNode,
                    onFiledSubmittedValue: (value) {},
                    keyBoardType: TextInputType.text,
                    obscureText: false,
                    hint: 'Nhập xếp hạng',
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
                      'rating': double.parse(_ratingController.text)
                    }).then((value) {
                      _ratingController.clear();
                    });
                    Navigator.pop(context);
                  },
                  child: Text('OK'))
            ],
          );
        });
  }

  Future<void> showDeleteHotelDialogAlert(
      BuildContext context, String hotelId) async {
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
                    hotelsCollection.doc(hotelId).delete();
                    NavigationServices(context).gotoBaseScreen();
                  },
                  child: Text('Có'))
            ],
          );
        });
  }

  Future<void> showHotelReviewsDialogAlert(
      BuildContext context, int name, String hotelId) async {
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
                    hint: 'Nhập đánh giá',
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
  Future<void> showHotelNumberRoomDialogAlert(
      BuildContext context, int name, String hotelId) async {
    _numberRoomController.text = name.toString();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Center(child: Text('Cập nhật số phòng')),
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
                    hotelsCollection.doc(hotelId).update({
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

  Future<void> showHotelPeopleDialogAlert(
      BuildContext context, int name, String hotelId) async {
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
                    hotelsCollection.doc(hotelId).update({
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
