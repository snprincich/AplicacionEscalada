import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:app_escalada/models/entrenamiento_detalles_model.dart';
import 'package:app_escalada/models/entrenamiento_model.dart';
import 'package:get_it/get_it.dart';
import 'package:app_escalada/models/datos_model.dart';
import 'package:app_escalada/services/db/db_datos.dart';

class EntrenamientoDetallesPage extends StatefulWidget {
  final EntrenamientoDetalles detalle;
  final Entrenamiento entrenamiento;

  const EntrenamientoDetallesPage({
    super.key,
    required this.detalle,
    required this.entrenamiento,
  });

  @override
  State<EntrenamientoDetallesPage> createState() =>
      _EntrenamientoDetallesPageState();
}

class _EntrenamientoDetallesPageState extends State<EntrenamientoDetallesPage> {
  final dbDatos = GetIt.I<DBDatos>();
  List<Datos> datos = [];
  bool isLoading = true;

  double yMax = 100;
  double xMax = 10;

  int? selectedSerie;
  int? selectedRepeticion;

  List<int> seriesDisponibles = [];
  List<int> repeticionesDisponibles = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  // TRAE DATOS DE LA BASE DE DATOS
  Future<void> _cargarDatos() async {
    final data = await dbDatos.getDatosPorDetalle(
      widget.detalle.idEntrenamientoDetalles!,
    );
    setState(() {
      datos = data;
      isLoading = false;

      // SACA LAS SERIES Y REPETICIONES DISPONIBLES
      seriesDisponibles = datos.map((d) => d.numSerie).toSet().toList()..sort();
      repeticionesDisponibles =
          datos.map((d) => d.numRepeticion).toSet().toList()..sort();

      selectedSerie =
          seriesDisponibles.isNotEmpty ? seriesDisponibles.first : null;
      selectedRepeticion =
          repeticionesDisponibles.isNotEmpty
              ? repeticionesDisponibles.first
              : null;

      _actualizarMaximos();
    });
  }

  // ACTUALIZA VALORES MAXIMOS PARA EL GRAFICO
  void _actualizarMaximos() {
    final datosFiltrados = _filtrarDatos();

    if (datosFiltrados.isNotEmpty) {
      yMax =
          datosFiltrados.map((d) => d.peso!).reduce((a, b) => a > b ? a : b) +
          10;
      xMax = datosFiltrados.length.toDouble();
    } else {
      yMax = 100;
      xMax = 10;
    }
  }

  // FILTRA DATOS SEGUN SERIE Y REPECION SELECCIONADA
  List<Datos> _filtrarDatos() {
    return datos.where((d) {
      final serieMatch = selectedSerie == null || d.numSerie == selectedSerie;
      final repMatch =
          selectedRepeticion == null || d.numRepeticion == selectedRepeticion;
      return serieMatch && repMatch;
    }).toList();
  }

  // GENERA LOS PUNTOS Y LINEAS PARA EL GRAFICO
  // SI EL SEGUNDO PUNTO ESTA POR DEBAJO DEL PESO OBJETIVO SE COLOREA DE ROJO, SI ESTA POR ENCIMA, DE VERDE
  List<LineChartBarData> _colorearSegmentos() {
    final datosFiltrados = _filtrarDatos();

    if (datosFiltrados.isEmpty) return [];

    List<FlSpot> spots = [];
    for (int i = 0; i < datosFiltrados.length; i++) {
      spots.add(FlSpot((i + 1).toDouble(), datosFiltrados[i].peso!));
    }

    return [
      LineChartBarData(
        spots: spots,
        isCurved: false,
        color: Colors.blue,
        barWidth: 3,
        dotData: FlDotData(show: true),
      ),
    ];
  }

  // FORMATEA FECHA
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalles del entrenamiento')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    Text(
                      widget.entrenamiento.nombreEntrenamiento,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _infoRow(
                              'Fecha:',
                              _formatearFechaHora(widget.detalle.fecha),
                            ),
                            _infoRow(
                              'Duración:',
                              '${widget.detalle.duracionRepeticion!.toInt()} segundos por repetición',
                            ),
                            _infoRow(
                              'Peso objetivo:',
                              '${widget.detalle.pesoObjetivo} kg',
                            ),
                            _infoRow('Series:', '${widget.detalle.series}'),
                            _infoRow(
                              'Repeticiones:',
                              '${widget.detalle.repeticiones}',
                            ),
                            _infoRow(
                              'Descanso entre repeticiones:',
                              '${widget.detalle.descansoRepeticion!.toInt()} segundos',
                            ),
                            _infoRow(
                              'Descanso entre series:',
                              '${widget.detalle.descansoSerie!.toInt()} segundos',
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    const Text(
                      'Seleccionar progreso',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        const Text('Serie:'),
                        const SizedBox(width: 10),
                        DropdownButton<int>(
                          value: selectedSerie,
                          items:
                              seriesDisponibles
                                  .map(
                                    (s) => DropdownMenuItem(
                                      value: s,
                                      child: Text('$s'),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedSerie = val;
                              _actualizarMaximos();
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Repetición:'),
                        const SizedBox(width: 10),
                        DropdownButton<int>(
                          value: selectedRepeticion,
                          items:
                              repeticionesDisponibles
                                  .map(
                                    (r) => DropdownMenuItem(
                                      value: r,
                                      child: Text('$r'),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedRepeticion = val;
                              _actualizarMaximos();
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Progreso',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _colorearSegmentos().isEmpty
                        ? const Text('No hay datos.')
                        : SizedBox(
                          height: 200,
                          child: LineChart(
                            LineChartData(
                              minY: 0,
                              maxY: yMax,
                              minX: 1,
                              maxX: xMax,
                              titlesData: FlTitlesData(
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, _) {
                                      if (value == 0 || value == yMax) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            left: 8,
                                          ),
                                          child: Text('${value.toInt()}'),
                                        );
                                      }
                                      return Container();
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, _) {
                                      if (value == 0 || value == yMax) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            right: 8,
                                          ),
                                          child: Text('${value.toInt()}'),
                                        );
                                      }
                                      return Container();
                                    },
                                  ),
                                ),

                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 1,
                                    getTitlesWidget:
                                        (value, _) => Text('${value.toInt()}'),
                                  ),
                                ),
                              ),
                              gridData: FlGridData(show: true),
                              borderData: FlBorderData(show: true),
                              lineBarsData: _colorearSegmentos(),
                              lineTouchData: LineTouchData(enabled: false),
                              extraLinesData: ExtraLinesData(
                                horizontalLines: [
                                  HorizontalLine(
                                    y: widget.detalle.pesoObjetivo,
                                    color: Colors.red,
                                    strokeWidth: 2,
                                    dashArray: [5, 5],
                                  ),
                                ],
                              ),
                              clipData: FlClipData.all(),
                            ),
                          ),
                        ),
                  ],
                ),
              ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
