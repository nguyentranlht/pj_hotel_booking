
class MyUser {
	final String Userid;
	final String email;
	final String firstname;
  final String lastname;
	String? picture;

	MyUser({
		required this.Userid,
		required this.email,
		required this.firstname,
    required this.lastname,
		this.picture,
	});

	/// Empty user which represents an unauthenticated user.
	static final empty = MyUser(
			Userid: '',
			email: '',
			firstname: '',
			lastname: '',
			picture: ''
	);

	/// Modify MyUser parameters
	MyUser copyWith({
		String? id,
		String? email,
		String? name,
		String? picture,
	}) {
		return MyUser(
			Userid: Userid ?? this.Userid,
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
			'Userid': Userid,
			'email': email,
			'firstname': firstname,
			'lastname': lastname,
			'picture': picture,
		};
	}

	static MyUser fromDocument(Map<String, dynamic> doc) {
		return MyUser(
				Userid: doc['Userid'] as String,
				email: doc['email'] as String,
				firstname: doc['firstname'] as String,
				lastname: doc['lastname'] as String,
				picture: doc['picture'] as String?
		);
	}

	@override
	List<Object?> get props => [Userid, email, firstname, lastname, picture];

	@override
	String toString() {
		return '''UserEntity: {
      Userid: $Userid
      email: $email
      firstname: $firstname
      lastname: $lastname
      picture: $picture
    }''';
	}

}