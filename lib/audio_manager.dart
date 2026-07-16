import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  // Оставляем только один плеер для резинки, так как она должна быть под контролем (Loop)
  static final AudioPlayer _stretchPlayer = AudioPlayer();
  static final Random _random = Random();
  static bool _isStretching = false;

  static Future<void> init() async {
    _stretchPlayer.setReleaseMode(ReleaseMode.loop);
  }

  // ЗВУК НАТЯЖЕНИЯ РОГАТКИ
  static void playStretch() async {
    if (_isStretching) return;
    _isStretching = true;
    try {
      await _stretchPlayer.stop();
      await _stretchPlayer.play(AssetSource('audio/sling_stretch.MP3'));
    } catch (e) {
      print("Ошибка stretch: $e");
    }
  }

  // СТОП НАТЯЖЕНИЯ
  static void stopStretch() async {
    _isStretching = false;
    try {
      await _stretchPlayer.stop();
    } catch (e) {
      print("Ошибка остановки stretch: $e");
    }
  }

  // СЛУЧАЙНЫЙ ВЫСТРЕЛ
  static void playLaunch() {
    int num = _random.nextInt(2) + 1;
    _playParallel('audio/sling_launch$num.mp3'); 
  }

  // СЛУЧАЙНОЕ ПОПАДАНИЕ ПО СВИНЬЕ
  static void playPigHit() {
    int num = _random.nextInt(3) + 1;
    _playParallel('audio/pig_hit$num.MP3');
  }

  // СЛУЧАЙНЫЙ ПРОМАХ
  static void playMiss() {
    int num = _random.nextInt(3) + 1;
    _playParallel('audio/bird_miss$num.MP3');
  }

  // РАЗРУШЕНИЕ БЛОКОВ (КАМЕНЬ / ДЕРЕВО)
  static void playBlockBreak(bool isStone) {
    if (isStone) {
      _playParallel('audio/stone_break.mp3');
    } else {
      _playParallel('audio/wood_break.mp3');
    }
  }

  // СВИНУЮ СОПЕНИЕ МАКСИМА
  static void playPigSnort() {
    _playParallel('audio/pig_snort.mp3');
  }

  // ЭКРАН ВЫИГРЫША
  static void playVictory() {
    stopStretch();
    _playParallel('audio/victory_screamer.MP3');
  }

  // ЭКРАН ПРОИГРЫША
  static void playGameOver() {
    stopStretch();
    _playParallel('audio/game_over_fail.MP3');
  }

    // ИСПРАВЛЕНО: Убрали сломанный конструктор контекста, теперь компиляция пройдёт идеально!
  static void _playParallel(String assetPath) async {
    try {
      final AudioPlayer temporaryPlayer = AudioPlayer();
      
      // Запускаем звук в параллельном потоке с низкой задержкой для игр
      await temporaryPlayer.play(AssetSource(assetPath), mode: PlayerMode.lowLatency);
      
      // Очищаем память: когда звук доиграет, плеер сам себя уничтожит
      temporaryPlayer.onPlayerComplete.listen((_) {
        temporaryPlayer.dispose();
      });
    } catch (e) {
      print("Ошибка параллельного звука $assetPath: $e");
    }
  }
}
