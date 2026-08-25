import 'main.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide Wallet;
import 'package:angry_mollusk/audio_manager.dart'; // Подключаем наш звуковой движок
import 'package:shared_preferences/shared_preferences.dart';

// Главный экран игры с поддержкой оверлеев: Победа, Пауза, Проигрыш
class GameScreen extends StatelessWidget {
    final AngryMolluskGame gameInstance = AngryMolluskGame();
    GameScreen({super.key});

        @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget<AngryMolluskGame>(
            game: gameInstance,
            overlayBuilderMap: {
              // 1. ОВЕРЛЕЙ ПОБЕДЫ СО ЗВЁЗДАМИ
              'VictoryMenu': (BuildContext context, AngryMolluskGame game) {
                if (game.birdsQueue.length == 2) {
                  SharedPreferences.getInstance().then((prefs) async {
                    final alreadyUnlocked = prefs.getBool('achievement_sniper') ?? false;
                    if (!alreadyUnlocked) {
                      await prefs.setBool('achievement_sniper', true);
                      AudioManager.playAchievement(); // Наш победный космический звук фанфар!
                      game.overlays.add('AchievementToast');
                      Future.delayed(const Duration(seconds: 5), () {
                        game.overlays.remove('AchievementToast');
                      });
                    }
                  });
                }
                  
                  int starsCount = 0;
                if (AngryMolluskGame.score >= game.targetScore3Stars) {
                  starsCount = 3;
                } else if (AngryMolluskGame.score >= game.targetScore2Stars) {
                  starsCount = 2;
                } else if (AngryMolluskGame.score >= game.targetScore1Star) {
                  starsCount = 1;
                }

                return Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.55,
                    height: MediaQuery.of(context).size.height * 0.75,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9C4), 
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFFBC02D), width: 6), 
                      boxShadow: const [
                        BoxShadow(color: Colors.black45, blurRadius: 15, offset: Offset(0, 8)),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Text(
                          "Ты победил, красавчик!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFD84315), 
                            shadows: [Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black26)],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (index) {
                            bool isLit = index < starsCount;
                            return Icon(
                              Icons.star_rounded,
                              size: 65,
                              color: isLit ? const Color(0xFFFFD54F) : Colors.grey.shade400,
                              shadows: isLit ? const [Shadow(color: Color(0xFFFF8F00), blurRadius: 8)] : null,
                            );
                          }),
                        ),
                        Text(
                          "ИТОГОВЫЙ СЧЁТ: ${AngryMolluskGame.score}",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3E2723), 
                          ),
                        ),
                                               Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 1. КНОПКА СЛЕВА: ДОМИК (ВЫХОД В ГЛАВНОЕ МЕНЮ КАРТОЧЕК)
                            Container(
                              width: 60, height: 60,
                              decoration: const BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle),
                              child: RawMaterialButton(
                                shape: const CircleBorder(),
                                onPressed: () {
                                  AudioManager.stopAllLevelSounds();
                                  game.overlays.remove('VictoryMenu');
                                  Navigator.pop(context); // Возвращает в меню уровней
                                },
                                child: const Icon(Icons.home_rounded, color: Colors.white, size: 32),
                              ),
                            ),
                            const SizedBox(width: 20),
                            
                            // 2. КНОПКА ПО ЦЕНТРУ: ЗАНОВО (ПЕРЕЗАПУСК ТЕКУЩЕГО УРОВНЯ)
                            Container(
                              width: 60, height: 60,
                              decoration: const BoxDecoration(color: Color(0xFFFF9800), shape: BoxShape.circle),
                              child: RawMaterialButton(
                                shape: const CircleBorder(),
                                onPressed: () {
                                  game.overlays.remove('VictoryMenu');
                                  AngryMolluskGame.score = 0; 
                                  game.isVictorySequenceStarted = false;
                                  game.levelCleared = false;
                                  game.buildLevelStructures(); // Перестраивает этот же уровень с нуля
                                },
                                child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 32),
                              ),
                            ),
                            const SizedBox(width: 20),                          
                            
                            // 3. КНОПКА СПРАВА: УМНАЯ СТРЕЛКА (ПЕРЕХОД НА СЛЕДУЮЩИЙ УРОВЕНЬ)
                            Container(
                              width: 60, height: 60,
                              decoration: const BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle),
                              child: RawMaterialButton(
                                shape: const CircleBorder(),
                               // ЗАМЕНИТЬ ДЕЙСТВИЕ onPressed УМНОЙ СТРЕЛКИ СПРАВА НА ЭТОТ БЛОК:
                              onPressed: () {
                              // 1. ПЕРВЫМ ДЕЛОМ СЧИТАЕМ ЗВЁЗДЫ ЗА ТОЛЬКО ЧТО ПРОЙДЕННЫЙ БОЙ
                              int currentRoundStars = 0;
                              if (AngryMolluskGame.score >= game.targetScore3Stars) {
                              currentRoundStars = 3;
                              } else if (AngryMolluskGame.score >= game.targetScore2Stars) {
                              currentRoundStars = 2;
                              } else if (AngryMolluskGame.score >= game.targetScore1Star) {
                                currentRoundStars = 1;
                                }

  // 2. ХАРДКОРНАЯ ПРОВЕРКА: Если звёзд меньше 2 — стрелка блокируется!
  if (currentRoundStars < 2) {
    // Вместо перехода закрываем оверлей победы и перезапускаем этот же уровень, заставляя переигрывать!
    game.overlays.remove('VictoryMenu');
    AngryMolluskGame.score = 0; 
    game.isVictorySequenceStarted = false;
    game.levelCleared = false;
    game.buildLevelStructures(); 
    return; // Мертвая отсечка, код ниже не выполнится
  }

  // 3. ЕСЛИ ИГРОК КРАСАВЧИК (НАБРАЛ 2 ИЛИ 3 ЗВЕЗДЫ) — ПУСКАЕМ ДАЛЬШЕ
  game.overlays.remove('VictoryMenu');
  
  if (game.currentLevel == 3) {
    Navigator.pop(context); 
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ComicIntroScreen()),
    );
  } else if (game.currentLevel < 3) {
    game.currentLevel = game.currentLevel + 1;
  }
  
  AngryMolluskGame.score = 0;
  game.worldScrollX = 0.0;
  game.isVictorySequenceStarted = false;
  game.levelCleared = false;
  game.buildLevelStructures();
},

                                child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 32),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
              
                            
              
                            
              
              // ИСПРАВЛЕНО: НОВОЕ ВСПЛЫВАЮЩЕЕ ОКНО ДОСТИЖЕНИЙ (ТОСТ НА 5 СЕКУНД)
              'AchievementToast': (BuildContext context, AngryMolluskGame game) {
                return Positioned(
                  top: 24,
                  left: MediaQuery.of(context).size.width * 0.25,
                  right: MediaQuery.of(context).size.width * 0.25,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1565C0).withOpacity(0.95), // Сочный глянцевый синий фон
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF64B5F6), width: 3),
                      boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 4))],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.emoji_events_rounded, color: Color(0xFFFFD54F), size: 28),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "ДОСТИЖЕНИЕ РАЗБЛОКИРОВАНО!",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.1),
                            ),
                            Text(
                              "Загляни в меню достижений на главном экране!",
                              style: TextStyle(fontSize: 11, color: Color(0xFFE3F2FD)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },

              // 2. ОВЕРЛЕЙ МЕНЮ ПАУЗЫ
              'PauseMenu': (BuildContext context, AngryMolluskGame game) {
                return Center(
                  child: Container(
                    width: 280,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange, width: 4),
                      boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 5))],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'ПАУЗА',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            onPressed: () {
                                AudioManager.stopAllLevelSounds();
                                game.overlays.remove('PauseMenu');
                              game.resumeEngine();
                            },
                            child: const Text('ПРОДОЛЖИТЬ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            onPressed: () {
                              game.overlays.remove('PauseMenu');
                              game.resumeEngine();
                              AngryMolluskGame.score = 0;
                              game.isVictorySequenceStarted = false;
                              game.levelCleared = false;
                              game.buildLevelStructures();
                            },
                            child: const Text('ЗАНОВО', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            onPressed: () {
                              game.overlays.remove('PauseMenu');
                              game.resumeEngine();
                              Navigator.pop(context); 
                            },
                            child: const Text('В МЕНЮ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },        
                     
                // 3. ОВЕРЛЕЙ ПРОИГРЫША (GAME OVER)
                'GameOverMenu': (BuildContext context, AngryMolluskGame game) {
                return Center(
                  child: Container(
                    width: 300,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3E2723),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFF9800), width: 4),
                      boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 5))],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'ПТИЦЫ КОНЧИЛИСЬ!\nМАКСИМ ПОБЕДИЛ!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.1),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.home_rounded, color: Colors.white, size: 32),
                              onPressed: () {
                                  AudioManager.stopAllLevelSounds();
                                  game.overlays.remove('GameOverMenu');
                                Navigator.pop(context);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 32),
                              onPressed: () {
                                game.overlays.remove('GameOverMenu');
                                AngryMolluskGame.score = 0; 
                                game.isVictorySequenceStarted = false;
                                game.levelCleared = false;
                                game.buildLevelStructures(); 
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            }, // Конец overlayBuilderMap
          ), // Конец GameWidget
          
          // КНОПКА ПАУЗЫ В УГЛУ ЭКРАНА
          Positioned(
            top: 16,
            left: 16,
            child: IconButton(
              style: IconButton.styleFrom(backgroundColor: Colors.black45, padding: const EdgeInsets.all(10)),
              icon: const Icon(Icons.pause_rounded, color: Colors.white, size: 28),
              onPressed: () {
                gameInstance.pauseEngine();
                gameInstance.overlays.add('PauseMenu');
              },
            ),
          ),
        ], // Конец Stack
      ), // Конец Scaffold
    ); // Конец return
  } // Конец метода build
} // Конец класса GameScreen


              

class AngryMolluskGame extends FlameGame with DragCallbacks {
  double groundY = 0.73; // Уровень земли (73% от высоты экрана)
  AngryMolluskGame() : super();

  List<Bunnyhop> birdsQueue = [];
  Bunnyhop? currentBird;
  // Объявляем переменные, которых не хватало компилятору
  double sunRotation = 0.0;
  double cloudOffset1 = 0.0;
  double cloudOffset2 = 0.0;
  double worldScrollX = 0.0;
  double _safetyTimer = 0.0;
  double _pigSoundTimer = 0.0;
  bool isPaused = false;
  bool isAiming = false;
  bool showFlyingLosePhoto = false; // Флаг запуска вылета фотки
  double losePhotoScale = 0.0;     // Размер фотки (растёт от 0.0 до 0.5)
  static int pillsRemaining = 3;
  double acidBackgroundTimer = 0.0;
  // ИСПРАВЛЕНО: Переменные для интерактивной анимации шляпы шерифа на 1 уровне!
  double hatAnimTimer = 0.0;     // Общий таймер анимации полёта и сползания
  bool isHatSplatSoundPlayed = false; // Флаг, чтобы звук шлепка бахнул ровно один раз
  bool hasWantedPoster = false;       // Сгенерировался ли плакат на уровне
  bool showWantedBig = false;         // Показывается ли большой плакат на весь экран
  double wantedPosterX = 0.0;         // Относительная X координата маленькой бумажки
  double wantedPosterY = 0.0;         // Относительная Y координата маленькой бумажки
  double wantedAnimTimer = 0.0;       // Таймер анимации вылета и удержания
  int wantedAttachedBlockIndex = -1;  // Индекс балки, к которой приклеен плакат


 
    int currentLevel = 1;
    
    // СИСТЕМА ОЧКОВ И ЗВЁЗД
  static int score = 0;
  int targetScore1Star = 200;
  int targetScore2Stars = 250;
  int targetScore3Stars = 300;
  bool isVictorySequenceStarted = false; // Чтобы очки за птиц начислялись один раз

  
  // Контейнеры для управления объектами безForge2D
  List<GameBlock> blocks = [];
  List<MolluskMaksim> pigs = [];
  bool spawnCompleted = false; // Добавляем объявление флага спавна

  // Переменные под текстуры
  Sprite? bunnySprite;
  Sprite? maksimSprite;

  
  bool levelCleared = false;
  bool levelFailed = false;

  // Координаты рогатки на экране (вычисляются в процентах от размера экрана)
  Offset get slingshotCenter => Offset(canvasSize.x * 0.2, canvasSize.y * 0.7);

    @override
  Future<void> onLoad() async {
    await super.onLoad();
    await AudioManager.init();
    
    groundY = 0.73; // Земля установлена!
    AngryMolluskGame.score = 0;
    isVictorySequenceStarted = false;
    
    bunnySprite = await loadSprite('bunnyhop.png');
    maksimSprite = await loadSprite('maksim.png');
    await images.load('bunnyhop_lose.png');
    
    add(BackgroundDecoration());
    buildLevelStructures(); // Вызываем чистую постройку
  }


