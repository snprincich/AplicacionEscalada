import 'package:app_escalada/models/entrenamiento_detalles_model.dart';
import 'package:app_escalada/services/db/db_main.dart';

class DBEntrenamientosDetalles {
  Future<int> insertDetalle(EntrenamientoDetalles detalle) async {
    final db = await DBMain.getDatabase();
    return db.insert('entrenamiento_detalles', detalle.toMap());
  }

  Future<List<EntrenamientoDetalles>> getDetallesPorEntrenamiento(
    int entrenamientoId,
  ) async {
    final db = await DBMain.getDatabase();
    final result = await db.query(
      'entrenamiento_detalles',
      where: 'id_entrenamiento = ?',
      whereArgs: [entrenamientoId],
    );
    return result.map((map) => EntrenamientoDetalles.fromMap(map)).toList();
  }

  Future<EntrenamientoDetalles?> getDetalle(int id) async {
    final db = await DBMain.getDatabase();
    final result = await db.query(
      'entrenamiento_detalles',
      where: 'id_entrenamiento_detalles = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty
        ? EntrenamientoDetalles.fromMap(result.first)
        : null;
  }

  Future<List<EntrenamientoDetalles>> getDetallesPorPerfil(
    String perfilId,
  ) async {
    final db = await DBMain.getDatabase();
    final result = await db.query(
      'entrenamiento_detalles',
      where: 'id_perfil = ?',
      whereArgs: [perfilId],
    );
    return result.map((map) => EntrenamientoDetalles.fromMap(map)).toList();
  }

  Future<int> updateDetalle(EntrenamientoDetalles detalle) async {
    final db = await DBMain.getDatabase();
    return db.update(
      'entrenamiento_detalles',
      detalle.toMap(),
      where: 'id_entrenamiento_detalles = ?',
      whereArgs: [detalle.idEntrenamientoDetalles],
    );
  }

  Future<int> deleteDetalle(int id) async {
    final db = await DBMain.getDatabase();
    return db.delete(
      'entrenamiento_detalles',
      where: 'id_entrenamiento_detalles = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteDetallesDeEntrenamiento(int entrenamientoId) async {
    final db = await DBMain.getDatabase();
    return db.delete(
      'entrenamiento_detalles',
      where: 'id_entrenamiento = ?',
      whereArgs: [entrenamientoId],
    );
  }
}
