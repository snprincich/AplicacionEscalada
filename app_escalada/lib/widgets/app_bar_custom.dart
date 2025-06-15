import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:app_escalada/services/ble/bluetooth.dart';
import 'package:app_escalada/pages/ble_page.dart';
import 'package:app_escalada/pages/perfil_page.dart';

class AppBarCustom extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final ble = GetIt.I<Ble>();

  AppBarCustom({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    // ESCUCHA LOS CAMBIOS DE CONEXIÓN DEL BLUETOOTH PARA ACTUALIZAR EL ICONO
    return ValueListenableBuilder<bool>(
      valueListenable: ble.conectadoNotifier,
      builder: (context, conectado, _) {
        return AppBar(
          automaticallyImplyLeading: false,
          title: Text(title),
          actions: [
            Padding(
              // CAMBIA EL COLOR DEPENDIENDO DEL ESTADO DE CONEXION
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: conectado ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.bluetooth, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => BlePage()),
                    );
                  },
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PerfilPage()),
                );
              },
            ),
            // BOTONES PARA FUTURAS FUNCIONALIDADES
            /*
            IconButton(icon: const Icon(Icons.info), onPressed: () {}),
            IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
            */
          ],
        );
      },
    );
  }

  // ALTURA DE LA APPBAR
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