    void buildLevelStructures() {
    blocks.clear();
    pigs.clear();
    birdsQueue.clear();
    
    isVictorySequenceStarted = false;
    levelCleared = false;
    levelFailed = false;

    // Свежая очередь из 3 птиц
    for (int i = 0; i < 3; i++) {
      final startX = 0.15 - (i * 0.04);
      final startY = i == 0 ? groundY - 0.07 : groundY - 0.04; 
      birdsQueue.add(Bunnyhop(Offset(startX, startY), i == 0));
    }
    currentBird = birdsQueue.first;

    // ==========================================
    // ГЕОМЕТРИЯ УРОВНЯ 1 (СТАРАЯ КЛАССИЧЕСКАЯ БАШНЯ)
    // ==========================================
    if (currentLevel == 1) {
    targetScore1Star = 200;
    targetScore2Stars = 250;
    targetScore3Stars = 300;
       
    final double bx = 0.62; 
      
      // Стены и перекрытия
      blocks.add(GameBlock(bx + 0.00, 0.59, 0.02, 0.14, true));
      blocks.add(GameBlock(bx + 0.07, 0.59, 0.02, 0.14, true));
      blocks.add(GameBlock(bx + 0.14, 0.59, 0.02, 0.14, true));
      blocks.add(GameBlock(bx + 0.21, 0.59, 0.02, 0.14, true));
      blocks.add(GameBlock(bx - 0.01, 0.57, 0.11, 0.02, true));
      blocks.add(GameBlock(bx + 0.13, 0.57, 0.11, 0.02, true));
      blocks.add(GameBlock(bx + 0.01, 0.47, 0.015, 0.10, false));
      blocks.add(GameBlock(bx + 0.10, 0.47, 0.015, 0.10, false));
      blocks.add(GameBlock(bx + 0.20, 0.47, 0.015, 0.10, false));
      blocks.add(GameBlock(bx + 0.00, 0.45, 0.23, 0.02, false));
      blocks.add(GameBlock(bx + 0.05, 0.37, 0.015, 0.08, false));
      blocks.add(GameBlock(bx + 0.16, 0.37, 0.015, 0.08, false));
      blocks.add(GameBlock(bx + 0.03, 0.35, 0.17, 0.02, false));

      // ИСПРАВЛЕНО: Старые добрые фиксированные высоты 1-го уровня
      pigs.add(MolluskMaksim(bx + 0.035, 0.57 - 0.019)); 
      pigs.add(MolluskMaksim(bx + 0.175, 0.57 - 0.019)); 
      pigs.add(MolluskMaksim(bx + 0.105, 0.45 - 0.019));
   
      pigs.add(MolluskMaksim(bx + 0.035, 0.57 - 0.019)); 
      pigs.add(MolluskMaksim(bx + 0.175, 0.57 - 0.019)); 
      pigs.add(MolluskMaksim(bx + 0.105, 0.45 - 0.019));

            // ИСПРАВЛЕНО: СУНДУК И ЖЕЛЕЗО СПАВНЯТСЯ ТОЛЬКО ЕСЛИ АЧИВКА ЕЩЁ НЕ ОТКРЫТА!
      // Если игрок уже разгадал тайну сундука, они навсегда исчезают с 1 уровня
      SharedPreferences.getInstance().then((prefs) {
        final isUnlocked = prefs.getBool('achievement_secret_chest') ?? false;
        if (!isUnlocked) {
          blocks.add(GameBlock(1.35, 0.40, 0.04, 0.33, true)..isIronShield = true);
          blocks.add(GameBlock(1.65, 0.55, 0.08, 0.18, false)..isSecretChest = true);
        }
      });
    } 
    // ==========================================
    // ГЕОМЕТРИЯ УРОВНЯ 2 (ЗАМОК "ДВА УХА" СТРОГО ПО КАРТИНКЕ)
    // ==========================================
    else if (currentLevel == 2) {
    targetScore1Star = 600;
    targetScore2Stars = 700;
    targetScore3Stars = 800;
        
        final double bx = 1.35; // Замок унесен вправо на новый остров

      // --- ПЕРВЫЙ ЭТАЖ ---
      blocks.add(GameBlock(bx + 0.00, 0.55, 0.03, 0.18, false)); 
      blocks.add(GameBlock(bx + 0.12, 0.55, 0.03, 0.18, false)); 
      blocks.add(GameBlock(bx + 0.03, 0.70, 0.04, 0.03, true));  
      blocks.add(GameBlock(bx + 0.08, 0.70, 0.04, 0.03, true));  
      
      blocks.add(GameBlock(bx + 0.17, 0.55, 0.03, 0.18, false)); 
      blocks.add(GameBlock(bx + 0.29, 0.55, 0.03, 0.18, false)); 
      blocks.add(GameBlock(bx + 0.20, 0.70, 0.04, 0.03, false)); 
      blocks.add(GameBlock(bx + 0.25, 0.70, 0.04, 0.03, false)); 

      blocks.add(GameBlock(bx - 0.01, 0.53, 0.16, 0.02, false)); 
      blocks.add(GameBlock(bx + 0.15, 0.53, 0.16, 0.02, false)); 

      // --- ВТОРОЙ ЭТАЖ ---
      blocks.add(GameBlock(bx + 0.01, 0.37, 0.025, 0.16, false));
      blocks.add(GameBlock(bx + 0.11, 0.37, 0.025, 0.16, false));
      blocks.add(GameBlock(bx + 0.00, 0.35, 0.14, 0.02, false)); 

      blocks.add(GameBlock(bx + 0.18, 0.37, 0.025, 0.16, false));
      blocks.add(GameBlock(bx + 0.28, 0.37, 0.025, 0.16, false));
      blocks.add(GameBlock(bx + 0.17, 0.35, 0.14, 0.02, false)); 

      // ИСПРАВЛЕНО: Высоты под замок 2-го уровня
      pigs.add(MolluskMaksim(bx + 0.045, 0.53 - 0.019)); 
      pigs.add(MolluskMaksim(bx + 0.215, 0.53 - 0.019)); 
      pigs.add(MolluskMaksim(bx + 0.045, 0.35 - 0.019)); 
      pigs.add(MolluskMaksim(bx + 0.215, 0.35 - 0.019)); 
        
      // --- ДЕКОРАТИВНЫЕ УШКИ НА КРЫШЕ ---
      blocks.add(GameBlock(bx + 0.02, 0.27, 0.03, 0.08, false));
      blocks.add(GameBlock(bx + 0.08, 0.27, 0.03, 0.08, false));
      blocks.add(GameBlock(bx + 0.01, 0.25, 0.11, 0.02, false));

      blocks.add(GameBlock(bx + 0.20, 0.27, 0.03, 0.08, false));
      blocks.add(GameBlock(bx + 0.26, 0.27, 0.03, 0.08, false));
      blocks.add(GameBlock(bx + 0.19, 0.25, 0.11, 0.02, false));
    }

        // ==========================================
    // ГЕОМЕТРИЯ УРОВНЯ 3 (КРЕПОСТЬ С ЖИВЫМ ЩИТОМ)
    // ==========================================
    else if (currentLevel == 3) {
      // Задаем лимиты очков под сложный Третий уровень
      targetScore1Star = 450;
      targetScore2Stars = 500;
      targetScore3Stars = 550;

      // 🏢 ЗДАНИЕ №1: ВЫСОКИЙ КАМЕННЫЙ ЖИВОЙ ЩИТ (Спереди на координате 1.22)
      final double bx1 = 1.22;
      // 1 этаж щита
      blocks.add(GameBlock(bx1 + 0.00, 0.55, 0.03, 0.18, true)); 
      blocks.add(GameBlock(bx1 + 0.10, 0.55, 0.03, 0.18, true)); 
      blocks.add(GameBlock(bx1 - 0.01, 0.53, 0.15, 0.02, true)); 
      // 2 этаж щита
      blocks.add(GameBlock(bx1 + 0.02, 0.37, 0.03, 0.16, true)); 
      blocks.add(GameBlock(bx1 + 0.08, 0.37, 0.03, 0.16, true)); 
      blocks.add(GameBlock(bx1 + 0.01, 0.35, 0.11, 0.02, true)); 
      // 3 этаж (тяжелая верхушка-монолит)
      blocks.add(GameBlock(bx1 + 0.04, 0.25, 0.05, 0.10, true)); 
      // Внутри этого здания свиней НЕТ — это глухая стена-таран!


      // 🪵 ЗДАНИЕ №2: ДЕРЕВЯННАЯ РЕЗИДЕНЦИЯ С МАКСИМАМИ (Сзади на координате 1.55)
      final double bx2 = 1.55;
      
      blocks.add(GameBlock(bx2 + 0.02, 0.71, 0.08, 0.02, false)); // пол левой комнаты
      blocks.add(GameBlock(bx2 + 0.13, 0.71, 0.08, 0.02, false)); // пол правой комнаты
      
      // 1 этаж деревянного замка (две комнаты рядом)
      blocks.add(GameBlock(bx2 + 0.00, 0.55, 0.025, 0.18, false)); 
      blocks.add(GameBlock(bx2 + 0.11, 0.55, 0.025, 0.18, false)); 
      blocks.add(GameBlock(bx2 + 0.22, 0.55, 0.025, 0.18, false)); 
      blocks.add(GameBlock(bx2 - 0.01, 0.53, 0.26, 0.02, false)); // длинное перекрытие
      
      // 2 этаж деревянного замка (центральная башня)
      blocks.add(GameBlock(bx2 + 0.05, 0.37, 0.025, 0.16, false)); 
      blocks.add(GameBlock(bx2 + 0.16, 0.37, 0.025, 0.16, false)); 
      blocks.add(GameBlock(bx2 + 0.04, 0.35, 0.16, 0.02, false)); // крыша

          // ИСПРАВЛЕНО: Рассадка свиней под новую тактику! Две внизу, одна — король горы на крыше!
      pigs.add(MolluskMaksim(bx2 + 0.04, 0.71 - 0.019));  // в левой нижней комнате
      pigs.add(MolluskMaksim(bx2 + 0.15, 0.71 - 0.019));  // в правой нижней комнате
      pigs.add(MolluskMaksim(bx2 + 0.13, 0.35 - 0.019));  // ИСПРАВЛЕНО: Третья свинья теперь на самой верхушке башни!
    }

        // =========================================================================
    // ГЕОМЕТРИЯ УРОВНЯ 4 (МЁРТВАЯ ПЕТЛЯ RED BALL И БРОНЕСТЕКЛО)
    // =========================================================================
    else if (currentLevel == 4) {
      // Сбрасываем пачку таблеток на старте уровня
      pillsRemaining = 3;

      // ИСПРАВЛЕНО: Новый сбалансированный подсчёт звёзд для 4 уровня!
      targetScore1Star = 350;
      targetScore2Stars = 400;
      targetScore3Stars = 450;


      // 🏢 ЗДАНИЕ №1: ВЫСОКАЯ УЗКАЯ БАШНЯ ИЗ БРОНЕСТЕКЛА (Спереди на координате 1.22)
      final double bx1 = 1.22;
      blocks.add(GameBlock(bx1 + 0.02, 0.55, 0.03, 0.18, false)..isGlassBlock = true); 
      blocks.add(GameBlock(bx1 + 0.08, 0.55, 0.03, 0.18, false)..isGlassBlock = true); 
      blocks.add(GameBlock(bx1 + 0.01, 0.53, 0.11, 0.02, false)..isGlassBlock = true); // крыша 1 этажа
      blocks.add(GameBlock(bx1 + 0.04, 0.35, 0.03, 0.18, false)..isGlassBlock = true); // 2 этаж
      
      pigs.add(MolluskMaksim(bx1 + 0.08, 0.53 - 0.019));

      // 🪵 ЗДАНИЕ №2: ДЕРЕВЯННАЯ РЕЗИДЕНЦИЯ ОДИН В ОДИН КАК НА 3 УРОВНЕ! (Сзади на 1.55)
      final double bx2 = 1.55;
      blocks.add(GameBlock(bx2 + 0.02, 0.71, 0.08, 0.02, false)); // пол левой комнаты
      blocks.add(GameBlock(bx2 + 0.13, 0.71, 0.08, 0.02, false)); // пол правой комнаты
      blocks.add(GameBlock(bx2 + 0.00, 0.55, 0.025, 0.18, false)); 
      blocks.add(GameBlock(bx2 + 0.11, 0.55, 0.025, 0.18, false)); 
      blocks.add(GameBlock(bx2 + 0.22, 0.55, 0.025, 0.18, false)); 
      blocks.add(GameBlock(bx2 - 0.01, 0.53, 0.26, 0.02, false)); 
      blocks.add(GameBlock(bx2 + 0.05, 0.37, 0.025, 0.16, false)); 
      blocks.add(GameBlock(bx2 + 0.16, 0.37, 0.025, 0.16, false)); 
      blocks.add(GameBlock(bx2 + 0.04, 0.35, 0.16, 0.02, false)); 

      // Рассаживаем 3 Максимов внутри деревянного дома в точности как на 3 уровне
      pigs.add(MolluskMaksim(bx2 + 0.06, 0.71 - 0.019));  
      pigs.add(MolluskMaksim(bx2 + 0.17, 0.71 - 0.019));  
      pigs.add(MolluskMaksim(bx2 + 0.12, 0.53 - 0.019));  
    }
    
    // ДОБАВИТЬ В САМЫЙ КОНЕЦ МЕТОДА buildLevelStructures():
hasWantedPoster = false;
showWantedBig = false;
wantedAnimTimer = 0.0;
wantedAttachedBlockIndex = -1;

if (currentLevel == 2 || currentLevel == 3) {
  // Жесткие 20% шанса при каждом заходе или рестарте
  if (Random().nextDouble() < 0.20) {
    hasWantedPoster = true;
    
    // Ищем подходящую балку на уровне
    for (int i = 0; i < blocks.length; i++) {
      final b = blocks[i];
      // На 2 уровне крепим к деревянной вертикальной балке, на 3 — к каменной
      if (currentLevel == 2 && !b.isStone && b.h > b.w) {
        wantedAttachedBlockIndex = i;
        break;
      }
      if (currentLevel == 3 && b.isStone && b.h > b.w) {
        wantedAttachedBlockIndex = i;
        break;
      }
    }
  }
}

    spawnCompleted = true;
  }

  void loadNextBird() {
    if (birdsQueue.isNotEmpty) {
      birdsQueue.removeAt(0);
      if (birdsQueue.isNotEmpty) {
        AudioManager.resetTokensForNextBird(); 
        currentBird = birdsQueue.first;
        currentBird!.position = Offset(0.15, groundY - 0.04);
        currentBird!.isReadyForLaunch = true;
      } else {
        // Птицы просто физически закончились в рогатке. 
        // Игра сама проверит итог в методе update, когда все блоки и свиньи затихнут!
        currentBird = null; 
      }
    }
  }

