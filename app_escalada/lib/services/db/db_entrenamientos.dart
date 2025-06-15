import 'package:app_escalada/models/entrenamiento_model.dart';
import 'package:app_escalada/services/db/db_main.dart';

// NO HAY INSERT/UPDATE/DELETE YA QUE SE INSERTAN POR DEFECTO AL CREAR LA BASE DE DATOS
class DBEntrenamientos {
  // OBTIENE TODOS LOS ENTRENAMIENTOS DE LA BASE DE DATOS
  Future<List<Entrenamiento>> getAllEntrenamientos() async {
    final db = await DBMain.getDatabase();
    final result = await db.query('entrenamientos');
    return result.map((map) => Entrenamiento.fromMap(map)).toList();
  }

  // OBTIENE UN ENTRENAMIENTO POR SU ID
  Future<Entrenamiento?> getEntrenamiento(int id) async {
    final db = await DBMain.getDatabase();
    final result = await db.query(
      'entrenamientos',
      where: 'id_entrenamiento = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? Entrenamiento.fromMap(result.first) : null;
  }
}
