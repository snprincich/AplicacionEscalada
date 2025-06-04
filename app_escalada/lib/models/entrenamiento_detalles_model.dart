class EntrenamientoDetalles {
  final int? idEntrenamientoDetalles;
  final String? idPerfil;
  final int idEntrenamiento;
  final double pesoObjetivo;
  final int repeticiones;
  final int series;
  final double? descansoRepeticion;
  final double? descansoSerie;
  final double? duracionRepeticion;
  final double? duracionTotal;
  final String fecha;

  EntrenamientoDetalles({
    this.idEntrenamientoDetalles,
    required this.idPerfil,
    required this.idEntrenamiento,
    required this.pesoObjetivo,
    required this.repeticiones,
    required this.series,
    this.descansoRepeticion,
    this.descansoSerie,
    this.duracionRepeticion,
    this.duracionTotal,
    required this.fecha,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_entrenamiento_detalles': idEntrenamientoDetalles,
      'id_perfil': idPerfil,
      'id_entrenamiento': idEntrenamiento,
      'peso_objetivo': pesoObjetivo,
      'repeticiones': repeticiones,
      'series': series,
      'descanso_repeticion': descansoRepeticion,
      'descanso_serie': descansoSerie,
      'duracion_repeticion': duracionRepeticion,
      'duracion_total': duracionTotal,
      'fecha': fecha,
    };
  }

  factory EntrenamientoDetalles.fromMap(Map<String, dynamic> map) {
    return EntrenamientoDetalles(
      idEntrenamientoDetalles: map['id_entrenamiento_detalles'],
      idPerfil: map['id_perfil'],
      idEntrenamiento: map['id_entrenamiento'],
      pesoObjetivo: map['peso_objetivo'],
      repeticiones: map['repeticiones'],
      series: map['series'],
      descansoRepeticion: map['descanso_repeticion'],
      descansoSerie: map['descanso_serie'],
      duracionRepeticion: map['duracion_repeticion'],
      duracionTotal: map['duracion_total'],
      fecha: map['fecha'],
    );
  }
}
