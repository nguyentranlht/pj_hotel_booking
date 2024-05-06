class Hotel {
  final String id;
  final String name;
  final String location;
  final int rating;
  final double pricePerNight;
  final String? picture;

  Hotel({
    required this.id,
    required this.name,
    required this.location,
    required this.rating,
    required this.pricePerNight,
    this.picture,
  });

  static final empty = Hotel(
    id: '',
    name: '',
    location: '',
    rating: 0,
    pricePerNight: 0.0,
    picture: '',
  );

  Hotel copyWith({
    String? id,
    String? name,
    String? location,
    int? rating,
    double? pricePerNight,
    String? picture,
  }) {
    return Hotel(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      rating: rating ?? this.rating,
      pricePerNight: pricePerNight ?? this.pricePerNight,
      picture: picture ?? this.picture,
    );
  }

  bool get isEmpty => this == Hotel.empty;

  bool get isNotEmpty => this != Hotel.empty;

  Map<String, Object?> toDocument() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'rating': rating,
      'pricePerNight': pricePerNight,
      'picture': picture,
    };
  }

  static Hotel fromDocument(Map<String, dynamic> doc) {
    return Hotel(
      id: doc['id'] as String,
      name: doc['name'] as String,
      location: doc['location'] as String,
      rating: doc['rating'] as int,
      pricePerNight: doc['pricePerNight'] as double,
      picture: doc['picture'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, name, location, rating, pricePerNight, picture];

  @override
  String toString() {
    return '''Hotel: {
      id: $id
      name: $name
      location: $location
      rating: $rating
      pricePerNight: $pricePerNight
      picture: $picture
    }''';
  }
}
