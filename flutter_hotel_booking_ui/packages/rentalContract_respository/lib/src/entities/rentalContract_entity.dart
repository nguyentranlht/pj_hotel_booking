import '../models/date_text.dart';
import '../models/time_text.dart';
import '../entities/date_text.dart';
import '../entities/time_text.dart';

class RentalContractEntity {
  String contractId;          
  String bikeId;               
  String customerId;    
        
  DateText dateTxt;
  TimeText timeTxt;

  double totalPrice;            
  bool paymentStatus;         
  double depositAmount;       
  String pickupLocation;        
  String returnLocation; 
  
  RentalContractEntity({
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

  Map<String, Object?> toDocument() {
    return {     
       'contractId': contractId,
       'bikeId': bikeId,
       'customerId': customerId,
       
       'dateTxt': dateTxt.toEntity().toDocument(),
       'timeTxt': timeTxt.toEntity().toDocument(),

       'totalPrice': totalPrice,
       'paymentStatus': paymentStatus,
       'depositAmount': depositAmount,
       'pickupLocation': pickupLocation,
       'returnLocation': returnLocation
    };
  }
  
  static RentalContractEntity fromDocument(Map<String, dynamic> doc) {
    return RentalContractEntity(
      contractId: doc['contractId'],
      bikeId: doc['bikeId'],
      customerId: doc['customerId'],

      dateTxt:
          DateText.fromEntity(DateTextEntity.fromDocument(doc['dateTxt'])),
      timeTxt:
          TimeText.fromEntity(TimeTextEntity.fromDocument(doc['timeTxt'])),

      totalPrice: doc['totalPrice'],
      paymentStatus: doc['paymentStatus'],
      depositAmount: doc['depositAmount'],
      pickupLocation: doc['pickupLocation'],
      returnLocation: doc['returnLocation'],
    );
  }
}