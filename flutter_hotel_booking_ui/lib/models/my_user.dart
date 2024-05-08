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

  MyUser({
    required this.userId,
    required this.email,
    required this.firstname,
    required this.lastname,
    this.picture,
  });

  factory MyUser.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    return MyUser(
      userId: data?["userId"],
      email: data?["email"],
      firstname: data?["firstname"],
      lastname: data?["lastname"],
      picture: data!["userpictureId"],
    );
  }


  // Empty user which represents an unauthenticated user.
  static final empty =
      MyUser(userId: '', email: '', firstname: '', lastname: '', picture: '');

  /// Modify MyUser parameters
  MyUser copyWith({
    String? id,
    String? email,
    String? name,
    String? picture,
  }) {
    return MyUser(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      picture: picture ?? this.picture,
    );
  }

  /// Convenience getter to determine whether the current user is empty.
  bool get isEmpty => this == MyUser.empty;

  /// Convenience getter to determine whether the current user is not empty.
  bool get isNotEmpty => this != MyUser.empty;

  Map<String, Object?> toDocument() {
    return {
      'userId': userId,
      'email': email,
      'firstname': firstname,
      'lastname': lastname,
      'picture': picture,
    };
  }

  static MyUser fromDocument(Map<String, dynamic> doc) {
    return MyUser(
        userId: doc['userId'] as String,
        email: doc['email'] as String,
        firstname: doc['firstname'] as String,
        lastname: doc['lastname'] as String,
        picture: doc['picture'] as String?);
  }

  @override
  List<Object?> get props => [userId, email, firstname, lastname, picture];

  @override
  String toString() {
    return '''UserEntity: {
      userId: $userId
      email: $email
      firstname: $firstname
      lastname: $lastname
      picture: $picture
    }''';
  }

}
