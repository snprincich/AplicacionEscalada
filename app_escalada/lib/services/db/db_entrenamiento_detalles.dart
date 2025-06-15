import 'package:app_escalada/models/entrenamiento_detalles_model.dart';
import 'package:app_escalada/services/db/db_main.dart';

class DBEntrenamientosDetalles {
  // INSERTA UN 'EntrenamientoDetalles' EN LA BASE DE DATOS
  Future<int> insertDetalle(EntrenamientoDetalles detalle) async {
    final db = await DBMain.getDatabase();
    return db.insert('entrenamiento_detalles', detalle.toMap());
  }

  // OBTIENE 'EntrenamientoDetalles' POR SU ID
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

  // TRAE LOS 'EntrenamientoDetalles' ASOCIADOS A UN PERFIL
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

  // ACTUALIZA UN 'EntrenamientoDetalles' EXISTENTE
  Future<int> updateDetalle(EntrenamientoDetalles detalle) async {
    final db = await DBMain.getDatabase();
    return db.update(
      'entrenamiento_detalles',
      detalle.toMap(),
      where: 'id_entrenamiento_detalles = ?',
      whereArgs: [detalle.idEntrenamientoDetalles],
    );
  }

  // ELIMINA UN 'EntrenamientoDetalles' POR ID
  Future<int> deleteDetalle(int id) async {
    final db = await DBMain.getDatabase();
    return db.delete(
      'entrenamiento_detalles',
      where: 'id_entrenamiento_detalles = ?',
      whereArgs: [id],
    );
  }
}
