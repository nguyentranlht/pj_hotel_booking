import 'package:equatable/equatable.dart';

import '../entities/entities.dart';

class MyUser extends Equatable {
	final String userId;
  final String email;
  final String firstname;
  final String lastname;
  String? picture;
  final String role;

	MyUser({
		required this.userId,
		required this.email,
		required this.firstname,
    required this.lastname,
		this.picture,
    required this.role,
	});

	/// Empty user which represents an unauthenticated user.
  static final empty = MyUser(
		userId: '', 
		email: '',
		firstname: '', 
    lastname: '', 
		picture: '',
    role: ''
	);

	/// Modify MyUser parameters
	MyUser copyWith({
    String? userId,
    String? email,
    String? firstname,
    String? lastname,
    String? picture,
    String? role,
  }) {
    return MyUser(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      picture: picture ?? this.picture,
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
      role: role,
    );
  }

	static MyUser fromEntity(MyUserEntity entity) {
    return MyUser(
      userId: entity.userId,
      email: entity.email,
      firstname: entity.firstname,
      lastname: entity.lastname,
      picture: entity.picture,
      role: entity.role,
    );
  }


	@override
	List<Object?> get props => [userId, email, firstname, lastname, picture, role];
	
}