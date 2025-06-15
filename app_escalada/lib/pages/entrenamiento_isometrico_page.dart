import 'dart:async';
import 'dart:math';
import 'package:app_escalada/services/audio/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:app_escalada/services/ble/bluetooth.dart';
import 'package:app_escalada/models/datos_model.dart';
import 'package:app_escalada/models/entrenamiento_detalles_model.dart';
import 'package:app_escalada/pages/pagina_principal.dart';
import 'package:app_escalada/services/db/db_datos.dart';
import 'package:app_escalada/services/db/db_entrenamiento_detalles.dart';
import 'package:app_escalada/widgets/app_bar_custom.dart';

class EntrenamientoIsometricoPage extends StatefulWidget {
  final EntrenamientoDetalles detalles;

  final ble = GetIt.I<Ble>();
  final AudioService audioService = GetIt.I<AudioService>();

  EntrenamientoIsometricoPage({super.key, required this.detalles});

  @override
  EntrenamientoIsometricoPageState createState() =>
      EntrenamientoIsometricoPageState();
}

class EntrenamientoIsometricoPageState
    extends State<EntrenamientoIsometricoPage> {
  bool ejecucion = false;
  String boton = 'assets/icons/play.svg';

  int setActual = 1;
  int repActual = 1;

  double pesoActual = 0;

  int time = 0;

  late double _timer;
  Timer? _countdownTimer;

  double _cuentaAtrasDescanso = 0;
  Timer? _cuentaAtrasDescansoTemporizador;

  double _cuentaAtras = 0;
  Timer? _cuentaAtrasTimer;

  Random random = Random();

  List<FlSpot> spots = [];

  List<Datos> datosGuardados = [];

  bool isConnecting = false;

  @override
  void initState() {
    super.initState();
    widget.ble.onDataReceived = agregarDato;

    _timer = widget.detalles.duracionRepeticion!;

    widget.ble.conectadoNotifier.addListener(() {
      if (!widget.ble.conectadoNotifier.value) {
        if (ejecucion) {
          _pauseEntrenamiento();
        }
      }
    });
  }

  void agregarDato(double dato) {
    setState(() {
      addNewPoint(dato / 1000);
      pesoActual = dato / 1000;
      guardarDatosActuales();
    });
  }

  Future<void> _startTimer() async {
    _countdownTimer?.cancel();

    _countdownTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        if (_timer > 0.0) {
          double oldTimer = _timer;
          _timer -= 0.1;
          if (_timer < 0) _timer = 0;

          if (oldTimer.floor() != _timer.floor()) {
            int t = _timer.floor();
            switch (t) {
              case 5:
                widget.audioService.playFive();
                break;
              case 4:
                widget.audioService.playFour();
                break;
              case 3:
                widget.audioService.playThree();
                break;
              case 2:
                widget.audioService.playTwo();
                break;
              case 1:
                widget.audioService.playOne();
                break;
              case 0:
                widget.audioService.playRest();
                break;
            }
          }
        } else {
          _countdownTimer?.cancel();
          avanzarRepeticion();
        }
      });
    });
  }

  String formatTime(double timer) {
    int minutes = (timer / 60).floor();
    int seconds = (timer % 60).floor();
    int tenths = ((timer * 10) % 10).toInt();

    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${tenths.toString()}";
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _cuentaAtrasTimer?.cancel();
    super.dispose();
  }

  void addNewPoint(double value) {
    setState(() {
      spots.add(FlSpot(time.toDouble(), value));
      time++;
    });
  }

  List<LineChartBarData> _colorearSegmentos() {
    List<LineChartBarData> barDataList = [];

    for (int i = 0; i < spots.length - 1; i++) {
      FlSpot start = spots[i];
      FlSpot end = spots[i + 1];

      Color color;
      if (start.y < widget.detalles.pesoObjetivo &&
          end.y > widget.detalles.pesoObjetivo) {
        color = Colors.green;
      } else if (start.y > widget.detalles.pesoObjetivo &&
          end.y < widget.detalles.pesoObjetivo) {
        color = Colors.red;
      } else if (start.y > widget.detalles.pesoObjetivo &&
          end.y > widget.detalles.pesoObjetivo) {
        color = Colors.green;
      } else {
        color = Colors.red;
      }

      barDataList.add(
        LineChartBarData(
          spots: [start, end],
          isCurved: false,
          color: color,
          barWidth: 2,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
        ),
      );
    }
    return barDataList;
  }

  void _pauseEntrenamiento() {
    setState(() {
      boton = 'assets/icons/play.svg';
      _countdownTimer?.cancel();
      ejecucion = false;
      widget.ble.dejarRecibirDatos();
    });
  }

  void _empezarEntrenamiento() async {
    await widget.ble.recibirDatos();
    setState(() {
      boton = 'assets/icons/pause.svg';
      ejecucion = true;
      _startTimer();
      isConnecting = false;
    });
  }

  void playPause() {
    if (!widget.ble.conectadoNotifier.value) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Debes conectar el dispositivo Bluetooth para comenzar',
          ),
        ),
      );
      return;
    }

    if (isConnecting) {
      return;
    }

    setState(() {
      if (ejecucion) {
        _pauseEntrenamiento();
      } else {
        isConnecting = true;
        _startCuentaAtras();
      }
    });
  }

  void _startCuentaAtras() {
    _cuentaAtras = 5;

    widget.audioService.playFive();

    _cuentaAtrasTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_cuentaAtras > 0) {
        setState(() {
          _cuentaAtras--;
        });

        switch (_cuentaAtras) {
          case 5:
            await widget.audioService.playFive();
            break;
          case 4:
            await widget.audioService.playFour();
            break;
          case 3:
            await widget.audioService.playThree();
            break;
          case 2:
            await widget.audioService.playTwo();
            break;
          case 1:
            await widget.audioService.playOne();
            break;
          case 0:
            await widget.audioService.playGo();
            break;
        }
      } else {
        timer.cancel();
        _empezarEntrenamiento();
      }
    });
  }

  void finalizarEntrenamiento() async {
    _pauseEntrenamiento();

    await guardarSesionEntrenamiento();
    
  if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Entrenamiento finalizado')));

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => PaginaPrincipal()),
      (Route<dynamic> route) => false, // elimina TODAS las páginas anteriores
    );
  }

  void limpiarSpots() {
    spots.clear();
    time = 0;
  }

  void avanzarRepeticionManual() {
    _pauseEntrenamiento();
    setState(() {
      limpiarSpots();
      borrarDatosSetRep(setActual, repActual);

      if (repActual < widget.detalles.repeticiones) {
        repActual++;
      } else if (setActual < widget.detalles.series) {
        setActual++;
        repActual = 1;
      }
      _timer = widget.detalles.duracionRepeticion!;
    });
  }

  void avanzarRepeticion() {
    _cuentaAtrasDescansoTemporizador?.cancel();

    widget.ble.dejarRecibirDatos();

    setState(() {
      limpiarSpots();

      if (repActual < widget.detalles.repeticiones) {
        repActual++;
        _cuentaAtrasDescanso = widget.detalles.descansoRepeticion!;
      } else if (setActual < widget.detalles.series) {
        setActual++;
        repActual = 1;
        _cuentaAtrasDescanso = widget.detalles.descansoSerie!;
      } else {
        finalizarEntrenamiento();
        return;
      }

      _iniciarCuentaAtrasDescanso();
    });
  }

  bool _descansoActivo = false;
  void _iniciarCuentaAtrasDescanso() {
    _descansoActivo = true;

    _cuentaAtrasDescansoTemporizador = Timer.periodic(Duration(seconds: 1), (
      timer,
    ) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _cuentaAtrasDescanso--;
      });

      switch (_cuentaAtrasDescanso) {
        case 5:
          await widget.audioService.playFive();
          break;
        case 4:
          await widget.audioService.playFour();
          break;
        case 3:
          await widget.audioService.playThree();
          break;
        case 2:
          await widget.audioService.playTwo();
          break;
        case 1:
          await widget.audioService.playOne();
          break;
        case 0:
          await widget.audioService.playGo();
          break;
      }

      if (_cuentaAtrasDescanso <= 0) {
        timer.cancel();
        _cuentaAtrasDescansoTemporizador = null;

        _descansoActivo = false;

        _timer = widget.detalles.duracionRepeticion!;
        _empezarEntrenamiento();
      }
    });
  }

  void retrocederRepeticionManual() {
    _pauseEntrenamiento();
    setState(() {
      limpiarSpots();

      borrarDatosSetRep(setActual, repActual);

      if (repActual > 1) {
        repActual--;
        borrarDatosSetRep(setActual, repActual);
      } else if (setActual > 1) {
        setActual--;
        repActual = widget.detalles.repeticiones;
        borrarDatosSetRep(setActual, repActual);
      }
      _timer = widget.detalles.duracionRepeticion!;
    });
  }

  void avanzarSerieManual() {
    _pauseEntrenamiento();
    setState(() {
      limpiarSpots();

      if (setActual < widget.detalles.series) {
        setActual++;
        repActual = 1;
      }
      _timer = widget.detalles.duracionRepeticion!;
    });
  }

  void retrocederSerieManual() {
    _pauseEntrenamiento();
    setState(() {
      limpiarSpots();

      for (int r = repActual; r >= 1; r--) {
        borrarDatosSetRep(setActual, r);
      }

      if (setActual > 1) {
        setActual--;

        borrarDatosSetRep(setActual, repActual);
      } else {
        repActual = 1;
      }

      _timer = widget.detalles.duracionRepeticion!;
    });
  }

  Future<void> guardarSesionEntrenamiento() async {
    final dbEntrenamientosDetalles = GetIt.I<DBEntrenamientosDetalles>();
    final dbDatos = GetIt.I<DBDatos>();

    int detallesId = await dbEntrenamientosDetalles.insertDetalle(
      widget.detalles,
    );

    for (Datos dato in datosGuardados) {
      dato.idEntrenamientoDetalle = detallesId;
    }
    
  if (!mounted) return;
    dbDatos.insertDatos(datosGuardados, context);
  }

  void guardarDatosActuales() {
    final nuevoDato = Datos(
      idEntrenamientoDetalle: null,
      numRepeticion: repActual,
      numSerie: setActual,
      tiempo: spots.last.x,
      peso: spots.last.y,
    );

    datosGuardados.add(nuevoDato);
  }

  void borrarDatosSetRep(int set, int rep) {
    datosGuardados.removeWhere(
      (d) => d.numSerie == set && d.numRepeticion == rep,
    );
  }

  @override
  Widget build(BuildContext context) {
    int mostrarUltimos = 14;

    double xMax = spots.isNotEmpty ? spots.last.x : 0;

    if (xMax < widget.detalles.duracionRepeticion! && xMax < mostrarUltimos) {
      xMax = widget.detalles.duracionRepeticion!;
      if (widget.detalles.duracionRepeticion! > mostrarUltimos) {
        xMax = mostrarUltimos.toDouble();
      }
    }

    double xMin = 0;
    if (xMax > mostrarUltimos) {
      xMin = xMax - mostrarUltimos;
    }

    double yMax = widget.detalles.pesoObjetivo * 1.5;

    if (spots.isNotEmpty) {
      final ultimosSpots = spots.sublist(
        spots.length > mostrarUltimos ? spots.length - mostrarUltimos : 0,
        spots.length,
      );
      double maxYUltimos =
          ultimosSpots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) +
          5;

      if (maxYUltimos > yMax) {
        yMax = maxYUltimos;
      }
    }

    return Scaffold(
      appBar: AppBarCustom(title: 'Entrenamiento'),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    margin: EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${pesoActual.toStringAsFixed(1)} kg',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: yMax,
                        minX: xMin.toDouble(),
                        maxX: xMax.toDouble(),
                        titlesData: FlTitlesData(
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, _) {
                                if (value == 0 || value == yMax) {
                                  return Padding(
                                    padding: EdgeInsets.only(right: 8),
                                    child: Text('${value.toInt()}'),
                                  );
                                }
                                return Container();
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, _) {
                                if (value == 0 || value == yMax) {
                                  return Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: Text('${value.toInt()}'),
                                  );
                                }
                                return Container();
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: false,
                              interval: 1,
                              getTitlesWidget:
                                  (value, _) => Text('${value.toInt()}s'),
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
                              y: widget.detalles.pesoObjetivo,
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
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 80,

                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Center(
                          child:
                              _cuentaAtras > 0
                                  ? Text(
                                    'Comenzando en ${_cuentaAtras.toInt()}...',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  )
                                  : Text(
                                    formatTime(_timer),
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        ),
                        if (_descansoActivo)
                          Container(
                            width: double.infinity,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Descanso: ${_cuentaAtrasDescanso.toInt()}...',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 80,
                          margin: EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'REP',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '$repActual/${widget.detalles.repeticiones}',
                                  style: TextStyle(fontSize: 24),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 80,
                          margin: EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'SET',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '$setActual/${widget.detalles.series}',
                                  style: TextStyle(fontSize: 24),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.first_page),
                        iconSize: 32,
                        onPressed: retrocederSerieManual,
                      ),
                      IconButton(
                        icon: Icon(Icons.fast_rewind),
                        iconSize: 32,
                        onPressed: retrocederRepeticionManual,
                      ),
                      ElevatedButton(
                        onPressed: playPause,
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                            Colors.transparent,
                          ),
                          elevation: WidgetStateProperty.all(0),
                          padding: WidgetStateProperty.all(EdgeInsets.all(0)),
                        ),
                        child: SvgPicture.asset(
                          boton,
                          width: 32,
                          height: 32,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.fast_forward),
                        iconSize: 32,
                        onPressed: avanzarRepeticionManual,
                      ),
                      IconButton(
                        icon: Icon(Icons.last_page),
                        iconSize: 32,
                        onPressed: avanzarSerieManual,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
