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
  static final AudioPlayer _bossMusicPlayer = AudioPlayer();
  static bool _isLevel6BattleMusicActive = false;
  static final AudioPlayer _level6MusicPlayer = AudioPlayer();
  static bool isLevel6ArenaActive = false; 


  
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
    

        // ТОЧЕЧНО ДОБАВИТЬ В КЛАСС AudioManager В LIB/AUDIO_MANAGER.DART:

  // Вызывается автоматически при сворачивании игры в фон
  static void pauseAllForBackground() {
    try {
      _bossMusicPlayer.pause(); // Ставим музыку босса на паузу
      _rainPlayer.pause();      // Ставим капли/ливень на паузу
      _fxPlayer.stop();         // Глушим ор ярости
    } catch (e) {
      print("Ошибка аварийной паузы фона: $e");
    }
  }

  // Обновляем метод полной очистки при выходе игрока в Главное Меню
  static Future<void> stopLevelAudioAndPlayMenu() async {
    try {
      _isStretching = false;
      await _stretchPlayer.stop();
      await _fxPlayer.stop();
      await _rainPlayer.stop();      // Намертво тушим капли/дождь
      await _bossMusicPlayer.stop(); // НАМЕРТВО ТУШИМ МУЗЫКУ БОССА! Она больше не пролезет в меню!
      await stopRage();
      await _level6MusicPlayer.stop();
      
      // Запускаем дефолтную музыку главного меню
      await _finalMenuPlayer.stop();
      await _finalMenuPlayer.setVolume(0.40);
      await _finalMenuPlayer.setReleaseMode(ReleaseMode.loop);
      await _finalMenuPlayer.play(AssetSource('music/bg_music.mp3'), mode: PlayerMode.mediaPlayer); 
      print("Все боевые плееры зачищены. Включена музыка меню.");
    } catch (e) {
      print("Ошибка возврата к меню: $e");
    }
  }


 static Future<void> startCastleDrops() async {
    try {
      await _rainPlayer.stop();
      await _rainPlayer.setVolume(0.85);
      await _rainPlayer.setReleaseMode(ReleaseMode.loop);
      await _rainPlayer.play(AssetSource('music/castle_drops.mp3'), mode: PlayerMode.lowLatency);
    } catch (e) {
      print("Ошибка старта капель комикса: $e");
    }
  }

      // ИСПРАВЛЕНО: Возвращен жесткий принудительный запуск Low Latency, который пробивает любые звуки комикса!
  static void startLevel6BattleMusic() async {
    try {
      // Защита от ежесекундного сброса трека к началу: если капли УЖЕ играют на _level6MusicPlayer, не перебиваем их
      if (_level6MusicPlayer.state == PlayerState.playing && !_isLevel6BattleMusicActive) {
        return; 
      }
      
      _isLevel6BattleMusicActive = false; // Сбрасываем флаг под Фазу 1

      _level6MusicPlayer.setVolume(1.0);
      _level6MusicPlayer.setReleaseMode(ReleaseMode.loop);
      
      // ВОЗВРАЩЕНО К ОРИГИНАЛУ: Жесткий Low Latency запуск, который сочно глушит грохот камня!
      await _level6MusicPlayer.play(AssetSource('music/castle_drops.mp3'), mode: PlayerMode.lowLatency);
      print("Музыка Фазы 1 (Капли) принудительно запущена через Low Latency.");
    } catch (e) {
      print("Ошибка старта музыки Фазы 1: $e");
    }
  }

  // ИСПРАВЛЕНО: Возвращен жесткий Low Latency, который не дает другим эффектам прервать Кровавый Рок!
  static void switchToBossPhase2Music() async {
    try {
      // Защита от ежесекундного сброса трека к началу: если Рок УЖЕ играет на _level6MusicPlayer, просто пропускаем шаг
      if (_level6MusicPlayer.state == PlayerState.playing && _isLevel6BattleMusicActive) {
        return; 
      }

      _isLevel6BattleMusicActive = true; // Фиксируем, что включена Фаза 2
      
      // Мгновенно тушим сквозной фон капель на плеере дождя, если он мешает
      await _rainPlayer.stop(); 
      
      _level6MusicPlayer.setVolume(1.0);
      _level6MusicPlayer.setReleaseMode(ReleaseMode.loop);
      
      // ВОЗВРАЩЕНО К ОРИГИНАЛУ: Жесткий Low Latency запуск рока, который никакой другой звук не сможет прервать!
      await _level6MusicPlayer.play(AssetSource('music/boss_battle.mp3'), mode: PlayerMode.lowLatency);
      print("Рок Фазы 2 принудительно запущен через Low Latency без задержек.");
    } catch (e) {
      print("Ошибка start рока Фазы 2: $e");
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

  static void playPigHit() async {
    if (_isRageSoundPlaying) return;
    
    // ИСПРАВЛЕНО ТОЧЕЧНО: На 6 уровне бьем без лимитов, на остальных — проверяем жетон!
    if (!isLevel6ArenaActive) {
      if (!hasPigHitToken) return; 
      hasPigHitToken = false; 
    }

    int num = _random.nextInt(3) + 1;
    try {
      final AudioPlayer hitPlayer = AudioPlayer();
      await hitPlayer.setReleaseMode(ReleaseMode.release);
      await hitPlayer.setVolume(1.0); 
      await hitPlayer.play(AssetSource('audio/pig_hit$num.MP3'), mode: PlayerMode.lowLatency);
      
      hitPlayer.onPlayerComplete.listen((_) => hitPlayer.dispose());
    } catch (e) {
      print("Ошибка внеочередного звука удара: $e");
    }
  }

  static void playMiss() {
    if (_isRageSoundPlaying) return;
    
    // ИСПРАВЛЕНО ТОЧЕЧНО: На 6 уровне ранения Вани озвучиваются всегда, на остальных — по токену!
    if (!isLevel6ArenaActive) {
      if (!hasMissToken) return; 
      hasMissToken = false;
    }

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

        static bool get isCastleDropsPlaying {
    try {
      return _rainPlayer.state == PlayerState.playing;
    } catch (_) {
      return false;
    }
  }



static bool get isBossMusicPlaying {
    try {
      // Проверяем, играет ли нативный плеер музыки босса прямо сейчас
      return _bossMusicPlayer.state == PlayerState.playing;
    } catch (_) {
      return false; // Мягкая защита от зависания при инициализации трека
    }
  }

  
  // ТОЧЕЧНО ЗАМЕНИТЬ МЕТОД STOPLEVEL5RAIN В LIB/AUDIO_MANAGER.DART:
  static Future<void> stopLevel5Rain() async {
    try {
      await _rainPlayer.stop();
      print("Звук ливня 5 уровня полностью заглушен.");
    } catch (e) {
      print("Ошибка при остановке дождя: $e");
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
       _isLevel6BattleMusicActive = false; // Сбрасываем замок музыки боя
       await _bossMusicPlayer.stop();
      
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
