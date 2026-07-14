import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide Wallet;

// Главный экран игры с поддержкой оверлеев: Победа, Пауза, Проигрыш
class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameInstance = AngryMolluskGame();

    return Scaffold(
      body: Stack(
        children: [
          GameWidget(
            game: gameInstance,
            overlayBuilderMap: {
              // Оверлей ПОБЕДЫ
              'VictoryMenu': (BuildContext context, AngryMolluskGame game) {
                return Center(
                  child: Container(
                    width: 340,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange, width: 4),
                      boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 5))],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'ТЫ ПОБЕДИЛ, КРАСАВЧИК!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              game.overlays.remove('VictoryMenu');
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            child: const Text('К УРОВНЯМ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              // Оверлей ПАУЗЫ
              'PauseMenu': (BuildContext context, AngryMolluskGame game) {
                return Center(
                  child: Container(
                    width: 340,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.redAccent, width: 4),
                      boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 5))],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'ПАУЗА',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () {
                                    game.resumeEngine();
                                    game.overlays.remove('PauseMenu');
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                  child: const Text('ИГРАТЬ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () {
                                    game.resumeEngine();
                                    game.overlays.remove('PauseMenu');
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade800, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                  child: const Text('В МЕНЮ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
              // Оверлей ПРОИГРЫША
              'GameOverMenu': (BuildContext context, AngryMolluskGame game) {
                return Center(
                  child: Container(
                    width: 340,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.red, width: 4),
                      boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 5))],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'ПТИЦЫ КОНЧИЛИСЬ!\nМАКСИМ ПОБЕДИЛ!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2, height: 1.4),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              game.overlays.remove('GameOverMenu');
                              Navigator.replace(context, oldRoute: ModalRoute.of(context)!, newRoute: MaterialPageRoute(builder: (context) => const GameScreen()));
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            child: const Text('ПОВТОР ЗАПУСКА', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            },
          ),
          
          // Кнопка Паузы
          Positioned(
            top: 16,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.pause_rounded, size: 32, color: Colors.white),
              style: IconButton.styleFrom(backgroundColor: Colors.black45, padding: const EdgeInsets.all(10)),
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
  bool isPaused = false;

  // Контейнеры для управления объектами безForge2D
  List<GameBlock> blocks = [];
  List<MolluskMaksim> pigs = [];

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

    // Загружаем текстуры для ручного рендеринга
    bunnySprite = await loadSprite('bunnyhop.png');
    maksimSprite = await loadSprite('maksim.png');
    // Задний фон (облака, солнце)
    add(BackgroundDecoration());

        // Создаем 3 птиц Баннихопов в очередь с правильными аргументами Offset
    for (int i = 0; i < 3; i++) {
      final startX = 0.15 - (i * 0.04);
      final startY = i == 0 ? groundY - 0.04 : groundY - 0.02; 
      final bird = Bunnyhop(Offset(startX, startY), i == 0);
      birdsQueue.add(bird);
    }
    currentBird = birdsQueue.first;

    // СТРОИМ ЗАМОК (Координаты привязаны к процентам от экрана смартфона)
    double baseGridX = 0.65; // Начало замка на правом острове
    groundY = 0.73;

    // Каменные вертикальные опоры (серые)
    blocks.add(GameBlock(baseGridX, groundY - 0.1, 0.02, 0.1, true));
    blocks.add(GameBlock(baseGridX + 0.06, groundY - 0.1, 0.02, 0.1, true));
    blocks.add(GameBlock(baseGridX + 0.12, groundY - 0.1, 0.02, 0.1, true));
    blocks.add(GameBlock(baseGridX + 0.18, groundY - 0.1, 0.02, 0.1, true));
    
        // Каменные плиты перекрытия сверху опор
    blocks.add(GameBlock(baseGridX + 0.03, groundY - 0.155, 0.1, 0.015, true));
    blocks.add(GameBlock(baseGridX + 0.15, groundY - 0.155, 0.08, 0.015, true));

    // Деревянные стены первого этажа (коричневые)
    blocks.add(GameBlock(baseGridX + 0.02, groundY - 0.205, 0.015, 0.085, false));
    blocks.add(GameBlock(baseGridX + 0.09, groundY - 0.205, 0.015, 0.085, false));
    blocks.add(GameBlock(baseGridX + 0.15, groundY - 0.205, 0.015, 0.085, false));

    // Деревянный потолок первого этажа
    blocks.add(GameBlock(baseGridX + 0.085, groundY - 0.252, 0.16, 0.015, false));

    // Верхняя деревянная башня
    blocks.add(GameBlock(baseGridX + 0.05, groundY - 0.292, 0.015, 0.065, false));
    blocks.add(GameBlock(baseGridX + 0.12, groundY - 0.292, 0.015, 0.065, false));
    blocks.add(GameBlock(baseGridX + 0.085, groundY - 0.33, 0.10, 0.015, false));

    // РАССТАНОВКА СВИНЕЙ МАКСИМОВ
    pigs.add(MolluskMaksim(baseGridX + 0.055, groundY - 0.185)); // Левый нижний
    pigs.add(MolluskMaksim(baseGridX + 0.12, groundY - 0.185));  // Правый нижний
    pigs.add(MolluskMaksim(baseGridX + 0.085, groundY - 0.285)); // Верхний в башне
  }

  void loadNextBird() {
    if (birdsQueue.isNotEmpty) {
      birdsQueue.removeAt(0);
      if (birdsQueue.isNotEmpty) {
        currentBird = birdsQueue.first;
        currentBird!.position = Offset(0.15, groundY - 0.04);
        currentBird!.isReadyForLaunch = true;
      } else {
        currentBird = null;
        // Если птицы кончились, а свиньи живы — через 3 секунды выводим проиграл
        Future.delayed(const Duration(seconds: 3), () {
          if (pigs.isNotEmpty && !levelCleared && !levelFailed) {
            levelFailed = true;
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

    // Анимация облаков и солнца
    sunRotation += 0.3 * dt;
    cloudOffset1 += 0.015 * dt;
    cloudOffset2 += 0.008 * dt;

    // Обновление летящей птицы
    if (currentBird != null && currentBird!.isLaunched) {
      currentBird!.update(dt, blocks, pigs, groundY);
      if (currentBird!.shouldRemove) {
        loadNextBird();
      }
    }

    // Обновление падающих блоков и цепных реакций
    for (var block in blocks) {
      block.update(dt, blocks, pigs, groundY);
    }

    // Обновление падающих свиней
    for (var pig in pigs) {
      pig.update(dt, blocks, groundY);
    }

    // Удаляем уничтоженные объекты
    blocks.removeWhere((b) => b.shouldRemove);
    pigs.removeWhere((p) => p.shouldRemove);

    // ЖЕЛЕЗНАЯ ЗАЩИТА ОТ АВТОПОБЕДЫ: Уровень не может быть пройден в первые 2 секунды
    _safetyTimer += dt;
    if (_safetyTimer < 2.0) return;

    if (pigs.isEmpty && !levelCleared && !levelFailed) {
      levelCleared = true;
      overlays.add('VictoryMenu');
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
    for (var pig in pigs) {
      pig.render(canvas, size, maksimSprite);
    }
    if (currentBird != null && (!currentBird!.isLaunched || !currentBird!.shouldRemove)) {
      currentBird!.render(canvas, size, bunnySprite);
    }
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
  void onDragUpdate(DragUpdateEvent event) {
    if (currentBird != null && currentBird!.isReadyForLaunch && !currentBird!.isLaunched) {
      final size = canvasSize.toSize();
      final touchX = event.localEndPosition.x / size.width;
      final touchY = event.localEndPosition.y / size.height;

      final slingX = 0.15;
      final slingY = groundY - 0.04;

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
      currentBird!.launch(0.15, groundY - 0.04);
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

        // Влияние гравитации на вектор скорости снаряда
        // Слабая гравитация для затяжного красивого полёта
    velocity = Offset(velocity.dx, velocity.dy + 0.35 * dt);
    position = Offset(position.dx + velocity.dx * dt, position.dy + velocity.dy * dt);

    // Столкновение с кубиками замка Максима
    for (var block in blocks) {
      if (!block.isFalling &&
          position.dx >= block.x && position.dx <= block.x + block.w &&
          position.dy >= block.y && position.dy <= block.y + block.h) {
        block.hit(velocity);
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

      @override
  void render(Canvas canvas, Size size, Sprite? sprite) {
    final screenPos = Offset(size.width * position.dx, size.height * position.dy);
    final radius = size.width * 0.016;

    // 1. Сначала рисуем базовый красный круг-подложку
    canvas.drawCircle(screenPos, radius, Paint()..color = const Color(0xFFE53935));

    // 2. Затем накладываем лицо Баннихопа из ассетов
    if (sprite != null) {
      sprite.render(canvas, position: Vector2(screenPos.dx - radius, screenPos.dy - radius), size: Vector2(radius * 2, radius * 2));
    }

    // 3. ТЕПЕРЬ ПЕРЫШКИ РИСУЮТСЯ ПОВЕРХ СПРАЙТА! Они точно не исчезнут
    final featherPaint = Paint()..color = const Color(0xFFD32F2F)..style = PaintingStyle.fill;
    final featherPath = Path();
    // Левое пёрышко
    featherPath.moveTo(screenPos.dx - radius * 0.3, screenPos.dy - radius);
    featherPath.lineTo(screenPos.dx - radius * 0.5, screenPos.dy - radius * 1.4);
    featherPath.lineTo(screenPos.dx, screenPos.dy - radius * 0.8);
    // Правое пёрышко
    featherPath.moveTo(screenPos.dx, screenPos.dy - radius * 0.8);
    featherPath.lineTo(screenPos.dx + radius * 0.2, screenPos.dy - radius * 1.5);
    featherPath.lineTo(screenPos.dx + radius * 0.3, screenPos.dy - radius);
    featherPath.close();
    canvas.drawPath(featherPath, featherPaint);

    // 4. Траектория полёта белыми точками
    if (isReadyForLaunch && !isLaunched && position.dx != 0.15) {
      final dotsPaint = Paint()..color = Colors.white;
      final slingX = 0.15;
      final slingY = gameRef.groundY - 0.04;
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
    vx = birdVelocity.dx * 0.5;
    vy = birdVelocity.dy * 0.5;
    isFalling = true;
  }

  void update(double dt, List<GameBlock> blocks, double groundY) {
        // Свиньи не падают и не умирают сами на старте уровня
    if (gameRef._safetyTimer < 1.5) {
      isFalling = false;
      vx = 0;
      vy = 0;
      return;
    }
    if (isFalling) {
      vy += 1.8 * dt; // Гравитация свиньи
      x += vx * dt;
      y += vy * dt;

      // Удар об землю острова
      if (y >= groundY - 0.02) {
        shouldRemove = true; // Умер от удара о скалу
      }
    } else {
      // Проверка опоры: если кубик под свиньей улетел, она падает
      bool supported = false;
      for (var block in blocks) {
        if (x >= block.x && x <= block.x + block.w && (block.y - y).abs() < 0.03) {
          supported = true;
          break;
        }
      }
      if (!supported && y < groundY - 0.02) {
        isFalling = true;
      }
    }
  }

    @override
  void render(Canvas canvas, Size size, Sprite? sprite) {
    final screenPos = Offset(size.width * x, size.height * y);
    final radius = size.width * 0.019;

    // 1. Базовый зеленый круг
    canvas.drawCircle(screenPos, radius, Paint()..color = const Color(0xFF4CAF50));

    // 2. Накладываем лицо Максима Рыбалкина
    if (sprite != null) {
      sprite.render(canvas, position: Vector2(screenPos.dx - radius, screenPos.dy - radius), size: Vector2(radius * 2, radius * 2));
    }

    // 3. ТЕПЕРЬ ЗЕЛЕНЫЕ УШИ РИСУЮТСЯ ПОВЕРХ ЛИЦА!
    final earPaint = Paint()..color = const Color(0xFF4CAF50)..style = PaintingStyle.fill;
    final earBorderPaint = Paint()..color = const Color(0xFF2E7D32)..style = PaintingStyle.stroke..strokeWidth = 1.5;
    
    // Левое ушко (смещено влево и чуть вверх относительно центра screenPos)
    canvas.drawOval(Rect.fromCenter(center: Offset(screenPos.dx - radius * 0.8, screenPos.dy - radius * 0.6), width: radius * 0.6, height: radius * 0.8), earPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(screenPos.dx - radius * 0.8, screenPos.dy - radius * 0.6), width: radius * 0.6, height: radius * 0.8), earBorderPaint);
    
    // Правое ушко (смещено вправо и чуть вверх)
    canvas.drawOval(Rect.fromCenter(center: Offset(screenPos.dx + radius * 0.8, screenPos.dy - radius * 0.6), width: radius * 0.6, height: radius * 0.8), earPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(screenPos.dx + radius * 0.8, screenPos.dy - radius * 0.6), width: radius * 0.6, height: radius * 0.8), earBorderPaint);
  }
}

// КЛАСС СТРОИТЕЛЬНОГО БЛОКА С ЦЕПНЫМИ РАЗРУШЕНИЯМИ И МАТЕРИАЛАМИ
class GameBlock {
  double x, y, w, h;
  final bool isStone;
  double vx = 0.0, vy = 0.0;
  bool isFalling = false;
  bool shouldRemove = false;

  GameBlock(this.x, this.y, this.w, this.h, this.isStone);

  void hit(Offset impactVelocity) {
    vx = impactVelocity.dx * 0.45;
    vy = impactVelocity.dy * 0.45;
    isFalling = true;
  }

  void update(double dt, List<GameBlock> allBlocks, List<MolluskMaksim> allPigs, double groundY) {
       // ЖЕЛЕЗНЫЙ ФИКС: Замок стоит намертво первые 1.5 секунды и не рушится сам!
    if (gameRef._safetyTimer < 1.5) {
      isFalling = false;
      vx = 0;
      vy = 0;
      return;
    }

    // ПОЧИНЕНО: Блоки больше не падают сами по себе на старте уровня!
    if (!isFalling && y < groundY - h) {
      bool hasFloor = false;
      // Если блок стоит прямо на земле острова — опора железно есть
      if ((y + h - groundY).abs() < 0.005) {
        hasFloor = true;
      } else {
        // Проверяем, стоит ли блок на другом блоке с хорошим зазором
        for (var other in allBlocks) {
          if (other != this &&
              (other.x - x).abs() < (w + other.w) * 0.48 && // Четкое совпадение по ширине
              other.y > y && 
              (other.y - (y + h)).abs() < 0.02) { // Увеличенный зазор для стабильности
            hasFloor = true;
            break;
          }
        }
      }
      if (!hasFloor) isFalling = true;
    }

    if (isFalling) {
      vy += 1.8 * dt; // Гравитация блока
      x += vx * dt;
      y += vy * dt;

      // ЛАВИНА И СТОЛКНОВЕНИЯ: Толкаем соседние блоки
      for (var other in allBlocks) {
        if (other != this && !other.isFalling) {
          if ((x - other.x).abs() < (w + other.w) / 2 && (y - other.y).abs() < (h + other.h) / 2) {
            other.hit(Offset(vx * 0.75, vy * 0.75));
          }
        }
      }

      // Падающие блоки давят свиней Максимов под собой
      for (var pig in allPigs) {
        if (!pig.isFalling) {
          if (pig.x >= x && pig.x <= x + w && (pig.y - y).abs() < (h / 2 + 0.02)) {
            pig.hit(Offset(vx * 0.8, vy * 0.8));
          }
        }
      }

      // Приземление на твердый остров
      if (y >= groundY - h) {
        y = groundY - h;
        vx = 0;
        vy = 0;
        isFalling = false;
      }

      // Падение в океан между скалами
      if (x < 0.55 && y >= groundY - h / 2 && x > 0.25) {
        shouldRemove = true;
      }
    }
  }

  void render(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(size.width * x, size.height * y, size.width * w, size.height * h);

    final blockPaint = Paint()
      ..color = isStone ? const Color(0xFFB0BEC5) : const Color(0xFFFFB74D)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = isStone ? const Color(0xFF455A64) : const Color(0xFFD84315)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRect(rect, blockPaint);
    canvas.drawRect(rect, borderPaint);

    // ДЕТАЛИЗАЦИЯ: Узоры волокон дерева или швов кирпича
    if (!isStone) {
      final woodPaint = Paint()..color = const Color(0xFFE65100)..strokeWidth = 1.2;
      canvas.drawLine(Offset(rect.left + 3, rect.top + rect.height * 0.35), Offset(rect.right - 3, rect.top + rect.height * 0.35), woodPaint);
      canvas.drawLine(Offset(rect.left + 3, rect.top + rect.height * 0.7), Offset(rect.right - 3, rect.top + rect.height * 0.7), woodPaint);
    } else {
      final stonePaint = Paint()..color = const Color(0xFF37474F)..strokeWidth = 1.5;
      canvas.drawLine(Offset(rect.left + rect.width * 0.3, rect.top + 2), Offset(rect.left + rect.width * 0.3, rect.bottom - 2), stonePaint);
      canvas.drawLine(Offset(rect.left + rect.width * 0.7, rect.top + 2), Offset(rect.left + rect.width * 0.7, rect.bottom - 2), stonePaint);
    }
  }
}

// Класс заднего фона: рисует градиент неба, вращающееся солнце и движущиеся облака
class BackgroundDecoration extends Component with HasGameRef<AngryMolluskGame> {
  @override
  void render(Canvas canvas) {
  }
}       
