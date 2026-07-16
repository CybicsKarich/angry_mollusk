import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  // оставляем только один плеер для резинки, так как она должна быть под контролем (Loop)
  static final AudioPlayer _stretchPlayer = AudioPlayer();
  static final Random _random = Random();
  static bool _isStretching = false;
  static int _lastBlockBreakTime = 0; 

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

    // СВЯЗАНО С ОГРАНИЧЕНИЕМ ПОВТОРОВ: Блоки больше не спамят звуком при скольжении!
  static void playBlockBreak(bool isStone) {
    final int currentTime = DateTime.now().millisecondsSinceEpoch;
    
    // Если прошло меньше 150 миллисекунд с прошлой вспышки — глушим дубликат
    if (currentTime - _lastBlockBreakTime < 150) {
      return; 
    }
    _lastBlockBreakTime = currentTime;

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

      // ИСПРАВЛЕНО БЕСКОНЕЧНОЕ ВОСПРОИЗВЕДЕНИЕ: Вшит принудительный ReleaseMode!
  static void _playParallel(String assetPath) async {
    try {
      final AudioPlayer temporaryPlayer = AudioPlayer();
      
      // Запрещаем звуку зацикливаться при любых обстоятельствах
      await temporaryPlayer.setReleaseMode(ReleaseMode.release);
      
      // Запускаем в параллельном потоке
      await temporaryPlayer.play(AssetSource(assetPath), mode: PlayerMode.lowLatency);
      
      temporaryPlayer.onPlayerComplete.listen((_) {
        temporaryPlayer.dispose();
      });
    } catch (e) {
      print("Ошибка параллельного звука $assetPath: $e");
    }
  }
}
