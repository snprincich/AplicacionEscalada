import 'package:flutter/material.dart';
import 'package:app_escalada/pages/config_entrenamiento_isometrico_page.dart';
import 'package:app_escalada/pages/historial_page.dart';
import 'package:app_escalada/widgets/appBarCustom.dart';

class PaginaPrincipal extends StatefulWidget {
  const PaginaPrincipal({Key? key}) : super(key: key);

  @override
  State<PaginaPrincipal> createState() => _PaginaPrincipalState();
}

class _PaginaPrincipalState extends State<PaginaPrincipal> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              title: Text('Entrenamiento 2'),
              subtitle: Text('Repeticiones'),
              onTap: () {},
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.history),
        tooltip: 'Ir al historial',
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => HistoriaPage()));
        },
      ),
    );
  }
}
