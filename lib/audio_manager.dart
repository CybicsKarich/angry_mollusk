import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AudioManager {
  // Плееры для контролируемых звуков
  static final AudioPlayer _stretchPlayer = AudioPlayer();
  static final AudioPlayer _finalMenuPlayer = AudioPlayer();
  static final AudioPlayer _fxPlayer = AudioPlayer(); 
  static final List<AudioPlayer> _fxPool = List.generate(4, (_) => AudioPlayer());
  static int _fxPoolIndex = 0;
  static final AudioPlayer _rainPlayer = AudioPlayer();
  static bool _isStartingRain = false;
  static final AudioPlayer _bossMusicPlayer = AudioPlayer();
  static bool _isLevel6BattleMusicActive = false;
  static final AudioPlayer _level6MusicPlayer = AudioPlayer();
  static bool isLevel6ArenaActive = false;
  static final AudioPlayer _skyFreedomPlayer = AudioPlayer();
  static final AudioPlayer _eternalLoopPlayer = AudioPlayer();

  // Флаг-замок для отмены цикла затухания, если музыку выключили принудительно
  static bool _isFadeOutCancelled = false;
    static double masterVolume = 0.5; // Глобальный множитель громкости (от 0.0 до 1.0)

  // Геттер для получения текущего состояния фонового плеера
  static AudioPlayer get menuPlayer => _finalMenuPlayer;

  // Устанавливает громкость для ВСЕХ активных плееров и сохраняет её на диск
  static Future<void> setMasterVolume(double volume) async {
    masterVolume = volume.clamp(0.0, 1.0);
    
    // Сохраняем выбранную громкость в память устройства
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('game_master_volume', masterVolume);

    // Моментально обновляем громкость у всех постоянных плееров
    await _finalMenuPlayer.setVolume(0.5 * masterVolume);
    await _stretchPlayer.setVolume(masterVolume);
    await _fxPlayer.setVolume(masterVolume);
    await _rainPlayer.setVolume(0.5 * masterVolume);
    await _bossMusicPlayer.setVolume(masterVolume);
    await _level6MusicPlayer.setVolume(masterVolume);
    await _skyFreedomPlayer.setVolume(masterVolume);
    await _eternalLoopPlayer.setVolume(masterVolume);
    
    for (var player in _fxPool) {
      await player.setVolume(masterVolume);
    }
  }


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
    final prefs = await SharedPreferences.getInstance();
    masterVolume = prefs.getDouble('game_master_volume') ?? 0.5;

    // Чистый игровой контекст для эффектов и 6 уровня: звуки смешиваются и не выбивают друг друга
    final gameMixContext = AudioContext(
      android: const AudioContextAndroid(
        contentType: AndroidContentType.sonification,
        usageType: AndroidUsageType.game,
        audioFocus: AndroidAudioFocus.none,
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.ambient,
      ),
    );

    await _level6MusicPlayer.setAudioContext(gameMixContext);
    await _fxPlayer.setAudioContext(gameMixContext);

    _stretchPlayer.setReleaseMode(ReleaseMode.loop);
    _finalMenuPlayer.setReleaseMode(ReleaseMode.release);
    resetTokensForNextBird();
  }





    // === ВСTАВЛЯЙ НОВЫЙ МЕТОД СТРОГО СЮДА ===
  static Future<void> playBackgroundMusic() async {
    try {
      if (_finalMenuPlayer.state != PlayerState.playing) {
        await _finalMenuPlayer.setReleaseMode(ReleaseMode.loop);
        await _finalMenuPlayer.setVolume(0.5 * masterVolume);
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
      await _fxPlayer.setVolume(0.85 * masterVolume);
      
      _fxPlayer.play(AssetSource('audio/bunnyhop_rage.mp3'), mode: PlayerMode.lowLatency);
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


    static Future<void> playBossWhip() async {
    try {
      await _fxPlayer.stop();
      await _fxPlayer.setVolume(0.75 * masterVolume);
      await _fxPlayer.play(AssetSource('audio/boss_whip.mp3'), mode: PlayerMode.lowLatency);
    } catch (e) {
      print("Ошибка воспроизведения звука замаха босса: $e");
    }
  }

  static Future<void> playBossStrike() async {
    try {
      await _fxPlayer.stop();
      await _fxPlayer.setVolume(1.0 * masterVolume);
      await _fxPlayer.play(AssetSource('audio/boss_strike.mp3'), mode: PlayerMode.lowLatency);
    } catch (e) {
      print("Ошибка воспроизведения звука удара босса: $e");
    }
  }



  // ТОЧЕЧНО ДОБАВИТЬ В КЛАСС AudioManager В ФАЙЛЕ lib/audio_manager.dart:
  static bool get isBossMusicPlaying {
    try {
      // Проверяем, играет ли нативный плеер музыки босса прямо сейчас
      return _bossMusicPlayer.state == PlayerState.playing;
    } catch (_) {
      return false; // Мягкая защита от зависания при инициализации трека
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
      await _fxPlayer.setVolume(1.0 * masterVolume);
      await _fxPlayer.play(AssetSource('audio/hat_splat.mp3')); 
    } catch (e) {
      print("Ошибка воспроизведения звука шлепка шляпы: $e");
    }
  }

 // ДОБАВИТЬ В КЛАСС AudioManager В ФАЙЛЕ lib/audio_manager.dart:
static Future<void> playPaperRustle() async {
  try {
    await _fxPlayer.stop(); // Глушим прошлый звук эффектов, чтобы не накладывался
    await _fxPlayer.setVolume(1.0 * masterVolume);
    await _fxPlayer.play(AssetSource('audio/paper_rustle.mp3')); // Чистый путь относительно папки assets/
  } catch (e) {
    print("Ошибка воспроизведения звука шелеста бумаги: $e");
  }
}  

        

  // Обновляем метод полной очистки при выходе игрока в Главное Меню
  static Future<void> stopLevelAudioAndPlayMenu() async {
    try {
      isLevel6ArenaActive = false;
      resetTokensForNextBird();
      _isStretching = false;
      await _stretchPlayer.stop();
      await _fxPlayer.stop();
      await _rainPlayer.stop();      // Намертво тушим капли/дождь
      await _bossMusicPlayer.stop(); // НАМЕРТВО ТУШИМ МУЗЫКУ БОССА! Она больше не пролезет в меню!
      await stopRage();
      await _level6MusicPlayer.stop();
      
      // Запускаем дефолтную музыку главного меню
      await _finalMenuPlayer.stop();
      await _finalMenuPlayer.setVolume(0.50 * masterVolume);
      await _finalMenuPlayer.setReleaseMode(ReleaseMode.loop);
      await _finalMenuPlayer.play(AssetSource('music/bg_music.mp3'), mode: PlayerMode.mediaPlayer); 
      print("Все боевые плееры зачищены. Включена музыка меню.");
    } catch (e) {
      print("Ошибка возврата к меню: $e");
    }
  }

    // =========================================================================
  // 🎵 МУЗЫКАЛЬНАЯ СИСТЕМА ДЛЯ ФИНАЛЬНОГО КОМИКСА (ЧАСТЬ 1 И ЧАСТЬ 2)
  // =========================================================================

    /// 1. Чистый запуск триумфальной музыки неба (Часть 1)
  static Future<void> playSkyFreedom() async {
    try {
      _isFadeOutCancelled = false;
      await _eternalLoopPlayer.stop(); 
      
      // Запускаем победный трек на текущей общей громкости
      await _skyFreedomPlayer.setVolume(masterVolume);
      await _skyFreedomPlayer.setReleaseMode(ReleaseMode.loop);
      await _skyFreedomPlayer.play(AssetSource('music/sky_freedom.mp3'));
      print("🚀 Финальная музыка триумфа 'sky_freedom' успешно запущена.");
    } catch (e) {
      print("Ошибка при запуске музыки триумфа: $e");
    }
  }

  /// 2. Переход на истинную тему Моллюска с плавным затуханием первой части за 1.5 секунды
  static Future<void> switchToEternalLoopWithFade() async {
    try {
      _isFadeOutCancelled = false;
      double currentVolume = masterVolume; // Стартуем с текущей громкости из настроек
      double step = masterVolume / 20;     // Вычисляем шаг снижения за 20 тактов
      
      print("⏳ Начинается плавное затухание музыки триумфа...");

      for (int i = 0; i < 20; i++) {
        if (_isFadeOutCancelled) return;

        currentVolume -= step;
        if (currentVolume < 0.0) currentVolume = 0.0;

        await _skyFreedomPlayer.setVolume(currentVolume);
        await Future.delayed(const Duration(milliseconds: 75));
      }

      await _skyFreedomPlayer.stop();

      // Запускаем тему кукловода строго на уровне общей громкости
      await _eternalLoopPlayer.setVolume(masterVolume);
      await _eternalLoopPlayer.setReleaseMode(ReleaseMode.loop);
      await _eternalLoopPlayer.play(AssetSource('music/eternal_loop.mp3'));
      
      print("👁️ Истинная тема Дона Моллюска 'eternal_loop' запущена после затухания.");
    } catch (e) {
      print("Ошибка при переключении музыки с затуханием: $e");
    }
  }


  /// 3. Полная экстренная зачистка финальных плееров (вызывать при выходе в Главное меню)
  static void stopFinalComicAudio() async {
    try {
      _isFadeOutCancelled = true; // Ломаем асинхронный цикл затухания, если он шёл прямо сейчас
      
      await _skyFreedomPlayer.stop();
      await _eternalLoopPlayer.stop();
      
      await _skyFreedomPlayer.release();
      await _eternalLoopPlayer.release();
      
      print("🧹 Аудиоканалы финального комикса успешно зачищены из RAM устройства.");
    } catch (e) {
      print("Ошибка при экстренной остановке финальной музыки: $e");
    }
  }

  // ИСПРАВЛЕНО ТОЧЕЧНО: Нативное освобождение RAM, выгрузка треков и тотальная зачистка кэша
  static void clearBossMusicAndCache() async {
    try {
      // 1. .stop() останавливает воспроизведение, если оно шло
      await _level6MusicPlayer.stop(); 
      await _rainPlayer.stop();        
      
      // 2. .release() ЖЕСТКО освобождает все ресурсы ОС, удаляет аудиопотоки из RAM и чистит нативный кэш!
      await _level6MusicPlayer.release(); 
      await _rainPlayer.release();        
      
      print("🧠 ТОТАЛЬНЫЙ СБРОС: Музыка боссфайта полностью выгружена из оперативной памяти устройства.");
    } catch (e) {
      print("Критическая ошибка при глубокой очистке RAM боссфайта: $e");
    }
  }

  // ИСПРАВЛЕНО ТОЧЕЧНО: Метод тотальной мгновенной зачистки всех боевых эффектов при победе
  static void clearAllBattleFX() async {
    try {
      await _fxPlayer.stop(); // Глушим основной канал (ор ярости, замахи, удары)
      
      // Намертво выключаем и обнуляем весь пул мелких звуков (взрывы блоков, свиней)
      for (var player in _fxPool) {
        await player.stop();
      }
      print("💥 ВСЕ звуковые эффекты арены принудительно выгружены из кэша микшера девайса.");
    } catch (e) {
      print("Ошибка экстренной очистки эффектов: $e");
    }
  }

 
    static Future<void> startCastleDrops() async {
    try {
      if (_rainPlayer.state == PlayerState.playing) return;
      await _rainPlayer.setVolume(0.85 * masterVolume);
      await _rainPlayer.setReleaseMode(ReleaseMode.loop);
      await _rainPlayer.play(AssetSource('music/castle_drops.mp3'), mode: PlayerMode.lowLatency);
    } catch (e) {
      print("Ошибка старта капель комикса: $e");
    }
  }


      static Future<void> startLevel6BattleMusic() async {
    try {
      if (_level6MusicPlayer.state == PlayerState.playing) return;
      await _level6MusicPlayer.setVolume(masterVolume);
      await _level6MusicPlayer.setReleaseMode(ReleaseMode.loop);
      await _level6MusicPlayer.play(AssetSource('music/castle_drops.mp3'), mode: PlayerMode.mediaPlayer);
    } catch (e) {
      print("Ошибка старта музыки Фазы 1: $e");
    }
  }


  // Переключение на боевой рок Фазы 2 (однократный чистый переход)
  static Future<void> switchToBossPhase2Music() async {
    try {
      await _rainPlayer.setVolume(0.30 * masterVolume);
      await _level6MusicPlayer.stop();
      await _level6MusicPlayer.setVolume(masterVolume);
      await _level6MusicPlayer.setReleaseMode(ReleaseMode.loop);
      await _level6MusicPlayer.play(AssetSource('music/boss_battle.mp3'), mode: PlayerMode.mediaPlayer);
    } catch (e) {
      print("Ошибка старта рока Фазы 2: $e");
    }
  }





        static Future<void> pauseAll() async {
    try {
      await _finalMenuPlayer.pause();    // Музыка главного меню
      await _rainPlayer.pause();         // Ливень 5 уровня и капли замка
      await _stretchPlayer.pause();      // Натяжение рогатки
      await _bossMusicPlayer.pause();    // Резервный плеер босса
      await _level6MusicPlayer.pause();  // Капли Фазы 1 и рок Фазы 2 (6 уровень)
      await _skyFreedomPlayer.pause();   // Музыка 1-й части финала (хорошая концовка)
      await _eternalLoopPlayer.pause();  // Музыка 2-й части финала (идеальная концовка)
      print("Все звуковые потоки поставлены на паузу при сворачивании приложения.");
    } catch (e) {
      print("Ошибка при паузе звуков: $e");
    }
  }

  static Future<void> resumeAll() async {
    try {
      if (_finalMenuPlayer.state == PlayerState.paused) {
        await _finalMenuPlayer.resume();
      }
      if (_rainPlayer.state == PlayerState.paused) {
        await _rainPlayer.resume();
      }
      if (_bossMusicPlayer.state == PlayerState.paused) {
        await _bossMusicPlayer.resume();
      }
      if (_level6MusicPlayer.state == PlayerState.paused) {
        await _level6MusicPlayer.resume();
      }
      if (_skyFreedomPlayer.state == PlayerState.paused) {
        await _skyFreedomPlayer.resume();
      }
      if (_eternalLoopPlayer.state == PlayerState.paused) {
        await _eternalLoopPlayer.resume();
      }
      print("Все поставленные на паузу звуковые потоки возобновлены.");
    } catch (e) {
      print("Ошибка при возобновлении звуков: $e");
    }
  }





  // 1. ЗВУК НАТЯЖЕНИЯ РОГАТКИ
  static void playStretch() async {
    if (_isStretching) return;
    _isStretching = true;
    try {
      await _stretchPlayer.stop();
      await _stretchPlayer.setVolume(masterVolume);
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

    if (!isLevel6ArenaActive) {
      if (!hasPigHitToken) return; 
      hasPigHitToken = false; 
    }

    int num = _random.nextInt(3) + 1;
    try {
      final AudioPlayer hitPlayer = AudioPlayer();
      await hitPlayer.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.game,
            audioFocus: AndroidAudioFocus.none,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.ambient,
          ),
        ),
      );
      await hitPlayer.setReleaseMode(ReleaseMode.release);
      await hitPlayer.setVolume(1.0 * masterVolume);
      await hitPlayer.play(AssetSource('audio/pig_hit$num.MP3'), mode: PlayerMode.lowLatency);
      
      hitPlayer.onPlayerComplete.listen((_) => hitPlayer.dispose());
    } catch (e) {
      print("Ошибка внеочередного звука удара: $e");
    }
  }


  static void playMiss() {
    if (_isRageSoundPlaying) return;

    // ИСПРАВЛЕНО ТОЧЕЧНО: Если это НЕ 6 уровень, то проверяем и сжигаем жетон промаха птицы.
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
      await _fxPlayer.setVolume(masterVolume);
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
      await _fxPlayer.setVolume(1.0 * masterVolume);
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
      await _fxPlayer.setVolume(masterVolume);
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
      await player.setVolume(masterVolume);
      await player.play(AssetSource(assetPath), mode: PlayerMode.lowLatency);
    } catch (e) {
      print("Ошибка пула мелких эффектов: $e");
    }
  }


      static Future<void> startLevel5Rain() async {
    try {
      await _finalMenuPlayer.stop();
      await _rainPlayer.setVolume(0.45 * masterVolume); 
      await _rainPlayer.setReleaseMode(ReleaseMode.loop); 
      await _rainPlayer.play(AssetSource('music/rain_ambient.mp3'), mode: PlayerMode.lowLatency);
    } catch (e) {
      print("Ошибка запуска звука дождя: $e");
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

    // ТОЧЕЧНО ЗАМЕНИТЬ ГЕТТЕР ISCASTLEDROPSPLAYING В LIB/AUDIO_MANAGER.DART:
  static bool get isCastleDropsPlaying {
    try {
      // Теперь проверяем статус изолированного плеера капель/дождя!
      return _rainPlayer.state == PlayerState.playing;
    } catch (_) {
      return false;
    }
  }


  
    static Future<void> stopLevel5Rain() async {
    try {
      await _rainPlayer.stop();
      await _rainPlayer.release();
      print("Звук ливня и капель полностью заглушен.");
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
      await thunderPlayer.setVolume(0.85 * masterVolume);
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
    isLevel6ArenaActive = false;
    resetTokensForNextBird();
    await stopLevel5Rain(); // Тушим дождь и капли замка
    
    try {
      await _stretchPlayer.stop();
      await _fxPlayer.stop(); // Глушим замахи, удары босса (boss_whip, boss_strike) и ярость
      
      // Глушим весь пул мелких звуковых эффектов
      for (var player in _fxPool) {
        await player.stop();
      }
      
      // Намертво останавливаем и выгружаем музыку 1-й и 2-й фазы 6-го уровня
      _isLevel6BattleMusicActive = false;
      await _bossMusicPlayer.stop();
      await _level6MusicPlayer.stop();
      await _level6MusicPlayer.release();
      
      // Перезапускаем фоновую музыку меню на ровной громкости 0.5
      await _finalMenuPlayer.stop();
      await _finalMenuPlayer.setVolume(0.5 * masterVolume);
      await _finalMenuPlayer.setReleaseMode(ReleaseMode.loop);
      await _finalMenuPlayer.play(AssetSource('music/bg_music.mp3'), mode: PlayerMode.mediaPlayer);
      print("Полная зачистка всех аудиопотоков (включая 6 уровень) завершена.");
    } catch (e) {
      print("Ошибка при полной остановке звуков: $e");
    }
  }






  // 3. ИСПРАВЛЕНО: ЗВУК АЧИВКИ МЕДАЛИ
  static Future<void> playAchievement() async {
    try {
      await _fxPlayer.stop();
      await _fxPlayer.setVolume(1.0 * masterVolume);
      await _fxPlayer.play(AssetSource('audio/achievement_unlocked.mp3'));
    } catch (e) {
      print("КРИТИЧЕСКАЯ ОШИБКА ФАНФАР МЕДАЛИ: $e");
    }
  }

    // =========================================================================
  // 📊 ИСПРАВЛЕННЫЙ СЧЁТЧИК СТАТИСТИКИ ДЛЯ KARRICK STUDIO (ПРИНИМАЕТ ОБЪЁМ)
  // =========================================================================
  static void incrementStat(String key, {int amount = 1}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int currentVal = prefs.getInt(key) ?? 0;
      await prefs.setInt(key, currentVal + amount); // Прибавляем переданный объём!
    } catch (e) {
      print("Ошибка записи статистики $key: $e");
    }
  }
} // <--- ВОТ ЭТА ОДНА СКОБКА ТЕПЕРЬ САМАЯ ПОСЛЕДНЯЯ В ФАЙЛЕ! Она закрывает весь класс AudioManager.
