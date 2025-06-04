class Datos {
  int? idEntrenamientoDetalle;
  final int numRepeticion;
  final int numSerie;
  final double tiempo;
  final double? peso;

  Datos({
    required this.idEntrenamientoDetalle,
    required this.numRepeticion,
    required this.numSerie,
    required this.tiempo,
    this.peso,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_entrenamiento_detalles': idEntrenamientoDetalle,
      'num_repeticion': numRepeticion,
      'num_serie': numSerie,
      'tiempo': tiempo,
      'peso': peso,
    };
  }

  factory Datos.fromMap(Map<String, dynamic> map) {
    return Datos(
      idEntrenamientoDetalle: map['id_entrenamiento_detalles'],
      numRepeticion: map['num_repeticion'],
      numSerie: map['num_serie'],
      tiempo: map['tiempo'],
      peso: map['peso'],
    );
  }
}
