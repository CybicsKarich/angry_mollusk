import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  // Плееры для контролируемых звуков
  static final AudioPlayer _stretchPlayer = AudioPlayer();
  static final AudioPlayer _finalMenuPlayer = AudioPlayer();
  static final AudioPlayer _fxPlayer = AudioPlayer();
  static final AudioPlayer _rainPlayer = AudioPlayer();
  
    // Геттер для получения текущего состояния фонового плеера (нужен для main.dart)
  static AudioPlayer get menuPlayer => _finalMenuPlayer;

  // Метод для изменения громкости музыки на лету из экрана настроек
  static Future<void> setMenuVolume(double volume) async {
    await _finalMenuPlayer.setVolume(volume);
  }

  
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

    // === ВСTАВЛЯЙ НОВЫЙ МЕТОД СТРОГО СЮДА ===
  static Future<void> playBackgroundMusic() async {
    try {
      if (_finalMenuPlayer.state != PlayerState.playing) {
        await _finalMenuPlayer.setReleaseMode(ReleaseMode.loop);
        await _finalMenuPlayer.play(AssetSource('music/bg_music.mp3'));
      }
    } catch (e) {
      print("Ошибка запуска фоновой музыки: $e");
    }
  }
  // =========================================================================
  // ТОЧЕЧНЫЙ БЛОК ЯРОСТИ ВАНЯ-ПТИЦЫ: ПЕРЕМЕННЫЕ И МЕТОДЫ ВМЕСТЕ!
  // =========================================================================
  static AudioPlayer? _ragePlayer;
  static bool _isRageSoundPlaying = false;

  // Возвращаем статус аудио-замка, чтобы другие методы могли его считывать
  static bool get isRageSoundPlaying => _isRageSoundPlaying;

  // Звук ярости на максимальной громкости 1.0 из корня папки audio
  static Future<void> playRage() async {
    if (_isRageSoundPlaying) return; // Защита от наложения
    
    _isRageSoundPlaying = true;
    try {
      _ragePlayer = AudioPlayer();
      await _ragePlayer!.setVolume(1.0); // Выкручиваем громкость ярости на 100%
      await _ragePlayer!.play(AssetSource('audio/bunnyhop_rage.mp3')); 
    } catch (e) {
      print("Ошибка звука ярости: $e");
    }

    // Автоматический сброс замка через 2.5 секунды, если птица выжила
    Future.delayed(const Duration(milliseconds: 2500), () {
      _isRageSoundPlaying = false;
      _ragePlayer = null;
    });
  }

  // Метод мгновенной остановки гула при смерти Вани Баннихопа!
  static Future<void> stopRage() async {
    if (_ragePlayer != null) {
      try {
        await _ragePlayer!.stop(); // Выключаем звук намертво!
      } catch (e) {
        print("Ошибка остановки звука ярости: $e");
      }
      _ragePlayer = null;
    }
    _isRageSoundPlaying = false; // Мгновенно открываем аудио-замок для других эффектов
  }


    
  // МЕТОД ОБНУЛЕНИЯ: Вызывается, когда на рогатку встает НОВАЯ птица
  static void resetTokensForNextBird() {
    hasStoneToken = true;
    hasWoodToken = true;
    hasPigHitToken = true;
    hasMissToken = true;
  }

    // ИСПРАВЛЕНО: Звук шлепка шляпы шерифа на максимальной громкости 1.0 из корня папки audio
  static Future<void> playHatSplat() async {
    try {
      await _fxPlayer.stop(); // Глушим прошлый звук, если он наложился
      await _fxPlayer.setVolume(1.0); // Выкручиваем громкость на 100%
      await _fxPlayer.play(AssetSource('audio/hat_splat.mp3')); 
    } catch (e) {
      print("Ошибка воспроизведения звука шлепка шляпы: $e");
    }
  }

 // ДОБАВИТЬ В КЛАСС AudioManager В ФАЙЛЕ lib/audio_manager.dart:
