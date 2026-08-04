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
                                onPressed: () {
                                  game.overlays.remove('VictoryMenu');
                                  
                                  // Динамически двигаем игрока вперед
                                  if (game.currentLevel < 3) {
                                    game.currentLevel = game.currentLevel + 1;
                                  } else {
                                    game.currentLevel = 3; 
                                  }
                                  
                                  AngryMolluskGame.score = 0;
                                  game.worldScrollX = 0.0; // Сбрасываем скролл камеры к рогатке
                                  
                                  game.isVictorySequenceStarted = false;
                                  game.levelCleared = false;
                                  game.buildLevelStructures(); // Строим замок следующего уровня
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

      // ИСПРАВЛЕНО: ПАСХАЛКА ДЛЯ 1 УРОВНЯ (СУНДУК IVANDROP И ЖЕЛЕЗНЫЙ ЗАСЛОН В ТЕМНОТЕ)
      // Спавним железную плиту-заслон на координате x = 1.35
      blocks.add(GameBlock(1.35, 0.40, 0.04, 0.33, true)..isIronShield = true);
      
      // Спавним секретный сундук IvanDrop дальше в темноте — на x = 1.65
      blocks.add(GameBlock(1.65, 0.55, 0.08, 0.18, false)..isSecretChest = true);
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
    if (canvasSize.x == 0 || canvasSize.y == 0) return;
    super.update(dt);
    if (isPaused) return;

    // Анимация облаков и солнца
    sunRotation += 0.3 * dt;
    cloudOffset1 += 0.015 * dt;
    cloudOffset2 += 0.008 * dt;

    // Обновление летящей птицы
    if (currentBird != null && currentBird!.isLaunched) {
      currentBird!.update(dt, blocks, pigs, groundY, currentLevel);
      if (currentBird!.shouldRemove) {
        loadNextBird();
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

        // Градиент неба растягивается под ширину уровня
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.blue.shade300, Colors.lightBlue.shade100],
      ).createShader(Rect.fromLTWH(0, 0, size.width * worldWidthFactor, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width * worldWidthFactor, size.height), skyPaint);

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
    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.85);
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
      _renderIsland(canvas, size, 0.55, 1.0); // Остров уровня 1
    } else if (currentLevel == 2) {
      _renderIsland(canvas, size, 1.28, 1.75); // Остров уровня 2 под замок bx=1.35
    }  else if (currentLevel == 3) {
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

    // 8. ОТРИСОВКА ВСЕХ ОБЪЕКТОВ УРОВНЯ
    for (var block in blocks) {
      block.render(canvas, size);
    }

    // СЮДА ВСТАВЛЯЕМ СВИНЕЙ! (Они нарисуются поверх островов и блоков)
    for (var pig in pigs) {
      pig.render(canvas, size, maksimSprite);
    }

    // СЮДА ЖЕ ВСТАВЛЯЕМ ПТИЦУ С ТРАЕКТОРИЕЙ! (Чтобы она была видна игроку)
    if (currentBird != null && (!currentBird!.isLaunched || !currentBird!.shouldRemove)) {
      currentBird!.render(canvas, size, bunnySprite);
    }
       // ОТОБРАЖЕНИЕ СЧЁТЧИКА ОЧКОВ (В правом верхнем углу)
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'SCORE: $score',
        style: TextStyle(
          fontFamily: 'Arial',
          fontSize: size.width * 0.035,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFFFD54F), // Сочный жёлтый цвет
          shadows: const [
            Shadow(offset: Offset(2, 2), blurRadius: 3.0, color: Colors.black87),
          ],
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
          color: const Color(0xFFE53935), // Фирменный красный цвет птиц
          shadows: const [Shadow(offset: Offset(1.5, 1.5), blurRadius: 2.0, color: Colors.black87)],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    birdsPainter.layout();
    birdsPainter.paint(canvas, Offset(size.width * 0.05, size.height * 0.88));
    
    canvas.restore();
  }

         @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    
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

    for (var block in blocks) {
      if (!block.isBroken && !block.shouldRemove &&
          position.dx >= block.x && position.dx <= block.x + block.w &&
          position.dy >= block.y && position.dy <= block.y + block.h) {
        
        // ИСПРАВЛЕНО: ХАК ДЛЯ СУНДУКА! Если птица коснулась сундука IvanDrop — она намертво зависает в воздухе!
        if (block.isSecretChest) {
          velocity = Offset.zero; // Полностью гасим скорость снаряда в ноль
          position = Offset(block.x + block.w / 2, block.y - 0.02); // Фиксируем птицу ровно над сундуком
          block.chestCapturedBird = true; // Включаем таймер лора ачивки с клешнёй
          return; // Мгновенно выходим из апдейта, чтобы птица не падала под землю и не удалялась!
        }

        // ИСПРАВЛЕНО: ХАК ДЛЯ ЖЕЛЕЗА! Если ворота не разбиты тапом пальца, птица просто бьётся о них и падает
        if (block.isIronShield) {
          velocity = Offset(-velocity.dx * 0.2, 0.1); // Рикошетит назад
          return;
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
    // ИСПРАВЛЕНО: ЛОГИКА СЕКРЕТНОГО СУНДУКА IVANDROP С КЛЕШНЕЙ И СОХРАНЕНИЕМ МЕДАЛИ
    if (isSecretChest && chestCapturedBird) {
      isSleeping = false; // Пробуждаем сундук из спячки
      chestAnimTimer += dt;
      
      // В самую первую миллисекунду касания запускаем звук фанфар и выдаём ачивку!
      if (chestAnimTimer >= 0.02 && chestAnimTimer < 0.08) {
        SharedPreferences.getInstance().then((prefs) async {
          final alreadyUnlocked = prefs.getBool('achievement_secret_chest') ?? false;
          if (!alreadyUnlocked) {
            await prefs.setBool('achievement_secret_chest', true);
            AudioManager.playAchievement(); // Твой новый победный звук 2.5 секунды!
            game.overlays.add('AchievementToast'); // Выкатываем глянцевый тост наверх
            
            Future.delayed(const Duration(seconds: 5), () {
              game.overlays.remove('AchievementToast');
            });
          }
        });
      }

      // Ровно через 2 секунды (когда клешня "утащила" птицу), сундук красиво удаляется с поля боя
      if (chestAnimTimer >= 2.0) {
        shouldRemove = true;
      }
      return; // Блокируем для сундука стандартную физику падения блоков, чтобы он стоял монолитно
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
        
        if ((y + h - groundY).abs() < 0.005 && (x <= 0.25 || x >= 0.55)) {
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
