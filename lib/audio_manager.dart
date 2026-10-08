import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  // Плееры для контролируемых звуков
  static final AudioPlayer _stretchPlayer = AudioPlayer();
  static final AudioPlayer _finalMenuPlayer = AudioPlayer();
  static final AudioPlayer _fxPlayer = AudioPlayer(); 
  static final List<AudioPlayer> _fxPool = List.generate(4, (_) => AudioPlayer());
  static int _fxPoolIndex = 0;
  static final AudioPlayer _rainPlayer = AudioPlayer();
  static DateTime? _lastMainSoundStartTime; 
  static String _currentMainSound = ""; // Теперь только 'drops', 'boss_phase2' или 'menu'
  

  static bool _canInterruptCurrentMainSound(String newSound) {
    if (_lastMainSoundStartTime == null || _currentMainSound == "") return true;
    if (_currentMainSound == newSound) return false; 

    final elapsed = DateTime.now().difference(_lastMainSoundStartTime!);
    if (elapsed.inMilliseconds < 1000) {
      print("Защита звука: '$_currentMainSound' играет всего ${elapsed.inMilliseconds}мс. Перекрытие отклонено.");
      return false;
    }
    return true;
  }


  
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

    // ТОЧЕЧНО ЗАМЕНИТЬ МЕТОДЫ ЯРОСТИ В LIB/AUDIO_MANAGER.DART:
  
  // Звук ярости таблетки виагры — играет ВТОРЫМ ПОТОКОМ как эффект!
  static Future<void> playRage() async {
    try {
      await _fxPlayer.stop();
      await _fxPlayer.setVolume(0.85); // Делаем ор ярости громким и сочным
      
      // ИСПРАВЛЕНО: Твой оригинальный файл ярости из папки audio/
      await _fxPlayer.play(AssetSource('audio/bunnyhop_rage.mp3'));
      print("Эффект ярости Шерифа 'bunnyhop_rage' запущен вторым потоком.");
    } catch (e) {
      print("Ошибка воспроизведения эффекта ярости: $e");
    }
  }

  // Остановка ярости (например, когда Ваня нанёс удар боссу)
  static Future<void> stopRage() async {
    try {
      await _fxPlayer.stop();
    } catch (e) {
      print("Ошибка остановки эффекта ярости: $e");
    }
  }


      // ТОЧЕЧНО ДОБАВИТЬ В КЛАСС К ОСТАЛЬНЫМ ЭФФЕКТАМ ДЛЯ 6 УРОВНЯ:

  // Звук 1: Бешеное кручение/замах щупальца или клешни босса в воздухе (700-800мс)
  static Future<void> playBossWhip() async {
    try {
      await _fxPlayer.stop(); // Глушим прошлый эффект, чтобы не было каши
      await _fxPlayer.setVolume(0.75); // Настраиваем сочную громкость замаха
      await _fxPlayer.play(AssetSource('audio/boss_whip.mp3'));
      print("Эффект замаха босса запущен успешно.");
    } catch (e) {
      print("Ошибка воспроизведения звука замаха босса: $e");
    }
  }

  // Звук 2: Сокрушительный удар щупальца по полу или клешни по верху (1 сек)
  static Future<void> playBossStrike() async {
    try {
      await _fxPlayer.stop(); // Мгновенно сбрасываем канал под удар
      await _fxPlayer.setVolume(1.0); // Удар Дона должен греметь на максимум!
      await _fxPlayer.play(AssetSource('audio/boss_strike.mp3'));
      print("Эффект удара босса запущен успешно.");
    } catch (e) {
      print("Ошибка воспроизведения звука удара босса: $e");
    }
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
    

        static Future<void> stopLevelAudioAndPlayMenu() async {
      try {
      _isStretching = false;
      await _stretchPlayer.stop();
      await _fxPlayer.stop();
      
      await stopLevel5Rain(); // ИСПРАВЛЕНО: Теперь при выходе в меню ливень и его кэш тоже уничтожаются!
      await stopRage();
      
      await _finalMenuPlayer.stop();
      await _finalMenuPlayer.setVolume(0.40);
      await _finalMenuPlayer.setReleaseMode(ReleaseMode.loop);
      await _finalMenuPlayer.play(AssetSource('music/bg_music.mp3')); 
      
      print("Все игровые звуки заглушены. Фоновая музыка меню запущена принудительно.");
    } catch (e) {
      print("Ошибка при принудительном возврате к музыке меню: $e");
    }
  }


   // ТОЧЕЧНО ЗАМЕНИТЬ МЕТОД STARTCASTLEDROPS В LIB/AUDIO_MANAGER.DART:
  static Future<void> startCastleDrops() async {
    try {
      // Тушим старые эффекты, если они были
      await _fxPlayer.stop();
      
      // Запускаем капли на абсолютно изолированном плеере _rainPlayer!
      await _rainPlayer.stop();
      await _rainPlayer.setVolume(1.0); 
      await _rainPlayer.setReleaseMode(ReleaseMode.loop); 
      await _rainPlayer.play(AssetSource('music/castle_drops.mp3'), mode: PlayerMode.lowLatency); 
      
      print("Бронебойный эмбиент капель запущен на изолированном канале плеера дождя.");
    } catch (e) {
      print("Ошибка при запуске капель замка: $e");
    }
  }


    static Future<void> startBossPhase2Music() async {
    try {
      // Останавливаем капли тронного зала
      await _finalMenuPlayer.stop();

      // Выставляем боевые параметры
      await _finalMenuPlayer.setVolume(0.90); // Музыка босса должна качать!
      await _finalMenuPlayer.setReleaseMode(ReleaseMode.loop);
      
      // Название трека для второй фазы, лежит строго в music/
      await _finalMenuPlayer.play(AssetSource('music/boss_battle.mp3'));
      print("ВТОРАЯ ФАЗА! Запущена динамичная музыка босса из папки music.");
    } catch (e) {
      print("Ошибка запуска боевой музыки фазы 2: $e");
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

    // Сочный затяжной грохот обрушения каменного потолка замка
  static Future<void> playCastleCollapse() async {
    try {
      await _fxPlayer.stop();
      await _fxPlayer.setVolume(1.0);
      await _fxPlayer.play(AssetSource('audio/stone_break.mp3'));
    } catch (e) {
      print("Ошибка звука обрушения потолка: $e");
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

      // ТОЧЕЧНО ЗАМЕНИТЬ СТАРЫЙ МЕТОД В САМОМ КОНЦЕ ФАЙЛА AUDIO_MANAGER.DART:
  static void _playSingleEffect(String assetPath) async {
    try {
      // Мелкие звуки (блоки, свиньи) крутятся в своем изолированном пуле
      final AudioPlayer player = _fxPool[_fxPoolIndex];
      _fxPoolIndex = (_fxPoolIndex + 1) % _fxPool.length;

      await player.stop();
      await player.setReleaseMode(ReleaseMode.release);
      await player.play(AssetSource(assetPath), mode: PlayerMode.lowLatency);
    } catch (e) {
      print("Ошибка пула мелких эффектов: $e");
    }
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

    // ТОЧЕЧНО ЗАМЕНИТЬ ГЕТТЕР ISCASTLEDROPSPLAYING В LIB/AUDIO_MANAGER.DART:
  static bool get isCastleDropsPlaying {
    try {
      // Теперь проверяем статус изолированного плеера капель/дождя!
      return _rainPlayer.state == PlayerState.playing;
    } catch (_) {
      return false;
    }
  }


  
  // ТОЧЕЧНО ЗАМЕНИТЬ МЕТОД STOPLEVEL5RAIN В LIB/AUDIO_MANAGER.DART:
  static Future<void> stopLevel5Rain() async {
    try {
      await _rainPlayer.stop();
      // Вместо жесткого release, который ломает нативный девайс, 
      // мы принудительно сбрасываем источник звука в ноль, очищая ОЗУ
      await _rainPlayer.setSource(BytesSource(Uint8List(0))); 
      print("Звук ливня 5 уровня полностью потушен, ОЗУ очищена.");
    } catch (e) {
      print("Ошибка при мягкой зачистке кэша дождя: $e");
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