    @override
  void update(double dt) {
    
    // ДОБАВИТЬ В НАЧАЛО МЕТОДА update(double dt):
if (showWantedBig) {
  wantedAnimTimer += dt;
  if (wantedAnimTimer >= 6.0) {
    showWantedBig = false; // Через 6 секунд плакат улетает насовсем
  }
}

// Если балка, на которой висел плакат, зашевелилась или сломалась — плакат падает в воду
if (hasWantedPoster && wantedAttachedBlockIndex != -1 && !showWantedBig) {
  final b = blocks[wantedAttachedBlockIndex];
  if (b.isBroken || b.shouldRemove || !b.isSleeping) {
    hasWantedPoster = false; // Плакат уничтожен лавиной вместе с домом
  } else {
    // Плакат намертво приклеен к координатам балки
    wantedPosterX = b.x + b.w / 2 - 0.01;
    wantedPosterY = b.y + b.h / 2 - 0.02;
  }
}
  
      
      // ИСПРАВЛЕНО: На 1 уровне крутим таймер летящей в экран шляпы шерифа
   if (currentLevel == 1 && hatAnimTimer < 3.5) {
     hatAnimTimer += dt;
   }
      
      if (canvasSize.x == 0 || canvasSize.y == 0) return;
    super.update(dt);
    if (isPaused) return;

    // Анимация облаков и солнца
    sunRotation += 0.3 * dt;
    cloudOffset1 += 0.015 * dt;
    cloudOffset2 += 0.008 * dt;

              if (currentBird != null && currentBird!.isLaunched) {
        if (currentLevel == 4 && currentBird!.isInLoopRotation) {
          // Сама игра уменьшает статическую пачку таблеток ровно в момент проката
          if (currentBird!.loopAngle >= 0.85 * pi && currentBird!.loopAngle <= 1.05 * pi && AngryMolluskGame.pillsRemaining > 0) {
            AngryMolluskGame.pillsRemaining--; 
          }
        }

        // Сама игра крутит таймер кислоты, только если Ваня РЕАЛЬНО съел таблетку
        if (currentLevel == 4 && currentBird!.isAngryMode) {
          acidBackgroundTimer += dt;
        }

        currentBird!.update(dt, blocks, pigs, groundY, currentLevel);


        
        // Если птица отработала заряд или разбилась насмерть — гасим звук ярости на месте
        if (currentBird!.shouldRemove) {
          if (currentLevel == 4 && currentBird!.isAngryMode) {
            AudioManager.stopRage(); // Глушим гул таблетки мгновенно
          }
          loadNextBird(); // Загружаем следующую птицу у рогатки
        }
      }




    // Обновление блоков замка и начисление очков
    for (var block in blocks) {
      block.update(dt, blocks, pigs, groundY, this);
      if (block.shouldRemove) {
        AngryMolluskGame.score += block.isStone ? 30 : 20;
      }
    }
    blocks.removeWhere((b) => b.shouldRemove);

    // Обновление свиней Максимов
    for (var pig in pigs) {
      pig.update(dt, blocks, groundY);
    }
    // КРИТИЧЕСКИЙ ФИКС: Удаляем убитых свиней строго ДО проверки победы!
    pigs.removeWhere((p) => p.shouldRemove);

   // =========================================================================
    // ТРИГГЕРЫ ДОСТИЖЕНИЙ (ПЕРВАЯ КРОВЬ И СНАЙПЕР)
    // =========================================================================
    
    // 1. ПЕРВАЯ КРОВЬ: Если на 1 уровне массив свиней уменьшился (кто-то погиб)
    if (spawnCompleted && currentLevel == 1 && pigs.length < 3) {
      SharedPreferences.getInstance().then((prefs) async {
        final alreadyUnlocked = prefs.getBool('achievement_first_blood') ?? false;
        if (!alreadyUnlocked) {
          await prefs.setBool('achievement_first_blood', true);
          AudioManager.playAchievement(); // Бахает сочный победный звук фанфар!
          overlays.add('AchievementToast'); // Показывает тост на экране боя
          
          // Автоматически прячем тост ровно через 5 секунд
          Future.delayed(const Duration(seconds: 5), () {
            overlays.remove('AchievementToast'); 
          });
        }
      });
    }


     
    // 3. ИСПРАВЛЕНО: ТРИУМФ (Если прямо сейчас игрок победил и потенциально набрал 9 звёзд)
    if (spawnCompleted && pigs.isEmpty && !levelFailed && !levelCleared && !isVictorySequenceStarted) {
      // Считаем текущие звёзды за этот раунд ДО сохранения
      int currentRoundStars = 0;
      if (AngryMolluskGame.score >= targetScore3Stars) currentRoundStars = 3;
      else if (AngryMolluskGame.score >= targetScore2Stars) currentRoundStars = 2;
      else if (AngryMolluskGame.score >= targetScore1Star) currentRoundStars = 1;

      SharedPreferences.getInstance().then((prefs) async {
        // Читаем старые рекорды остальных уровней
        int s1 = currentLevel == 1 ? currentRoundStars : (prefs.getInt('level_1_stars') ?? 0);
        int s2 = currentLevel == 2 ? currentRoundStars : (prefs.getInt('level_2_stars') ?? 0);
        int s3 = currentLevel == 3 ? currentRoundStars : (prefs.getInt('level_3_stars') ?? 0);
        
        // Если суммарно набралось 9 звёзд
        if ((s1 + s2 + s3) >= 9) {
          final alreadyUnlocked = prefs.getBool('achievement_triumph') ?? false;
          if (!alreadyUnlocked) {
            await prefs.setBool('achievement_triumph', true);
            AudioManager.playAchievement(); // Победный дзынь!
            overlays.add('AchievementToast'); // Глянцевая плашка наверх
            
            Future.delayed(const Duration(seconds: 5), () {
              overlays.remove('AchievementToast');
            });
          }
        }
      });
    }
      
      // Живая атмосфера (звуки свиней раз в 9 секунд)
    if (pigs.isNotEmpty && !levelCleared && !levelFailed) {
      _pigSoundTimer += dt;
      if (_pigSoundTimer >= 9.0) {
        _pigSoundTimer = 0.0; 
        if (Random().nextBool()) {
          AudioManager.playPigSnort(); 
        }
      }
    }

    // =========================================================================
    // УМНАЯ СИСТЕМА ОЖИДАНИЯ КОНЦА ВСЕХ ДЕЙСТВИЙ (ФИКС СЧЁТА И АВТОПОРАЖЕНИЯ)
    // =========================================================================
    bool isAnythingMoving = false;
    
    // Проверяем, движется или разрушается ли сейчас хоть один блок
    for (var b in blocks) {
      if (b.isFalling || !b.isSleeping || b.isBroken) {
        isAnythingMoving = true;
        break;
      }
    }
    // Проверяем, катится или падает ли сейчас хоть одна свинья
    for (var p in pigs) {
      if (p.isFalling) {
        isAnythingMoving = true;
        break;
      }
    }

        // LINE: 33
    // ЧЕСТНАЯ ПОБЕДА: Свиньи уничтожены, и ВСЕ блоки/осколки полностью затихли!
    if (spawnCompleted && pigs.isEmpty && !levelCleared && !levelFailed && !isVictorySequenceStarted && !isAnythingMoving) {
      isVictorySequenceStarted = true;
      
      int remainingBirds = birdsQueue.length;

      // ИСПРАВЛЕНО: ВСТАВИЛИ ТРИГГЕР МЕДАЛИ "СНАЙПЕР" СТРОГО СЮДА!
      // Проверяем в момент триумфа: если в очереди осталось ровно 2 птицы, значит потрачена всего одна!
      if (remainingBirds == 2) {
        SharedPreferences.getInstance().then((prefs) async {
          final alreadyUnlocked = prefs.getBool('achievement_sniper') ?? false;
          if (!alreadyUnlocked) {
            await prefs.setBool('achievement_sniper', true);
            AudioManager.playAchievement(); // Звук фанфар
            overlays.add('AchievementToast'); // Вылетает синяя плашка
            
            // Прячем плашку ровно через 5 секунд
            Future.delayed(const Duration(seconds: 5), () {
              overlays.remove('AchievementToast');
            });
          }
        });
      }

      AngryMolluskGame.score += remainingBirds * 70;  
      
      int currentStars = 0;
      if (AngryMolluskGame.score >= targetScore3Stars) currentStars = 3;
      else if (AngryMolluskGame.score >= targetScore2Stars) currentStars = 2;
      else if (AngryMolluskGame.score >= targetScore1Star) currentStars = 1;

      // Динамическое сохранение рекорда под текущий уровень в SharedPreferences
      SharedPreferences.getInstance().then((prefs) async {
        int savedStars = prefs.getInt('level_${currentLevel}_stars') ?? 0;
        if (currentStars > savedStars) {
          await prefs.setInt('level_${currentLevel}_stars', currentStars);
        }
      });

      levelCleared = true;
      AudioManager.playVictory(); 

      // Плавная задержка перед оверлеем, чтобы SCORE зафиксировал финальную цифру
      Future.delayed(const Duration(milliseconds: 200), () {
        overlays.add('VictoryMenu');
      });
      return;
    }


    // ЧЕСТНОЕ ПОРАЖЕНИЕ: Птицы кончились, всё остановилось, а свиньи ВЫЖИЛИ!
    if (spawnCompleted && currentBird == null && birdsQueue.isEmpty && pigs.isNotEmpty && 
        !levelCleared && !levelFailed && !isVictorySequenceStarted && !isAnythingMoving) {
      
      levelFailed = true;
      AudioManager.playGameOver();
      overlays.add('GameOverMenu');
      return;
    }
  }

