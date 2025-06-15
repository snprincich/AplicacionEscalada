import 'package:app_escalada/pages/ble_page.dart';
import 'package:app_escalada/services/ble/bluetooth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:app_escalada/models/perfil_model.dart';
import 'package:app_escalada/pages/pagina_principal.dart';
import 'package:app_escalada/services/db/db_perfil.dart';
import 'package:app_escalada/services/perfil/perfil_service.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

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

  // CARGA TODOS LOS PERFILES QUE HAY EN LA DB
  void _cargarPerfiles() async {
    List<Perfil> nuevosPerfiles = await db.getAllPerfiles();

    setState(() {
      perfiles = nuevosPerfiles;
    });
  }

  // CAMBIA EL PERFIL ACTIVO Y NAVEGA A LA PAGINA PRINCIPAL
  void _cargarPerfil(Perfil perfil) async {
    if (await perfilService.cambiarPerfil(perfil)) {
      navegar(PaginaPrincipal());
    }
  }

  // INSERTA UN NUEVO PERFIL EN LA BASE DE DATOS Y RECARGA LA LISTA
  void _insertarPerfil(String nombre) async {
    await db.insertPerfil(Perfil(nombrePerfil: nombre));
    _cargarPerfiles();
  }

  // BORRA UN PERFIL, ELIMINA EL PERFIL ACTIVO Y RECARGA LA LISTA
  void _borrarPerfil(String id) async {
    await db.deletePerfil(id);
    await perfilService.eliminarPerfil();
    _cargarPerfiles();
  }

  // MUESTRA UN POP-UP PARA CREAR UN NUEVO PERFIL
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

  // NAVEGA A OTRA PAGINA
  void navegar(Widget pagina) {
    if (!mounted) return;

    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => pagina));
    }
  }

  @override
  Widget build(BuildContext context) {
    final perfilActivo = perfilService.perfilActivo;
    final ble = GetIt.I<Ble>();
    // DETECTA CUANDO SE INTENTA SALIR DE LA APLICACION Y PIDE CONFIRMACION
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        final salir = await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
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
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: ValueListenableBuilder<bool>(
            valueListenable: ble.conectadoNotifier,
            builder: (context, conectado, _) {
              return AppBar(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                iconTheme: const IconThemeData(color: Colors.white),
                title: const Text(
                  'Perfil',
                  style: TextStyle(color: Colors.white),
                ),
                automaticallyImplyLeading: false,
                actions: [
                  Padding(
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
                ],
              );
            },
          ),
        ),
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
      ),
    );
  }
}
