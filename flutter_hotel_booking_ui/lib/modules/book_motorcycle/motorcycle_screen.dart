import 'package:bike_repository/bike_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ui/language/appLocalizations.dart';
import 'package:flutter_hotel_booking_ui/routes/route_names.dart';
import 'package:flutter_hotel_booking_ui/utils/themes.dart';
import 'package:intl/intl.dart';
import 'package:user_repository/user_repository.dart';

class MotorcycleScreen extends StatefulWidget {
  final AnimationController animationController;

  const MotorcycleScreen({Key? key, required this.animationController})
      : super(key: key);
  @override
  // ignore: library_private_types_in_public_api
  _MotorcycleScreenState createState() => _MotorcycleScreenState();
}

class _MotorcycleScreenState extends State<MotorcycleScreen> {
  late AnimationController tabAnimationController;
  DateTime? startDate;
  DateTime? endDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  TimeOfDay? initTimeStart = const TimeOfDay(hour: 7, minute: 00);
  TimeOfDay? initTimeEnd = const TimeOfDay(hour: 19, minute: 30);
  bool returnToSameLocation = false;

  String? selectedLocation;
  String? selectedLocationNhanXe;
  String? selectedXe;
  String? locationId;
  String? userId;

  List<String> locations = [];
  List<String> dsLocations = [];
  List<String> typebikes = [];
  Map<String, List<String>> cityLocationMap = {};

  String? locationName, locationNhanXe, locationType;

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;

