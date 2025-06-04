import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:app_escalada/models/entrenamiento_detalles_model.dart';
import 'package:app_escalada/pages/entrenamiento_isometrico_page.dart';
import 'package:app_escalada/services/perfil/perfil_service.dart';

class ConfigEntrenamientoIsometricoPage extends StatefulWidget {
  const ConfigEntrenamientoIsometricoPage({super.key});

  @override
  State<ConfigEntrenamientoIsometricoPage> createState() =>
      _ConfigEntrenamientoIsometricoPageState();
}

class _ConfigEntrenamientoIsometricoPageState
    extends State<ConfigEntrenamientoIsometricoPage> {
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _setsController = TextEditingController();
  final TextEditingController _tiempoController = TextEditingController();
  final TextEditingController _descSetsController = TextEditingController();
  final TextEditingController _descRepsController = TextEditingController();

  void _aceptar() {
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
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('Configurar Entrenamiento')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            TextField(
              controller: _pesoController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: const InputDecoration(labelText: 'Peso (kg)'),
            ),

            TextField(
              controller: _repsController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'Repeticiones'),
            ),

            TextField(
              controller: _setsController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'Sets'),
            ),

            TextField(
              controller: _tiempoController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Tiempo por repetición (segundos)',
              ),
            ),

            TextField(
              controller: _descSetsController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Descanso entre sets (segundos)',
              ),
            ),

            TextField(
              controller: _descRepsController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Descanso entre repeticiones (segundos)',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _aceptar, child: const Text('Aceptar')),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
