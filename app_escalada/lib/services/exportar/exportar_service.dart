import 'package:app_escalada/models/datos_model.dart';
import 'package:app_escalada/models/entrenamiento_detalles_model.dart';
import 'package:app_escalada/models/entrenamiento_model.dart';
import 'package:app_escalada/models/exportar_entrenamieno_model.dart';
import 'package:app_escalada/services/db/db_datos.dart';
import 'package:app_escalada/services/exportar/csv_service.dart';

class ExportarService {
  final DBDatos _dbDatos;
  final CSVService _csvService;

  ExportarService(this._dbDatos, this._csvService);

  Future<String> exportarEntrenamientos({
    required List<EntrenamientoDetalles> detallesSeleccionados,
    required List<Entrenamiento> entrenamientos,
    String nombreArchivo = 'archivo.csv',
  }) async {
    List<int> idsDetalles =
        detallesSeleccionados.map((d) => d.idEntrenamientoDetalles!).toList();
    List<Datos> datos = await _dbDatos.getDatosPorDetalles(idsDetalles);

    List<ExportarEntrenamienoModel> exportarModel = await combinarParaExportar(
      entrenamientos: entrenamientos,
      detalles: detallesSeleccionados,
      datos: datos,
    );

    List<List<String>> data = [];

    // Cabecera
    data.add([
      'id_entrenamiento',
      'nombre_entrenamiento',
      'id_entrenamiento_detalles',
      'peso_objetivo',
      'repeticiones',
      'series',
      'descanso_repeticion',
      'descanso_serie',
      'duracion_repeticion',
      'fecha',
      'num_serie',
      'num_repeticion',
      'tiempo',
      'peso',
    ]);

    // Filas de datos
    for (var item in exportarModel) {
      data.add([
        item.idEntrenamiento.toString(),
        item.nombreEntrenamiento,
        item.idEntrenamientoDetalle.toString(),
        item.pesoObjetivo.toString(),
        item.repeticiones.toString(),
        item.series.toString(),
        item.descansoRepeticion?.toString() ?? '',
        item.descansoSerie?.toString() ?? '',
        item.duracionRepeticion?.toString() ?? '',
        item.fecha,
        item.numSerie.toString(),
        item.numRepeticion.toString(),
        item.tiempo.toString(),
        item.peso?.toString() ?? '',
      ]);
    }

    return _csvService.exportarCSV(data: data, nombreArchivo: nombreArchivo);
  }

  Future<List<ExportarEntrenamienoModel>> combinarParaExportar({
    required List<Entrenamiento> entrenamientos,
    required List<EntrenamientoDetalles> detalles,
    required List<Datos> datos,
  }) async {
    List<ExportarEntrenamienoModel> exportList = [];

    for (var dato in datos) {
      final detalle = detalles.firstWhere(
        (d) => d.idEntrenamientoDetalles == dato.idEntrenamientoDetalle,
        orElse:
            () =>
                throw Exception(
                  'Detalle no encontrado para id ${dato.idEntrenamientoDetalle}',
                ),
      );

      final entrenamiento = entrenamientos.firstWhere(
        (e) => e.idEntrenamiento == detalle.idEntrenamiento,
        orElse:
            () =>
                throw Exception(
                  'Entrenamiento no encontrado para id ${detalle.idEntrenamiento}',
                ),
      );

      exportList.add(
        ExportarEntrenamienoModel(
          idEntrenamiento: entrenamiento.idEntrenamiento ?? 0,
          nombreEntrenamiento: entrenamiento.nombreEntrenamiento,
          idEntrenamientoDetalle: detalle.idEntrenamientoDetalles ?? 0,
          pesoObjetivo: detalle.pesoObjetivo,
          repeticiones: detalle.repeticiones,
          series: detalle.series,
          descansoRepeticion: detalle.descansoRepeticion,
          descansoSerie: detalle.descansoSerie,
          duracionRepeticion: detalle.duracionRepeticion,
          fecha: detalle.fecha,
          numSerie: dato.numSerie,
          numRepeticion: dato.numRepeticion,
          tiempo: dato.tiempo,
          peso: dato.peso,
        ),
      );
    }

    return exportList;
  }
}
