import 'dart:convert';
import 'package:get_it/get_it.dart';
import 'package:app_escalada/models/perfil_model.dart';
import 'package:app_escalada/services/db/db_perfil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PerfilService {
  final db = GetIt.I<DBPerfil>();

  Perfil? _perfil;

  Perfil? get perfilActivo => _perfil;

  Future<void> cargarPerfil() async {
    final prefs = await SharedPreferences.getInstance();
    String? perfilJson = prefs.getString('perfil');

    if (perfilJson != null) {
      _perfil = Perfil.fromMap(jsonDecode(perfilJson));
    }
  }

  Future<bool> cambiarPerfil(Perfil perfil) async {
    _perfil = perfil;
    await guardarPerfil();
    return true;
  }

  Future<void> guardarPerfil() async {
    final prefs = await SharedPreferences.getInstance();

    if (_perfil != null) {
      String perfilJson = jsonEncode(_perfil!.toMap());
      await prefs.setString('perfil', perfilJson);
    }
  }

  Future<void> eliminarPerfil() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('perfil');
    _perfil = null;
  }

  Future<bool> perfilValido() async {
    if (_perfil == null) return false;

    Perfil? perfilConsulta = await db.getPerfil(_perfil!.idPerfil);

    if (perfilConsulta != null) {
      return _perfil == perfilConsulta;
    }

    return false;
  }
}
