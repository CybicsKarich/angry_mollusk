import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  // Создаем три раздельных плеера, чтобы звуки могли накладываться друг на друга
  static final AudioPlayer _effectsPlayer = AudioPlayer();
  static final AudioPlayer _stretchPlayer = AudioPlayer();
  static final AudioPlayer _snortPlayer = AudioPlayer(); // Отдельный плеер для сопения Максима
  
  static final Random _random = Random();
  static bool _isStretching = false; // Флаг, защищающий от спама звука резинки в update

  // ИНИЦИАЛИЗАЦИЯ И ХАК ДЛЯ ГЛУШЕНИЯ ЛИШНИХ ЗВУКОВ
  static Future<void> init() async {
    try {
      // ХИТРЫЙ ХАК: При старте уровня принудительно сбрасываем плеер,
      // чтобы остановить любые фоновые звуки из меню, если они зависли
      await _effectsPlayer.stop(); 
    } catch (e) {
      print("Очистка каналов при старте: $e");
    }
    
    // Настраиваем режимы освобождения ресурсов для каждого плеера
    _effectsPlayer.setReleaseMode(ReleaseMode.release);
    _stretchPlayer.setReleaseMode(ReleaseMode.loop); // Резинку настраиваем на бесконечный повтор (Loop)
    _snortPlayer.setReleaseMode(ReleaseMode.release);
  }

  // 1. ЗВУК НАТЯЖЕНИЯ РОГАТКИ (Включается строго один раз из onDragStart!)
  static void playStretch() async {
    if (_isStretching) return; // Если звук уже запущен — игнорируем спам-вызовы
    _isStretching = true;
    try {
      await _stretchPlayer.stop();
      await _stretchPlayer.play(AssetSource('audio/sling_stretch.MP3'));
    } catch (e) {
      print("Ошибка воспроизведения stretch: $e");
    }
  }

  // СТОП ЗВУКА НАТЯЖЕНИЯ (Когда отпустили палец или уровень завершен)
  static void stopStretch() async {
    _isStretching = false;
    try {
      await _stretchPlayer.stop();
    } catch (e) {
      print("Ошибка остановки stretch: $e");
    }
  }

  // 2. СЛУЧАЙНЫЙ ВЫСТРЕЛ ИЗ РОГАТКИ (1 или 2)
  static void playLaunch() {
    int num = _random.nextInt(2) + 1; // Выбирает случайное число: 1 или 2
    _playEffect('audio/sling_launch$num.mp3'); 
  }

  // 3. СЛУЧАЙНОЕ ПОПАДАНИЕ ПО СВИНЬЕ МАКСИМУ (1, 2 или 3)
  static void playPigHit() {
    int num = _random.nextInt(3) + 1; // Выбирает случайное число: 1, 2 или 3
    _playEffect('audio/pig_hit$num.MP3');
  }

  // 4. СЛУЧАЙНЫЙ ПРОМАХ БАННИХОПА (1, 2 или 3)
  static void playMiss() {
    int num = _random.nextInt(3) + 1; // Выбирает случайное число: 1, 2 или 3
    _playEffect('audio/bird_miss$num.MP3');
  }

  // 5. ХРУСТ ДЕРЕВА ИЛИ ГРОХОТ КАМНЯ ПРИ РАЗРУШЕНИИ ЗАМКА
  static void playBlockBreak(bool isStone) {
    if (isStone) {
      _playEffect('audio/stone_break.mp3');
    } else {
      _playEffect('audio/wood_break.mp3');
    }
  }

  // 6. ИЗОЛИРОВАННОЕ СОПЕНИЕ МАКСИМА (Для живой атмосферы, больше не глушит реплики!)
  static void playPigSnort() async {
    try {
      await _snortPlayer.stop();
      await _snortPlayer.play(AssetSource('audio/pig_snort.mp3'));
    } catch (e) {
      print("Ошибка воспроизведения snort: $e");
    }
  }

  // 7. ЭКРАН ВЫИГРЫША (ПОБЕДНЫЙ СКРИМЕР)
  static void playVictory() {
    stopStretch();
    _playEffect('audio/victory_screamer.MP3');
  }

  // 8. ЭКРАН ПРОИГРЫША (ФЕЙЛ)
  static void playGameOver() {
    stopStretch();
    _playEffect('audio/game_over_fail.MP3');
  }

  // ВНУТРЕННИЙ МЕТОД ДЛЯ МГНОВЕННОГО ЗАПУСКА ЭФФЕКТОВ НА ПЕРЕДНЕМ ПЛАНЕ
  static void _playEffect(String assetPath) async {
    try {
      await _effectsPlayer.stop(); // Прерываем прошлый крик, чтобы мгновенно включить новый
      await _effectsPlayer.play(AssetSource(assetPath));
    } catch (e) {
      print("Ошибка воспроизведения эффекта $assetPath: $e");
    }
  }
}
