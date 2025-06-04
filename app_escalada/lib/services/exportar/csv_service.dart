import 'dart:io';
import 'package:csv/csv.dart';

class CSVService {
  Future<String> exportarCSV({
    required List<List<String>> data,
    String nombreArchivo = 'archivo.csv',
  }) async {
    final csv = const ListToCsvConverter().convert(data);

    final downloadsDirectory = Directory('/storage/emulated/0/Download');
    if (!downloadsDirectory.existsSync()) {
      downloadsDirectory.createSync(recursive: true);
    }

    final path = '${downloadsDirectory.path}/$nombreArchivo';
    final file = File(path);

    await file.writeAsString(csv);

    return path;
  }
}