    @override
  void render(Canvas canvas) {
    final size = canvasSize.toSize();
    
    canvas.save(); // ЗАЩИТА: Сохраняем состояние холста, чтобы экран НЕ чернел!
    
    // Сдвигаем холст на величину нашего скролла пальцем
    canvas.translate(size.width * worldScrollX, 0);

        final double worldWidthFactor = currentLevel == 1 ? 1.0 : (currentLevel == 2 ? 1.8 : 2.0);

    // ИСПРАВЛЕНО: КИСЛОТНОЕ НЕБО С БЛИКАМИ ПРИ АКТИВАЦИИ ТАБЛЕТКИ!
    Paint skyPaint;
    if (currentLevel == 4 && currentBird != null && currentBird!.isAngryMode) {
      // Генерируем сумасшедшие неоновые поп-арт цвета на основе синуса времени
      double hueFactor = (sin(acidBackgroundTimer * 6.0) + 1.0) / 2.0; 
      Color colorTop = Color.lerp(const Color(0xFFD500F9), const Color(0xFF00E676), hueFactor)!; // Ярко-фиолетовый в кислотно-зеленый
      Color colorBottom = Color.lerp(const Color(0xFFFF1744), const Color(0xFF2979FF), hueFactor)!; // Бешеный розовый в неоново-синий

      skyPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colorTop, colorBottom],
        ).createShader(Rect.fromLTWH(0, 0, size.width * worldWidthFactor, size.height));
    } else {
      // Обычное красивое мультяшное небо для остальных уровней
      skyPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade300, Colors.lightBlue.shade100],
        ).createShader(Rect.fromLTWH(0, 0, size.width * worldWidthFactor, size.height));
    }
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width * worldWidthFactor, size.height), skyPaint);

    // ИСПРАВЛЕНО: СВЕТОВЫЕ БЛИКИ НА НЕБЕ ДЛЯ ТРЭШ-ЭФФЕКТА ТАБЛЕТКИ
    if (currentLevel == 4 && currentBird != null && currentBird!.isAngryMode) {
      final glarePaint = Paint()..color = Colors.white.withOpacity(0.15)..style = PaintingStyle.fill;
      for (int i = 0; i < 4; i++) {
        double offsetX = (size.width * 0.3 * i) + sin(acidBackgroundTimer * 4 + i) * 60;
        final path = Path()
          ..moveTo(offsetX, 0)
          ..lineTo(offsetX + 60, 0)
          ..lineTo(offsetX - 40, size.height)
          ..lineTo(offsetX - 100, size.height)
          ..close();
        canvas.drawPath(path, glarePaint);
      }
    }


    // Солнце (рисуется на фоне)
    canvas.save();
    final sunCenter = Offset(size.width * 0.15, size.height * 0.2);
    final sunRadius = size.height * 0.08;
    canvas.translate(sunCenter.dx, sunCenter.dy);
    canvas.rotate(sunRotation);
    canvas.drawCircle(Offset.zero, sunRadius, Paint()..color = const Color(0xFFFFF176));
    final rayPaint = Paint()..color = const Color(0xFFFFF59D)..style = PaintingStyle.stroke..strokeWidth = 3;
    for (int i = 0; i < 8; i++) {
      canvas.rotate(pi / 4);
      canvas.drawLine(Offset(sunRadius + 5, 0), Offset(sunRadius + 20, 0), rayPaint);
    }
    canvas.restore();

    // Облака летают по всей ширине фона
    final cloudPaint = Paint()..color = Colors.white.withOpacity(0.85);
    double c1X = (size.width * 0.3 + cloudOffset1 * size.width) % (size.width * worldWidthFactor + 200) - 100;
    canvas.drawCircle(Offset(c1X, size.height * 0.15), 30, cloudPaint);
    canvas.drawCircle(Offset(c1X + 35, size.height * 0.12), 42, cloudPaint);
    canvas.drawCircle(Offset(c1X + 75, size.height * 0.15), 32, cloudPaint);

    // Вода и океан тянутся до самого края фона уровня
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.83, size.width * worldWidthFactor, size.height * 0.02), Paint()..color = const Color(0xFF29B6F6));
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.85, size.width * worldWidthFactor, size.height * 0.15), Paint()..color = const Color(0xFF0288D1));

    // Острова суши встают на свои места
    _renderIsland(canvas, size, 0.0, 0.25); // Островок рогатки
    
    if (currentLevel == 1) {
      _renderIsland(canvas, size, 0.55, 1.0); 
    } else if (currentLevel == 2) {
      _renderIsland(canvas, size, 1.28, 1.75); 
    } else if (currentLevel == 3 || currentLevel == 4) {
      // ИСПРАВЛЕНО: На 4 уровне земля и трава второго острова теперь отрисовываются на 100%!
      _renderIsland(canvas, size, 1.15, 1.95); 
    }


    // 6. КРАСНАЯ РЕЗИНКА РОГАТКИ (Отрисовывается ВСЕГДА до выстрела)
    final slingBaseX = size.width * 0.15;
    final slingTopY = size.height * (groundY - 0.08);
    final leftHorn = Offset(slingBaseX - 12, slingTopY);
    final rightHorn = Offset(slingBaseX + 12, slingTopY);
    final paintRubber = Paint()..color = const Color(0xFFD32F2F)..strokeWidth = 5.0;

    if (currentBird != null && !currentBird!.isLaunched) {
      final birdScreenPos = Offset(size.width * currentBird!.position.dx, size.height * currentBird!.position.dy);
      canvas.drawLine(leftHorn, birdScreenPos, paintRubber);
      canvas.drawLine(rightHorn, birdScreenPos, paintRubber);
    }

    // 7. СЛИНГШОТ С НАДЁЖНЫМ КРЕПЛЕНИЕМ НА ТРАВЕ
    final paintSlingshot = Paint()..color = const Color(0xFF4E342E)..strokeWidth = 8.0;
    final paintSlingshotHighlight = Paint()..color = const Color(0xFF8D6E63)..strokeWidth = 2.5;
    final groundScreenY = size.height * groundY;
    canvas.drawLine(Offset(slingBaseX, groundScreenY), Offset(slingBaseX, slingTopY + 15), paintSlingshot);
    canvas.drawLine(Offset(slingBaseX, groundScreenY), Offset(slingBaseX, slingTopY + 15), paintSlingshotHighlight);
    canvas.drawLine(Offset(slingBaseX, slingTopY + 15), leftHorn, paintSlingshot);
    canvas.drawLine(Offset(slingBaseX, slingTopY + 15), rightHorn, paintSlingshot);

        // ИСПРАВЛЕНО: Компактная петля у неба, зев направлен строго вниз на воду (края равны!)
    if (currentLevel == 4) {
      // Вернули петлю на место — наверх в облака (высота 0.25)
      final loopCenter = Offset(0.78 * size.width, 0.25 * size.height);
      final loopRadius = size.height * 0.15; 
      
      final loopPaint = Paint()
        ..color = const Color(0xFF795548) // Деревянный каркас
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12.0
        ..strokeCap = StrokeCap.round; // Красивые круглые края балок
        
      final trackPaint = Paint()
        ..color = const Color(0xFF4E342E) // Полотно трека разгона
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round;

      // ИСПРАВЛЕНО: Линия дырки параллельна воде и смотрит строго вниз!
      // Диапазон от 0.85*pi до 2.15*pi делает левую и правую стороны абсолютно равными
      final loopRect = Rect.fromCircle(center: loopCenter, radius: loopRadius);
      canvas.drawArc(loopRect, 0.85 * pi, 1.3 * pi, false, loopPaint);
      canvas.drawArc(Rect.fromCircle(center: loopCenter, radius: loopRadius - 4), 0.85 * pi, 1.3 * pi, false, trackPaint);

            // ИСПРАВЛЕНО: Проверяем таблетки через статический вызов AngryMolluskGame.pillsRemaining
      if (AngryMolluskGame.pillsRemaining > 0) {
        final pillPaint = Paint()..color = const Color(0xFF29B6F6); 
        final pillBorder = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1.0;
        
        // ИСПРАВЛЕНО: В цикле тоже читаем статическую переменную класса
        for (int i = 0; i < AngryMolluskGame.pillsRemaining; i++) {
          // Таблетки висят на верхнем внутреннем своде
          double angle = (pi * 1.1) + (i * 0.35);
          Offset pillPos = Offset(loopCenter.dx + cos(angle) * (loopRadius - 12), loopCenter.dy + sin(angle) * (loopRadius - 12));
          
          canvas.drawCircle(pillPos, 6.0, pillPaint);
          canvas.drawCircle(pillPos, 6.0, pillBorder);
          
          final tp = TextPainter(
            text: const TextSpan(text: 'V', style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: Colors.white)),
            textDirection: TextDirection.ltr,
          )..layout();
          tp.paint(canvas, pillPos + const Offset(-2.5, -4.5));
        }
      }
    }




      
      // 8. ИСПРАВЛЕНО: ОТРИСОВКА ВСЕХ ОБЪЕКТОВ С УМНОЙ ПРОВЕРКОЙ НА СУНДУК, ЖЕЛЕЗО И БРОНЕСТЕКЛО
    for (var block in blocks) {
      if (block.isSecretChest) {
        // Отрисовка кастомного сундука с твоей картинки (с замком и открыванием!)
        final boxRect = Rect.fromLTWH(block.x * size.width, block.y * size.height, block.w * size.width, block.h * size.height);
        final woodPaint = Paint()..color = const Color(0xFFD84315);
        final goldPaint = Paint()..color = const Color(0xFFFFD54F);
        final lockPaint = Paint()..color = const Color(0xFFFFB300);
        final darkInside = Paint()..color = const Color(0xFF1A0A0A);
        final borderPaint = Paint()..color = const Color(0xFF5D4037)..style = PaintingStyle.stroke..strokeWidth = 1.5;

        if (!block.chestCapturedBird) {
          // 🧰 А) ЗАКРЫТЫЙ СУНДУК С КАРТИНКИ
          canvas.drawRect(boxRect, woodPaint);
          canvas.drawRect(boxRect, borderPaint);
          canvas.drawRect(Rect.fromLTWH(boxRect.left, boxRect.top, boxRect.width, 4), goldPaint);
          canvas.drawRect(Rect.fromLTWH(boxRect.left, boxRect.bottom - 4, boxRect.width, 4), goldPaint);
          canvas.drawRect(Rect.fromLTWH(boxRect.left, boxRect.top, 4, boxRect.height), goldPaint);
          canvas.drawRect(Rect.fromLTWH(boxRect.right - 4, boxRect.top, 4, boxRect.height), goldPaint);
          canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: boxRect.center, width: 14, height: 16), const Radius.circular(3)), lockPaint);
          canvas.drawCircle(boxRect.center, 2.5, Paint()..color = const Color(0xFF3E2723));
        } else {
          // 🔓 Б) ОТКРЫТЫЙ СУНДУК С КАРТИНКИ (Крышка откинута назад)
          final bottomRect = Rect.fromLTWH(boxRect.left, boxRect.top + boxRect.height * 0.4, boxRect.width, boxRect.height * 0.6);
          canvas.drawRect(bottomRect, woodPaint);
          canvas.drawRect(bottomRect, borderPaint);
          final topRect = Rect.fromLTWH(boxRect.left, boxRect.top - boxRect.height * 0.2, boxRect.width, boxRect.height * 0.4);
          canvas.drawRect(topRect, woodPaint);
          canvas.drawRect(topRect, borderPaint);
          canvas.drawRect(Rect.fromLTWH(boxRect.left + 4, boxRect.top + 2, boxRect.width - 8, boxRect.height * 0.35), darkInside);
          canvas.drawRect(Rect.fromLTWH(bottomRect.left, bottomRect.bottom - 4, bottomRect.width, 4), goldPaint);
          canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: bottomRect.topCenter + const Offset(0, 8), width: 14, height: 14), const Radius.circular(3)), lockPaint);
        }

        // ИСПРАВЛЕНО: РИСУЕМ НАСТОЯЩУЮ КРАБЬЮ КЛЕШНЮ, КАК НА МЕДАЛИ, ИЗ ЦЕНТРА СУНДУКА!
        if (block.chestCapturedBird && block.chestAnimTimer < 1.5) {
          canvas.save();
          // Сдвигаем холст к верхней части открытого сундука
          canvas.translate(boxRect.center.dx - 20, boxRect.top - 25);
          
          double openFactor = sin(block.chestAnimTimer * pi * 2).abs();
          
          // Вызываем CrabClawPainter, который мы сейчас добавим прямо в этот файл!
          CrabClawPainter(openFactor: openFactor).paint(canvas, const Size(40, 50));
          
          canvas.restore();
        }
      } else if (block.isIronShield) {
        // 🧱 Отрисовка железных ворот серебристым цветом с заклёпками
        final boxRect = Rect.fromLTWH(block.x * size.width, block.y * size.height, block.w * size.width, block.h * size.height);
        final ironPaint = Paint()..color = const Color(0xFFB0BEC5);
        final borderPaint = Paint()..color = const Color(0xFF37474F)..style = PaintingStyle.stroke..strokeWidth = 2.0;
        canvas.drawRect(boxRect, ironPaint);
        canvas.drawRect(boxRect, borderPaint);
        // Заклёпки по углам железа
        final rivetPaint = Paint()..color = const Color(0xFF455A64);
        canvas.drawCircle(boxRect.topLeft + const Offset(5, 5), 2, rivetPaint);
        canvas.drawCircle(boxRect.topRight + const Offset(-5, 5), 2, rivetPaint);
        canvas.drawCircle(boxRect.bottomLeft + const Offset(5, -5), 2, rivetPaint);
        canvas.drawCircle(boxRect.bottomRight + const Offset(-5, -5), 2, rivetPaint);
      } else if (block.isGlassBlock) {
        // ИСПРАВЛЕНО: КРАСИВОЕ ПОЛУПРОЗРАЧНОЕ НЕОНОВО-ГОЛУБОЕ БРОНЕСТЕКЛО МАКСИМОВ!
        final boxRect = Rect.fromLTWH(block.x * size.width, block.y * size.height, block.w * size.width, block.h * size.height);
        
        // Неоновая полупрозрачная голубая заливка (альфа-канал 0x99)
        final glassPaint = Paint()..color = const Color(0x9900E5FF); 
        final borderPaint = Paint()..color = const Color(0xFF00B0FF)..style = PaintingStyle.stroke..strokeWidth = 2.0;
        
        canvas.drawRect(boxRect, glassPaint);
        canvas.drawRect(boxRect, borderPaint);

        // Мультяшные белые блики по диагонали стекла
        final glarePaint = Paint()..color = Colors.white.withOpacity(0.4)..strokeWidth = 1.5;
        canvas.drawLine(boxRect.bottomLeft + const Offset(4, -4), boxRect.topRight + const Offset(-4, 4), glarePaint);
        
        // Если обычная птица врезалась в стекло и оно затрещало — рисуем сочную паутину трещин!
        if (block.isBroken || block.vx != 0) {
          final crackPaint = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1.2;
          canvas.drawLine(boxRect.center, boxRect.topLeft, crackPaint);
          canvas.drawLine(boxRect.center, boxRect.topRight, crackPaint);
          canvas.drawLine(boxRect.center, boxRect.bottomLeft, crackPaint);
          canvas.drawLine(boxRect.center, boxRect.bottomRight, crackPaint);
        }
      } else {
        // Обычные блоки замка (дерево и камень) рисуются стандартно
        block.render(canvas, size);
      }
    }


    // СВИНЬИ! (Они нарисуются поверх островов и блоков)
    for (var pig in pigs) {
      pig.render(canvas, size, maksimSprite);
    }

      // ДОБАВИТЬ СРАЗУ ПОСЛЕ ЦИКЛА ОТРИСОВКИ СВИНЕЙ:
