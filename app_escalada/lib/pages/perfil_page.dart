import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:app_escalada/models/perfil_model.dart';
import 'package:app_escalada/pages/pagina_principal.dart';
import 'package:app_escalada/services/db/db_perfil.dart';
import 'package:app_escalada/services/perfil/perfil_service.dart';
import 'package:app_escalada/widgets/appBarCustom.dart';

class PerfilPage extends StatefulWidget {
  @override
  PerfilPageState createState() => PerfilPageState();
}

class PerfilPageState extends State<PerfilPage> {
  final db = GetIt.I<DBPerfil>();
  final perfilService = GetIt.I<PerfilService>();

  List<Perfil> perfiles = [];

  @override
  void initState() {
    _cargarPerfiles();
    super.initState();
  }

  void _cargarPerfiles() async {
    List<Perfil> nuevosPerfiles = await db.getAllPerfiles();

    setState(() {
      perfiles = nuevosPerfiles;
    });
  }

  void _cargarPerfil(Perfil perfil) async {
    if (await perfilService.cambiarPerfil(perfil)) {
      navegar(PaginaPrincipal());
    }
  }

  void _insertarPerfil(String nombre) async {
    await db.insertPerfil(Perfil(nombrePerfil: nombre));
    _cargarPerfiles();
  }

  void _borrarPerfil(String id) async {
    await db.deletePerfil(id);
    await perfilService.eliminarPerfil();
    _cargarPerfiles();
  }

  void _crearPerfil() async {
    String nuevoNombre = '';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Crear nuevo perfil'),
          content: TextField(
            onChanged: (value) {
              nuevoNombre = value;
            },
            decoration: InputDecoration(hintText: "Nombre del perfil"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (nuevoNombre.trim().isNotEmpty) {
                  setState(() {
                    _insertarPerfil(nuevoNombre.trim());
                  });
                }
                Navigator.of(context).pop();
              },
              child: Text('Crear'),
            ),
          ],
        );
      },
    );
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
    final perfilActivo = perfilService.perfilActivo;

    return Scaffold(
      appBar: AppBarCustom(title: 'Perfil'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: ElevatedButton(
                onPressed: _crearPerfil,
                child: Text('Crear nuevo perfil'),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: perfiles.length,
                  itemBuilder: (context, index) {
                    final perfil = perfiles[index];
                    final esActivo =
                        perfilActivo != null &&
                        perfil.idPerfil == perfilActivo.idPerfil;

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 6),
                      color: esActivo ? Colors.green[100] : null,
                      child: ListTile(
                        title: Text(
                          perfil.nombrePerfil,
                          style: TextStyle(
                            color: esActivo ? Colors.green[900] : null,
                            fontWeight: esActivo ? FontWeight.bold : null,
                          ),
                        ),
                        onTap: () {
                          _cargarPerfil(perfil);
                        },
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            bool confirmar = false;

                            await showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: Text('¿Eliminar perfil?'),
                                    content: Text(
                                      '¿Estás seguro de que quieres eliminar este perfil?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.of(context).pop(),
                                        child: Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          confirmar = true;
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          'Eliminar',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                            );

                            if (confirmar) {
                              _borrarPerfil(perfil.idPerfil);
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
