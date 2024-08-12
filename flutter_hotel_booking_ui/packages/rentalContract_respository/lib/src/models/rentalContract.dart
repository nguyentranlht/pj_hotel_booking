import 'dart:ffi';

import 'package:uuid/uuid.dart';
import '../models/date_text.dart';
import '../models/time_text.dart';
import '../entities/rentalContract_entity.dart';


class RentalContract {
  String contractId;            // ID hợp đồng thuê xe
  String bikeId;                // ID của xe máy được thuê
  String customerId;    
        
  DateText dateTxt;
  TimeText timeTxt;

  double totalPrice;            // Tổng số tiền thuê
  bool paymentStatus;         // Trạng thái thanh toán (chưa thanh toán, đã thanh toán)
  double depositAmount;         // Số tiền đặt cọc
  String pickupLocation;        // Địa điểm nhận xe
  String returnLocation; 
  
  RentalContract({
    required this.contractId,
    required this.bikeId,
    required this.customerId,
    required this.dateTxt,
    required this.timeTxt,
    required this.totalPrice,
    required this.paymentStatus,
    required this.depositAmount,
    required this.pickupLocation,
    required this.returnLocation,
    
  });     
  static var empty = RentalContract(
		contractId: const Uuid().v1(),
    bikeId: '',
    customerId: '',
    dateTxt: DateText.empty,
    timeTxt: TimeText.empty,
    totalPrice: 0,
    paymentStatus: false,
    depositAmount: 0,
    pickupLocation: '',
    returnLocation: '',
    );

  RentalContractEntity toEntity() {
    return RentalContractEntity(
        contractId: contractId,
        bikeId: bikeId,
        customerId: customerId,
        dateTxt: dateTxt,
        timeTxt: timeTxt,
        totalPrice: totalPrice,
        paymentStatus: paymentStatus,
        depositAmount: depositAmount,
        pickupLocation: pickupLocation,
        returnLocation: returnLocation,
    );
  }

  static RentalContract fromEntity(RentalContractEntity entity) {
    return RentalContract(
      contractId: entity.contractId,
      bikeId: entity.bikeId,
      customerId: entity.customerId,
      dateTxt: entity.dateTxt,
      timeTxt: entity.timeTxt,
      totalPrice: entity.totalPrice,
      paymentStatus: entity.paymentStatus,
      depositAmount: entity.depositAmount,
      pickupLocation: entity.pickupLocation,
      returnLocation: entity.returnLocation,
    );
  }

    @override
  String toString() {
    return '''
    contractId: $contractId,
    bikeId: $bikeId,
    customerId: $customerId,
    dateTxt: $dateTxt,
    timeTxt: $timeTxt,
    totalPrice: $totalPrice,
    paymentStatus: $paymentStatus,
    depositAmount: $depositAmount,
    pickupLocation: $contractId,
    returnLocation: $returnLocation,
    ''';
    }
}