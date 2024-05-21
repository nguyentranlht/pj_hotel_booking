// import 'package:shared_preferences/shared_preferences.dart';

// class SharedPreferenceHelper{

//   static String userIdKey="USERKEY";
//   static String userFirstNameKey="USERFIRSTNAMEKEY";
//   static String userLastNameKey="USERLASTNAMEKEY";
//   static String userEmailKey="USEREMAILKEY";
//   static String userWalletKey="USERWALLERKEY";

//   static String userPictureKey="USERPICTUREKEY";
//   static String userRoleKey="USERROLEKEY";

//   Future<bool> saveUserId(String getUserId) async{
//     SharedPreferences prefs= await SharedPreferences.getInstance();
//     return prefs.setString(userIdKey,getUserId);
//   }

//   Future<bool> saveFirstUserName(String getUserFirstName) async{
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.setString(userFirstNameKey, getUserFirstName);
//   }
//   Future<bool> saveLastUserName(String getUserLastName) async{
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.setString(userLastNameKey, getUserLastName);
//   }

//   Future<bool> saveUserEmail(String getUserEmail) async{
//     SharedPreferences prefs= await SharedPreferences.getInstance();
//     return prefs.setString(userEmailKey,getUserEmail);
//   }
//   Future<bool> saveUserWallet(String getUserWallet) async{
//     SharedPreferences prefs= await SharedPreferences.getInstance();
//     return prefs.setString(userWalletKey,getUserWallet);
//   }
//   Future<bool> saveUserPicture(String getUserPicture) async{
//     SharedPreferences prefs= await SharedPreferences.getInstance();
//     return prefs.setString(userPictureKey,getUserPicture);
//   }
//   Future<bool> saveUserRole(String getUserRole) async{
//     SharedPreferences prefs= await SharedPreferences.getInstance();
//     return prefs.setString(userRoleKey,getUserRole);
//   }
//   /////
//   Future<String?> getUserId()async{
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString(userIdKey);
//   }
//   Future<String?> getFirstUserName()async{
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString(userFirstNameKey);
//   }
//    Future<String?> getLastUserName()async{
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString(userLastNameKey);
//   }
//   Future<String?> getUserEmail()async{
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString(userEmailKey);
//   }
//   Future<String?> getUserWallet()async{
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString(userWalletKey);
//   }

  
// }