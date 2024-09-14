import 'package:flutter/material.dart';

class BikeEntity {
  String bikeId;                // ID duy nhất của xe máy
  String bikeName;              // Tên hoặc model của xe máy
  String bikeType;              // Loại xe máy (tay ga, xe số, xe côn)
  String bikeImage;             // URL hình ảnh của xe máy
  String bikeLicensePlate;      // Biển số xe
  String bikeColor;             // Màu sắc của xe máy
  String bikeStatus;            // Trạng thái của xe máy (có sẵn, đã cho thuê, bảo trì)
  double bikeRentPricePerDay;   // Giá thuê mỗi ngày  // Giá thuê theo giờ
  String bikeFuelType;          // Loại nhiên liệu (xăng, điện)
  DateTime startDate;
  DateTime endDate;
  TimeOfDay startTime;
  TimeOfDay endTime;
  String locationId;

  BikeEntity({
    required this.bikeId,
    required this.bikeName,
    required this.bikeType,
    required this.bikeImage,
    required this.bikeLicensePlate,
    required this.bikeColor,
    required this.bikeStatus,
    required this.bikeRentPricePerDay,
    required this.bikeFuelType,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.locationId,
    
  });    
  Map<String, Object?> toDocument() {
    return {
      'bikeId': bikeId,
      'bikeName': bikeName,
      'bikeType': bikeType,
      'bikeImage': bikeImage,
      'bikeLicensePlate': bikeLicensePlate,
      'bikeColor': bikeColor,
      'bikeStatus': bikeStatus,
      'bikeRentPricePerDay': bikeRentPricePerDay,
      'bikeFuelType': bikeFuelType,
      'startDate':startDate,
      'endDate':endDate,
      'startTime':startTime,
      'endTime':endTime,
      'bikeLocation': locationId,
    };
  } 
   static BikeEntity fromDocument(Map<String, dynamic> doc) {
    return BikeEntity(
      bikeId: doc['bikeId'],
      bikeName: doc['bikeName'],
      bikeType: doc['bikeType'],
      bikeImage: doc['bikeImage'],
      bikeLicensePlate: doc['bikeLicensePlate'],
      bikeColor: doc['bikeColor'],
      bikeStatus: doc['bikeStatus'],
      bikeRentPricePerDay: doc['bikeRentPricePerDay'],
      bikeFuelType: doc['bikeFuelType'],
      startDate: doc['startDate'],
      endDate:doc['endDate'],
      startTime:doc['startTime'],
      endTime:doc['endTime'],
      locationId: doc['locationId'],
    );
  }
}
