import 'package:app_escalada/models/entrenamiento_model.dart';
import 'package:app_escalada/services/db/db_main.dart';

class DBEntrenamientos {
  Future<int> insertEntrenamiento(Entrenamiento entrenamiento) async {
    final db = await DBMain.getDatabase();
    return db.insert('entrenamientos', entrenamiento.toMap());
  }

  Future<List<Entrenamiento>> getAllEntrenamientos() async {
    final db = await DBMain.getDatabase();
    final result = await db.query('entrenamientos');
    return result.map((map) => Entrenamiento.fromMap(map)).toList();
  }

  Future<Entrenamiento?> getEntrenamiento(int id) async {
    final db = await DBMain.getDatabase();
    final result = await db.query(
      'entrenamientos',
      where: 'id_entrenamiento = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? Entrenamiento.fromMap(result.first) : null;
  }

  Future<int> updateEntrenamiento(Entrenamiento entrenamiento) async {
    final db = await DBMain.getDatabase();
    return db.update(
      'entrenamientos',
      entrenamiento.toMap(),
      where: 'id_entrenamiento = ?',
      whereArgs: [entrenamiento.idEntrenamiento],
    );
  }

  Future<int> deleteEntrenamiento(int id) async {
    final db = await DBMain.getDatabase();
    return db.delete(
      'entrenamientos',
      where: 'id_entrenamiento = ?',
      whereArgs: [id],
    );
  }
}