if (hasWantedPoster && wantedAttachedBlockIndex != -1 && !showWantedBig) {
  final paperPaint = Paint()..color = const Color(0xFFFFF9C4);
  final borderPaint = Paint()..color = const Color(0xFF5D4037)..style = PaintingStyle.stroke..strokeWidth = 1.0;
  
  final smallRect = Rect.fromLTWH(wantedPosterX * size.width, wantedPosterY * size.height, size.width * 0.02, size.height * 0.05);
  canvas.drawRect(smallRect, paperPaint);
  canvas.drawRect(smallRect, borderPaint);
  
  // Маленький жирный красный восклицательный знак на листе
  final tpEx = TextPainter(
    text: const TextSpan(text: '!', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red)),
    textDirection: TextDirection.ltr,
  )..layout();
  tpEx.paint(canvas, Offset(smallRect.left + smallRect.width * 0.35, smallRect.top + smallRect.height * 0.1));
}
   
      
      // ПТИЦА С ТРАЕКТОРИЕЙ! (ИСПРАВЛЕНО: Синий шлейф, шипастая подложка по картинке, звезды и молнии!)
      if (currentBird != null && (!currentBird!.isLaunched || !currentBird!.shouldRemove)) {
        canvas.save();
        
        double birdScreenX = currentBird!.position.dx * size.width;
        double birdScreenY = currentBird!.position.dy * size.height;
        final double birdRadius = (size.height * 0.024);

        if (currentBird!.isAngryMode) {
          // =========================================================================
          // А) АНИМИРОВАННЫЙ СИНИЙ ШЛЕЙФ ЗА СПИНОЙ БАННИХОПА
          // =========================================================================
          final tailPaint = Paint()..color = const Color(0x3300B0FF)..style = PaintingStyle.fill;
          for (int i = 0; i < currentBird!.rageTailPositions.length; i++) {
            double tailX = currentBird!.rageTailPositions[i].dx * size.width;
            double tailY = currentBird!.rageTailPositions[i].dy * size.height;
            double factor = (i + 1) / currentBird!.rageTailPositions.length;
            canvas.drawCircle(Offset(tailX, tailY), birdRadius * 1.5 * factor, tailPaint);
          }

          // =========================================================================
          // Б) КРУТЯЩАЯСЯ РВАНАЯ ПОП-АРТ ПОДЛОЖКА ПО ТВОЕЙ КАРТИНКЕ (ШИПЫ И ОБВОДКА)
          // =========================================================================
          canvas.save();
          canvas.translate(birdScreenX, birdScreenY);
          // Бешено вращаем подложку вокруг Вани Баннихопа!
          canvas.rotate(currentBird!.rageSparkTimer * 12.0); 
          
          // Эффект пульсации: шипы мягко сжимаются и разжимаются от синуса времени
          double pulse = 1.0 + (sin(currentBird!.rageSparkTimer * 15.0) * 0.08);

          final auraFill = Paint()..color = const Color(0xFF00E5FF)..style = PaintingStyle.fill; // Ярко-голубой поп-арт
          final auraBorder = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2.5;

          // Рисуем рваную шипастую многоконечную звезду с фотографии через Path
          final auraPath = Path();
          int spikeCount = 12; // 12 острых шипов по кругу
          for (int i = 0; i < spikeCount; i++) {
            double angle = (i * pi * 2) / spikeCount;
            // Чередуем длинные шипы и короткие впадины, создавая рваный комиксный взрыв с фото!
            double currentRadius = (i % 2 == 0 ? birdRadius * 2.2 : birdRadius * 1.4) * pulse;
            
            double x = cos(angle) * currentRadius;
            double y = sin(angle) * currentRadius;
            if (i == 0) auraPath.moveTo(x, y); else auraPath.lineTo(x, y);
          }
          auraPath.close();
          canvas.drawPath(auraPath, auraFill);
          canvas.drawPath(auraPath, auraBorder);

         // В) ИСПРАВЛЕНО: ХАОТИЧНЫЕ НЕОНОВО-СИНИЕ ЭЛЕКТРИЧЕСКИЕ РАЗРЯДЫ (УКОРОЧЕНЫ В УПОР К ШИПАМ!)
            
            final sparkPaint = Paint()
            ..color = const Color(0xFF00E5FF) // Ярко-голубой/синий неон вместо белого
            ..strokeWidth = 2.0
            ..style = PaintingStyle.stroke;

          final rand = Random((currentBird!.rageSparkTimer * 80).toInt());
          for (int i = 0; i < 4; i++) {
            double sparkAngle = rand.nextDouble() * pi * 2;
            double startX = cos(sparkAngle) * (birdRadius * 2.2);
            double startY = sin(sparkAngle) * (birdRadius * 2.2);
            
            final sparkPath = Path()..moveTo(startX, startY);
            double cx = startX; double cy = startY;
            
            for (int step = 0; step < 2; step++) {
              cx += cos(sparkAngle) * 6 + (rand.nextDouble() * 4 - 2);
              cy += sin(sparkAngle) * 6 + (rand.nextDouble() * 4 - 2);
              sparkPath.lineTo(cx, cy);
            }
            canvas.drawPath(sparkPath, sparkPaint);
          }
          canvas.restore();

          // =========================================================================
          // Г) ВЫЛЕТАЮЩИЕ МАЛЕНЬКИЕ ЖЁЛТЫЕ ЗВЁЗДОЧКИ С КРАЁВ АУРЫ ПО ФОТОГРАФИИ
          // =========================================================================
          final starPaint = Paint()..color = const Color(0xFFFFD54F)..style = PaintingStyle.fill;
          final starBorder = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 0.8;
          final starRand = Random((currentBird!.rageSparkTimer * 40).toInt());
          
          for (int i = 0; i < 3; i++) {
            // Звёзды вылетают из зоны подложки и плавно смещаются назад против вектора движения
            double starAngle = starRand.nextDouble() * pi * 2;
            double distanceFactor = birdRadius * (1.8 + starRand.nextDouble() * 1.5);
            Offset starPos = Offset(
              birdScreenX + cos(starAngle) * distanceFactor - (currentBird!.velocity.dx * 40 * starRand.nextDouble()),
              birdScreenY + sin(starAngle) * distanceFactor + (starRand.nextDouble() * 15 - 7.5),
            );

            // Рисуем классическую четырехконечную маленькую мультяшную звёздочку с картинки
            final starPath = Path()
              ..moveTo(starPos.dx, starPos.dy - 5)
              ..lineTo(starPos.dx + 1.5, starPos.dy - 1.5)
              ..lineTo(starPos.dx + 5, starPos.dy)
              ..lineTo(starPos.dx + 1.5, starPos.dy + 1.5)
              ..lineTo(starPos.dx, starPos.dy + 5)
              ..lineTo(starPos.dx - 1.5, starPos.dy + 1.5)
              ..lineTo(starPos.dx - 5, starPos.dy)
              ..lineTo(starPos.dx - 1.5, starPos.dy - 1.5)
              ..close();
            canvas.drawPath(starPath, starPaint);
            canvas.drawPath(starPath, starBorder);
          }
        }

        // Отрисовываем саму Ваня-птицу поверх всей этой безумной неоновой дискотеки
        currentBird!.render(canvas, size, bunnySprite);
        canvas.restore();
      }




    // ОТОБРАЖЕНИЕ СЧЁТЧИКА ОЧКОВ (В правом верхнем углу)
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'SCORE: $score',
        style: TextStyle(
          fontFamily: 'Arial',
          fontSize: size.width * 0.035,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFFFD54F),
          shadows: const [Shadow(offset: Offset(2, 2), blurRadius: 3.0, color: Colors.black87)],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width * 0.8, size.height * 0.05));

    // ОТОБРАЖЕНИЕ ОСТАВШИХСЯ ПТИЦ В ЛЕВОМ НИЖНЕМ УГЛУ
    final int birdsCount = birdsQueue.length;
    final birdsPainter = TextPainter(
      text: TextSpan(
        text: 'BIRDS: $birdsCount',
        style: TextStyle(
          fontSize: size.width * 0.032,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFE53935),
          shadows: const [Shadow(offset: Offset(1.5, 1.5), blurRadius: 2.0, color: Colors.black87)],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    birdsPainter.layout();
    birdsPainter.paint(canvas, Offset(size.width * 0.05, size.height * 0.88));
    
        // ИСПРАВЛЕНО: Теперь на холст вылетает НАСТОЯЩАЯ фотография из памяти, а не чёрный квадрат!
    if (showFlyingLosePhoto) {
      canvas.save();
      double chestScreenX = 1.65 * size.width;
      double chestScreenY = 0.55 * size.height;

      canvas.translate(chestScreenX, chestScreenY);
      canvas.scale(losePhotoScale); 

      try {
        // Достаём загруженную картинку напрямую из кэша Flame
        final loseImage = images.fromCache('bunnyhop_lose.png');

        // Задаём фиксированный размер фотографии
        double photoW = size.width * 0.45;
        double photoH = size.width * 0.45;

        // Центрируем картинку и рисуем её на игровом поле
        final srcRect = Rect.fromLTWH(0, 0, loseImage.width.toDouble(), loseImage.height.toDouble());
        final dstRect = Rect.fromCenter(center: Offset.zero, width: photoW, height: photoH);

        canvas.drawImageRect(loseImage, srcRect, dstRect, Paint()..filterQuality = FilterQuality.high);
      } catch (e) {
        // Подстраховка на случай сбоя
        canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: 200, height: 200), Paint()..color = Colors.red);
      }
      canvas.restore();
    }

        // =========================================================================
    // ИСПРАВЛЕНО: КРУТОЙ 3D-ВЫЛЕТ ШЛЯПЫ ШЕРИФА СКВОЗЬ ЭКРАН В ЛИЦО ИГРОКУ! (1 УРОВЕНЬ)
    // =========================================================================
    if (currentLevel == 1 && hatAnimTimer < 2.2) {
      canvas.save();

      double scale = 1.0;
      double offsetX = size.width * 0.5;
      double offsetY = size.height * 0.5;
      double rotation = 0.0;
      double opacity = 1.0;

      if (hatAnimTimer <= 1.0) {
        // ФАЗА 1: Шляпа стремительно летит из глубины рогатки к центру стекла экрана
        double progress = hatAnimTimer / 1.0;
        scale = 0.1 + (3.4 * progress); // Увеличивается до нормального размера
        offsetX = (0.15 * size.width) + ((0.5 * size.width) - (0.15 * size.width)) * progress;
        offsetY = (0.65 * size.height) - ((0.65 * size.height) - (0.5 * size.height)) * progress;
        rotation = progress * pi * 3; // Крутится в полёте
      } else if (hatAnimTimer > 1.0 && hatAnimTimer <= 1.4) {
        // ФАЗА 2: Шляпа с сочным звуком ПРИЛИПАЕТ К СТЕКЛУ изнутри экрана!
        double progress = (hatAnimTimer - 1.0) / 0.4;
        scale = 3.5 + (1.5 * progress); // Слегка пружинит на стекле
        offsetX = size.width * 0.5;
        offsetY = size.height * 0.5;
        rotation = 0.0;

        if (!isHatSplatSoundPlayed) {
          isHatSplatSoundPlayed = true;
          AudioManager.playHatSplat(); // Железно бахает шлепок о стекло!
        }
      } else if (hatAnimTimer > 1.4 && hatAnimTimer <= 2.2) {
        // ФАЗА 3: Шляпа вылетает ИЗ ЭКРАНА прямо в лицо игроку (пролетая сквозь четвертую стену!)
        double progress = (hatAnimTimer - 1.4) / 0.8;
        // Масштаб раздувается до гигантских 22.0 масштабов, пролетая мимо глаз!
        scale = 5.0 + (17.0 * progress); 
        offsetX = size.width * 0.5;
        offsetY = size.height * 0.5;
        rotation = sin(progress * pi) * 0.1; // Легкое покачивание перед лицом
        opacity = (1.0 - progress).clamp(0.0, 1.0); // Полностью растворяется в воздухе, улетая сквозь экран
      }

      // Смещаем холст в точку 3D-анимации шляпы
      canvas.translate(offsetX, offsetY);
      canvas.scale(scale);
      canvas.rotate(rotation);

      // Рисуем ковбойскую шляпу шерифа стороной со звездой
      final hatPaint = Paint()..color = const Color(0xFF795548).withValues(alpha: opacity);
      final brimPaint = Paint()..color = const Color(0xFF6D4C41).withValues(alpha: opacity);
      final strapPaint = Paint()..color = const Color(0xFF212121).withValues(alpha: opacity);
      final borderPaint = Paint()..color = Colors.black.withValues(alpha: opacity)..style = PaintingStyle.stroke..strokeWidth = 0.5;

      // 1. Ковбойская тулья
      final hatRect = Rect.fromLTWH(-8, -12, 16, 11);
      canvas.drawRRect(RRect.fromRectAndRadius(hatRect, const Radius.circular(3)), hatPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(hatRect, const Radius.circular(3)), borderPaint);

      // 2. Скругленные ковбойские поля шляпы
      final brimRect = Rect.fromLTWH(-16, -2, 32, 3);
      canvas.drawRRect(RRect.fromRectAndRadius(brimRect, const Radius.circular(1.5)), brimPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(brimRect, const Radius.circular(1.5)), borderPaint);

      // 3. Плетёный чёрный ремешок вдоль полей
      final strapRect = Rect.fromLTWH(-7.5, -3.5, 15, 1.2);
      canvas.drawRect(strapRect, strapPaint);

      // 4. Серебряная звезда шерифа по центру тульи
      final starPaint = Paint()..color = Colors.blueGrey.shade100.withValues(alpha: opacity);
      final starPath = Path()
        ..moveTo(0, -11)
        ..lineTo(1.5, -8)
        ..lineTo(4.5, -8)
        ..lineTo(2, -6)
        ..lineTo(3.5, -3)
        ..lineTo(0, -5)
        ..lineTo(-3.5, -3)
        ..lineTo(-2, -6)
        ..lineTo(-4.5, -8)
        ..lineTo(-1.5, -8)
        ..close();
      canvas.drawPath(starPath, starPaint);
      canvas.drawPath(starPath, borderPaint);
      
      // Металлическая печать-заклёпка по центру шерифской звезды
      final centerPaint = Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: opacity);
      canvas.drawCircle(const Offset(0, -7), 1.0, centerPaint);

      canvas.restore();
    }

    // ЗАМЕНИТЬ ОТРЕЗОК ОТРИСОВКИ showWantedBig ВНУТРИ МЕТОДА render() НА ЭТОТ КОРРЕКТНЫЙ ВАРИАНТ:
if (showWantedBig) {
  canvas.save();
  
  // Рассчитываем стартовую координату острова с замком Максимов
  double islandStart = currentLevel == 1 ? 0.55 : (currentLevel == 2 ? 1.28 : 1.15);
  
  // Формула сдвига: на 1 уровне — по центру экрана, на 2 и 3 уровнях — строго с левой стороны здания над водой!
  double targetX = currentLevel == 1 
      ? size.width / 2 
      : (islandStart - 0.20) * size.width; // Сдвигаем на 20% левее постройки, чётко над океаном
      
  double targetY = size.height / 2; // Высота остаётся центральной для лучшего обзора

  canvas.translate(targetX, targetY);
  
  double scale = 1.0;
  if (wantedAnimTimer < 0.4) {
    scale = (wantedAnimTimer / 0.4) * 1.0;
  } else if (wantedAnimTimer > 5.5) {
    scale = 1.0 - ((wantedAnimTimer - 5.5) / 0.5);
  }
  canvas.scale(scale);

  final posterSize = Size(size.width * 0.30, size.height * 0.85);
  WantedPosterPainter(animTimer: wantedAnimTimer).paint(canvas, posterSize);

  canvas.restore();
}


    canvas.restore();
    }

         @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    
 // ЗАМЕНИТЬ БЛОК КЛИКА ПО БУМАЖКЕ ВНУТРИ МЕТОДА onDragStart НА ЭТОТ ИСПРАВЛЕННЫЙ:
if (hasWantedPoster && !showWantedBig) {
  double clickX = event.localPosition.x / canvasSize.x - worldScrollX;
  double clickY = event.localPosition.y / canvasSize.y;
  
  if ((clickX - wantedPosterX).abs() < 0.04 && (clickY - wantedPosterY).abs() < 0.06) {
    hasWantedPoster = false; 
    showWantedBig = true;    
    wantedAnimTimer = 0.0;
    
    // ИСПРАВЛЕНО: Вместо фанфар теперь играет реалистичный шелест разворачивания бумаги!
    AudioManager.playPaperRustle(); 
    return; 
  }
}


      // ИСПРАВЛЕНО: Во Flame 1.38+ начальная точка считывается через localPosition!
    double startX = event.localPosition.x / canvasSize.x;
    
    // Если игрок нажал в левой части экрана (в районе рогатки, где x < 0.3)
    if (currentBird != null && currentBird!.isReadyForLaunch && !currentBird!.isLaunched && startX < 0.3) {
      isAiming = true; // Включаем режим прицеливания!
      AudioManager.playStretch(); 
    } else {
      isAiming = false; // Игрок нажал мимо рогатки — значит, он хочет скроллить мир!
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    // 1. РЕЖИМ ПРИЦЕЛИВАНИЯ: Работает только если мы коснулись рогатки в самом начале!
    if (isAiming && currentBird != null && currentBird!.isReadyForLaunch && !currentBird!.isLaunched) {
      double touchX = event.localEndPosition.x / canvasSize.x;
      double touchY = event.localEndPosition.y / canvasSize.y;
      
      final slingX = 0.15;
      final slingY = groundY - 0.07;
      
      double dx = touchX - slingX;
      double dy = touchY - slingY;
      double dist = sqrt(dx * dx + dy * dy);
      
      if (dist > 0.12) {
        touchX = slingX + (dx / dist) * 0.12;
        touchY = slingY + (dy / dist) * 0.12;
      }
      currentBird!.position = Offset(touchX, touchY);
    } 

          // 2. РЕЖИМ СКРОЛЛА: Включается, если первое нажатие было мимо рогатки
    else if (!isAiming) {
      // ИСПРАВЛЕНО: КЛИК ПО ЖЕЛЕЗУ. Считаем, куда нажал игрок с учётом сдвига камеры worldScrollX
      double clickX = event.localEndPosition.x / canvasSize.x - worldScrollX;
      
      // Если это 1 уровень и палец попал прямо в зону железного заслона (1.35)
      if (currentLevel == 1 && (clickX - 1.35).abs() < 0.1) {
        blocks.removeWhere((b) => b.isIronShield); // Ломаем железные ворота пальцем!
        AudioManager.playBlockBreak(true); // Издаём сочный каменный/железный грохот
      }

      worldScrollX += event.localDelta.x / canvasSize.x;
      
      // ИСПРАВЛЕНО: На 1 уровне раздвигаем лимит скролла до -0.9, чтобы доехать камерой до сундука!
      double minScroll = currentLevel == 3 ? -1.0 : (currentLevel == 1 ? -0.9 : -0.8);

      if (worldScrollX > 0.0) worldScrollX = 0.0; 
      if (worldScrollX < minScroll) worldScrollX = minScroll; 
    }

  }
  
  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    
    // Выстрел происходит ТОЛЬКО если мы реально целились рогаткой
    if (isAiming && currentBird != null && currentBird!.isReadyForLaunch && !currentBird!.isLaunched) {
      AudioManager.stopStretch(); 
      AudioManager.playLaunch();  
      currentBird!.launch(0.15, groundY - 0.07);
    }
    
    // В конце любого перетаскивания сбрасываем флаг прицеливания
    isAiming = false;
  }

    void _renderIsland(Canvas canvas, Size size, double startPct, double endPct) {
    final startX = size.width * startPct;
    final endX = size.width * endPct;
    final topY = size.height * groundY;
    final bottomY = size.height * 0.83;

    // Коричневая скала
    canvas.drawRect(Rect.fromLTRB(startX, topY, endX, bottomY), Paint()..color = const Color(0xFF6D4C41));

    // Прослойки темной земли для детализации
    final layerPaint = Paint()..color = const Color(0xFF4E342E)..strokeWidth = 3;
    canvas.drawLine(Offset(startX, topY + 25), Offset(endX, topY + 28), layerPaint);
    canvas.drawLine(Offset(startX, topY + 65), Offset(endX, topY + 62), layerPaint);

    // Мультяшная зеленая трава с зубчиками
    final grassPaint = Paint()..color = const Color(0xFF4CAF50);
    canvas.drawRect(Rect.fromLTWH(startX, topY, endX - startX, 12), grassPaint);
    final grassPath = Path();
    for (double x = startX; x < endX; x += 10) {
      grassPath.moveTo(x, topY + 11);
      grassPath.lineTo(x + 5, topY + 19);
      grassPath.lineTo(x + 10, topY + 11);
    }
    canvas.drawPath(grassPath, grassPaint);
  }
}
    // ДЕТАЛИЗИРОВАННЫЙ КЛАСС ПТИЦЫ БАННИХОПА
class Bunnyhop {
  Offset position;
  bool isReadyForLaunch;
  bool isLaunched = false;
  bool shouldRemove = false;
  bool isAngryMode = false;   // Включена ли виагра
  double rageSparkTimer = 0.0; // Таймер для хаотичных синих молний
  // ИСПРАВЛЕНО: Свойства для честного вращения Баннихопа внутри петли на 360 градусов!
  bool isInLoopRotation = false; // Летит ли птица сейчас по кругу внутри петли
  double loopAngle = 0.0;        // Текущий угол вращения птицы внутри кольца
  double loopSpeed = 7.5;        // Скорость набора угла (вращения)
  // Массив хранит прошлые позиции птицы для создания анимированного синего шлейфа
  final List<Offset> rageTailPositions = [];
  bool hasDoneLoop = false;

 
    Offset velocity = Offset.zero;
  double _lifeTimer = 0.0;
  List<Offset> trajectoryDots = [];

  Bunnyhop(this.position, this.isReadyForLaunch);

