import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  // Плееры для контролируемых звуков
  static final AudioPlayer _stretchPlayer = AudioPlayer();
  static final AudioPlayer _finalMenuPlayer = AudioPlayer();
  
  static final Random _random = Random();
  static bool _isStretching = false;

  // СИСТЕМА ЖЕТОНОВ: Ровно 1 звук каждого типа за весь полет одной птицы!
  static bool hasStoneToken = true;
  static bool hasWoodToken = true;
  static bool hasPigHitToken = true;
  static bool hasMissToken = true;

  static Future<void> init() async {
    _stretchPlayer.setReleaseMode(ReleaseMode.loop);
    _finalMenuPlayer.setReleaseMode(ReleaseMode.release);
    resetTokensForNextBird(); // Заряжаем жетоны при старте
  }

  // МЕТОД ОБНУЛЕНИЯ: Вызывается, когда на рогатку встает НОВАЯ птица
  static void resetTokensForNextBird() {
    hasStoneToken = true;
    hasWoodToken = true;
    hasPigHitToken = true;
    hasMissToken = true;
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

  // 2. СЛУЧАЙНЫЙ ВЫСТРЕЛ (Играет всегда 1 раз при пуске)
  static void playLaunch() {
    resetTokensForNextBird(); // В момент выстрела СБРАСЫВАЕМ жетоны для текущего полета!
    int num = _random.nextInt(2) + 1;
    _playSingleEffect('audio/sling_launch$num.mp3'); 
  }

  // 3. ПОПАДАНИЕ ПО СВИНЬЕ (Строго 1 раз за полет птицы)
  static void playPigHit() {
    if (!hasPigHitToken) return; // Жетон сгорел — приглушаем все следующие повторы!
    hasPigHitToken = false; 

    int num = _random.nextInt(3) + 1;
    _playSingleEffect('audio/pig_hit$num.MP3');
  }

  // 4. ПРОМАХ БАННИХОПА (Строго 1 раз за полет птицы)
  static void playMiss() {
    if (!hasMissToken) return; // Жетон сгорел — глушим эхо
    hasMissToken = false;

    int num = _random.nextInt(3) + 1;
    _playSingleEffect('audio/bird_miss$num.MP3');
  }

  // 5. ЖИВОЕ СОПЕНИЕ (Оставляем без изменений)
  static void playPigSnort() {
    _playSingleEffect('audio/pig_snort.mp3');
  }

  // 6. ХРУСТ БЛОКОВ (Строго 1 раз для камня и 1 раз для дерева за полет!)
  static void playBlockBreak(bool isStone) async {
    if (isStone) {
      if (!hasStoneToken) return; // Если в этом выстреле камень УЖЕ ХРУСТЕЛ — выходим!
      hasStoneToken = false;
    } else {
      if (!hasWoodToken) return; // Если дерево уже хрустело — выходим!
      hasWoodToken = false;
    }

    try {
      final AudioPlayer blockPlayer = AudioPlayer();
      await blockPlayer.setReleaseMode(ReleaseMode.release);
      
      String path = isStone ? 'audio/stone_break.mp3' : 'audio/wood_break.mp3';
      await blockPlayer.play(AssetSource(path), mode: PlayerMode.lowLatency);
      
      // ТАЙМЕР ОБРЕЗКИ: Ровно через 1 секунду намертво тушим плеер, убирая бесконечный гул!
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

  // 7. МГНОВЕННЫЙ ЗВУК ПОБЕДЫ (Глобальный плеер вне движка)
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

    // Твой последний рабочий метод эффектов (оставляем без изменений)
  static void _playSingleEffect(String assetPath) async {
    try {
      final AudioPlayer temporaryPlayer = AudioPlayer();
      await temporaryPlayer.setReleaseMode(ReleaseMode.release);
      await temporaryPlayer.play(AssetSource(assetPath), mode: PlayerMode.lowLatency);
      
      temporaryPlayer.onPlayerComplete.listen((_) {
        temporaryPlayer.dispose();
      });
    } catch (e) {
      print("Ошибка звука: $e");
    }
  } // <--- ЗАКРЫВАЕТ МЕТОД _playSingleEffect

  // ИСПРАВЛЕНО: Теперь этот метод стоит СТРОГО ВНУТРИ класса AudioManager!
  static void stopAllLevelSounds() async {
    _isStretching = false;
    try {
      await _stretchPlayer.stop();
      // Если у тебя в коде используется _snortPlayer, раскомментируй строку ниже:
      // await _snortPlayer.stop();
      await _finalMenuPlayer.stop();
      
      // Запускаем фоновую музыку меню обратно на чистом канале
      final AudioPlayer menuBgm = AudioPlayer();
      await menuBgm.setReleaseMode(ReleaseMode.loop);
      await menuBgm.play(AssetSource('music/bg_music.mp3'));
    } catch (e) {
      print("Ошибка при полной остановке звуков: $e");
    }
  } // <--- ЗАКРЫВАЕТ МЕТОД stopAllLevelSounds

} // <--- ВОТ ЭТА ОДНА СКОБКА ТЕПЕРЬ САМАЯ ПОСЛЕДНЯЯ В ФАЙЛЕ! Она закрывает весь класс AudioManager.
