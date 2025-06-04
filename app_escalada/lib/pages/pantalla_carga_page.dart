import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:app_escalada/services/ble/bluetooth.dart';
import 'package:app_escalada/pages/pagina_principal.dart';
import 'package:app_escalada/pages/perfil_page.dart';
import 'package:app_escalada/services/db/db_main.dart';
import 'package:app_escalada/services/perfil/perfil_service.dart';

class PantallaCargaPage extends StatefulWidget {
  @override
  State<PantallaCargaPage> createState() => _PantallaCargaPageState();
}

class _PantallaCargaPageState extends State<PantallaCargaPage> {
  @override
  void initState() {
    super.initState();
    _inicializarApp();
  }

  void _inicializarApp() async {
    final perfilService = GetIt.I<PerfilService>();
    final ble = GetIt.I<Ble>();

    ble.loadDevice();

    //HACE UN AWAIT DE LO QUE HAYA DENTRO
    try {
      //HACE UN AWAIT DE LO QUE HAYA DENTRO
      await Future.wait([
        DBMain.getDatabase(),
        perfilService.cargarPerfil(),
        Future.delayed(Duration(seconds: 3)),
        //ble.loadDevice().timeout(Duration(seconds: 3),onTimeout: () {print('Timeout global en loadDevice'); return null;},),
      ]);
    } catch (e) {
      print('Error durante la inicialización: $e');
    }

    if (!await perfilService.perfilValido()) {
      navegar(PerfilPage());
    } else {
      navegar(PaginaPrincipal());
    }
  }

  void navegar(Widget pagina) {
    if (!mounted)
      return; //NOS ASEGURAMOS DE QUE FLUTTER NO INTENTA ACCEDER A UN CONTEXT QUE YA NO EXISTE
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => pagina));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'MiApp',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 32),
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando...', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
