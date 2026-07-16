import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  // Создаем два раздельных плеера, чтобы звуки могли накладываться друг на друга
  static final AudioPlayer _effectsPlayer = AudioPlayer();
  static final AudioPlayer _stretchPlayer = AudioPlayer();
  
  static final Random _random = Random();

  // 1. ПРЕДВАРИТЕЛЬНАЯ ЗАГРУЗКА ЗВУКОВ (Preload)
  static Future<void> init() async {
    // В версии 6.0.0+ для локальных ассетов из папки assets/audio/
    // настраиваем кэш, чтобы звуки воспроизводились мгновенно без задержек
    _effectsPlayer.setReleaseMode(ReleaseMode.release);
    _stretchPlayer.setReleaseMode(ReleaseMode.loop); // Резинку настраиваем на бесконечный повтор
  }

  // 2. ЗВУК НАТЯЖЕНИЯ РОГАТКИ (Включается loop)
  static void playStretch() async {
    try {
      // Останавливаем, если уже играл, и запускаем заново
      await _stretchPlayer.stop();
      await _stretchPlayer.play(AssetSource('audio/sling_stretch.MP3'));
    } catch (e) {
      print("Ошибка воспроизведения stretch: $e");
    }
  }

  // СТОП ЗВУКА НАТЯЖЕНИЯ (Когда отпустили палец)
  static void stopStretch() async {
    await _stretchPlayer.stop();
  }

  // 3. СЛУЧАЙНЫЙ ВЫСТРЕЛ ИЗ РОГАТКИ (1 или 2)
  static void playLaunch() {
    int num = _random.nextInt(2) + 1; // Выбирает 1 или 2
    _playEffect('audio/sling_launch$num.mp3'); 
    // Если файлы на гитхабе названы с большой MP3, то пишем .MP3, Dart чувствителен к регистру!
  }

  // 4. СЛУЧАЙНОЕ ПОПАДАНИЕ ПО СВИНЬЕ МАКСИМУ (1, 2 или 3)
  static void playPigHit() {
    int num = _random.nextInt(3) + 1; // Выбирает 1, 2 или 3
    _playEffect('audio/pig_hit$num.MP3');
  }

  // 5. СЛУЧАЙНЫЙ ПРОМАХ БАННИХОПА (1, 2 или 3)
  static void playMiss() {
    int num = _random.nextInt(3) + 1; // Выбирает 1, 2 или 3
    _playEffect('audio/bird_miss$num.MP3');
  }

  // 6. ХРУСТ ДЕРЕВА ИЛИ КАМНЯ
  static void playBlockBreak(bool isStone) {
    if (isStone) {
      _playEffect('audio/stone_break.mp3');
    } else {
      _playEffect('audio/wood_break.mp3');
    }
  }

  // 7. СВИНУЮ СОПЕНИЕ МАКСИМА (Для атмосферы)
  static void playPigSnort() {
    _playEffect('audio/pig_snort.mp3');
  }

  // 8. ЭКРАН ВЫИГРЫША
  static void playVictory() {
    stopStretch();
    _playEffect('audio/victory_screamer.MP3');
  }

  // 9. ЭКРАН ПРОИГРЫША
  static void playGameOver() {
    stopStretch();
    _playEffect('audio/game_over_fail.MP3');
  }

  // Внутренний метод для мгновенного запуска эффектов
  static void _playEffect(String assetPath) async {
    try {
      // В audioplayers 6.x метод play с AssetSource запускает звук прямо из папки assets/
      await _effectsPlayer.stop(); // Прерываем прошлый крик/удар, чтобы включить новый
      await _effectsPlayer.play(AssetSource(assetPath));
    } catch (e) {
      print("Ошибка воспроизведения эффекта $assetPath: $e");
    }
  }
}
