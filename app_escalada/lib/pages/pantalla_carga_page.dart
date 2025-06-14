import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:app_escalada/services/ble/bluetooth.dart';
import 'package:app_escalada/pages/pagina_principal.dart';
import 'package:app_escalada/pages/perfil_page.dart';
import 'package:app_escalada/services/db/db_main.dart';
import 'package:app_escalada/services/perfil/perfil_service.dart';

class PantallaCargaPage extends StatefulWidget {
  const PantallaCargaPage({super.key});

  @override
  State<PantallaCargaPage> createState() => _PantallaCargaPageState();
}

class _PantallaCargaPageState extends State<PantallaCargaPage> {
  @override
  void initState() {
    super.initState();

    // LLAMA AL METODO QUE INICIALIZA TODOS LOS SERVICIOS NECESARIOS PARA QUE FUNCIONE LA APLICACION
    _inicializarApp();
  }

  // INICIALIZA TODOS LOS SERVICIOS NECESARIOS PARA QUE FUNCIONE LA APLICACION
  // INICIALIZA BD, PERFIL Y BLUETOOTH
  void _inicializarApp() async {
    final perfilService = GetIt.I<PerfilService>();
    final ble = GetIt.I<Ble>();

    ble.loadDevice();

    try {
      // HACE UN AWAIT DE LO QUE HAYA DENTRO
      // ESPERA A QUE TERMINEN TODAS LAS LLAMADAS ASINCRONAS ANTES DE AVANZAR
      await Future.wait([
        DBMain.getDatabase(),
        perfilService.cargarPerfil(),
        Future.delayed(Duration(seconds: 3)),
      ]);
    } catch (e) {
      if (kDebugMode) {
        print('Error durante la inicialización: $e');
      }
    }

    // NAVEGA A PERFIL SI NO HAY PERFIL VÁLIDO, SINO A PÁGINA PRINCIPAL
    if (!await perfilService.perfilValido()) {
      navegar(PerfilPage());
    } else {
      navegar(PaginaPrincipal());
    }
  }

  void navegar(Widget pagina) {
    if (!mounted) {
      return; //NOS ASEGURAMOS DE QUE FLUTTER NO INTENTA ACCEDER A UN CONTEXT QUE YA NO EXISTE
    }
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
              'Aplicación Escalada',
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