          if (endDate != null &&
              endDate!.isBefore(startDate!.add(const Duration(days: 1)))) {
            endDate = null; // Đặt lại endDate nếu không hợp lệ
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Ngày kết thúc phải lớn hơn ngày bắt đầu ít nhất 1 ngày'),
              ),
            );
          }
        } else {
          if (picked.isBefore(startDate!.add(const Duration(days: 1)))) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Ngày kết thúc phải lớn hơn ngày bắt đầu ít nhất 1 ngày'),
              ),
            );
          } else {
            endDate = picked;
          }
        }
      });
    }
  }

  Future<void> _loadLocations() async {
    final locationsSnapshot =
        await FirebaseFirestore.instance.collection('locations').get();
    final locationNames = locationsSnapshot.docs
        .map((doc) => doc['locationName'] as String)
        .toList();
    setState(() {
      locations.addAll(locationNames);
    });
  }

  Future<void> _loadChooseLocations() async {
    try {
      final locationsSnapshot2 =
          await FirebaseFirestore.instance.collection('locations').get();
      for (var doc in locationsSnapshot2.docs) {
        final cityName = doc['locationName'] as String;
        final Map<String, dynamic>? typeLocationMap =
            doc['location'] as Map<String, dynamic>?;

        if (typeLocationMap != null) {
          for (var location in typeLocationMap.values) {
            setState(() {
              if (!cityLocationMap.containsKey(cityName)) {
                cityLocationMap[cityName] = [];
              }
              cityLocationMap[cityName]!.add(location.toString());
            });
          }
        }
      }
    } catch (e) {
      print('Error loading locations: $e');
    }
  }

  Future<void> _loadChooseBikes() async {
    try {
      final locationsSnapshot2 =
          await FirebaseFirestore.instance.collection('locations').get();
      for (var doc in locationsSnapshot2.docs) {
        final Map<String, dynamic>? typeTextMap =
            doc['TypeText'] as Map<String, dynamic>?;
        if (typeTextMap != null) {
          typeTextMap.forEach((key, value) {
            setState(() {
              typebikes.add(value.toString());
            });
          });
        }
      }
    } catch (e) {
      print('Error loading bike types: $e');
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      // Giới hạn thời gian từ 6:00 sáng đến 20:00 tối
      if (picked.hour >= 6 && picked.hour <= 20) {
        setState(() {
          if (isStartTime) {
            startTime = picked;
          } else {
            endTime = picked;
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng chọn thời gian từ 7:00 sáng đến 20:00 tối'),
          ),
        );
      }
    }
  }

  getthesharedpref() async {
    userId = await FirebaseUserRepository().getUserId();
    setState(() {});
  }

  ontheload() async {
    await getthesharedpref();

    setState(() {});
  }

  @override
  void initState() {
    //widget.animationController.forward();
    ontheload();
    super.initState();
    // Load locations from Firebase
    _loadLocations();
    _loadChooseLocations();
    _loadChooseBikes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFDDDCDC),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(),
        ),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.motorcycle_rounded,
              color: Colors.black87,
              size: 35,
            ),
            const SizedBox(width: 10),
            Text(
              AppLocalizations(context).of("Rent_Motorcycle"),
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.black26,
                    offset: Offset(0.5, 0.5),
                  ),
                ],
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          children: <Widget>[
            SwitchListTile(
              title: Text(
                'Quay lại vị trí cũ',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.fontcolor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              value: returnToSameLocation,
              onChanged: (bool value) {
                setState(() {
                  returnToSameLocation = value;
                });
              },
              activeColor: AppTheme.primaryColor,
            ),
            const SizedBox(height: 20.0),
            _buildLocationDropdown(),
            const SizedBox(height: 20.0),
            _buildLocationNameDropdown(),
            const SizedBox(height: 20.0),
            _buildDateTimePicker(
                context, 'Ngày nhận xe', startDate, startTime, true),
            const SizedBox(height: 20.0),
            _buildDateTimePicker(
                context, 'Ngày trả xe', endDate, endTime, false),
            const SizedBox(height: 20.0),
            _buildTypeBike(),
            const SizedBox(height: 40.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if ([
                    locationName,
                    locationNhanXe,
                    locationType,
                    startDate,
                    endDate,
                    startTime,
                    endTime,
                    locationId
                  ].contains(null)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Vui lòng chọn đầy đủ thông tin'),
                      ),
                    );
                    return;
                  }

                  try {
                    // Step 1: Fetch available bikes with no time overlap
                    List<Map<String, dynamic>> availableBikes =
                        await findAvailableBikes(
                      locationId: locationId!,
                      locationNhanXe: locationNhanXe!,
                      typeBike: locationType!,
                      startDate: startDate!,
                      endDate: endDate!,
                      startTime: startTime!,
                      endTime: endTime!,
                    );
                    // Step 2: Handle cases where no bikes are available
                    if (availableBikes.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Không có xe nào phù hợp.'),
                        ),
                      );
                    } else {
                      // Save search history and show available bikes
                      Map<String, dynamic> dateSearch = {
                        "startDate": startDate.toString(),
                        "endDate": endDate.toString()
                      };
                      Map<String, dynamic> timeSearch = {
                        "startTime": startTime.toString(),
                        "endTime": endTime.toString()
                      };

                      await FirebaseBikeRepo().addHistorySearchToUser(
                        availableBikes,
                        userId!,
                        dateSearch,
                        timeSearch,
                      );
                      await FirebaseBikeRepo().addHistorySearchToFirebase(
                        availableBikes,
                        userId!,
                        dateSearch,
                        timeSearch,
                      );
                      await FirebaseBikeRepo().clearMarketHistory(userId!);

                      NavigationServices(context).gotoHistorySearch();
                    }
                  } catch (e) {
                    debugPrint('Lỗi khi tìm kiếm xe: $e');
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: AppTheme.primaryColor,
                ),
                child: Text(
                  'Tìm',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.fontcolor,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTypeBike() {
    final uniqueBikeType = typebikes.toSet().toList();

    if (!uniqueBikeType.contains(selectedXe)) {
      selectedXe = null; // Or set it to a default value from uniqueLocations
    }
    return DropdownButtonFormField(
      decoration: InputDecoration(
        labelText: 'Chọn loại xe',
        labelStyle: TextStyle(
          color: AppTheme.fontcolor,
          fontWeight: FontWeight.w600,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      value: selectedXe,
      onChanged: (String? newValue) {
        setState(() {
          selectedXe = newValue!;
          locationType = selectedXe;
        });
      },
      items: uniqueBikeType.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget _buildLocationNameDropdown() {
    final filteredLocations = selectedLocation != null &&
            cityLocationMap.containsKey(selectedLocation)
        ? cityLocationMap[selectedLocation]!.toSet().toList()
        : [];

    return LayoutBuilder(
      builder: (context, constraints) {
        return DropdownButtonFormField<String>(
          isExpanded: true, // Ensure dropdown occupies full width
          decoration: InputDecoration(
            labelText: 'Địa Điểm Nhận Xe',
            labelStyle: TextStyle(
              color: AppTheme.fontcolor,
              fontWeight: FontWeight.w600,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          value: selectedLocationNhanXe,
          onChanged: (String? newValue) {
            setState(() {
              selectedLocationNhanXe = newValue;
              locationNhanXe = selectedLocationNhanXe;
            });
          },
          items:
              filteredLocations.map<DropdownMenuItem<String>>((dynamic value) {
            return DropdownMenuItem<String>(
              value: value,
              // ignore: sized_box_for_whitespace
              child: Container(
                width: constraints.maxWidth *
                    0.9, // Adjust width to prevent overflow
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis, // Prevent text overflow
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildLocationDropdown() {
    final uniqueLocations = locations.toSet().toList();

    return DropdownButtonFormField(
      decoration: InputDecoration(
        labelText: 'Chọn Thành Phố',
        labelStyle: TextStyle(
          color: AppTheme.fontcolor,
          fontWeight: FontWeight.w600,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      value: selectedLocation,
      onChanged: (String? newValue) async {
        setState(() {
          selectedLocation = newValue!;
          locationName = selectedLocation;
          selectedLocationNhanXe = null;
        });
        locationId = await FirebaseBikeRepo().getLocationId(selectedLocation!);
        print("locationId: $locationId");
      },
      items: uniqueLocations.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget _buildDateTimePicker(BuildContext context, String label,
      DateTime? date, TimeOfDay? time, bool isStart) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: InkWell(
            onTap: () => _selectDate(context, isStart),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(
                  color: AppTheme.fontcolor,
                  fontWeight: FontWeight.w600,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    date == null
                        ? 'Chọn ngày'
                        : DateFormat('EEE, d MMM yyyy').format(date),
                  ),
                  Icon(Icons.calendar_today, color: AppTheme.primaryColor),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8.0),
        Expanded(
          child: InkWell(
            onTap: () => _selectTime(context, isStart),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Giờ',
                labelStyle: TextStyle(
                  color: AppTheme.fontcolor,
                  fontWeight: FontWeight.w600,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    time == null ? 'Chọn giờ' : time.format(context),
                  ),
                  Icon(Icons.access_time, color: AppTheme.primaryColor),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<List<Map<String, dynamic>>> findAvailableBikes({
    required String locationId,
    required String locationNhanXe,
    required String typeBike,
    required DateTime startDate,
    required DateTime endDate,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
  }) async {
    List<Map<String, dynamic>> availableBikes = [];

    try {
      print('Start searching bikes...');

      // Bước 1: Tìm các xe trùng với locationId, bikeType, và locationBike
      QuerySnapshot<Map<String, dynamic>> bikesSnapshot =
          await FirebaseFirestore.instance
              .collection('locations')
              .doc(locationId)
              .collection('bikes')
              .where('bikeType', isEqualTo: typeBike)
              .where('locationBike', isEqualTo: locationNhanXe)
              .get();

      print('Bikes found: ${bikesSnapshot.docs.length}');

      for (var bikeDoc in bikesSnapshot.docs) {
        var bikeData = bikeDoc.data();
        var bikeId = bikeData['bikeId'];
        print('Checking bikeId: $bikeId');

        // Lấy tất cả các hợp đồng để kiểm tra xe
        QuerySnapshot<Map<String, dynamic>> contractsSnapshot =
            await FirebaseFirestore.instance.collection('contracts').get();

        print(
            'Contracts found: ${contractsSnapshot.docs.length} for bikeId: $bikeId');

        bool isAvailable = true;

        for (var contractDoc in contractsSnapshot.docs) {
          var contractData = contractDoc.data();
          List bikesInContract =
              contractData['bikes']; // Danh sách xe trong hợp đồng

          // Kiểm tra nếu `bikeId` có trong danh sách xe
          if (bikesInContract.any((bike) => bike['bikeId'] == bikeId)) {
            if (contractData.containsKey('dateSearch') &&
                contractData.containsKey('timeSearch')) {
              // Chuyển đổi chuỗi ngày thành DateTime
              DateTime contractStartDate =
                  DateTime.parse(contractData['dateSearch']['startDate']);
              DateTime contractEndDate =
                  DateTime.parse(contractData['dateSearch']['endDate']);

              TimeOfDay contractStartTime = TimeOfDay(
                hour: int.parse(
                    contractData['timeSearch']['startTime'].split(':')[0]),
                minute: int.parse(
                    contractData['timeSearch']['startTime'].split(':')[1]),
              );
              TimeOfDay contractEndTime = TimeOfDay(
                hour: int.parse(
                    contractData['timeSearch']['endTime'].split(':')[0]),
                minute: int.parse(
                    contractData['timeSearch']['endTime'].split(':')[1]),
              );

              print(
                  "contractStartDate $contractStartDate, contractEndDate $contractEndDate");
              print(
                  "contractStartTime $contractStartTime, contractEndTime $contractEndTime");
              print("startDate $startDate, endDate $endDate");
              print("startTime $startTime, endTime $endTime");

              // Kiểm tra sự trùng lặp về ngày
              bool dateOverlap = !(contractEndDate.isBefore(startDate) ||
                  contractStartDate.isAfter(endDate));

              // Kiểm tra sự trùng lặp về thời gian trong ngày trùng lặp
              bool timeOverlap = true;
              var finalTimeHour = startTime.hour - contractEndTime.hour;
              var finalTimeMinute = startTime.minute - contractEndTime.minute;
              print(
                  "finalTimeHour: $finalTimeHour, finalTimeMinute: $finalTimeMinute");
              // Chỉ kiểm tra thời gian nếu có sự trùng lặp về ngày
              if (dateOverlap) {
                // Trường hợp ngày bắt đầu của người dùng trùng với ngày kết thúc của hợp đồng
                if (startDate.isAtSameMomentAs(contractEndDate)) {
                  if (((startTime.hour > contractEndTime.hour &&
                      finalTimeHour >= 1 &&
                      finalTimeMinute >= 29))) {
                    timeOverlap = false;
                  }
                }
                // Trường hợp ngày kết thúc của người dùng trùng với ngày bắt đầu của hợp đồng
                else if (endDate.isAtSameMomentAs(contractStartDate)) {
                  if ((endTime.hour < contractStartTime.hour &&
                          finalTimeHour > 1 &&
                          finalTimeMinute == 0) ||
                      (endTime.hour == contractStartTime.hour &&
                          endTime.minute < contractStartTime.minute)) {
                    timeOverlap = false;
                  }
                }
                // Trường hợp trùng cả ngày bắt đầu và ngày kết thúc
                else if (startDate.isAtSameMomentAs(contractStartDate) &&
                    endDate.isAtSameMomentAs(contractEndDate)) {
                  if ((startTime.hour == contractStartTime.hour &&
                          startTime.minute == contractStartTime.minute &&
                          finalTimeHour == 0 &&
                          finalTimeMinute == 0) &&
                      (endTime.hour == contractEndTime.hour &&
                          endTime.minute == contractEndTime.minute)) {
                    timeOverlap = true;
                  }
                }
                // Nếu không phải trường hợp đặc biệt, đánh dấu thời gian là trùng lặp nếu có
                else {
                  timeOverlap = true;
                }
              }
              print('dateOverlap, timeOverlap: $dateOverlap, $timeOverlap');
              // Nếu cả dateOverlap và timeOverlap đều trùng, xe không khả dụng
              if (dateOverlap && timeOverlap) {
                print('Time overlap found for bikeId $bikeId');
                isAvailable = false;
                break;
              }
            }
          }
        }

        if (isAvailable) {
          availableBikes.add(bikeData);
        }
      }

      print('Available bikes: ${availableBikes.length}');
    } catch (e) {
      print('Error fetching available bikes: $e');
    }

    return availableBikes;
  }
}
