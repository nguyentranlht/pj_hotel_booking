import 'package:equatable/equatable.dart';

import '../entities/entities.dart';

class MyUser extends Equatable {
  final String userId;
  final String email;
  final String firstname;
  final String lastname;
  String? picture;
  final String number;
  final String birthday;
  final String? wallet;
  final String role;

  MyUser({
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

  /// Empty user which represents an unauthenticated user.
  static final empty = MyUser(
      userId: '',
      email: '',
      firstname: '',
      lastname: '',
      picture: '',
      number: '',
      birthday: '',
      wallet: '',
      role: '');

  /// Modify MyUser parameters
  MyUser copyWith({
    String? userId,
    String? email,
    String? firstname,
    String? lastname,
    String? picture,
    String? number,
    String? birthday,
    String? role,
    String? wallet,
  }) {
    return MyUser(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      picture: picture ?? this.picture,
      number: number ?? this.number,
      birthday: birthday ?? this.birthday,
      wallet: wallet ?? this.wallet,
      role: role ?? this.role,
    );
  }

  /// Convenience getter to determine whether the current user is empty.
  bool get isEmpty => this == MyUser.empty;

  /// Convenience getter to determine whether the current user is not empty.
  bool get isNotEmpty => this != MyUser.empty;

  MyUserEntity toEntity() {
    return MyUserEntity(
      userId: userId,
      email: email,
      firstname: firstname,
      lastname: lastname,
      picture: picture,
      number: number,
      birthday: birthday,
      role: role,
      wallet: wallet,
    );
  }

  static MyUser fromEntity(MyUserEntity entity) {
    return MyUser(
      userId: entity.userId,
      email: entity.email,
      firstname: entity.firstname,
      lastname: entity.lastname,
      picture: entity.picture,
      number: entity.number,
      birthday: entity.birthday,
      role: entity.role,
      wallet: entity.wallet,
    );
  }

  @override
  List<Object?> get props =>
      [userId, email, firstname, lastname, picture, number, birthday, role, wallet];
}
