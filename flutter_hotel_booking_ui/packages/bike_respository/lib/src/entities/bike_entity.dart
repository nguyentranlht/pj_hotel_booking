class BikeEntity {
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
  
  BikeEntity({
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
      'bikeRentPricePerHour': bikeRentPricePerHour,
      'bikeFuelType': bikeFuelType,
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
      bikeRentPricePerHour: doc['bikeRentPricePerHour'],
      bikeFuelType: doc['bikeFuelType'],
    );
  }
}
