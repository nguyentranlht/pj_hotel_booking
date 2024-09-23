class TypeBikeEntity {
  String xeGa;
  String xeSo;

  TypeBikeEntity({
    required this.xeGa,
    required this.xeSo,
  });
  static final empty = TypeBikeEntity(
    xeGa: 'Xe Ga',
    xeSo: 'Xe Số',
  );

  get location2 => null;

  Map<String, Object?> toDocument() {
    return {
      'xeGa': xeGa,
      'xeSố': xeSo,
    };
  }

  static TypeBikeEntity fromDocument(Map<String, dynamic> doc) {
    return TypeBikeEntity(
      xeGa: doc['xeGa'],
      xeSo: doc['xeSố'],
    );
  }
}