static Future<void> playPaperRustle() async {
  try {
    await _fxPlayer.stop(); // Глушим прошлый звук эффектов, чтобы не накладывался
    await _fxPlayer.setVolume(1.0); // Включаем на полную громкость
    await _fxPlayer.play(AssetSource('audio/paper_rustle.mp3')); // Чистый путь относительно папки assets/
  } catch (e) {
    print("Ошибка воспроизведения звука шелеста бумаги: $e");
  }
}

  // =========================================================================
  // ЖУТКИЙ ЗВУК КАПЕЛЬ ДЛЯ 6 УРОВНЯ (ГЛУШИТ СТАРЫЕ, НО УСТУПАЕТ НОВЫМ)
  // =========================================================================
  static Future<void> startCastleDrops() async {
    try {
      // 1. Принудительно тушим фоновую музыку меню и ливень 5 уровня, если они играли
      await _finalMenuPlayer.stop();
      await _rainPlayer.stop();
      
      // 2. Настраиваем плеер капель на среднюю, гнетущую громкость
      await _rainPlayer.setVolume(0.35); 
      await _rainPlayer.setReleaseMode(ReleaseMode.loop);
      
      // 3. Запускаем капли в режиме lowLatency, чтобы нативная система ОС 
      // автоматически приглушила этот поток, как только появится любой новый эффект!
      await _rainPlayer.play(
        AssetSource('music/castle_drops.mp3'), 
        mode: PlayerMode.lowLatency
      );
      print("Жуткий эмбиент капель замка запущен.");
    } catch (e) {
      print("Ошибка запуска звука капель замка: $e");
    }
  }

      static Future<void> pauseAll() async {
    try {
      await _finalMenuPlayer.pause();
      await _rainPlayer.pause(); 
      await _stretchPlayer.pause(); // Добавлена пауза натяжения рогатки
      print("Все звуковые потоки поставлены на паузу при выходе из приложения.");
    } catch (e) {print("Ошибка запуска звука капель кочка: $e");}
  }

  static Future<void> resumeAll() async {
    try {
      // Музыка возобновляется строго из состояния паузы, без перезапусков
      if (_finalMenuPlayer.state == PlayerState.paused) {
        await _finalMenuPlayer.resume();
      }
      if (_rainPlayer.state == PlayerState.paused) {
        await _rainPlayer.resume();
      }
      print("Звуковые потоки возобновлены.");
    } catch (e) {print("Ошибка запуска звука капель кочка: $e");}
  }


      static Future<void> stopLevelAudioAndPlayMenu() async {
    try {
      // 1. Мгновенно глушим все игровые эффекты и звуки уровня
      _isStretching = false;
      await _stretchPlayer.stop();
      await _fxPlayer.stop();
      await _rainPlayer.stop();
      await stopRage();
      
      // 2. СБРАСЫВАЕМ плеер фона, чтобы снять любые зависания состояния
      await _finalMenuPlayer.stop();
      
      // 3. Выставляем настройки и запускаем принудительно (без проверок state)
      await _finalMenuPlayer.setVolume(0.40);
      await _finalMenuPlayer.setReleaseMode(ReleaseMode.loop);
      await _finalMenuPlayer.play(AssetSource('music/bg_music.mp3')); 
      
      print("Все игровые звуки заглушены. Фоновая музыка меню запущена принудительно.");
    } catch (e) {
      print("Ошибка при принудительном возврате к музыке меню: $e");
    }
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
    if (_isRageSoundPlaying) return;
    if (!hasPigHitToken) return; // Жетон сгорел — приглушаем все следующие повторы!
    hasPigHitToken = false; 

    int num = _random.nextInt(3) + 1;
    _playSingleEffect('audio/pig_hit$num.MP3');
  }

  // 4. ПРОМАХ БАННИХОПА (Строго 1 раз за полет птицы)
  static void playMiss() {
    if (_isRageSoundPlaying) return;
    if (!hasMissToken) return; // Жетон сгорел — глушим эхо
    hasMissToken = false;

    int num = _random.nextInt(3) + 1;
    _playSingleEffect('audio/bird_miss$num.MP3');
  }

  // 5. ЖИВОЕ СОПЕНИЕ (Оставляем без изменений)
  static void playPigSnort() {
    if (_isRageSoundPlaying) return;
    _playSingleEffect('audio/pig_snort.mp3');
  }

  static void playBlockBreak(bool isStone) {
    if (_isRageSoundPlaying) return;
    if (isStone) {
      if (!hasStoneToken) return;
      hasStoneToken = false;
    } else {
      if (!hasWoodToken) return;
      hasWoodToken = false;
    }

    String path = isStone ? 'audio/stone_break.mp3' : 'audio/wood_break.mp3';
    _playSingleEffect(path);
  }
    // =========================================================================
  // ИСПРАВЛЕНО: ЗВУК ПОБЕДЫ ИГРАЕТ БЕЗ ДУБЛЯЖА И НЕ ПОРТИТ МУЗЫКУ МЕНЮ!
  // =========================================================================
  static void playVictory() async {
    stopStretch();
    try {
      // 1. ИСПРАВЛЕНО: Перед запуском сбрасываем плеер эффектов, чтобы убрать эхо и дублирование!
      await _fxPlayer.stop();
      
      // Отключаем бесконечный повтор для эффекта победы
      await _fxPlayer.setReleaseMode(ReleaseMode.release);
      
      // 2. ИСПРАВЛЕНО: Перенесли трек на _fxPlayer, чтобы он больше не затирал _finalMenuPlayer!
      await _fxPlayer.play(AssetSource('audio/victory_screamer.MP3'));
      print("Звук победы успешно запущен на канале эффектов в один поток.");
    } catch (e) {
      print("Ошибка звука победы: $e");
    }
  }


  static void playGameOver() async {
    stopStretch();
    try {
      await _fxPlayer.stop();
      await _fxPlayer.setReleaseMode(ReleaseMode.release);
      await _fxPlayer.play(AssetSource('audio/game_over_fail.MP3'));
    } catch (e) {
      print("Ошибка звука поражения: $e");
    }
  }

    static void _playSingleEffect(String assetPath) async {
    try {
      // Удален лишний вызов await _fxPlayer.stop(), плейеры полностью изолированы
      final AudioPlayer temporaryPlayer = AudioPlayer();
      await temporaryPlayer.setReleaseMode(ReleaseMode.release);
      await temporaryPlayer.play(AssetSource(assetPath), mode: PlayerMode.lowLatency);
      
      temporaryPlayer.onPlayerComplete.listen((_) {
        temporaryPlayer.dispose();
      });
    } catch (e) {print("Ошибка запуска звука капель кочка: $e");}
  }


    // =========================================================================
  // БЛОК ГРОЗЫ И ЛИВНЯ ДЛЯ ЭПИЧНОГО 5 УРОВНЯ
  // =========================================================================

    static Future<void> startLevel5Rain() async {
    try {
      await _finalMenuPlayer.stop(); // Гарантированно убираем музыку меню во время ливня
      await _rainPlayer.setVolume(0.45); 
      await _rainPlayer.setReleaseMode(ReleaseMode.loop); 
      await _rainPlayer.play(AssetSource('music/rain_ambient.mp3'), mode: PlayerMode.lowLatency);
    } catch (e) {print("Ошибка запуска звука капель кочка: $e");}
  }


  // 2. БЕЗОПАСНЫЙ ГЕТТЕР СТУСА ДЛЯ ИГРОВОГО ЦИКЛА (Защита от зависаний)
  static bool get isRainPlaying {
    try {
      return _rainPlayer.state == PlayerState.playing;
    } catch (_) {
      return false; // Если плеер занят инициализацией, мягко возвращаем false без вылета игры
    }
  }
  // 2. Мгновенная остановка дождя при выходе из 5 уровня
  static Future<void> stopLevel5Rain() async {
    try {
      await _rainPlayer.stop();
    } catch (e) {
      print("Ошибка остановки дождя: $e");
    }
  }

  // 3. Сочный раскат грома, который накладывается поверх дождя (вызывается вместе с молнией)
  static Future<void> playThunderStrike() async {
    try {
      // Создаем отдельный временный плеер, чтобы звук грома накладывался на дождь
      final AudioPlayer thunderPlayer = AudioPlayer();
      await thunderPlayer.setReleaseMode(ReleaseMode.release);
      await thunderPlayer.setVolume(0.85); // Делаем гром достаточно мощным
      await thunderPlayer.play(AssetSource('audio/thunder_strike.mp3'), mode: PlayerMode.lowLatency);
      
      // Сами чистим память после окончания раската
      thunderPlayer.onPlayerComplete.listen((_) {
        thunderPlayer.dispose();
      });
    } catch (e) {
      print("Ошибка звука молнии: $e");
    }
  }

    static void stopAllLevelSounds() async {
    _isStretching = false;
    await stopLevel5Rain(); // ГАРАНТИРОВАННО тушим дождь и капли 6 уровня!
    
    try {
      // Начисто тушим натяжение рогатки Вани
      await _stretchPlayer.stop();
      
      // ИСПРАВЛЕНО: Намертво выключаем плеер эффектов, чтобы звук победы не циклился в меню!
      await _fxPlayer.stop();
      
      // Сбрасываем старый системный плеер меню
      await _finalMenuPlayer.stop();
      await _finalMenuPlayer.setReleaseMode(ReleaseMode.loop);
      
      // Запускаем фоновую музыку обратно на чистом канале
      await _finalMenuPlayer.play(AssetSource('music/bg_music.mp3'));
      print("Полная зачистка всех аудиопотоков (включая _fxPlayer) завершена.");
    } catch (e) {
      print("Ошибка при полной остановке звуков: $e");
    }
  }





  // 3. ИСПРАВЛЕНО: ЗВУК АЧИВКИ МЕДАЛИ
  static Future<void> playAchievement() async {
    try {
      await _fxPlayer.stop();
      await _fxPlayer.setVolume(1.0);
      await _fxPlayer.play(AssetSource('audio/achievement_unlocked.mp3'));
    } catch (e) {
      print("КРИТИЧЕСКАЯ ОШИБКА ФАНФАР МЕДАЛИ: $e");
    }
  }
} // <--- ВОТ ЭТА ОДНА СКОБКА ТЕПЕРЬ САМАЯ ПОСЛЕДНЯЯ В ФАЙЛЕ! Она закрывает весь класс AudioManager.
