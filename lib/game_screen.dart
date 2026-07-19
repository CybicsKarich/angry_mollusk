import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide Wallet;
import 'package:angry_mollusk/audio_manager.dart'; // Подключаем наш звуковой движок

// Главный экран игры с поддержкой оверлеев: Победа, Пауза, Проигрыш
class GameScreen extends StatelessWidget {
    GameScreen({super.key});

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(
            game: gameInstance,
            overlayBuilderMap: {
                            // ОВЕРЛЕЙ ПОБЕДЫ СО ЗВЁЗДАМИ
              'VictoryMenu': (BuildContext context, AngryMolluskGame game) {
                int starsCount = 0;
                if (game.score >= game.targetScore3Stars) {
                  starsCount = 3;
                } else if (game.score >= game.targetScore2Stars) {
                  starsCount = 2;
                } else if (game.score >= game.targetScore1Star) {
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
                          "ИТОГОВЫЙ СЧЁТ: ${game.score}",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3E2723), 
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 60, height: 60,
                              decoration: const BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle),
                              child: RawMaterialButton(
                                shape: const CircleBorder(),
                                onPressed: () {
                                  game.overlays.remove('VictoryMenu');
                                  Navigator.pop(context); 
                                },
                                child: const Icon(Icons.home_rounded, color: Colors.white, size: 32),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Container(
                              width: 60, height: 60,
                              decoration: const BoxDecoration(color: Color(0xFFFF9800), shape: BoxShape.circle),
                              child: RawMaterialButton(
                                shape: const CircleBorder(),
                                onPressed: () {
                                  game.overlays.remove('VictoryMenu');
                                  game.score = 0;
                                  game.isVictorySequenceStarted = false;
                                  game.levelCleared = false;
                                  game.buildLevelStructures();
                                },
                                child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 32),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Container(
                              width: 60, height: 60,
                              decoration: BoxDecoration(color: Colors.grey.shade500, shape: BoxShape.circle),
                              child: RawMaterialButton(
                                shape: const CircleBorder(),
                                onPressed: () {},
                                child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 32),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }, // СКОБКА И ЗАПЯТАЯ ЗДЕСЬ СТОЯТ ИДЕАЛЬНО!
              // Оверлей МЕНЮ ПАУЗЫ (Оставляем рабочим)
              'PauseMenu': (BuildContext context, AngryMolluskGame game) {
                return Center(
                  child: Container(
                    width: 260,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            game.overlays.remove('PauseMenu');
                            game.resumeEngine();
                          },
                          child: const Text('ИГРАТЬ'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            },
          ),
          
          // ПОЧИНЕНА КНОПКА ПАУЗЫ В УГЛУ ЭКРАНА
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
        ],
      ),
    );
  }
}

// Главный движок игры
class AngryMolluskGame extends FlameGame with DragCallbacks {
  double groundY = 0.73; // Уровень земли (73% от высоты экрана)
  AngryMolluskGame() : super();

  List<Bunnyhop> birdsQueue = [];
  Bunnyhop? currentBird;
  // Объявляем переменные, которых не хватало компилятору
  double sunRotation = 0.0;
  double cloudOffset1 = 0.0;
  double cloudOffset2 = 0.0;
  double _safetyTimer = 0.0;
  double _pigSoundTimer = 0.0;
  bool isPaused = false;

    // СИСТЕМА ОЧКОВ И ЗВЁЗД
  int score = 0;
  final int targetScore1Star = 200;
  final int targetScore2Stars = 250;
  final int targetScore3Stars = 300;
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

    // Загружаем текстуры для ручного рендеринга
    bunnySprite = await loadSprite('bunnyhop.png');
    maksimSprite = await loadSprite('maksim.png');
    
    // Задний фон (облака, солнце)
    add(BackgroundDecoration());

    // Устанавливаем высоту земли ДО создания птиц, чтобы не было ошибок инициализации
    groundY = 0.73;

    // Создаем 3 птиц Баннихопов в очередь с правильными аргументами Offset
    for (int i = 0; i < 3; i++) {
      final startX = 0.15 - (i * 0.04);
      final startY = i == 0 ? groundY - 0.07 : groundY - 0.04; 
      final bird = Bunnyhop(Offset(startX, startY), i == 0);
      birdsQueue.add(bird);
    }
    currentBird = birdsQueue.first;

