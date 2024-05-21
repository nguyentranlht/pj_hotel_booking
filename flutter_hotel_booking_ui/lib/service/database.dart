import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods{
  Future addUserDetail(Map<String, dynamic> userInfoMap, String userId) async {
    return await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .set(userInfoMap);
  }
  
  UpdateUserwallet(String userId, String amount)async{
    return await FirebaseFirestore.instance
                .collection("users")
                .doc(userId)
                .update({"wallet":amount});
  }
    Future addPaymentToRoom(Map<String, dynamic> userInfoMap, String userId) async {
    return await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection("payment")
                .add(userInfoMap);
  }
  Future<Stream<QuerySnapshot>> getRoomPayment(String id) async{
    return await FirebaseFirestore.instance.collection("users").doc(id).collection("payment").snapshots();
  }
}