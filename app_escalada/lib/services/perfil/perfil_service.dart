import 'dart:convert';
import 'package:get_it/get_it.dart';
import 'package:app_escalada/models/perfil_model.dart';
import 'package:app_escalada/services/db/db_perfil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PerfilService {
  final db = GetIt.I<DBPerfil>();

  Perfil? _perfil;

  Perfil? get perfilActivo => _perfil;

  // CARGA EL PERFIL GUARDADO EN SHARED PREFERENCES, SI EXISTE
  Future<void> cargarPerfil() async {
    final prefs = await SharedPreferences.getInstance();
    String? perfilJson = prefs.getString('perfil');

    if (perfilJson != null) {
      _perfil = Perfil.fromMap(jsonDecode(perfilJson));
    }
  }

  // CAMBIA EL PERFIL ACTIVO Y LO GUARDA EN SHARED PREFERENCES
  Future<bool> cambiarPerfil(Perfil perfil) async {
    _perfil = perfil;
    await guardarPerfil();
    return true;
  }

  // GUARDA EL PERFIL ACTIVO EN SHARED PREFERENCES COMO JSON
  Future<void> guardarPerfil() async {
    final prefs = await SharedPreferences.getInstance();

    if (_perfil != null) {
      String perfilJson = jsonEncode(_perfil!.toMap());
      await prefs.setString('perfil', perfilJson);
    }
  }

  // ELIMINA EL PERFIL GUARDADO EN SHARED PREFERENCES
  Future<void> eliminarPerfil() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('perfil');
    _perfil = null;
  }

  // VERIFICA QUE EL PERFIL ACTIVO EXISTA EN LA BASE DE DATOS Y SEA EL MISMO
  Future<bool> perfilValido() async {
    if (_perfil == null) return false;

    Perfil? perfilConsulta = await db.getPerfil(_perfil!.idPerfil);

    if (perfilConsulta != null) {
      return _perfil == perfilConsulta;
    }

    return false;
  }
}
