import 'package:flutter/material.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart' as DateRangePicker;
import 'package:flutter_hotel_booking_ui/language/appLocalizations.dart';
import 'package:flutter_hotel_booking_ui/utils/text_styles.dart';
import 'package:flutter_hotel_booking_ui/utils/themes.dart';
import 'package:intl/intl.dart';

class MotorcycleScreen extends StatefulWidget {
  final AnimationController animationController;

  const MotorcycleScreen({Key? key, required this.animationController})
      : super(key: key);
  @override
  _MotorcycleScreenState createState() => _MotorcycleScreenState();
}

class _MotorcycleScreenState extends State<MotorcycleScreen> {
  DateTime? startDate;
  DateTime? endDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  String location = '';
  String typebike = '';
  bool returnToSameLocation = false;

  final _locations = ['Đà Lạt', 'Nha Trang', 'Vũng Tàu', 'Mũi Né - Phan Thiết', 'Buôn Mê Thuộc', 'Đà Nẵng', 'Quy Nhơn', 'Huế'];
  final _typeBike = ['Xe Ga', 'Xe Số'];

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
          // Kiểm tra và cập nhật endDate nếu cần thiết
          if (endDate != null && endDate!.isBefore(startDate!.add(Duration(days: 1)))) {
            endDate = null;  // Đặt lại endDate nếu không hợp lệ
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Ngày kết thúc phải lớn hơn ngày bắt đầu ít nhất 1 ngày'),
              ),
            );
          }
        } else {
          // Ràng buộc endDate phải lớn hơn startDate ít nhất 1 ngày
          if (picked.isBefore(startDate!.add(Duration(days: 1)))) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Ngày kết thúc phải lớn hơn ngày bắt đầu ít nhất 1 ngày'),
              ),
            );
          } else {
            endDate = picked;
          }
        }
      });
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
      // Hiển thị thông báo nếu thời gian đã chọn không nằm trong khoảng cho phép
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng chọn thời gian từ 6:00 sáng đến 20:00 tối'),
        ),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFDDDCDC),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
          ),
        ),
        title: const Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car,
              color: Colors.black87,
              size: 30,
            ),
            SizedBox(width: 10),
            Text(
              'Thuê Xe',
              style: TextStyle(
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
                  color:  AppTheme.fontcolor,
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
            SizedBox(height: 20.0),
            _buildLocationDropdown(),
            SizedBox(height: 20.0),
            _buildDateTimePicker(context, 'Ngày nhận xe', startDate, startTime, true),
            SizedBox(height: 20.0),
            _buildDateTimePicker(context, 'Ngày trả xe', endDate, endTime, false),
            SizedBox(height: 20.0),
            _buildTypeBike( ),
            SizedBox(height: 40.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Xử lý logic tìm kiếm tại đây.
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.0),
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
                    color:  AppTheme.fontcolor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildTypeBike(){
    return DropdownButtonFormField(
      decoration: InputDecoration(
        labelText: 'Chọn loại xe',
        labelStyle: TextStyle(
          color:  AppTheme.fontcolor,
          fontWeight: FontWeight.w600,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      value: typebike.isEmpty ? null : typebike,
      items: _typeBike.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          typebike = value.toString();
        });
      },
    );
  }

  Widget _buildLocationDropdown() {
    return DropdownButtonFormField(
      decoration: InputDecoration(
        labelText: 'Địa điểm nhận xe',
        labelStyle: TextStyle(
          color:  AppTheme.fontcolor,
          fontWeight: FontWeight.w600,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      value: location.isEmpty ? null : location,
      items: _locations.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          location = value.toString();
        });
      },
    );
  }

  Widget _buildDateTimePicker(BuildContext context, String label, DateTime? date, TimeOfDay? time, bool isStart) {
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
                  color:  AppTheme.fontcolor,
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
                    date == null ? 'Chọn ngày' : DateFormat('EEE, d MMM yyyy').format(date),
                  ),
                  Icon(Icons.calendar_today, color:  AppTheme.primaryColor),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 8.0),
        Expanded(
          child: InkWell(
            onTap: () => _selectTime(context, isStart),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Giờ',
                labelStyle: TextStyle(
                  color:  AppTheme.fontcolor,
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
}
