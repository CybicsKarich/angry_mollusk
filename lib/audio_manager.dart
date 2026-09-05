import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  // Плееры для контролируемых звуков
  static final AudioPlayer _stretchPlayer = AudioPlayer();
  static final AudioPlayer _finalMenuPlayer = AudioPlayer();
  static final AudioPlayer _fxPlayer = AudioPlayer();
  static final AudioPlayer _rainPlayer = AudioPlayer();
  
  
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

    // =========================================================================
  // ИСПРАВЛЕНО: ПРИНУДИТЕЛЬНАЯ ПАУЗА ВСЕХ ПЛЕЕРОВ ПРИ СВЕРТЫВАНИИ ИГРЫ
  // =========================================================================
  static Future<void> pauseAll() async {
    try {
      await _finalMenuPlayer.pause();
      await _rainPlayer.pause(); 
      print("Все звуковые потоки поставлены на паузу при выходе из приложения.");
    } catch (e) {
      print("Ошибка при паузе звуков: $e");
    }
  }

  // =========================================================================
  // ИСПРАВЛЕНО: ВОЗОБНОВЛЕНИЕ ЗВУКОВ ПРИ ВОЗВРАЩЕНИИ В ПРИЛОЖЕНИЕ
  // =========================================================================
  static Future<void> resumeAll() async {
    try {
      // Возвращаем на паузу только то, что должно играть в данный момент
      await _finalMenuPlayer.resume();
      await _rainPlayer.resume();
      print("Все звуковые потоки успешно возобновлены.");
    } catch (e) {
      print("Ошибка при возобновлении звуков: $e");
    }
  }

  // =========================================================================
  // ИСПРАВЛЕНО: ТУШИМ ДОЖДЬ/КАПЛИ И ВОЗВРАЩАЕМ МУЗЫКУ МЕНЮ ПРИ ВЫХОДЕ ИЗ БОЯ
  // =========================================================================
  static Future<void> stopLevelAudioAndPlayMenu() async {
    try {
      // 1. Начисто тушим игровой плеер, где сидят дождь 5 уровня и капли 6 уровня
      await _rainPlayer.stop();
      
      // 2. Возобновляем или запускаем фоновую музыку меню заново
      await _finalMenuPlayer.setVolume(0.40);
      await _finalMenuPlayer.setReleaseMode(ReleaseMode.loop);
      
      // Если музыка была остановлена через .stop(), запускаем её из ассетов заново
      // (замени 'music/menu_theme.mp3' на точное имя твоего главного трека меню, если нужно)
      await _finalMenuPlayer.play(AssetSource('music/menu_theme.mp3')); 
      print("Игровые амбиенты остановлены. Фоновая музыка меню возобновлена.");
    } catch (e) {
      print("Ошибка при возврате к музыке меню: $e");
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

  // 6. ХРУСТ БЛОКОВ (Строго 1 раз для камня и 1 раз для дерева за полет!)
  static void playBlockBreak(bool isStone) async {
    if (_isRageSoundPlaying) return;
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

  // 2. ИСПРАВЛЕННЫЙ МЕТОД ОДИНOЧНЫХ ЭФФЕКТОВ (Полная изоляция от дождя!)
  static void _playSingleEffect(String assetPath) async {
    try {
      // Глушим ТОЛЬКО старый FX плеер, плеер дождя (_rainPlayer) здесь не упоминается,
      // а за счет системного разделения потоков Android больше не будет тушить ливень!
      await _fxPlayer.stop(); 
      
      final AudioPlayer temporaryPlayer = AudioPlayer();
      await temporaryPlayer.setReleaseMode(ReleaseMode.release);
      await temporaryPlayer.play(AssetSource(assetPath), mode: PlayerMode.lowLatency);
      
      temporaryPlayer.onPlayerComplete.listen((_) {
        temporaryPlayer.dispose();
      });
    } catch (e) {
      print("Ошибка игрового звука: $e");
    }
  }

    // =========================================================================
  // БЛОК ГРОЗЫ И ЛИВНЯ ДЛЯ ЭПИЧНОГО 5 УРОВНЯ
  // =========================================================================

  // 1. ИСПРАВЛЕННЫЙ БЕЗОПАСНЫЙ ЗАПУСК ДОЖДЯ ДЛЯ ЧЕКЕРА
  static Future<void> startLevel5Rain() async {
    try {
      await _rainPlayer.setVolume(0.45); 
      await _rainPlayer.setReleaseMode(ReleaseMode.loop); 
      // Возвращаем lowLatency, так как чекер теперь сам будет удерживать поток без сбоев ОС!
      await _rainPlayer.play(AssetSource('music/rain_ambient.mp3'), mode: PlayerMode.lowLatency);
    } catch (e) {
      print("Ошибка запуска неуязвимого дождя: $e");
    }
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
    await stopLevel5Rain(); // ГАРАНТИРОВАННО тушим дождь при любом выходе из уровня!
    
    try {
      await _stretchPlayer.stop();
      
      // ИСПРАВЛЕНО: Вместо создания нового плеера menuBgm, 
      // мы работаем строго с твоей глобальной переменной _finalMenuPlayer!
      await _finalMenuPlayer.stop();
      await _finalMenuPlayer.setReleaseMode(ReleaseMode.loop);
      
      // Запускаем фоновую музыку обратно на чистом, контролируемом канале
      // (Используем твой точный ассет 'music/bg_music.mp3')
      await _finalMenuPlayer.play(AssetSource('music/bg_music.mp3'));
      print("Все игровые звуки и капли остановлены. Родная музыка меню перезапущена.");
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
