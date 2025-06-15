import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_selector/file_selector.dart';

class CSVService {
  // PASA LA LIST<LIST<STRING>> A UN STRING
  String generarCSVString({required List<List<String>> data}) {
    return const ListToCsvConverter().convert(data);
  }

  // GUARDA EL CSV EN UN ARCHIVO Y DEVUELVE LA RUTA
  Future<String?> exportarCSV({
    required List<List<String>> data,
    String nombreSugerido = 'archivo.csv',
  }) async {
    final csv = generarCSVString(data: data);

    final FileSaveLocation? saveLocation = await getSaveLocation(suggestedName: nombreSugerido);

    if (saveLocation == null) return null;

    final file = File(saveLocation.path);
    await file.writeAsString(csv);

    return saveLocation.path;
  }
}
