import 'package:app_escalada/models/perfil_model.dart';
import 'package:app_escalada/services/db/db_main.dart';

class DBPerfil {
  Future<int> insertPerfil(Perfil perfil) async {
    final db = await DBMain.getDatabase();
    return db.insert('perfiles', perfil.toMap());
  }

  Future<int> updatePerfil(Perfil perfil) async {
    final db = await DBMain.getDatabase();
    return db.update(
      'perfiles',
      perfil.toMap(),
      where: 'id_perfil = ?',
      whereArgs: [perfil.idPerfil],
    );
  }

  Future<int> deletePerfil(String idPerfil) async {
    final db = await DBMain.getDatabase();
    return db.delete('perfiles', where: 'id_perfil = ?', whereArgs: [idPerfil]);
  }

  Future<Perfil?> getPerfil(String idPerfil) async {
    final db = await DBMain.getDatabase();
    final result = await db.query(
      'perfiles',
      where: 'id_perfil = ?',
      whereArgs: [idPerfil],
    );

    if (result.isNotEmpty) {
      return Perfil.fromMap(result.first);
    }
    return null;
  }

  Future<List<Perfil>> getAllPerfiles() async {
    final db = await DBMain.getDatabase();
    final result = await db.query('perfiles');
    return result.map((map) => Perfil.fromMap(map)).toList();
  }
}
