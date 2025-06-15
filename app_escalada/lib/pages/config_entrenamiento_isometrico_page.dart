import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:app_escalada/models/entrenamiento_detalles_model.dart';
import 'package:app_escalada/pages/entrenamiento_isometrico_page.dart';
import 'package:app_escalada/services/perfil/perfil_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigEntrenamientoIsometricoPage extends StatefulWidget {
  const ConfigEntrenamientoIsometricoPage({super.key});

  @override
  State<ConfigEntrenamientoIsometricoPage> createState() =>
      _ConfigEntrenamientoIsometricoPageState();
}

class _ConfigEntrenamientoIsometricoPageState
    extends State<ConfigEntrenamientoIsometricoPage> {
  // CONTROLADORES PARA LOS CAMPOS DE TEXTO
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _setsController = TextEditingController();
  final TextEditingController _tiempoController = TextEditingController();
  final TextEditingController _descSetsController = TextEditingController();
  final TextEditingController _descRepsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarDatosGuardados();
  }

  // CARGA DATOS DE SHARED PREFERENCES
  Future<void> _cargarDatosGuardados() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _pesoController.text = prefs.getString('pesoObjetivo') ?? '';
      _repsController.text = prefs.getInt('repeticiones')?.toString() ?? '';
      _setsController.text = prefs.getInt('series')?.toString() ?? '';
      _tiempoController.text =
          prefs.getInt('duracionRepeticion')?.toString() ?? '';
      _descSetsController.text =
          prefs.getInt('descansoSerie')?.toString() ?? '';
      _descRepsController.text =
          prefs.getInt('descansoRepeticion')?.toString() ?? '';
    });
  }

  // GUARDA DATOS EN SHARED PREFERENCES
  Future<void> _guardarDatos() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('pesoObjetivo', _pesoController.text);
    await prefs.setInt('repeticiones', int.tryParse(_repsController.text) ?? 0);
    await prefs.setInt('series', int.tryParse(_setsController.text) ?? 0);
    await prefs.setInt(
      'duracionRepeticion',
      int.tryParse(_tiempoController.text) ?? 0,
    );
    await prefs.setInt(
      'descansoSerie',
      int.tryParse(_descSetsController.text) ?? 0,
    );
    await prefs.setInt(
      'descansoRepeticion',
      int.tryParse(_descRepsController.text) ?? 0,
    );
  }

  // LLAMA AL METODO PARA GUARDAR DATOS, Y NAVEGA A LA PAGINA DE ENTRENAMIENTOS
  Future<void> _aceptar() async {
    await _guardarDatos();

    final peso = double.tryParse(_pesoController.text) ?? 0.0;
    final reps = int.tryParse(_repsController.text) ?? 0;
    final sets = int.tryParse(_setsController.text) ?? 0;
    final tiempo = int.tryParse(_tiempoController.text) ?? 0;
    final descSets = int.tryParse(_descSetsController.text) ?? 0;
    final descReps = int.tryParse(_descRepsController.text) ?? 0;

    final entrenamientoDetalles = EntrenamientoDetalles(
      idPerfil: GetIt.I<PerfilService>().perfilActivo!.idPerfil,
      idEntrenamiento: 1,
      pesoObjetivo: peso,
      repeticiones: reps,
      series: sets,
      duracionRepeticion: tiempo.toDouble(),
      descansoSerie: descSets.toDouble(),
      descansoRepeticion: descReps.toDouble(),
      fecha: DateTime.now().toString(),
    );

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => EntrenamientoIsometricoPage(detalles: entrenamientoDetalles),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TAMAÑOS PARA EL GRID
    final double cardSpacing = 16;
    final double horizontalPadding = 16;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - horizontalPadding * 2 - cardSpacing) / 2;

    // CONFIGURACION DE LOS CAMPOS DE ENTRADA
    final inputs = [
      {
        'label': 'Peso (kg)',
        'controller': _pesoController,
        'opciones': List.generate(200, (i) => i + 1),
        'permitirDecimal': true,
      },
      {
        'label': 'Repeticiones',
        'controller': _repsController,
        'opciones': List.generate(20, (i) => i + 1),
        'permitirDecimal': false,
      },
      {
        'label': 'Sets',
        'controller': _setsController,
        'opciones': List.generate(10, (i) => i + 1),
        'permitirDecimal': false,
      },
      {
        'label': 'Tiempo por repetición',
        'controller': _tiempoController,
        'opciones': List.generate(300, (i) => i + 1),
        'permitirDecimal': false,
      },
      {
        'label': 'Descanso entre sets',
        'controller': _descSetsController,
        'opciones': List.generate(300, (i) => i + 1),
        'permitirDecimal': false,
      },
      {
        'label': 'Descanso entre repeticiones',
        'controller': _descRepsController,
        'opciones': List.generate(300, (i) => i + 1),
        'permitirDecimal': false,
      },
    ];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Configurar Entrenamiento',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 24,
        ),
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: cardSpacing,
                mainAxisSpacing: cardSpacing,
                childAspectRatio: cardWidth / 130,
              ),
              itemCount: inputs.length,
              itemBuilder: (context, index) {
                final input = inputs[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          input['label'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 40,
                          child: SelectorNumero(
                            label: '',
                            controller:
                                input['controller'] as TextEditingController,
                            opciones: input['opciones'] as List<int>,
                            permitirDecimal: input['permitirDecimal'] as bool,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            Center(
              child: SizedBox(
                width: 160,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                      side: const BorderSide(color: Colors.black),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _aceptar,
                  child: const Text(
                    'Aceptar',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class SelectorNumero extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final List<int> opciones;
  final bool permitirDecimal;

  const SelectorNumero({
    super.key,
    required this.label,
    required this.controller,
    required this.opciones,
    this.permitirDecimal = false,
  });

  @override
  State<SelectorNumero> createState() => _SelectorNumeroState();
}

class _SelectorNumeroState extends State<SelectorNumero> {
  Future<void> _openPicker() async {
    final int? selected = await showDialog<int>(
      context: context,
      builder:
          (context) => SimpleDialog(
            title: Text('Selecciona:\n${widget.label}'),
            children:
                widget.opciones
                    .map(
                      (val) => SimpleDialogOption(
                        onPressed: () => Navigator.pop(context, val),
                        child: Text(val.toString()),
                      ),
                    )
                    .toList(),
          ),
    );

    if (selected != null) {
      if (widget.permitirDecimal) {
        widget.controller.text = "$selected.0";
      } else {
        widget.controller.text = selected.toString();
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: widget.controller,
        textAlignVertical: TextAlignVertical.center,
        keyboardType:
            widget.permitirDecimal
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.number,
        inputFormatters:
            widget.permitirDecimal
                ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))]
                : [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          labelText: widget.label,
          suffixIcon: IconButton(
            icon: const Icon(Icons.arrow_drop_down),
            onPressed: _openPicker,
          ),
        ),
      ),
    );
  }
}
