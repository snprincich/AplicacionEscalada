import 'package:audioplayers/audioplayers.dart';

// CADA METODO EJECUTA UN AUDIO
class AudioService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playBeepCorto() async {
    await _player.play(AssetSource('audios/beep_corto.mp3'));
  }

  Future<void> playBeepFinal() async {
    await _player.play(AssetSource('audios/beep_final.mp3'));
  }

  Future<void> playFive() async {
    await _player.play(AssetSource('audios/five.mp3'));
  }

  Future<void> playFour() async {
    await _player.play(AssetSource('audios/four.mp3'));
  }

  Future<void> playThree() async {
    await _player.play(AssetSource('audios/three.mp3'));
  }

  Future<void> playTwo() async {
    await _player.play(AssetSource('audios/two.mp3'));
  }

  Future<void> playOne() async {
    await _player.play(AssetSource('audios/one.mp3'));
  }

  Future<void> playGo() async {
    await _player.play(AssetSource('audios/go.mp3'));
  }

  Future<void> playStart() async {
    await _player.play(AssetSource('audios/start.mp3'));
  }

  Future<void> playRest() async {
    await _player.play(AssetSource('audios/rest.mp3'));
  }
}
