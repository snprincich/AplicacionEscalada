import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:app_escalada/models/entrenamiento_detalles_model.dart';
import 'package:app_escalada/models/entrenamiento_model.dart';
import 'package:app_escalada/pages/entrenamiento_detalles_page.dart';
import 'package:app_escalada/services/db/db_entrenamiento_detalles.dart';
import 'package:app_escalada/services/db/db_entrenamientos.dart';
import 'package:app_escalada/services/exportar/exportar_service.dart';
import 'package:app_escalada/services/perfil/perfil_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class HistorialPage extends StatefulWidget {
  const HistorialPage({super.key});

  @override
  HistorialPageState createState() => HistorialPageState();
}

class HistorialPageState extends State<HistorialPage> {
  final perfilService = GetIt.I<PerfilService>();
  final dbEntrenamientoDetalles = GetIt.I<DBEntrenamientosDetalles>();
  final dbEntrenamientos = GetIt.I<DBEntrenamientos>();
  final exportarService = GetIt.I<ExportarService>();

  List<EntrenamientoDetalles> detalles = [];
  List<Entrenamiento> entrenamientos = [];
  bool isLoading = true;

  final Set<EntrenamientoDetalles> _seleccionados = {};

  @override
  void initState() {
    super.initState();
    _cargarEntrenamientos();
  }

  // TRAE LOS ENTRENAMIENTOS Y DETALLES DESDE LA BD
  Future<void> _cargarEntrenamientos() async {
    if (perfilService.perfilActivo != null) {
      final dataDetalles = await dbEntrenamientoDetalles.getDetallesPorPerfil(
        perfilService.perfilActivo!.idPerfil,
      );
      final dataEntrenamientos = await dbEntrenamientos.getAllEntrenamientos();

      setState(() {
        detalles = dataDetalles;
        entrenamientos = dataEntrenamientos;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  //FORMATEA LA FECHA Y HORA
  String _formatearFechaHora(String fechaString) {
    final fecha = DateTime.tryParse(fechaString);
    if (fecha == null) return fechaString;

    String twoDigits(int n) => n.toString().padLeft(2, '0');

    final dia = twoDigits(fecha.day);
    final mes = twoDigits(fecha.month);
    final anio = fecha.year;
    final hora = twoDigits(fecha.hour);
    final minuto = twoDigits(fecha.minute);

    return '$dia/$mes/$anio $hora:$minuto';
  }

  // OBTIENE EL NOMBRE DEL ENTRENAMIENTO POR ID
  String _nombreEntrenamiento(int idEntrenamiento) {
    final entrenamiento = entrenamientos.firstWhere(
      (e) => e.idEntrenamiento == idEntrenamiento,
      orElse: () => Entrenamiento(nombreEntrenamiento: 'Desconocido'),
    );
    return entrenamiento.nombreEntrenamiento;
  }

  // EXPORTA LOS DETALLES SELECCIONADOS A CSV USANDO LA FUNCION DE COMPARTIR
  Future<void> _exportarCSV() async {
    if (_seleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No has seleccionado ningún detalle')),
      );
      return;
    }

    final controlador = TextEditingController(
      text: 'entrenamientos_export.csv',
    );

    final nombreArchivo = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Nombre del archivo'),
            content: TextField(
              controller: controlador,
              decoration: const InputDecoration(hintText: 'archivo.csv'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, controlador.text),
                child: const Text('Aceptar'),
              ),
            ],
          ),
    );

    if (nombreArchivo == null || nombreArchivo.trim().isEmpty) return;

    try {
      final csvString = await exportarService.generarCSVString(
        detallesSeleccionados: _seleccionados.toList(),
        entrenamientos: entrenamientos,
      );

      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$nombreArchivo';
      final file = File(filePath);
      await file.writeAsString(csvString);

      // ignore: deprecated_member_use
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Exportar entrenamientos',
        subject: 'Archivo CSV: $nombreArchivo',
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error exportando: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final perfil = perfilService.perfilActivo;

    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de ${perfil?.nombrePerfil ?? "Desconocido"}'),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : detalles.isEmpty
              ? const Center(child: Text('No hay detalles.'))
              : ListView.builder(
                itemCount: detalles.length,
                itemBuilder: (context, index) {
                  final detalle = detalles[index];
                  final nombreEntrenamiento = _nombreEntrenamiento(
                    detalle.idEntrenamiento,
                  );

                  return ListTile(
                    leading: Checkbox(
                      value: _seleccionados.contains(detalle),
                      onChanged: (bool? seleccionado) {
                        setState(() {
                          if (seleccionado == true) {
                            _seleccionados.add(detalle);
                          } else {
                            _seleccionados.remove(detalle);
                          }
                        });
                      },
                    ),
                    title: Text(nombreEntrenamiento),
                    subtitle: Text(
                      'Fecha: ${_formatearFechaHora(detalle.fecha)}\n',
                    ),
                    onTap: () {
                      final entrenamiento = entrenamientos.firstWhere(
                        (e) => e.idEntrenamiento == detalle.idEntrenamiento,
                        orElse:
                            () => Entrenamiento(
                              idEntrenamiento: 0,
                              nombreEntrenamiento: 'Desconocido',
                            ),
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => EntrenamientoDetallesPage(
                                detalle: detalle,
                                entrenamiento: entrenamiento,
                              ),
                        ),
                      );
                    },
                  );
                },
              ),
      floatingActionButton:
          _seleccionados.isNotEmpty
              ? FloatingActionButton(
                onPressed: _exportarCSV,
                tooltip: 'Exportar a CSV',
                child: const Icon(Icons.download),
              )
              : null,
    );
  }
}
