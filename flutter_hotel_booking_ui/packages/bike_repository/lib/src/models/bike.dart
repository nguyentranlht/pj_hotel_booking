import 'package:flutter/material.dart';
import '../entities/entities.dart';
import 'package:uuid/uuid.dart';

class Bike {
  String bikeId;                // ID duy nhất của xe máy
  String bikeName;              // Tên hoặc model của xe máy
  String bikeType;              // Loại xe máy (tay ga, xe số, xe côn)
  String bikeImage;             // URL hình ảnh của xe máy
  String bikeLicensePlate;      // Biển số xe
  String bikeColor;             // Màu sắc của xe máy
  String bikeStatus;            // Trạng thái của xe máy (có sẵn, đã cho thuê, bảo trì)
  double bikeRentPricePerDay;   // Giá thuê mỗi ngày
  String bikeFuelType;          // Loại nhiên liệu (xăng, điện)
  DateTime startDate;
  DateTime endDate;
  TimeOfDay startTime;
  TimeOfDay endTime;
  String locationId;
  Bike({
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
  static var empty = Bike(
		bikeId: const Uuid().v1(),
    bikeName: '',
    bikeType: '',
    bikeImage: '',
    bikeLicensePlate: '',
    bikeColor: '',
    bikeStatus: '',
    bikeRentPricePerDay: 0,
    bikeFuelType: '',
    startDate: DateTime.now(), 
    endDate: DateTime.now(),
    startTime: TimeOfDay.now(), 
    endTime: TimeOfDay.now(),
    locationId: ''
  );

  BikeEntity toEntity() {
    return BikeEntity(
      bikeId: bikeId,
      bikeName: bikeName,
      bikeType: bikeType,
      bikeImage: bikeImage,
      bikeLicensePlate: bikeLicensePlate,
      bikeColor: bikeColor,
      bikeStatus: bikeStatus,
      bikeRentPricePerDay: bikeRentPricePerDay,
      bikeFuelType:bikeFuelType,
      startDate:startDate,
      endDate:endDate,
      startTime:startTime,
      endTime:endTime,
      locationId:locationId,
    );
  }
  static Bike fromEntity(BikeEntity entity) {
    return Bike(
      bikeId: entity.bikeId,
      bikeName: entity.bikeName,
      bikeType: entity.bikeType,
      bikeImage: entity.bikeImage,
      bikeLicensePlate: entity.bikeLicensePlate,
      bikeColor: entity.bikeColor,
      bikeStatus: entity.bikeStatus,
      bikeRentPricePerDay: entity.bikeRentPricePerDay,
      bikeFuelType: entity.bikeFuelType,
      startDate: entity.startDate,
      endDate: entity.endDate,
      startTime:entity.startTime,
      endTime: entity.endTime,
      locationId: entity.locationId
    );
  }

    @override
  String toString() {
    return '''
      bikeId: $bikeId,
      bikeName: $bikeName,
      bikeType: $bikeType,
      bikeImage: $bikeImage,
      bikeLicensePlate: $bikeLicensePlate,
      bikeColor: $bikeColor,
      bikeStatus: $bikeStatus,
      bikeRentPricePerDay: $bikeRentPricePerDay,
      bikeFuelType: $bikeFuelType,
      startDate: $startDate,
      endDate: $endDate,
      startTime:$startTime,
      endTime: $endTime,
      locationId" $locationId
    ''';
  }
}
