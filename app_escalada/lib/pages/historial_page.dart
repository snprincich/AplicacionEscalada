import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:app_escalada/models/entrenamiento_detalles_model.dart';
import 'package:app_escalada/models/entrenamiento_model.dart';
import 'package:app_escalada/pages/entrenamiento_detalles_page.dart';
import 'package:app_escalada/services/db/db_entrenamiento_detalles.dart';
import 'package:app_escalada/services/db/db_entrenamientos.dart';
import 'package:app_escalada/services/exportar/exportar_service.dart';
import 'package:app_escalada/services/perfil/perfil_service.dart';

class HistoriaPage extends StatefulWidget {
  const HistoriaPage({Key? key}) : super(key: key);

  @override
  _HistoriaPageState createState() => _HistoriaPageState();
}

class _HistoriaPageState extends State<HistoriaPage> {
  final perfilService = GetIt.I<PerfilService>();
  final dbEntrenamientoDetalles = GetIt.I<DBEntrenamientosDetalles>();
  final dbEntrenamientos = GetIt.I<DBEntrenamientos>();
  final exportarService = GetIt.I<ExportarService>();

  List<EntrenamientoDetalles> detalles = [];
  List<Entrenamiento> entrenamientos = [];
  bool isLoading = true;

  Set<EntrenamientoDetalles> _seleccionados = {};

  @override
  void initState() {
    super.initState();
    _cargarEntrenamientos();
  }

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

  String _nombreEntrenamiento(int idEntrenamiento) {
    final entrenamiento = entrenamientos.firstWhere(
      (e) => e.idEntrenamiento == idEntrenamiento,
      orElse: () => Entrenamiento(nombreEntrenamiento: 'Desconocido'),
    );
    return entrenamiento.nombreEntrenamiento;
  }

  Future<void> _exportarCSV() async {
    if (_seleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No has seleccionado ningún detalle')),
      );
      return;
    }

    try {
      final path = await exportarService.exportarEntrenamientos(
        detallesSeleccionados: _seleccionados.toList(),
        entrenamientos: entrenamientos,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Archivo exportado a: $path')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error exportando CSV: $e')));
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
              ? const Center(child: Text('No hay detalles registrados.'))
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
                child: const Icon(Icons.download),
                tooltip: 'Exportar seleccionados a CSV',
              )
              : null,
    );
  }
}
