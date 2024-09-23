// ignore: file_names
import 'package:location_repository/src/entities/typeBike_entity.dart';

class TypeText {
  String xeGa;
  String xeSo;

  TypeText({
    required this.xeGa,
    required this.xeSo,
  });
  static final empty = TypeText(
    xeGa: 'Xe Ga',
    xeSo: 'Xe Số',
  );
  TypeBikeEntity toEntity() {
    return TypeBikeEntity(
      xeGa: xeGa,
      xeSo: xeSo,
    );
  }

  static TypeText fromEntity(TypeBikeEntity entity) {
    return TypeText(
      xeGa: entity.xeGa,
      xeSo: entity.xeSo,
    );
  }
}
