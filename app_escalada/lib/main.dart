import 'package:app_escalada/services/audio/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 👈 Importante para SystemChrome
import 'package:get_it/get_it.dart';
import 'package:app_escalada/services/ble/bluetooth.dart';
import 'package:app_escalada/services/db/db_datos.dart';
import 'package:app_escalada/services/db/db_entrenamiento_detalles.dart';
import 'package:app_escalada/services/db/db_entrenamientos.dart';
import 'package:app_escalada/pages/pantalla_carga_page.dart';
import 'package:app_escalada/services/db/db_perfil.dart';
import 'package:app_escalada/services/exportar/csv_service.dart';
import 'package:app_escalada/services/exportar/exportar_service.dart';
import 'package:app_escalada/services/perfil/perfil_service.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<Ble>(() => Ble());
  locator.registerLazySingleton<DBDatos>(() => DBDatos());
  locator.registerLazySingleton<DBPerfil>(() => DBPerfil());
  locator.registerLazySingleton<DBEntrenamientos>(() => DBEntrenamientos());
  locator.registerLazySingleton<DBEntrenamientosDetalles>(() => DBEntrenamientosDetalles());
  locator.registerLazySingleton<PerfilService>(() => PerfilService());
  locator.registerLazySingleton<CSVService>(() => CSVService());
  locator.registerLazySingleton(() => ExportarService(GetIt.I<DBDatos>(), GetIt.I<CSVService>()));
  locator.registerLazySingleton<AudioService>(() => AudioService());
}

void main() async {

  // SOLO ORIENTACION VERTICAL
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App escalada',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: PantallaCargaPage(),
    );
  }
}