  void launch(double slingX, double slingY) {
    isLaunched = true;
    // Направление полета противоположно оттягиванию пальца
    // Мощнейший толчок рогатки
    velocity = Offset((slingX - position.dx) * 9.0, (slingY - position.dy) * 9.0);
    trajectoryDots.clear();
  }

      
  void update(double dt, List<GameBlock> blocks, List<MolluskMaksim> pigs, double groundY, int level) {
    _lifeTimer += dt;
    if (_lifeTimer > 3.5) {
      shouldRemove = true;
      return;
    }

    velocity = Offset(velocity.dx, velocity.dy + 0.35 * dt);
    position = Offset(position.dx + velocity.dx * dt, position.dy + velocity.dy * dt);

    if (isInLoopRotation) {
      loopAngle += loopSpeed * dt;
      
      double loopCenterX = 0.78;
      double loopCenterY = 0.25;
      
      double loopRadiusY = 0.15 - 0.035; 
      double loopRadiusX = (0.15 / 1.7) - 0.022; 

      double currentAngle = (pi * 0.5) + loopAngle;
      position = Offset(
        loopCenterX + cos(currentAngle) * loopRadiusX,
        loopCenterY + sin(currentAngle) * loopRadiusY,
      );

     
      // Ваня съедает таблетку строго В УПОР и ТОЛЬКО если они реально есть в пачке!
      if (loopAngle >= 0.9 * pi && loopAngle <= 1.1 * pi && !isAngryMode) {
        if (AngryMolluskGame.pillsRemaining > 0) {
          isAngryMode = true; // Включаем статус ярости и хаотичные синие искры
          AudioManager.playRage(); // ГАРАНТИРОВАННО запускаем сочный гул таблетки!
        } else {
          // Если пачка пуста — жестко гарантируем, что Ваня останется обычным!
          isAngryMode = false;
        }
      }

      if (isAngryMode) {
        rageSparkTimer += dt;
        // Копируем текущую позицию Вани в массив шлейфа ярости
        rageTailPositions.add(position);
        if (rageTailPositions.length > 8) rageTailPositions.removeAt(0); // лимит длины хвоста
      }

            // Вылет из петли после полного внутреннего кувырка на 360 градусов
      if (loopAngle >= pi * 2) {
        isInLoopRotation = false; // Отключаем круговой режим
        hasDoneLoop = true;       // ИСПРАВЛЕНО: Запомнили, что птица уже открутилась!
        
        double speedMultiplier = isAngryMode ? 1.4 : 1.0;
        velocity = Offset(0.35 * speedMultiplier, 0.15 * (isAngryMode ? 1.35 : 1.0));
      }
      return; 
    }

        // ИСПРАВЛЕНО: Захват в петлю сработает ТОЛЬКО если птица ещё не делала круг!
    if (level == 4 && !isAngryMode && !isInLoopRotation && !hasDoneLoop) {
      // Ловим птицу строго в проёме открытого зева
      if (position.dx >= 0.73 && position.dx <= 0.86 && position.dy >= 0.26 && position.dy <= 0.46) {
        isInLoopRotation = true; 
        loopAngle = 0.0; // Стартуем вращение с нуля
        return;
      }
    


      // Ситуация Б: Влёт в правый зев
      if (position.dx >= 0.73 && position.dx <= 0.86 && position.dy >= 0.26 && position.dy <= 0.46) {
        isInLoopRotation = true; 
        loopAngle = 0.0; 
        
        // ИСПРАВЛЕНО: Звук бахает СТРОГО на входе в петлю, без задержек и пропусков!
        AudioManager.playRage(); 
        return;
      }
    }

    // Обычный полет вне петли под таблеткой продолжает копить синий шлейф
    if (isAngryMode) {
      rageSparkTimer += dt;
      rageTailPositions.add(position);
      if (rageTailPositions.length > 8) rageTailPositions.removeAt(0);
    }
      
    // СТОЛКНОВЕНИЕ С ЗЕМЛЁЙ ОСТРОВА (Птица не пролетает сквозь сушу!)
    if (position.dy >= groundY) {
      // Если птица находится на левом острове (<= 0.25) или на правом (>= 0.55) — она врезается в сушу
      if (position.dx <= 0.25 || position.dx >= 0.55) {
        position = Offset(position.dx, groundY);
        velocity = Offset.zero;
        AudioManager.playMiss();
        shouldRemove = true; // Останавливается и передает ход следующей птице
        return;
      }
    }

    double gapEnd = level == 1 ? 0.55 : (level == 2 ? 1.28 : 1.15);
    if (position.dx > 0.25 && position.dx < gapEnd && position.dy >= 0.95) {
      AudioManager.playMiss();
      shouldRemove = true;
      return;
    }

        // Столкновение с кубиками замка
    for (var block in blocks) { 
        if (!block.isBroken && !block.shouldRemove &&
          position.dx >= block.x && position.dx <= block.x + block.w &&
          position.dy >= block.y && position.dy <= block.y + block.h) {

        // Хак для сундука
        if (block.isSecretChest) {
          velocity = Offset.zero; 
          position = Offset(block.x + block.w / 2, block.y - 0.02); 
          block.chestCapturedBird = true; 
          return; 
        }

        // Хак для железа
        if (block.isIronShield) {
          velocity = Offset(-velocity.dx * 0.2, 0.1); 
          return;
        }

        // ИСПРАВЛЕНО: ЖЕЛЕЗНАЯ ФИЗИКА БРОНЕСТЕКЛА НА 4 УРОВНЕ!
        if (block.isGlassBlock) {
          if (!isAngryMode) {
            // ТАКТИКА 1: ОБЫЧНЫЙ БАННИХОП. 0% пробиваемости, скорость падает в ноль, стекло целое!
            velocity = Offset.zero; 
            return; // Птица бессильно отлипает и падает вниз
          } else {
            // ТАКТИКА 2: ЗЛОЙ БАННИХОП ПОД ТАБЛЕТКОЙ. Прошибает стекло со скоростью камня!
            block.hit(velocity);
            velocity = Offset(velocity.dx * 0.35, velocity.dy * 0.35); // гасит скорость умеренно
            continue; // Летит шибать замок дальше!
          }
        }

        block.hit(velocity); 
        if (block.isStone) {
          velocity = Offset(velocity.dx * 0.35, velocity.dy * 0.35);
        } else {
          velocity = Offset(velocity.dx * 0.65, velocity.dy * 0.65);
        }
      }
    }


        for (var pig in pigs) {
      double dx = position.dx - pig.x;
      double dy = position.dy - pig.y;
      if (sqrt(dx * dx + dy * dy) < 0.03) {
        pig.hit(velocity);
        pig.shouldRemove = true; // ИСПРАВЛЕНО: Баннихоп мгновенно уничтожает свинью при таране!
        AngryMolluskGame.score += 50; // Сразу начисляем пацанские очки
      }
    }
  }


    void render(Canvas canvas, Size size, Sprite? sprite) {
    final screenPos = Offset(size.width * position.dx, size.height * position.dy);
    final radius = size.width * 0.019; // Крупный сочный размер птицы

    // 1. Рисуем красный круг-подложку (все три птицы гарантированно красные!)
    canvas.drawCircle(screenPos, radius, Paint()..color = const Color(0xFFE53935));

    // 2. Накладываем лицо Баннихопа строго по центру
    if (sprite != null) {
      sprite.render(canvas, position: Vector2(screenPos.dx - radius, screenPos.dy - radius), size: Vector2(radius * 2, radius * 2));
    }

    // 3. Рисуем мультяшные перышки-хохолок поверх лица
    final featherPaint = Paint()..color = const Color(0xFFD32F2F)..style = PaintingStyle.fill;
    final featherPath = Path();
    featherPath.moveTo(screenPos.dx - radius * 0.3, screenPos.dy - radius);
    featherPath.lineTo(screenPos.dx - radius * 0.5, screenPos.dy - radius * 1.4);
    featherPath.lineTo(screenPos.dx, screenPos.dy - radius * 0.8);
    featherPath.moveTo(screenPos.dx, screenPos.dy - radius * 0.8);
    featherPath.lineTo(screenPos.dx + radius * 0.2, screenPos.dy - radius * 1.5);
    featherPath.lineTo(screenPos.dx + radius * 0.3, screenPos.dy - radius);
    featherPath.close();
    canvas.drawPath(featherPath, featherPaint);

    // 4. Траектория полёта белыми точками
    if (isReadyForLaunch && !isLaunched && position.dx != 0.15) {
      final dotsPaint = Paint()..color = Colors.white;
      final slingX = 0.15;
      final slingY = 0.73 - 0.07;
      final simVelocity = Offset((slingX - position.dx) * 9.0, (slingY - position.dy) * 9.0);

      for (int i = 1; i < 14; i++) {
        double t = i * 0.10;
        double x = position.dx + simVelocity.dx * t;
        double y = position.dy + simVelocity.dy * t + 0.5 * 0.35 * t * t;
        canvas.drawCircle(Offset(size.width * x, size.height * y), size.width * 0.003, dotsPaint);
      }
    }
  }
}

// КЛАСС СВИНЬИ С АНИМАЦИЕЙ И ФИЗИКОЙ ПАДЕНИЯ
class MolluskMaksim {
  double x, y;
  double vx = 0.0, vy = 0.0;
  bool isFalling = false;
  bool shouldRemove = false;

  MolluskMaksim(this.x, this.y);

    void hit(Offset birdVelocity) {
    AudioManager.playPigHit(); // Выбирает случайный крик pig_hit 1, 2 или 3!
    vx = birdVelocity.dx * 0.5;
    vy = birdVelocity.dy * 0.5;
    isFalling = true;
  }


      void update(double dt, List<GameBlock> blocks, double groundY) {
    // ИСПРАВЛЕНО: Счётчик блоков, которые задели свинью в этом кадре
    int hittingBlocksCount = 0;

    for (var block in blocks) {
      if (!block.isBroken && !block.shouldRemove && !block.isSleeping) {
        // Проверяем, пересекаются ли хитбоксы свиньи и движущегося кубика
        if (x >= block.x - 0.01 && x <= block.x + block.w + 0.01 &&
            y >= block.y - 0.01 && y <= block.y + block.h + 0.01) {
          
          hittingBlocksCount++; // Нашли соприкосновение с падающим блоком!

          // Считаем скорость конкретного летящего кубика
          double blockSpeed = sqrt(block.vx * block.vx + block.vy * block.vy);
          
          // ТАКТИКА 1: Одиночный блок убивает, если его скорость выше порога 0.20
          if (blockSpeed > 0.20) {
            AudioManager.playPigHit(); 
            AngryMolluskGame.score += 50;
            shouldRemove = true;
            return; 
          }
        }
      }
    }

    // ТАКТИКА 2: Автоматическая смерть от завала лавиной (если упало 2 или больше блоков одновременно)
    if (hittingBlocksCount >= 2 && !shouldRemove) {
      AudioManager.playPigHit(); 
      AngryMolluskGame.score += 50;
      shouldRemove = true;
      return;
    }

    // Физика падения самой свиньи
    if (isFalling) {
      vy += 1.8 * dt; 
      x += vx * dt;
      y += vy * dt;

      if (y >= groundY - 0.022) {
        y = groundY - 0.022;
        if (vy > 0.6) {
          AngryMolluskGame.score += 50;
          shouldRemove = true;
        } else {
          vx = 0;
          vy = 0;
          isFalling = false;
        }
      }
            
      if (y >= groundY + 0.05) {
        AngryMolluskGame.score += 50; 
        shouldRemove = true;
      }
    } else {
      bool supported = false;
      for (var block in blocks) {
        if (!block.isBroken && !block.shouldRemove &&
            x >= block.x && x <= block.x + block.w && 
            (block.y - y).abs() < 0.03) {
          supported = true;
          break;
        }
      }
      if (!supported && y < groundY - 0.02) {
        isFalling = true;
      }
    }
  }


    void render(Canvas canvas, Size size, Sprite? sprite) {
    final screenPos = Offset(size.width * x, size.height * y);
    final radius = size.width * 0.022; // Сочный размер свиньи

    // 1. Базовый зеленый круг
    canvas.drawCircle(screenPos, radius, Paint()..color = const Color(0xFF4CAF50));

    // 2. Накладываем лицо Максима Рыбалкина
    if (sprite != null) {
      sprite.render(canvas, position: Vector2(screenPos.dx - radius, screenPos.dy - radius), size: Vector2(radius * 2, radius * 2));
    }

    // 3. Зеленые свиные уши поверх лица
    final earPaint = Paint()..color = const Color(0xFF4CAF50)..style = PaintingStyle.fill;
    final earBorderPaint = Paint()..color = const Color(0xFF2E7D32)..style = PaintingStyle.stroke..strokeWidth = 1.2;
    
    canvas.drawOval(Rect.fromCenter(center: Offset(screenPos.dx - radius * 0.7, screenPos.dy - radius * 0.5), width: 8, height: 12), earPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(screenPos.dx - radius * 0.7, screenPos.dy - radius * 0.5), width: 8, height: 12), earBorderPaint);
    
    canvas.drawOval(Rect.fromCenter(center: Offset(screenPos.dx + radius * 0.7, screenPos.dy - radius * 0.5), width: 8, height: 12), earPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(screenPos.dx + radius * 0.7, screenPos.dy - radius * 0.5), width: 8, height: 12), earBorderPaint);
  }
}

// КЛАСС СТРОИТЕЛЬНОГО БЛОКА С ЦЕПНЫМИ РАЗРУШЕНИЯМИ И МАТЕРИАЛАМИ
class GameBlock {
  double x, y, w, h;
  final bool isStone;
  double vx = 0.0, vy = 0.0;
  bool isFalling = false;
  bool shouldRemove = false;
  bool isGlassBlock = false;  // Флаг бронестекла Максимов
 bool isCracked = false;    // Появились ли трещины после удара об землю
  double groundFade = 1.0;   // Плавное исчезновение после падения на землю
  bool isSleeping = true; // Блок спит и стоит мёртво до тех пор, пока в него не попадут
  bool isBroken = false; // Разрушен ли блок напополам
  double fragmentOffset = 0.0; // Смещение половинок при разлете
  double fragmentAlpha = 1.0;  // Плавное исчезновение (прозрачность)

  // ИСПРАВЛЕНО: Добавляем флаги для секретной пасхалки IvanDrop!
  bool isIronShield = false;       // Флаг стальных ворот (железа)
  bool isSecretChest = false;      // Флаг секретного сундука
  bool chestCapturedBird = false;  // Сработал ли захват Баннихопа
  double chestAnimTimer = 0.0;     // Таймер для логики исчезновения сундука
  
    GameBlock(this.x, this.y, this.w, this.h, this.isStone);

  void hit(Offset impactVelocity) {
    if (isBroken) return;
    isSleeping = false;

    // Включаем хруст дерева или грохот камня в зависимости от материала кубика
    AudioManager.playBlockBreak(isStone); 

    double speed = sqrt(impactVelocity.dx * impactVelocity.dx + impactVelocity.dy * impactVelocity.dy);
    if (speed > 1.2) {
      isBroken = true;
    }
    
    // Передаем блоку скорость толчка птицы, чтобы он изменил свою траекторию!
    vx = impactVelocity.dx * 0.65;
    vy = impactVelocity.dy * 0.65;
    isFalling = true; 
  }

