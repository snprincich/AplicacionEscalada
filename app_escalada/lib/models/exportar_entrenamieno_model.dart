class ExportarEntrenamienoModel {
  final int idEntrenamiento;
  final String nombreEntrenamiento;

  final int idEntrenamientoDetalle;
  final double pesoObjetivo;
  final int repeticiones;
  final int series;
  final double? descansoRepeticion;
  final double? descansoSerie;
  final double? duracionRepeticion;
  final String fecha;

  final int numSerie;
  final int numRepeticion;
  final double tiempo;
  final double? peso;

  ExportarEntrenamienoModel({
    required this.idEntrenamiento,
    required this.nombreEntrenamiento,
    required this.idEntrenamientoDetalle,
    required this.pesoObjetivo,
    required this.repeticiones,
    required this.series,
    this.descansoRepeticion,
    this.descansoSerie,
    this.duracionRepeticion,
    required this.fecha,
    required this.numSerie,
    required this.numRepeticion,
    required this.tiempo,
    this.peso,
  });
}
