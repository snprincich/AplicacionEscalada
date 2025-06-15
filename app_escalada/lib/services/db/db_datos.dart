import 'package:app_escalada/models/datos_model.dart';
import 'package:app_escalada/services/db/db_main.dart';
import 'package:flutter/material.dart';

class DBDatos {
  Future<int> insertDato(Datos dato, BuildContext context) async {
    try {
      final db = await DBMain.getDatabase();
      return await db.insert('datos', dato.toMap());
    } catch (e) {
      return -1;
    }
  }

  Future<int> insertDatos(List<Datos> listaDatos, BuildContext context) async {
    try {
      final db = await DBMain.getDatabase();

      await db.transaction((txn) async {
        for (var dato in listaDatos) {
          await txn.insert('datos', dato.toMap());
        }
      });
      return 1;
    } catch (e) {
      return -1;
    }
  }

  Future<List<Datos>> getDatosPorDetalle(int idEntrenamientoDetalle) async {
    final db = await DBMain.getDatabase();
    final result = await db.query(
      'datos',
      where: 'id_entrenamiento_detalles = ?',
      whereArgs: [idEntrenamientoDetalle],
    );
    return result.map((map) => Datos.fromMap(map)).toList();
  }

  Future<int> deleteDato(Datos dato) async {
    final db = await DBMain.getDatabase();
    return db.delete(
      'datos',
      where:
          'id_entrenamiento_detalles = ? AND num_repeticion = ? AND num_serie = ? AND tiempo = ?',
      whereArgs: [
        dato.idEntrenamientoDetalle,
        dato.numRepeticion,
        dato.numSerie,
        dato.tiempo,
      ],
    );
  }

  Future<int> deleteDatosDeDetalle(int idEntrenamientoDetalle) async {
    final db = await DBMain.getDatabase();
    return db.delete(
      'datos',
      where: 'id_entrenamiento_detalles = ?',
      whereArgs: [idEntrenamientoDetalle],
    );
  }

  Future<List<Datos>> getDatosPorDetalles(List<int> idsDetalles) async {
    final db = await DBMain.getDatabase();
    if (idsDetalles.isEmpty) return [];

    final rellenarWhereIn = List.filled(idsDetalles.length, '?').join(', ');

    final result = await db.query(
      'datos',
      where: 'id_entrenamiento_detalles IN ($rellenarWhereIn)',
      whereArgs: idsDetalles,
    );

    return result.map((map) => Datos.fromMap(map)).toList();
  }
}