       void update(double dt, List<GameBlock> allBlocks, List<MolluskMaksim> allPigs, double groundY, AngryMolluskGame game) {
    
       // ЛОГИКА СЕКРЕТНОГО СУНДУКА IVANDROP С КЛЕШНЕЙ И КРАСИВЫМ ВЫЛЕТОМ ФОТОКАРТОЧКИ
    if (isSecretChest && chestCapturedBird) {
      isSleeping = false; 
      chestAnimTimer += dt;
      
      // В первую миллисекунду выдаём ачивку и звук фанфар
      if (chestAnimTimer >= 0.02 && chestAnimTimer < 0.08) {
        SharedPreferences.getInstance().then((prefs) async {
          final alreadyUnlocked = prefs.getBool('achievement_secret_chest') ?? false;
          if (!alreadyUnlocked) {
            await prefs.setBool('achievement_secret_chest', true);
            AudioManager.playAchievement(); 
            game.overlays.add('AchievementToast');
            Future.delayed(const Duration(seconds: 5), () {
              game.overlays.remove('AchievementToast');
            });
          }
        });
      }

      // Через 1.5 секунды клешня прячет птицу, и ФОТКА НАЧИНАЕТ ВЫЛЕТАТЬ ИЗ СУНДУКА!
      if (chestAnimTimer >= 1.5) {
        if (game.currentBird != null) {
          game.currentBird!.shouldRemove = true; // Птица исчезает
        }
        game.showFlyingLosePhoto = true; // Включаем отрисовку фотки
        // Плавно увеличиваем масштаб фотки от 0.0 до красивого уменьшенного размера 0.45
        if (game.losePhotoScale < 0.45) {
          game.losePhotoScale += 0.35 * dt; 
        }
      }

      // Через 5.5 секунд плавно закрываем всё и выходим в главное меню карточек
      if (chestAnimTimer >= 5.5) {
        shouldRemove = true;
        game.showFlyingLosePhoto = false;
        game.losePhotoScale = 0.0;
        AudioManager.stopAllLevelSounds();
        Navigator.of(game.buildContext!).pop(); // Мягкий выход в меню
      }
      return; 
    }


    // Твой старый код апдейта обычных блоков (начинается с проверки сна):
    if (isSleeping) {
      isFalling = false;
      vx = 0;
      vy = 0;
      return;
    }


        if (isBroken) {
      fragmentOffset += 0.15 * dt; 
      fragmentAlpha -= 1.8 * dt;  
      if (fragmentAlpha <= 0) {
        AngryMolluskGame.score += isStone ? 30 : 20;
        shouldRemove = true;
        return;
      }
    } // ЗАКРЫВАЕТ if (fragmentAlpha <= 0)
  



    if (isCracked) {
      groundFade -= 1.2 * dt; 
      if (groundFade <= 0) {
        shouldRemove = true;
        return;
      }
    }

    if (isFalling) {
      vy += 2.8 * dt; // Скорость быстрого падения
      x += vx * dt;
      y += vy * dt;

      // Лавина: падающий проснувшийся блок будит соседние блоки и толкает их в сторону своего движения!
      for (var other in allBlocks) {
        if (other != this) {
          if ((x - other.x).abs() < (w + other.w) / 2 && (y - other.y).abs() < (h + other.h) / 2) {
            other.isSleeping = false; // Будим соседа
            other.hit(Offset(vx * 0.85, vy * 0.85)); // Передаем ему толчок
          }
        }
      }

      // Передаем импульс свиньям
      for (var pig in allPigs) {
        if (pig.x >= x && pig.x <= x + w && (pig.y - y).abs() < (h / 2 + 0.02)) {
          pig.hit(Offset(vx * 0.9, vy * 0.9));
        }
      }

            // ПРИЗЕМЛЕНИЕ НА ЗЕМЛЮ ОСТРОВА (Блок не проваливается сквозь землю!)
      if (y >= groundY - h) {
        // ИСПРАВЛЕНО: Рассчитываем, где начинается суша для каждого из 3 уровней
        double islandStart = game.currentLevel == 1 ? 0.55 : (game.currentLevel == 2 ? 1.28 : 1.15);

        // Проверяем, упал ли блок на сушу острова на основе рассчитанного islandStart
        if (x <= 0.25 || x >= islandStart) {
          y = groundY - h;
          vx = 0;
          vy = 0;
          isFalling = false;
          isCracked = true; // Трескается и исчезает на суше
        }
      }


      // ПАДЕНИЕ СКВОЗЬ ВОДУ (Если улетел в океан между скал, летит до самого дна экрана)
      if (x > 0.25 && x < 0.55 && y >= 0.95) {
        shouldRemove = true;
      }
    } else {
      // Проверка потери опоры в динамике: если нижний блок разрушен, верхний просыпается и падает
      bool hasFloor = false;
      
          double islandStart = game.currentLevel == 1 ? 0.55 : (game.currentLevel == 2 ? 1.28 : 1.15);
        
        // ИСПРАВЛЕНО: Теперь опора проверяется по умной переменной islandStart!
        if ((y + h - groundY).abs() < 0.005 && (x <= 0.25 || x >= islandStart)) {
        hasFloor = true;
      } else {
        for (var other in allBlocks) {
          if (other != this && !other.isBroken && !other.shouldRemove && !other.isSleeping) {
            if ((other.x - x).abs() < (w + other.w) * 0.48 &&
                other.y > y &&
                (other.y - (y + h)).abs() < 0.015) {
              hasFloor = true;
              break;
            }
          }
        }
      }
      if (!hasFloor) {
        isSleeping = false;
        isFalling = true;
      }
    }
  }

      void render(Canvas canvas, Size size) {
    if (groundFade <= 0) return;

    // Переводим относительные координаты в реальные пиксели экрана смартфона
    final rect = Rect.fromLTWH(
      size.width * x, 
      size.height * y, 
      size.width * w, 
      size.height * h
    );

    // Создаем изолированные кисти с прозрачностью для таяния на земле
    final paint = Paint()
      ..color = (isStone ? const Color(0xFFB0BEC5) : const Color(0xFFFFB74D)).withValues(alpha: groundFade)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = (isStone ? const Color(0xFF455A64) : const Color(0xFFD84315)).withValues(alpha: groundFade)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Рисуем сам кубик на экране
    canvas.drawRect(rect, paint);
    canvas.drawRect(rect, borderPaint);

    // Рисуем текстуру материалов (дерево или кирпич)
    if (!isStone) {
      final woodPaint = Paint()..color = const Color(0xFFE65100).withValues(alpha: groundFade)..strokeWidth = 1.2;
      canvas.drawLine(Offset(rect.left + 3, rect.top + rect.height * 0.35), Offset(rect.right - 3, rect.top + rect.height * 0.35), woodPaint);
      canvas.drawLine(Offset(rect.left + 3, rect.top + rect.height * 0.7), Offset(rect.right - 3, rect.top + rect.height * 0.7), woodPaint);
    } else {
      final stonePaint = Paint()..color = const Color(0xFF37474F).withValues(alpha: groundFade)..strokeWidth = 1.5;
      canvas.drawLine(Offset(rect.left + rect.width * 0.3, rect.top + 2), Offset(rect.left + rect.width * 0.3, rect.bottom - 2), stonePaint);
      canvas.drawLine(Offset(rect.left + rect.width * 0.7, rect.top + 2), Offset(rect.left + rect.width * 0.7, rect.bottom - 2), stonePaint);
    }

    // НАСТОЯЩИЕ ТРЕЩИНЫ: Появляются, когда блок шмякается об землю острова
    if (isCracked) {
      final crackPaint = Paint()
        ..color = const Color(0xFF212121).withValues(alpha: groundFade)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
        
      final crackPath = Path();
      crackPath.moveTo(rect.left + 5, rect.top + 5);
      crackPath.lineTo(rect.left + rect.width * 0.3, rect.top + rect.height * 0.4);
      crackPath.lineTo(rect.left + 2, rect.bottom - 5);
      crackPath.moveTo(rect.right - 5, rect.bottom - 5);
      crackPath.lineTo(rect.left + rect.width * 0.6, rect.top + rect.height * 0.5);
      
      canvas.drawPath(crackPath, crackPaint);
    }
  
    // МУЛЬТЯШНЫЕ ТРЕЩИНЫ: Рисуются поверх блока, если он жестко шмякнулся о землю скалы
    if (isCracked) {
      final crackPaint = Paint()
        ..color = const Color(0xFF212121).withValues(alpha: groundFade)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
        
      final crackPath = Path();
      // Левая трещина идет от верхнего левого края к центру
      crackPath.moveTo(rect.left + 5, rect.top + 5);
      crackPath.lineTo(rect.left + rect.width * 0.3, rect.top + rect.height * 0.4);
      crackPath.lineTo(rect.left + 2, rect.bottom - 5);
      // Правая трещина
      crackPath.moveTo(rect.right - 5, rect.bottom - 5);
      crackPath.lineTo(rect.left + rect.width * 0.6, rect.top + rect.height * 0.5);
      
      canvas.drawPath(crackPath, crackPaint);
    }
  }
} 
// Класс заднего фона: рисует градиент неба, вращающееся солнце и движущиеся облака
class BackgroundDecoration extends Component with HasGameRef<AngryMolluskGame> {
  @override
  void render(Canvas canvas) {
  }
}       

// =========================================================================
// КЛАСС ДЛЯ ВЕКТОРНОГО РИСОВАНИЯ НАСТОЯЩЕЙ КРАБЬЕЙ КЛЕШНИ С ФОТОГРАФИИ
// =========================================================================
class CrabClawPainter {
  final double openFactor; 
  CrabClawPainter({required this.openFactor});

  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()..color = const Color(0xFF1B4314)..style = PaintingStyle.fill;
    final clawPaint = Paint()..color = const Color(0xFF2E6F22)..style = PaintingStyle.fill;
    final borderPaint = Paint()..color = const Color(0xFF0D240A)..style = PaintingStyle.stroke..strokeWidth = 1.2;

    // 1. Нижний сустав клешни
    canvas.drawOval(Rect.fromLTWH(size.width * 0.25, size.height * 0.5, size.width * 0.5, size.height * 0.4), basePaint);
    canvas.drawOval(Rect.fromLTWH(size.width * 0.25, size.height * 0.5, size.width * 0.5, size.height * 0.4), borderPaint);

    // 2. Центральное монолитное тело клешни
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.15, size.height * 0.3, size.width * 0.7, size.height * 0.35), const Radius.circular(6)),
      clawPaint
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.15, size.height * 0.3, size.width * 0.7, size.height * 0.35), const Radius.circular(6)),
      borderPaint
    );

    // 3. ЛЕВАЯ СТВОРКА ЩИПЦА (Большой верхний крюк)
    canvas.save();
    canvas.translate(size.width * 0.25, size.height * 0.35);
    canvas.rotate(-openFactor * 0.35); 
    
    final leftHookPath = Path()
      ..moveTo(0, 0)
      ..cubicTo(-size.width * 0.3, -size.height * 0.2, -size.width * 0.2, -size.height * 0.5, size.width * 0.25, -size.height * 0.5) 
      ..lineTo(size.width * 0.2, -size.height * 0.35)
      ..cubicTo(size.width * 0.05, -size.height * 0.35, -size.width * 0.05, -size.height * 0.15, size.width * 0.1, 0)
      ..close();
    
    canvas.drawPath(leftHookPath, clawPaint);
    canvas.drawPath(leftHookPath, borderPaint);
    canvas.restore();

    // 4. ПРАВАЯ СТВОРКА ЩИПЦА (Нижний зажим)
    canvas.save();
    canvas.translate(size.width * 0.75, size.height * 0.35);
    canvas.rotate(openFactor * 0.35); 
    
    final rightHookPath = Path()
      ..moveTo(0, 0)
      ..cubicTo(size.width * 0.2, -size.height * 0.15, size.width * 0.1, -size.height * 0.4, -size.width * 0.25, -size.height * 0.45)
      ..lineTo(-size.width * 0.15, -size.height * 0.3)
      ..cubicTo(-size.width * 0.05, -size.height * 0.3, size.width * 0.02, -size.height * 0.15, -size.width * 0.1, 0)
      ..close();
    
    canvas.drawPath(rightHookPath, clawPaint);
    canvas.drawPath(rightHookPath, borderPaint);
    canvas.restore();
  }
}

// ПОЛНОСТЬЮ ЗАМЕНИ СТАРЫЙ КЛАСС WantedPosterPainter НА ЭТОТ ДЕТАЛИЗИРОВАННЫЙ ВАРИАНТ С 3D ЭФФЕКТОМ:
class WantedPosterPainter {
  final double animTimer;
  WantedPosterPainter({required this.animTimer});

  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // ГЛАВНЫЙ ПРЯМОУГОЛЬНИК ЛИСТА
    final mainRect = Rect.fromCenter(center: Offset.zero, width: w, height: h);

