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
  double bikeRentPricePerHour;  // Giá thuê theo giờ
  String bikeFuelType;          // Loại nhiên liệu (xăng, điện)
  
  Bike({
    required this.bikeId,
    required this.bikeName,
    required this.bikeType,
    required this.bikeImage,
    required this.bikeLicensePlate,
    required this.bikeColor,
    required this.bikeStatus,
    required this.bikeRentPricePerDay,
    required this.bikeRentPricePerHour,
    required this.bikeFuelType,
    
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
    bikeRentPricePerHour: 0,
    bikeFuelType: ''
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
      bikeRentPricePerHour: bikeRentPricePerHour,
      bikeFuelType:bikeFuelType
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
      bikeRentPricePerHour: entity.bikeRentPricePerHour,
      bikeFuelType: entity.bikeFuelType
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
      bikeRentPricePerHour: $bikeRentPricePerHour,
      bikeFuelType: $bikeFuelType
    ''';
  }
}
