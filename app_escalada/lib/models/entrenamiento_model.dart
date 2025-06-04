class Entrenamiento {
  final int? idEntrenamiento;
  final String nombreEntrenamiento;

  Entrenamiento({this.idEntrenamiento, required this.nombreEntrenamiento});

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{'nombre_entrenamiento': nombreEntrenamiento};
    if (idEntrenamiento != null) {
      map['id_entrenamiento'] = idEntrenamiento;
    }
    return map;
  }

  factory Entrenamiento.fromMap(Map<String, dynamic> map) {
    return Entrenamiento(
      idEntrenamiento: map['id_entrenamiento'],
      nombreEntrenamiento: map['nombre_entrenamiento'],
    );
  }
}
