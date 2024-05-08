import 'dart:developer';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyUser {
  final String userId;
  final String email;
  final String firstname;
  final String lastname;
  String? picture;
  final String role; //Them role

  MyUser({
    required this.userId,
    required this.email,
    required this.firstname,
    required this.lastname,
    this.picture,
    required this.role,
  });

  factory MyUser.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    return MyUser(
      userId: data?["userId"],
      email: data?["email"],
      firstname: data?["firstname"],
      lastname: data?["lastname"],
      picture: data!["picture"],
      role: data["role"],
    );
  }

  
}
