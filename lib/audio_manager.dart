import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  // Плеер для резинки рогатки (Loop)
  static final AudioPlayer _stretchPlayer = AudioPlayer();
  
  // АБСОЛЮТНО НЕЗАВИСИМЫЙ ПЛЕЕР ДЛЯ ФИНАЛОВ (Обходит паузу игры!)
  static final AudioPlayer _finalMenuPlayer = AudioPlayer();
  
  // Список активных плееров для контроля лимита дорожек
  static final List<AudioPlayer> _activePlayers = [];
  
  static final Random _random = Random();
  static bool _isStretching = false;

  static Future<void> init() async {
    _stretchPlayer.setReleaseMode(ReleaseMode.loop);
    _finalMenuPlayer.setReleaseMode(ReleaseMode.release);
  }

  // 1. ЗВУК НАТЯЖЕНИЯ РОГАТКИ
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

  static void stopStretch() async {
    _isStretching = false;
    try {
      await _stretchPlayer.stop();
    } catch (e) {
      print("Ошибка остановки stretch: $e");
    }
  }

  // 2. СЛУЧАЙНЫЙ ВЫСТРЕЛ (Соблюдает лимит)
  static void playLaunch() {
    int num = _random.nextInt(2) + 1;
    _playWithLimit('audio/sling_launch$num.mp3'); 
  }

  // 3. СЛУЧАЙНОЕ ПОПАДАНИЕ ПО СВИНЬЕ (Соблюдает лимит)
  static void playPigHit() {
    int num = _random.nextInt(3) + 1;
    _playWithLimit('audio/pig_hit$num.MP3');
  }

  // 4. СЛУЧАЙНЫЙ ПРОМАХ (Соблюдает лимит)
  static void playMiss() {
    int num = _random.nextInt(3) + 1;
    _playWithLimit('audio/bird_miss$num.MP3');
  }

  // 5. ЖИВОЕ СОПЕНИЕ (Соблюдает лимит)
  static void playPigSnort() {
    _playWithLimit('audio/pig_snort.mp3');
  }

  // 6. ХРУСТ БЛОКОВ: Играет ОБЯЗАТЕЛЬНО, но длится ровно 1 секунду!
  static void playBlockBreak(bool isStone) async {
    try {
      final AudioPlayer blockPlayer = AudioPlayer();
      await blockPlayer.setReleaseMode(ReleaseMode.release);
      
      String path = isStone ? 'audio/stone_break.mp3' : 'audio/wood_break.mp3';
      await blockPlayer.play(AssetSource(path), mode: PlayerMode.lowLatency);
      
      // ТАЙМЕР ОБРЕЗКИ: Ровно через 1 секунду глушим звук камня/дерева, чтобы убрать эхо!
      Future.delayed(const Duration(seconds: 1), () async {
        try {
          await blockPlayer.stop();
          await blockPlayer.dispose();
        } catch (_) {}
      });
    } catch (e) {
      print("Ошибка звука блока: $e");
    }
  }

  // 7. МГНОВЕННЫЙ ЗВУК ПОБЕДЫ (Использует глобальный плеер вне игрового цикла)
  static void playVictory() async {
    stopStretch();
    try {
      await _finalMenuPlayer.stop();
      await _finalMenuPlayer.play(AssetSource('audio/victory_screamer.MP3'));
    } catch (e) {
      print("Ошибка звука победы: $e");
    }
  }

  // 8. МГНОВЕННЫЙ ЗВУК ПРОИГРЫША
  static void playGameOver() async {
    stopStretch();
    try {
      await _finalMenuPlayer.stop();
      await _finalMenuPlayer.play(AssetSource('audio/game_over_fail.MP3'));
    } catch (e) {
      print("Ошибка звука поражения: $e");
    }
  }

  // УМНЫЙ МЕТОД: Контролирует, чтобы одновременно играло не более 2 дорожек эффектов!
  static void _playWithLimit(String assetPath) async {
    // Чистим список от уже завершенных плееров
    _activePlayers.removeWhere((p) => p.state == PlayerState.stopped);

    // ЖЕСТКИЙ ЛИМИТ: Если уже играют 2 дорожки реплик — третью затыкаем и не произносим!
    if (_activePlayers.length >= 2) {
      return; 
    }

    try {
      final AudioPlayer effPlayer = AudioPlayer();
      await effPlayer.setReleaseMode(ReleaseMode.release);
      
      _activePlayers.add(effPlayer); // Добавляем в список активных

      await effPlayer.play(AssetSource(assetPath), mode: PlayerMode.lowLatency);
      
      // По окончании удаляем плеер из памяти и из списка активных
      effPlayer.onPlayerComplete.listen((_) {
        _activePlayers.remove(effPlayer);
        effPlayer.dispose();
      });
    } catch (e) {
      print("Ошибка лимитированного звука: $e");
    }
  }
}
