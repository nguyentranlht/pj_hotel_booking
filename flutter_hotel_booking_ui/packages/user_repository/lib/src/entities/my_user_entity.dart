import 'package:equatable/equatable.dart';

class MyUserEntity extends Equatable {
  final String userId;
  final String email;
  final String firstname;
  final String lastname;
  final String? picture;
  final String number;
  final String birthday;
  final String role;
  final String? wallet;

  const MyUserEntity({
    required this.userId,
    required this.email,
    required this.firstname,
    required this.lastname,
    this.picture,
    required this.number,
    required this.birthday,
    required this.role,
    required this.wallet,
  });

  Map<String, Object?> toDocument() {
    return {
      'userId': userId,
      'email': email,
      'firstname': firstname,
      'lastname': lastname,
      'picture': picture,
      'number': number,
      'birthday': birthday,
      'role': role,
      'wallet': wallet,
    };
  }

  static MyUserEntity fromDocument(Map<String, dynamic> doc) {
    return MyUserEntity(
        userId: doc['userId'] as String,
        email: doc['email'] as String,
        firstname: doc['firstname'] as String,
        lastname: doc['lastname'] as String,
        picture: doc['picture'] as String?,
        number: doc['number'] as String,
        birthday: doc['birthday'] as String,
        wallet: doc['wallet'] as String?,
        role: doc['role'] as String);    
  }

  @override
  List<Object?> get props =>
      [userId, email, firstname, lastname, picture, number, birthday, role, wallet];

  @override
  String toString() {
    return '''UserEntity: {
      userId: $userId
      email: $email
      firstname: $firstname
      lastname: $lastname
      picture: $picture
      number: $number
      birthday: $birthday
      role: $role
      wallet: $wallet
    }''';
  }
}