    // =========================================================================
    // 1. СИСТЕМА 3D ТЕНЕЙ (ЭФФЕКТ ОБЪЁМА, БУМАЖКА ПАРИТ НАД ЭКРАНОМ)
    // =========================================================================
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12.0);
    // Рисуем тень со смещением вправо-вниз
    canvas.drawRect(mainRect.shift(const Offset(8, 12)), shadowPaint);

    // =========================================================================
    // 2. ЗАЛИВКА И КОНТУРЫ ЛИСТА ПО РЕФЕРЕНСУ
    // =========================================================================
    // Базовый ровный пожелтевший винтажный цвет бумаги
    canvas.drawRect(mainRect, Paint()..color = const Color(0xFFEEDCA5));

    // Пожелтевший состаренный внутренний контур (затемнение краев)
    final edgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0
      ..color = const Color(0xFFC6B27A);
    canvas.drawRect(mainRect.deflate(7), edgePaint);

    // Обязательная строгая тёмно-коричневая внешняя обводка по краю
    final borderPaint = Paint()
      ..color = const Color(0xFF4E342E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawRect(mainRect, borderPaint);
    // Внутренняя тонкая рамочная линия как на картинке
    canvas.drawRect(mainRect.deflate(14), borderPaint..strokeWidth = 1.0);

    // =========================================================================
    // 3. ТЕКСТУРА СТАРЕНИЯ: НЕБОЛЬШИЕ ГРЯЗНЫЕ ПЯТНА ПО ВСЕМУ ЛИСТУ
    // =========================================================================
    final spotPaint = Paint()..color = const Color(0xFF5D4037).withOpacity(0.12);
    final randSpots = Random(42); // Фиксированный сид, чтобы пятна не прыгали
    for (int i = 0; i < 15; i++) {
      double sx = (randSpots.nextDouble() - 0.5) * w;
      double sy = (randSpots.nextDouble() - 0.5) * h;
      double sRadius = randSpots.nextDouble() * 12 + 3;
      canvas.drawCircle(Offset(sx, sy), sRadius, spotPaint);
      // Парочка вытянутых клякс
      if (i % 4 == 0) {
        canvas.drawOval(Rect.fromCenter(center: Offset(sx + 5, sy), width: sRadius * 2, height: sRadius * 0.8), spotPaint);
      }
    }

        // ПОЛНОСТЬЮ ЗАМЕНИТЬ ПРЕДЫДУЩИЙ КОД ПЯТНА-КЛЕШНИ НА ЭТОТ ВАРИАНТ ПО СХЕМЕ:
    // Въевшееся кофейное пятно в виде массивной анатомической клешни Дона Моллюска
    final secretSpotPaint = Paint()
      ..color = const Color(0xFF5D4037).withOpacity(0.12) // Блёклый цвет грязи
      ..style = PaintingStyle.fill; // Заливка блоков

    canvas.save();
    // Позиционируем в левом нижнем углу плаката WANTED
    canvas.translate(-w * 0.36, h * 0.38);
    
    // 1. МАССИВНЫЙ КУЛАК (Широкое основание клешни из горизонтальных линий внизу)
    // Координаты: drawRect(Rect.fromLTWH(относительный_X, относительный_Y, ширина, высота))
    canvas.drawRect(const Rect.fromLTWH(-11, 24, 22, 2.5), secretSpotPaint);
    canvas.drawRect(const Rect.fromLTWH(-13, 21.5, 26, 2.5), secretSpotPaint);
    canvas.drawRect(const Rect.fromLTWH(-15, 19, 30, 2.5), secretSpotPaint);
    canvas.drawRect(const Rect.fromLTWH(-17, 16.5, 34, 2.5), secretSpotPaint);
    canvas.drawRect(const Rect.fromLTWH(-20, 14, 40, 2.5), secretSpotPaint);
    canvas.drawRect(const Rect.fromLTWH(-21, 11.5, 42, 2.5), secretSpotPaint);
    canvas.drawRect(const Rect.fromLTWH(-23, 9, 46, 2.5), secretSpotPaint);
    canvas.drawRect(const Rect.fromLTWH(-24, 6.5, 48, 2.5), secretSpotPaint);
    canvas.drawRect(const Rect.fromLTWH(-24, 4, 48, 2.5), secretSpotPaint);
    canvas.drawRect(const Rect.fromLTWH(-25, 1.5, 50, 2.5), secretSpotPaint);
    canvas.drawRect(const Rect.fromLTWH(-26, -1, 52, 2.5), secretSpotPaint);
    canvas.drawRect(const Rect.fromLTWH(-26, -3.5, 52, 2.5), secretSpotPaint);

    // Внутренние зазубрины под начало общего просвета (у основания усов)
    canvas.drawRect(const Rect.fromLTWH(-27, -6, 20, 2.5), secretSpotPaint);
    canvas.drawRect(const Rect.fromLTWH(7, -6, 20, 2.5), secretSpotPaint);

    // 2. ЛЕВЫЙ ГЛАДКИЙ КРАЙ ЩИПЦА (Идёт плотной ровной дугой вверх)
    canvas.drawRect(const Rect.fromLTWH(-28, -8.5, 14, 2.5), secretSpotPaint);
    canvas.drawRect(const Rect.fromLTWH(-29, -11, 12, 2.5), secretSpotPaint);
    canvas.drawRect(const Rect.fromLTWH(-30, -13.5, 11, 2.5), secretSpotPaint);
    canvas.drawRect(const Rect.fromLTWH(-30, -16, 10, 2.5), secretSpotPaint);
    canvas.drawRect(const Rect.fromLTWH(-31, -18.5, 9, 2.5), secretSpotPaint);
    canvas.drawRect(const Rect.fromLTWH(-31, -21, 9, 2.5), secretSpotPaint);
    canvas.drawRect(const Rect.fromLTWH(-31, -23.5, 9, 2.5), secretSpotPaint);
    canvas.drawRect(const Rect.fromLTWH(-31, -26, 9, 2.5), secretSpotPaint);
    canvas.drawRect(const Rect.fromLTWH(-31, -28.5, 9, 2.5), secretSpotPaint);
    canvas.drawRect(const Rect.fromLTWH(-30, -31, 9, 2.5), secretSpotPaint);
    canvas.drawRect(const Rect.fromLTWH(-30, -33.5, 10, 2.5), secretSpotPaint);
    canvas.drawRect(const Rect.fromLTWH(-29, -36, 11, 2.5), secretSpotPaint);
    canvas.drawRect(const Rect.fromLTWH(-27, -38.5, 12, 2.5), secretSpotPaint);
    canvas.drawRect(const Rect.fromLTWH(-25, -41, 14, 2.5), secretSpotPaint);

    // 3. ПРАВЫЙ КРАЙ С МЕЛКИМИ БУГОРКАМИ (Идёт ступенчатыми зазубринами вверх по схеме)
    canvas.drawRect(const Rect.fromLTWH(14, -8.5, 14, 2.5), secretSpotPaint);
    canvas.drawRect(const Rect.fromLTWH(17, -11, 12, 2.5), secretSpotPaint);
    canvas.drawRect(const Rect.fromLTWH(19, -13.5, 11, 2.5), secretSpotPaint);
    canvas.drawRect(const Rect.fromLTWH(20, -16, 10, 2.5), secretSpotPaint);
    canvas.drawRect(const Rect.fromLTWH(22, -18.5, 9, 2.5), secretSpotPaint);
    canvas.drawRect(const Rect.fromLTWH(22, -21, 9, 2.5), secretSpotPaint);
    canvas.drawRect(const Rect.fromLTWH(22, -23.5, 9, 2.5), secretSpotPaint);
    canvas.drawRect(const Rect.fromLTWH(21, -26, 10, 2.5), secretSpotPaint); // Бугорок наружу
    canvas.drawRect(const Rect.fromLTWH(22, -28.5, 9, 2.5), secretSpotPaint);
    canvas.drawRect(const Rect.fromLTWH(21, -31, 9, 2.5), secretSpotPaint);
    canvas.drawRect(const Rect.fromLTWH(20, -33.5, 10, 2.5), secretSpotPaint);
    canvas.drawRect(const Rect.fromLTWH(18, -36, 11, 2.5), secretSpotPaint);
    canvas.drawRect(const Rect.fromLTWH(15, -38.5, 12, 2.5), secretSpotPaint);
    canvas.drawRect(const Rect.fromLTWH(11, -41, 14, 2.5), secretSpotPaint);

    // 4. ШИРОКИЕ "ЛОЖКОВИДНЫЕ" КОНЦЫ (Плоское ровное смыкание с разрывом по центру сверху)
    // Левый кончик-ложка
    canvas.drawRect(const Rect.fromLTWH(-22, -43.5, 18, 2.5), secretSpotPaint);
    canvas.drawRect(const Rect.fromLTWH(-18, -46, 14, 2.5), secretSpotPaint);
    // Правый кончик-ложка (оставляем чёткий зазор [ОБЩИЙ ПРОСВЕТ] между ними на оси X от -4 до 4)
    canvas.drawRect(const Rect.fromLTWH(4, -43.5, 18, 2.5), secretSpotPaint);
    canvas.drawRect(const Rect.fromLTWH(4, -46, 14, 2.5), secretSpotPaint);

    canvas.restore();


      // =========================================================================
    // 4. СТРОГИЙ КОНТРАСТНЫЙ ТЕКСТ
    // =========================================================================
    void drawCleanText(String text, double fontSize, double offsetY, {bool isTitle = false}) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF1A0A0A),
            letterSpacing: isTitle ? 3.0 : 1.0,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(-textPainter.width / 2, offsetY));
    }

    drawCleanText('РАЗЫСКИВАЕТСЯ', 22, -h / 2 + 25, isTitle: true);

    // =========================================================================
    // 5. ОГРОМНЫЙ ПРЯМОУГОЛЬНЫЙ ВЫРЕЗ ПОД ФОТО (С ЭФФЕКТОМ ГЛУБИНЫ)
    // =========================================================================
    double photoW = w * 0.84; // Увеличенный размер выреза во всю ширь
    double photoH = h * 0.40;
    final photoRect = Rect.fromCenter(center: Offset(0, -h * 0.05), width: photoW, height: photoH);

    // Внутренняя тень выреза (создает эффект 3D-окна вовнутрь листа)
    final innerShadow = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
    canvas.drawRect(photoRect.shift(const Offset(2, 4)), innerShadow);

    // Сам глубокий чёрный прямоугольник фотографии
    canvas.drawRect(photoRect, Paint()..color = const Color(0xFF050505));
    canvas.drawRect(photoRect, Paint()..color = const Color(0xFF4E342E)..style = PaintingStyle.stroke..strokeWidth = 2.0);

    // =========================================================================
    // 6. ХУДОЖЕСТВЕННАЯ СЦЕНА: КЛЕШНЯ И РЕАЛИСТИЧНАЯ ЖИДКОСТЬ
    // =========================================================================
    canvas.save();
    canvas.translate(0, -h * 0.05);

    // А) РЕАЛИСТИЧНАЯ АСИММЕТРИЧНАЯ ЛУЖА КРОВИ (КЛЯКСА С БЛИКАМИ)
    final liquidPaint = Paint()..color = const Color(0xFF00FF66)..style = PaintingStyle.fill;
    final liquidPath = Path();
    
    // Рисуем естественную растекающуюся форму через кривые
    double lr = photoH * 0.45;
    liquidPath.moveTo(-lr, 5);
    liquidPath.cubicTo(-lr * 0.8, -lr * 0.5, lr * 0.2, -lr * 0.6, lr * 0.9, -10);
    liquidPath.cubicTo(lr * 1.1, lr * 0.4, lr * 0.5, lr * 0.8, 0, lr * 0.7);
    liquidPath.cubicTo(-lr * 0.6, lr * 0.8, -lr * 1.1, lr * 0.5, -lr, 5);
    liquidPath.close();
    canvas.drawPath(liquidPath, liquidPaint);

    // Объёмные глянцевые блики внутри лужи (свет на жидкости)
    final liqGlint = Paint()..color = Colors.white.withOpacity(0.25)..style = PaintingStyle.fill;
    canvas.drawOval(Rect.fromLTWH(-lr * 0.5, -lr * 0.3, lr * 0.4, 6), liqGlint);
    canvas.drawCircle(Offset(lr * 0.4, lr * 0.2), 3, liqGlint);

    // Маленькие капли-спутники вокруг большой лужи
    canvas.drawCircle(Offset(-lr * 0.8, lr * 0.5), 3.5, liquidPaint);

    // Б) ВЫСОКОДЕТАЛИЗИРОВАННАЯ КЛЕШНЯ (СТРОГО ГОРИЗОНТАЛЬНО)
    final clawPaint = Paint()..color = const Color(0xFF2E6F22)..style = PaintingStyle.fill;
    final linePaint = Paint()..color = const Color(0xFF0D240A)..style = PaintingStyle.stroke..strokeWidth = 1.2;

    const double cw = 55; // Увеличенный размер
    const double ch = 28;

    // 1. Базовый сустав (слева) с прорисовкой текстурных складок
    final jointRect = const Rect.fromLTWH(-26, -10, 22, 20);
    canvas.drawOval(jointRect, clawPaint);
    canvas.drawOval(jointRect, linePaint);
    canvas.drawLine(const Offset(-20, -5), const Offset(-12, 5), linePaint); // Поперечный рельеф панциря

    // 2. Центральное тело клешни с разделительной линией сегмента
    final bodyRRect = RRect.fromRectAndRadius(const Rect.fromLTWH(-12, -13, 34, 26), const Radius.circular(5));
    canvas.drawRRect(bodyRRect, clawPaint);
    canvas.drawRRect(bodyRRect, linePaint);
    // Продольный шов на броне для реалистичности
    canvas.drawLine(const Offset(-12, 0), const Offset(22, 0), linePaint);

    // 3. Вытянутая вперёд верхняя створка щипца
    final topClawPath = Path()
      ..moveTo(14, -8)
      ..cubicTo(28, -25, 52, -22, 56, -4) 
      ..lineTo(36, -2)
      ..cubicTo(32, -12, 22, -14, 14, -8)
      ..close();
    canvas.drawPath(topClawPath, clawPaint);
    canvas.drawPath(topClawPath, linePaint);
    // Зубчики на внутренней стороне верхнего щипца
    canvas.drawCircle(const Offset(38, -4), 1.0, linePaint);
    canvas.drawCircle(const Offset(44, -5), 1.0, linePaint);

    // 4. Вытянутая вперёд нижняя створка щипца
    final bottomClawPath = Path()
      ..moveTo(14, 6)
      ..cubicTo(26, 21, 48, 16, 52, 2)
      ..lineTo(34, 1)
      ..cubicTo(30, 10, 20, 11, 14, 6)
      ..close();
    canvas.drawPath(bottomClawPath, clawPaint);
    canvas.drawPath(bottomClawPath, linePaint);

    // Красивые вытянутые чёткие 3D-блики на панцире
    final shinePaint = Paint()..color = Colors.white.withOpacity(0.15)..style = PaintingStyle.fill;
    canvas.drawOval(const Rect.fromLTWH(-6, -8, 14, 4), shinePaint);
    canvas.drawOval(const Rect.fromLTWH(20, -12, 10, 3), shinePaint);

    canvas.restore();

    // =========================================================================
    // 7. НИЖНИЙ ТЕКСТ И НАГРАДА
    // =========================================================================
    drawCleanText('ДОН МОЛЛЮСК', 16, photoRect.bottom + 14);
    drawCleanText('НАГРАДА', 13, photoRect.bottom + 42);
    drawCleanText('1, 000, 000\$', 22, photoRect.bottom + 62);

    // =========================================================================
    // 8. ПУЛИ ИЗ ПЕРВОЙ ВЕРСИИ (РЕАЛИСТИЧНЫЕ ДЫРКИ С НАГАРОМ И ТРЕЩИНАМИ)
    // =========================================================================
    final bulletCenter = Paint()..color = const Color(0xFF1C1D1F);
    final bulletBurn = Paint()..color = const Color(0x663E2723);
    final crackPaint = Paint()..color = const Color(0x77212121)..strokeWidth = 0.7;

    void drawRealBulletHole(double bx, double by) {
      canvas.drawCircle(Offset(bx, by), 3.5, bulletCenter); // Чёрное сквозное отверстие
      canvas.drawCircle(Offset(bx, by), 8.0, bulletBurn..style = PaintingStyle.stroke..strokeWidth = 2); // Опалина вокруг
      
      // Тонкие радиальные трещины по бумаге от удара пули
      for (int i = 0; i < 4; i++) {
        double angle = i * pi / 2;
        canvas.drawLine(Offset(bx, by), Offset(bx + cos(angle) * 12, by + sin(angle) * 12), crackPaint);
      }
    }

    // Рассыпаем пулевые ранения чётко по углам плаката
    drawRealBulletHole(-w / 2 + 25, -h / 2 + h * 0.25);
    drawRealBulletHole(-w / 2 + 18, -h / 2 + h * 0.65);
    drawRealBulletHole(w / 2 - 28, -h / 2 + 65);
    drawRealBulletHole(w / 2 - 20, -h / 2 + h * 0.8);
  }
}


