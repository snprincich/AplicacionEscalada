import 'package:uuid/uuid.dart';

class Perfil {
  final String idPerfil;
  final String nombrePerfil;

  Perfil({required this.nombrePerfil})
    : idPerfil = Uuid().v4(); // AQUI SE GENERA ID CON UUID

  Perfil.withId({required this.idPerfil, required this.nombrePerfil});

  Map<String, dynamic> toMap() {
    return {'id_perfil': idPerfil, 'nombre_perfil': nombrePerfil};
  }

  factory Perfil.fromMap(Map<String, dynamic> map) {
    return Perfil.withId(
      nombrePerfil: map['nombre_perfil'],
      idPerfil: map['id_perfil'],
    );
  }

  static List<Perfil> fromMapList(List<Map<String, dynamic>> mapList) {
    return mapList.map((map) => Perfil.fromMap(map)).toList();
  }

  @override
  String toString() {
    return 'Perfil{id_perfil: $idPerfil, nombre_perfil: $nombrePerfil}';
  }

  // PARA PODER COMPARAR DOS PERFILES A PARTIR DE ID Y NOMBRE
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Perfil &&
          runtimeType == other.runtimeType &&
          idPerfil == other.idPerfil &&
          nombrePerfil == other.nombrePerfil;

  @override
  int get hashCode => Object.hash(idPerfil, nombrePerfil);
}
