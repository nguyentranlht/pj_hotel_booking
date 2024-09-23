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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final fnameFocusNode = FocusNode();
  final lnameFocusNode = FocusNode();
  final TextEditingController _distController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();
  final TextEditingController _reviewController = TextEditingController();
  final TextEditingController _peopleController = TextEditingController();
  final TextEditingController _numberRoomController = TextEditingController();
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
            content: SizedBox(
              height: 120,
              child: Column(children: [
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    pickCameraImage(context, hotelId);
                  },
                  leading: Icon(Icons.camera, color: AppTheme.primaryColor),
                  title: const Text('Camera'),
                ),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    pickGalleryImage(context, hotelId);
                  },
                  leading: Icon(Icons.image, color: AppTheme.primaryColor),
                  title: const Text('Gallery'),
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

  // Future<void> showHotelNameDialogAlert(
  //     BuildContext context, String name, String hotelId) async {
  //   _nameController.text = name;
  //   return showDialog(
  //       context: context,
  //       builder: (context) {
  //         return AlertDialog(
  //           title: Center(child: Text('Cập nhật tên khách sạn')),
  //           content: SingleChildScrollView(
  //             child: Column(
  //               children: [
  //                 InputTextField(
  //                   myController: _nameController,
  //                   focusNode: fnameFocusNode,
  //                   onFiledSubmittedValue: (value) {},
  //                   keyBoardType: TextInputType.text,
  //                   obscureText: false,
  //                   hint: 'Nhập tên khách sạn',
  //                   onValidator: (value) {},
  //                 )
  //               ],
  //             ),
  //           ),
  //           actions: [
  //             TextButton(
  //                 onPressed: () {
  //                   Navigator.pop(context);
  //                 },
  //                 child: Text('Cancel')),
  //             TextButton(
  //                 onPressed: () {
  //                   hotelsCollection.doc(hotelId).update({
  //                     'titleTxt': _nameController.text.toString()
  //                   }).then((value) {
  //                     _nameController.clear();
  //                   });
  //                   Navigator.pop(context);
  //                 },
  //                 child: Text('OK'))
  //           ],
  //         );
  //       });
  // }

  Future<String?> showHotelNameDialogAlert(
      BuildContext context, String name, String hotelId) async {
    _nameController.text = name;
    String? newValue;
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Center(child: Text('Cập nhật tên khách sạn')),
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
                  onValidator: (value) {
                    return null;
                  },
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, null);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                newValue = _nameController.text.toString();
                if (newValue != null && newValue!.isNotEmpty) {
                  hotelsCollection.doc(hotelId).update({
                    'titleTxt': newValue,
                  }).then((value) {
                    _nameController.clear();
                  });
                }
                Navigator.pop(context, newValue);
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<String?> showHotelAddressDialogAlert(
      BuildContext context, String name, String hotelId) async {
    _addressController.text = name;
    String? newValue;
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Center(child: Text('Cập nhật địa chỉ khách sạn')),
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
                  onValidator: (value) {
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, null);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                newValue = _addressController.text.toString();
                if (newValue != null && newValue!.isNotEmpty) {
                  hotelsCollection.doc(hotelId).update({
                    'subTxt': newValue,
                  }).then((value) {
                    _addressController.clear();
                  });
                }
                Navigator.pop(context, newValue);
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<int?> showHotelPriceDialogAlert(
      BuildContext context, int currentPrice, String hotelId) async {
    _priceController.text = currentPrice.toString();
    return showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Center(child: Text('Cập nhật giá')),
          content: SingleChildScrollView(
            child: Column(
              children: [
                InputTextField(
                  myController: _priceController,
                  focusNode: lnameFocusNode,
                  onFiledSubmittedValue: (value) {},
                  keyBoardType: TextInputType.number,
                  obscureText: false,
                  hint: 'Nhập giá',
                  onValidator: (value) {
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, null);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                int? newPrice = int.tryParse(_priceController.text);
                if (newPrice != null && newPrice != currentPrice) {
                  hotelsCollection.doc(hotelId).update({
                    'perNight': newPrice,
                  }).then((value) {
                    _priceController.clear();
                  });
                  Navigator.pop(context, newPrice);
                } else {
                  Navigator.pop(context, null);
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<double?> showHotelDistDialogAlert(
      BuildContext context, double currentDist, String hotelId) async {
    _distController.text = currentDist.toString();
    return showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Center(child: Text('Cập nhật khoảng cách')),
          content: SingleChildScrollView(
            child: Column(
              children: [
                InputTextField(
                  myController: _distController,
                  focusNode: numberFocusNode,
                  onFiledSubmittedValue: (value) {},
                  keyBoardType: TextInputType.number,
                  obscureText: false,
                  hint: 'Nhập khoảng cách',
                  onValidator: (value) {
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, null);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                double? newDist = double.tryParse(_distController.text);
                if (newDist != null && newDist != currentDist) {
                  hotelsCollection.doc(hotelId).update({
                    'dist': newDist,
                  }).then((value) {
                    _distController.clear();
                  });
                  Navigator.pop(context, newDist);
                } else {
                  Navigator.pop(context, null);
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<double?> showHotelRatingDialogAlert(
      BuildContext context, double currentRating, String hotelId) async {
    _ratingController.text = currentRating.toString();
    return showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Center(child: Text('Cập nhật xếp hạng')),
          content: SingleChildScrollView(
            child: Column(
              children: [
                InputTextField(
                  myController: _ratingController,
                  focusNode: numberFocusNode,
                  onFiledSubmittedValue: (value) {},
                  keyBoardType: TextInputType.number,
                  obscureText: false,
                  hint: 'Nhập xếp hạng',
                  onValidator: (value) {
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, null);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                double? newRating = double.tryParse(_ratingController.text);
                if (newRating != null && newRating != currentRating) {
                  hotelsCollection.doc(hotelId).update({
                    'rating': newRating,
                  }).then((value) {
                    _ratingController.clear();
                  });
                  Navigator.pop(context, newRating);
                } else {
                  Navigator.pop(context, null);
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> showDeleteHotelDialogAlert(
      BuildContext context, String hotelId) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Center(child: Text('Bạn có chắc muốn xoá!!')),
            content: const SingleChildScrollView(),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Không')),
              TextButton(
                  onPressed: () {
                    hotelsCollection.doc(hotelId).delete();
                    NavigationServices(context).gotoBaseScreen();
                  },
                  child: const Text('Có'))
            ],
          );
        });
  }

  Future<int?> showHotelReviewsDialogAlert(
      BuildContext context, int currentReviews, String hotelId) async {
    _reviewController.text = currentReviews.toString();
    return showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Center(child: Text('Cập nhật đánh giá')),
          content: SingleChildScrollView(
            child: Column(
              children: [
                InputTextField(
                  myController: _reviewController,
                  focusNode: numberFocusNode,
                  onFiledSubmittedValue: (value) {},
                  keyBoardType: TextInputType.number,
                  obscureText: false,
                  hint: 'Nhập đánh giá',
                  onValidator: (value) {
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, null);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                int? newReviews = int.tryParse(_reviewController.text);
                if (newReviews != null && newReviews != currentReviews) {
                  hotelsCollection.doc(hotelId).update({
                    'reviews': newReviews,
                  }).then((value) {
                    _reviewController.clear();
                  });
                  Navigator.pop(context, newReviews);
                } else {
                  Navigator.pop(context, null);
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<int?> showHotelNumberRoomDialogAlert(
      BuildContext context, int currentNumberRoom, String hotelId) async {
    _numberRoomController.text = currentNumberRoom.toString();
    return showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Center(child: Text('Cập nhật số phòng')),
          content: SingleChildScrollView(
            child: Column(
              children: [
                InputTextField(
                  myController: _numberRoomController,
                  focusNode: numberFocusNode,
                  onFiledSubmittedValue: (value) {},
                  keyBoardType: TextInputType.number,
                  obscureText: false,
                  hint: 'Nhập số phòng',
                  onValidator: (value) {
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, null);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                int? newNumberRoom = int.tryParse(_numberRoomController.text);
                if (newNumberRoom != null &&
                    newNumberRoom != currentNumberRoom) {
                  hotelsCollection.doc(hotelId).update({
                    'roomData.numberRoom': newNumberRoom,
                  }).then((value) {
                    _numberRoomController.clear();
                  });
                  Navigator.pop(context, newNumberRoom);
                } else {
                  Navigator.pop(context, null);
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<int?> showHotelPeopleDialogAlert(
      BuildContext context, int currentPeopleRoom, String hotelId) async {
    _peopleController.text = currentPeopleRoom.toString();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Center(child: Text('Cập nhật số người')),
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
                    onValidator: (value) {
                      return null;
                    },
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () {
                    int? newPeopleRoom = int.tryParse(_peopleController.text);
                    if (newPeopleRoom != null &&
                        newPeopleRoom != currentPeopleRoom) {
                      hotelsCollection.doc(hotelId).update({
                        'roomData.people': int.parse(_peopleController.text)
                      }).then((value) {
                        _peopleController.clear();
                      });
                      Navigator.pop(context, newPeopleRoom);
                    } else {
                      Navigator.pop(context, null);
                    }
                  },
                  child: const Text('Update')),
            ],
          );
        });
  }

  Future<void> showConformDialogAlert(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Center(child: Text('Khởi động lại ứng dụng')),
            actions: [
              TextButton(
                  onPressed: () {
                    NavigationServices(context).gotoLoginApp();
                  },
                  child: const Text('Update')),
            ],
          );
        });
  }
}