    // Вызываем выравнивание и постройку замка
    buildLevelStructures();
  }

   // НОВЫЙ ИДЕАЛЬНО РОВНЫЙ МЕТОД ПОСТРОЙКИ ЗАМКА
    void buildLevelStructures() {
    blocks.clear();
    pigs.clear();

    final double bx = 0.62; 

    // ЭТАЖ 1: Четыре каменные колонны (высота 0.14)
    // Координата Y: groundY (0.73) - высота (0.14) = 0.59
    blocks.add(GameBlock(bx + 0.00, 0.59, 0.02, 0.14, true));
    blocks.add(GameBlock(bx + 0.07, 0.59, 0.02, 0.14, true));
    blocks.add(GameBlock(bx + 0.14, 0.59, 0.02, 0.14, true));
    blocks.add(GameBlock(bx + 0.21, 0.59, 0.02, 0.14, true));
    
    // Каменные перекрытия (высота 0.02) ложатся строго на Y = 0.59. 
    // Значит их Y: 0.59 - 0.02 = 0.57
    blocks.add(GameBlock(bx - 0.01, 0.57, 0.11, 0.02, true));
    blocks.add(GameBlock(bx + 0.13, 0.57, 0.11, 0.02, true));

    // ЭТАЖ 2: Три деревянные стены (высота 0.10) ложатся на перекрытия (на Y = 0.57)
    // Значит их Y: 0.57 - 0.10 = 0.47
    blocks.add(GameBlock(bx + 0.01, 0.47, 0.015, 0.10, false));
    blocks.add(GameBlock(bx + 0.10, 0.47, 0.015, 0.10, false));
    blocks.add(GameBlock(bx + 0.20, 0.47, 0.015, 0.10, false));

    // Деревянный потолок (высота 0.02) ложится на стены (на Y = 0.47)
    // Значит его Y: 0.47 - 0.02 = 0.45
    blocks.add(GameBlock(bx + 0.00, 0.45, 0.23, 0.02, false));

    // ЭТАЖ 3: Башенка (высота 0.08) ложится на потолок (на Y = 0.45)
    // Значит Y стен башни: 0.45 - 0.08 = 0.37
    blocks.add(GameBlock(bx + 0.05, 0.37, 0.015, 0.08, false));
    blocks.add(GameBlock(bx + 0.16, 0.37, 0.015, 0.08, false));
    
    // Крыша башни (высота 0.02) ложится сверху на Y = 0.37
    // Значит её Y: 0.37 - 0.02 = 0.35
    blocks.add(GameBlock(bx + 0.03, 0.35, 0.17, 0.02, false));

    // Свиньи сидят строго на своих этажах без зависания
    pigs.add(MolluskMaksim(bx + 0.035, 0.57 - 0.019)); // На первом перекрытии
    pigs.add(MolluskMaksim(bx + 0.175, 0.57 - 0.019)); // На втором перекрытии
    pigs.add(MolluskMaksim(bx + 0.105, 0.45 - 0.019)); // На деревянном потолке
    
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
        currentBird = null;
        // Если птицы кончились, а свиньи живы — через 3 секунды выводим проиграл
        Future.delayed(const Duration(seconds: 3), () {
          if (pigs.isNotEmpty && !levelCleared && !levelFailed) {
            levelFailed = true;
            AudioManager.playGameOver();
            overlays.add('GameOverMenu');
          }
        });
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isPaused) return;

        // МГНОВЕННАЯ ПОБЕДА С ПОДСЧЁТОМ ОЧКОВ ЗА ПТИЦ
    if (spawnCompleted && pigs.isEmpty && !levelCleared && !levelFailed && !isVictorySequenceStarted) {
      isVictorySequenceStarted = true;
      
      // Добавляем по 70 очков за каждую оставшуюся птицу (включая текущую, если она на рогатке)
      int remainingBirds = birdsQueue.length;
      score += remainingBirds * 70;

      levelCleared = true;
      AudioManager.playVictory(); 
      overlays.add('VictoryMenu');
      return;
    }

