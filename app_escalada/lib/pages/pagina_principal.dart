import 'package:flutter/material.dart';
import 'package:app_escalada/pages/config_entrenamiento_isometrico_page.dart';
import 'package:app_escalada/pages/historial_page.dart';
import 'package:app_escalada/widgets/app_bar_custom.dart';
import 'package:flutter/services.dart';

class PaginaPrincipal extends StatefulWidget {
  const PaginaPrincipal({super.key});

  @override
  State<PaginaPrincipal> createState() => _PaginaPrincipalState();
}

class _PaginaPrincipalState extends State<PaginaPrincipal> {
  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
return WillPopScope(
  onWillPop: () async {
    final salir = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Salir de la aplicación?'),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
    return salir == true;
  },
      child: Scaffold(
        appBar: AppBarCustom(title: 'Página principal'),
        body: ListView(
          children: [
            Card(
              margin: EdgeInsets.all(8),
              child: ListTile(
                title: Text('Entrenamiento 1'),
                subtitle: Text('Isometrico'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ConfigEntrenamientoIsometricoPage(),
                    ),
                  );
                },
              ),
            ),
Card(
  margin: EdgeInsets.all(8),
  child: ListTile(
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'NO DISPONIBLE',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Entrenamiento 2',
          style: TextStyle(fontSize: 16),
        ),
      ],
    ),
    subtitle: const Text('Repeticiones'),
    onTap: () {},
  ),
)
          ],
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: 'Ir al historial',
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => HistorialPage()));
          },
          child: Icon(Icons.history),
        ),
      ),
    );
  }
}
