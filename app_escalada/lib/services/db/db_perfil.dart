import 'package:app_escalada/models/perfil_model.dart';
import 'package:app_escalada/services/db/db_main.dart';

class DBPerfil {
  // INSERTA UN PERFIL EN LA BASE DE DATOS
  Future<int> insertPerfil(Perfil perfil) async {
    final db = await DBMain.getDatabase();
    return db.insert('perfiles', perfil.toMap());
  }

  Future<int> deletePerfil(String idPerfil) async {
    final db = await DBMain.getDatabase();
    return db.delete('perfiles', where: 'id_perfil = ?', whereArgs: [idPerfil]);
  }

  // TRAE UN PERFIL POR ID DESDE LA BASE DE DATOS
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

  // TRAE TODOS LOS PERFILES DE LA BASE DE DATOS
  Future<List<Perfil>> getAllPerfiles() async {
    final db = await DBMain.getDatabase();
    final result = await db.query('perfiles');
    return result.map((map) => Perfil.fromMap(map)).toList();
  }
}