    // Анимация облаков и солнца
    sunRotation += 0.3 * dt;
    cloudOffset1 += 0.015 * dt;
    cloudOffset2 += 0.008 * dt;

    // ВОТ ЭТОТ КОД ОБНОВЛЕНИЯ ПТИЦЫ ОБЯЗАТЕЛЬНО ДОЛЖЕН СТОЯТЬ ЗДЕСЬ (В МЕТОДЕ UPDATE):
    if (currentBird != null && currentBird!.isLaunched) {
      currentBird!.update(dt, blocks, pigs, groundY);
      if (currentBird!.shouldRemove) {
        loadNextBird();
      }
    }

        // Обновление падающих блоков (передаем 'this' как ссылку на игру)
    for (var block in blocks) {
      block.update(dt, blocks, pigs, groundY, this);
    }

    // Обновление падающих свиней (передаем 'this' как ссылку на игру)
    for (var pig in pigs) {
      pig.update(dt, blocks, groundY, this);
    }


    // Удаляем уничтоженные объекты
    blocks.removeWhere((b) => b.shouldRemove);
    pigs.removeWhere((p) => p.shouldRemove);

    
      // ЖИВАЯ АТМОСФЕРА: Свиньи случайно сопят или хрюкают раз в 9 секунд, если они еще живы
    if (pigs.isNotEmpty && !levelCleared && !levelFailed) {
      _pigSoundTimer += dt;
      if (_pigSoundTimer >= 9.0) {
        _pigSoundTimer = 0.0; // Сбрасываем таймер
        
        // Подбрасываем монетку: 50% что Максим запетит/засопит
        if (Random().nextBool()) {
          AudioManager.playPigSnort(); // Включает pig_snort.mp3
        }
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final size = canvasSize.toSize(); // Это исправит все ошибки с size.width и size.height!

    // 1. ОТРИСОВКА НЕБА (ГРАДИЕНТ)
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF29B6F6), Color(0xFFE1F5FE)],
        ).createShader(Offset.zero & size);
        canvas.drawRect(Offset.zero & size, skyPaint);

    // 2. ДЕТАЛИЗИРОВАННОЕ ВРАЩАЮЩЕЕСЯ СОЛНЦЕ С КРАСИВЫМИ ЛУЧАМИ СЛЕВА
    final sunCenter = Offset(size.width * 0.15, size.height * 0.2);
    final sunRadius = size.height * 0.08;
    canvas.save();
    canvas.translate(sunCenter.dx, sunCenter.dy);
    canvas.rotate(sunRotation);
    final rayPaint = Paint()..color = const Color(0xFFFFF59D).withValues(alpha: 0.4)..style = PaintingStyle.fill;
    final rayPath = Path();
    for (int i = 0; i < 8; i++) {
      double angle = (i * 2 * pi) / 8;
      double nextAngle = angle + (pi / 8);
      rayPath.moveTo(0, 0);
      rayPath.lineTo(cos(angle) * sunRadius * 2.2, sin(angle) * sunRadius * 2.2);
      rayPath.lineTo(cos(nextAngle) * sunRadius * 1.4, sin(nextAngle) * sunRadius * 1.4);
      rayPath.close();
    }
    canvas.drawPath(rayPath, rayPaint);
    canvas.restore();
    canvas.drawCircle(sunCenter, sunRadius, Paint()..color = const Color(0xFFFBC02D));

    // 3. МУЛЬТЯШНЫЕ ПЛЫВУЩИЕ ОБЛАКА
    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.85);
    double c1X = (size.width * 0.3 + cloudOffset1 * size.width) % (size.width + 200) - 100;
    canvas.drawCircle(Offset(c1X, size.height * 0.15), 30, cloudPaint);
    canvas.drawCircle(Offset(c1X + 35, size.height * 0.12), 42, cloudPaint);
    canvas.drawCircle(Offset(c1X + 75, size.height * 0.15), 32, cloudPaint);

    double c2X = (size.width * 0.65 + cloudOffset2 * size.width) % (size.width + 200) - 100;
    canvas.drawCircle(Offset(c2X, size.height * 0.23), 25, cloudPaint);
    canvas.drawCircle(Offset(c2X + 30, size.height * 0.2), 35, cloudPaint);

    // 4. ГЛУБОКАЯ ВОДА (ОПУЩЕНА В САМЫЙ НИЗ)
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.83, size.width, size.height * 0.02), Paint()..color = const Color(0xFF29B6F6));
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.85, size.width, size.height * 0.15), Paint()..color = const Color(0xFF0288D1));

    // 5. ОТРИСОВКА ОСТРОВОВ С ТЕКСТУРОЙ ЗЕМЛИ И ЗУБЧАТОЙ ТРАВОЙ
    _renderIsland(canvas, size, 0.0, 0.25);
    _renderIsland(canvas, size, 0.55, 1.0);

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

    @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (currentBird != null && currentBird!.isReadyForLaunch && !currentBird!.isLaunched) {
      // Включаем звук натяжения строго ОДИН РАЗ в момент касания пальцем!
      AudioManager.playStretch(); 
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (currentBird != null && currentBird!.isReadyForLaunch && !currentBird!.isLaunched) {
      final size = canvasSize.toSize();
      final touchX = event.localEndPosition.x / size.width;
      final touchY = event.localEndPosition.y / size.height;

      final slingX = 0.15;
      final slingY = groundY - 0.07;

      double dx = touchX - slingX;
      double dy = touchY - slingY;
      double dist = sqrt(dx * dx + dy * dy);

      // Ограничение максимальной длины растяжения резинки
      if (dist > 0.06) {
        dx = (dx / dist) * 0.06;
        dy = (dy / dist) * 0.06;
      }

      currentBird!.position = Offset(slingX + dx, slingY + dy);
    }
  }

    @override
  void onDragEnd(DragEndEvent event) {
    if (currentBird != null && currentBird!.isReadyForLaunch && !currentBird!.isLaunched) {
      AudioManager.stopStretch(); // Глушим звук натяжения рогатки
      AudioManager.playLaunch();  // Стреляем со случайной угарной фразой запуска!
      currentBird!.launch(0.15, groundY - 0.07);
    }
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

    void update(double dt, List<GameBlock> blocks, List<MolluskMaksim> pigs, double groundY) {
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

    // Пролёт сквозь воду (если упала в промежуток между 0.25 и 0.55, летит вниз до дна экрана)
    if (position.dx > 0.25 && position.dx < 0.55 && position.dy >= 0.95) {
      AudioManager.playMiss();
      shouldRemove = true;
      return;
    }

    // Столкновение с кубиками замка (будим их и передаем им траекторию удара!)
    for (var block in blocks) {
      if (!block.isBroken && !block.shouldRemove &&
          position.dx >= block.x && position.dx <= block.x + block.w &&
          position.dy >= block.y && position.dy <= block.y + block.h) {
        block.hit(velocity); // Передаем скорость удара блоку
      }
    }

    // Столкновение со свиньями
    for (var pig in pigs) {
      double dx = position.dx - pig.x;
      double dy = position.dy - pig.y;
      if (sqrt(dx * dx + dy * dy) < 0.03) {
        pig.hit(velocity);
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


       // ИСПРАВЛЕНО: Теперь метод принимает ровно 3 аргумента, и ошибка компиляции исчезнет!
  void update(double dt, List<GameBlock> blocks, double groundY) {
    if (isFalling) {
      vy += 1.8 * dt; // Гравитация свиньи
      x += vx * dt;
      y += vy * dt;

      // Удар об землю острова
      if (y >= groundY - 0.02) {
        gameInstance.score += 50;
        shouldRemove = true; // Умер от удара о скалу
      }
    } else {
      // Проверка опоры: если кубик под свиньей улетел, она падает
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
    // Если блок спит — он физически не может упасть или сдвинуться сам по себе
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
        gameInstance.score += isStone ? 30 : 20; // начисляем через глобальный синглтон
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
        // Проверяем, упал ли он на сушу острова, а не в воду (вода между 0.25 и 0.55)
        if (x <= 0.25 || x >= 0.55) {
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
