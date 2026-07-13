import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide Wallet;

// Главный экран игры с поддержкой оверлеев
class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Создаем единственный экземпляр игры, чтобы кнопка во Flutter-слое могла им управлять
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
                                    game.resumeEngine(); // Снимаем игру с паузы
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
                                    Navigator.pop(context); // Выход в меню уровней
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
            },
          ),
          
          // Рабочая кнопка паузы
          Positioned(
            top: 16,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.pause_rounded, size: 32, color: Colors.white),
              style: IconButton.styleFrom(backgroundColor: Colors.black45, padding: const EdgeInsets.all(10)),
              onPressed: () {
                gameInstance.pauseEngine(); // Полностью останавливаем игровой цикл Flame
                gameInstance.overlays.add('PauseMenu'); // Выводим меню паузы поверх экрана
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
  AngryMolluskGame() : super();

  late Slingshot slingshot;
  List<Bunnyhop> birdsQueue = [];
  Bunnyhop? currentBird;
  bool levelCleared = false;

  static const double worldWidth = 60.0;
  static const double worldHeight = 30.0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Задний фон с анимацией солнца и облаков
    add(BackgroundDecoration());
    
    // СДЕЛАЛИ ЗЕМЛЮ НИЖЕ (теперь острова на высоте Y: 22, а не 18, чтобы здание влезло)
    add(IslandBoundary(Vector2(0, 22), Vector2(14, 30)));   // Левый остров
    add(IslandBoundary(Vector2(34, 22), Vector2(60, 30)));  // Правый остров (отодвинут дальше)

    // Рогатка стоит четко НА ТРАВЕ ( worldPos.y равен высоте острова)
    slingshot = Slingshot(Vector2(8, 22));
    add(slingshot);

    add(DragController());

    // Создаем 3 птиц Баннихопов в очередь
    for (int i = 0; i < 3; i++) {
      final startX = 5.0 - (i * 2.0);
      final startY = i == 0 ? 20.0 : 21.2; // Первая на рогатке, остальные сзади на траве
      final bird = Bunnyhop(Vector2(startX, startY), i == 0);
      birdsQueue.add(bird);
      add(bird);
    }
    currentBird = birdsQueue.first;

    // Строим замок
    _buildLevelStructures();
  }

  void _buildLevelStructures() {
    // Координаты Y пересчитаны под новую низкую землю (высота 22)
    // Каменные опоры (серые)
    add(GameBlock(Vector2(38, 20.5), Vector2(1.2, 3.0), true));
    add(GameBlock(Vector2(42, 20.5), Vector2(1.2, 3.0), true));
    add(GameBlock(Vector2(46, 20.5), Vector2(1.2, 3.0), true));
    add(GameBlock(Vector2(50, 20.5), Vector2(1.2, 3.0), true));
    
    // Каменные перекрытия сверху опор
    add(GameBlock(Vector2(42, 18.5), Vector2(6.8, 1.0), true));
    add(GameBlock(Vector2(48, 18.5), Vector2(5.5, 1.0), true));

    // Деревянные стены первого этажа (коричневые)
    add(GameBlock(Vector2(40, 15.5), Vector2(1.0, 5.0), false));
    add(GameBlock(Vector2(45, 15.5), Vector2(1.0, 5.0), false));
    add(GameBlock(Vector2(49, 15.5), Vector2(1.0, 5.0), false));

    // Деревянный потолок первого этажа
    add(GameBlock(Vector2(44.5, 12.5), Vector2(11.0, 1.2), false));

    // Верхняя деревянная башня
    add(GameBlock(Vector2(42.5, 10.0), Vector2(0.8, 3.8), false));
    add(GameBlock(Vector2(46.5, 10.0), Vector2(0.8, 3.8), false));
    add(GameBlock(Vector2(44.5, 7.5), Vector2(5.0, 1.2), false));

    // РАССТАВЛЯЕМ СВИНЕЙ МАКСИМОВ
    add(MolluskMaksim(Vector2(42.5, 16.5)));   
    add(MolluskMaksim(Vector2(47.0, 16.5)));   
    add(MolluskMaksim(Vector2(44.5, 10.0)));  
  }

  void loadNextBird() {
    if (birdsQueue.isNotEmpty) {
      birdsQueue.removeAt(0);
      if (birdsQueue.isNotEmpty) {
        currentBird = birdsQueue.first;
        currentBird!.jumpToSlingshot(Vector2(8, 20.0));
      } else {
        currentBird = null; 
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Исправлено: Защита от авто-победы. Считаем только Максимов, которые добавлены на сцену
    final pigCount = children.whereType<MolluskMaksim>().length;
    if (pigCount == 0 && !levelCleared && birdsQueue.isNotEmpty) {
      levelCleared = true;
      overlays.add('VictoryMenu');
    }
  }

  Vector2 worldToScreen(Vector2 worldPos) {
    return Vector2(
      (worldPos.x / worldWidth) * canvasSize.x,
      (worldPos.y / worldHeight) * canvasSize.y,
    );
  }
}

class DragController extends Component with DragCallbacks, HasGameRef<AngryMolluskGame> {
  @override
  void onDragUpdate(DragUpdateEvent event) {
    final currentBird = gameRef.currentBird;
    if (currentBird != null && currentBird.isReadyForLaunch && !currentBird.isLaunched) {
      final worldX = (event.localEndPosition.x / gameRef.canvasSize.x) * AngryMolluskGame.worldWidth;
      final worldY = (event.localEndPosition.y / gameRef.canvasSize.y) * AngryMolluskGame.worldHeight;
      currentBird.dragTo(Vector2(worldX, worldY));
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    final currentBird = gameRef.currentBird;
    if (currentBird != null && currentBird.isReadyForLaunch && !currentBird.isLaunched) {
      currentBird.launch();
    }
  }
}

// АНИМАЦИЯ: Солнце крутится, облака плывут
class BackgroundDecoration extends Component with HasGameRef<AngryMolluskGame> {
  double sunRotation = 0.0;
  double cloudOffset1 = 0.0;
  double cloudOffset2 = 0.0;

  @override
  void update(double dt) {
    super.update(dt);
    sunRotation += 0.5 * dt; // Скорость вращения солнца
    cloudOffset1 += 15.0 * dt; // Скорость первого слоя облаков
    cloudOffset2 += 8.0 * dt;  // Скорость второго слоя облаков
  }

  @override
  void render(Canvas canvas) {
    final size = gameRef.canvasSize;
    
    // Небо (Градиент)
    final skyPaint = Paint()..shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF29B6F6), Color(0xFFE1F5FE)],
    ).createShader(Offset.zero & size.toSize());
    canvas.drawRect(Offset.zero & size.toSize(), skyPaint);

    // ДЕТАЛИЗИРОВАННОЕ СОЛНЦЕ С ВРАЩЕНИЕМ СЛЕВА
    final sunCenter = Offset(size.x * 0.15, size.y * 0.2);
    final sunRadius = size.y * 0.09;
    
    canvas.save();
    canvas.translate(sunCenter.dx, sunCenter.y);
    canvas.rotate(sunRotation);
    // Лучи солнца в виде мультяшного скругленного креста
    final rayPaint = Paint()..color = const Color(0xFFFFF59D).withValues(alpha: 0.4);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: sunRadius * 2.8, height: sunRadius * 0.8), Radius.circular(10)), rayPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: sunRadius * 0.8, height: sunRadius * 2.8), Radius.circular(10)), rayPaint);
    canvas.restore();
    
    canvas.drawCircle(sunCenter, sunRadius, Paint()..color = const Color(0xFFFBC02D)); // Ядро солнца

    // МУЛЬТЯШНЫЕ ДВИЖУЩИЕСЯ ОБЛАКА (С эффектом бесконечного цикла)
    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.85);
    
    double c1X = (size.x * 0.3 + cloudOffset1) % (size.x + 200) - 100;
    canvas.drawCircle(Offset(c1X, size.y * 0.15), 30, cloudPaint);
    canvas.drawCircle(Offset(c1X + 30, size.y * 0.13), 40, cloudPaint);
    canvas.drawCircle(Offset(c1X + 70, size.y * 0.15), 35, cloudPaint);

    double c2X = (size.x * 0.7 + cloudOffset2) % (size.x + 200) - 100;
    canvas.drawCircle(Offset(c2X, size.y * 0.22), 25, cloudPaint);
    canvas.drawCircle(Offset(c2X + 30, size.y * 0.2), 35, cloudPaint);

    // Линия прибоя и вода
    canvas.drawRect(Rect.fromLTWH(0, size.y * 0.73, size.x, size.y * 0.02), Paint()..color = const Color(0xFF29B6F6));
    canvas.drawRect(Rect.fromLTWH(0, size.y * 0.75, size.x, size.y * 0.25), Paint()..color = const Color(0xFF0288D1));
  }
}

// Острова (коричневая скала, темные слои, зеленая трава)
class IslandBoundary extends Component with HasGameRef<AngryMolluskGame> {
  final Vector2 start;
  final Vector2 end;

  IslandBoundary(this.start, this.end);

  @override
  void render(Canvas canvas) {
    final pStart = gameRef.worldToScreen(start);
    final pEnd = gameRef.worldToScreen(end);

    canvas.drawRect(Rect.fromLTRB(pStart.x, pStart.y, pEnd.x, pEnd.y), Paint()..color = const Color(0xFF6D4C41));

    // Прослойки земли внутри скалы
    final layerPaint = Paint()..color = const Color(0xFF4E342E)..strokeWidth = 3;
    canvas.drawLine(Offset(pStart.x, pStart.y + 40), Offset(pEnd.x, pStart.y + 45), layerPaint);
    canvas.drawLine(Offset(pStart.x, pStart.y + 90), Offset(pEnd.x, pStart.y + 85), layerPaint);

    // Зеленая трава с зубчиками
    final paintGrass = Paint()..color = const Color(0xFF4CAF50);
    canvas.drawRect(Rect.fromLTWH(pStart.x, pStart.y, pEnd.x - pStart.x, 15), paintGrass);
    
    final grassPath = Path();
    for (double x = pStart.x; x < pEnd.x; x += 12) {
      grassPath.moveTo(x, pStart.y + 14);
      grassPath.lineTo(x + 6, pStart.y + 24);
      grassPath.lineTo(x + 12, pStart.y + 14);
    }
    canvas.drawPath(grassPath, paintGrass);
  }
}

// Рогатка
class Slingshot extends Component with HasGameRef<AngryMolluskGame> {
  final Vector2 worldPos;
  Slingshot(this.worldPos);

  @override
  void render(Canvas canvas) {
    final center = gameRef.worldToScreen(worldPos);
    final thickness = gameRef.canvasSize.x * 0.008;

    final paintFork = Paint()..color = const Color(0xFF4E342E)..strokeWidth = thickness;
    final paintHighlight = Paint()..color = const Color(0xFF8D6E63)..strokeWidth = thickness * 0.3;
    
    // Сдвинули основание рогатки на 5 пикселей вверх, чтобы она стояла ровно НА траве, а не тонула в ней
    canvas.drawLine(Offset(center.x, center.y - 5), Offset(center.x, center.y + gameRef.canvasSize.y * 0.12), paintFork);
    canvas.drawLine(Offset(center.x, center.y - 5), Offset(center.x, center.y + gameRef.canvasSize.y * 0.12), paintHighlight);

    final leftHorn = Offset(center.x - gameRef.canvasSize.x * 0.016, center.y - gameRef.canvasSize.y * 0.04);
    final rightHorn = Offset(center.x + gameRef.canvasSize.x * 0.016, center.y - gameRef.canvasSize.y * 0.04);

    canvas.drawLine(Offset(center.x, center.y - 4), leftHorn, paintFork);
    canvas.drawLine(Offset(center.x, center.y - 4), rightHorn, paintFork);
  }
}

// Класс Баннихопа
class Bunnyhop extends Component with HasGameRef<AngryMolluskGame> {
  Vector2 position;
  final Vector2 startPos;
  bool isReadyForLaunch;
  bool isLaunched = false;
  Vector2? dragPosition;
  Sprite? birdSprite;

  Vector2 velocity = Vector2.zero();
  static const double gravity = 14.0;

  Bunnyhop(this.startPos, this.isReadyForLaunch) : position = Vector2.copy(startPos);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    birdSprite = await gameRef.loadSprite('images/bunnyhop.png');
  }

  void jumpToSlingshot(Vector2 target) {
    position = Vector2.copy(target);
    isReadyForLaunch = true;
  }

  void dragTo(Vector2 target) {
    final slingCenter = gameRef.slingshot.worldPos - Vector2(0, 2.0);
    var dir = target - slingCenter;
    if (dir.length > 2.8) {
      dir = dir.normalized() * 2.8;
    }
    dragPosition = slingCenter + dir;
    position = dragPosition!;
  }

  void launch() {
    isLaunched = true;
    final slingCenter = gameRef.slingshot.worldPos - Vector2(0, 2.0);
    velocity = (slingCenter - position) * 7.5;
    dragPosition = null;

    Future.delayed(const Duration(seconds: 3), () {
      if (gameRef.isMounted) {
        gameRef.loadNextBird();
        removeFromParent(); 
      }
    });
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isLaunched) {
      velocity.y += gravity * dt;
      position += velocity * dt;

      for (final pig in gameRef.children.whereType<MolluskMaksim>()) {
        if ((position - pig.position).length < 2.0) {
          pig.hit(velocity); 
        }
      }

      for (final block in gameRef.children.whereType<GameBlock>()) {
        if (position.x >= block.position.x - block.size.x / 2 &&
            position.x <= block.position.x + block.size.x / 2 &&
            position.y >= block.position.y - block.size.y / 2 &&
            position.y <= block.position.y + block.size.y / 2) {
          block.hit(velocity); 
        }
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final screenPos = gameRef.worldToScreen(position);
    final radius = gameRef.canvasSize.x * 0.022;

    // ИСПРАВЛЕНО: КРАСНАЯ РЕЗИНКА ОТРЕСОВЫВАЕТСЯ ВСЕГДА!
    final center = gameRef.worldToScreen(gameRef.slingshot.worldPos);
    final leftHorn = Offset(center.x - gameRef.canvasSize.x * 0.016, center.y - gameRef.canvasSize.y * 0.04);
    final rightHorn = Offset(center.x + gameRef.canvasSize.x * 0.016, center.y - gameRef.canvasSize.y * 0.04);
    final paintRubber = Paint()..color = const Color(0xFFD32F2F)..strokeWidth = gameRef.canvasSize.x * 0.006;
    
    // Если птица на рогатке (тянем или просто сидит) — цепляем резинки к ней
    if (isReadyForLaunch && !isLaunched) {
      canvas.drawLine(leftHorn, Offset(screenPos.x, screenPos.y), paintRubber);
      canvas.drawLine(rightHorn, Offset(screenPos.x, screenPos.y), paintRubber);
    }

    // Круглая сочная подложка под фото друга
    canvas.drawCircle(Offset(screenPos.x, screenPos.y), radius, Paint()..color = const Color(0xFFE53935));

    // Наложение круглого лица Баннихопа
    if (birdSprite != null) {
      birdSprite!.render(canvas, position: Vector2(screenPos.x - radius, screenPos.y - radius), size: Vector2(radius * 2, radius * 2));
    }

    // Точки траектории полета
    if (dragPosition != null && isReadyForLaunch && !isLaunched) {
      final slingCenter = gameRef.slingshot.worldPos - Vector2(0, 2.0);
      final simVelocity = (slingCenter - position) * 7.5;
      final dotsPaint = Paint()..color = Colors.white;

      for (int i = 1; i < 12; i++) {
        double t = i * 0.12;
        double x = position.x + simVelocity.x * t;
        double y = position.y + simVelocity.y * t + 0.5 * gravity * t * t;
        final dotScreen = gameRef.worldToScreen(Vector2(x, y));
        canvas.drawCircle(Offset(dotScreen.x, dotScreen.y), gameRef.canvasSize.x * 0.004, dotsPaint);
      }
    }
  }
}

class MolluskMaksim extends Component with HasGameRef<AngryMolluskGame> {
  Vector2 position;
  Vector2 velocity = Vector2.zero();
  Sprite? pigSprite;
  bool isFalling = false; 

  MolluskMaksim(Vector2 startPos) : position = Vector2.copy(startPos);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    pigSprite = await gameRef.loadSprite('images/maksim.png');
  }

  void hit(Vector2 birdVelocity) {
    velocity = birdVelocity * 0.6;
    isFalling = true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (isFalling) {
      velocity.y += 14.0 * dt; 
      position += velocity * dt;

      // Разбился об новую низкую землю (Y: 22)
      if (position.y >= 22.0) {
        removeFromParent(); 
      }
    } else {
      bool standOnBlock = false;
      for (final block in gameRef.children.whereType<GameBlock>()) {
        if ((position.x - block.position.x).abs() < block.size.x / 2 &&
            (block.position.y - block.size.y / 2 - position.y).abs() < 1.2) {
          standOnBlock = true;
          break;
        }
      }
      if (!standOnBlock && position.y < 22.0) {
        isFalling = true;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final screenPos = gameRef.worldToScreen(position);
    final radius = gameRef.canvasSize.x * 0.025;

    canvas.drawCircle(Offset(screenPos.x, screenPos.y), radius, Paint()..color = const Color(0xFF4CAF50));

    // Наложение круглого лица Максима Рыбалкина
    if (pigSprite != null) {
      pigSprite!.render(canvas, position: Vector2(screenPos.x - radius, screenPos.y - radius), size: Vector2(radius * 2, radius * 2));
    }
  }
}

// Класс строительного блока
class GameBlock extends Component with HasGameRef<AngryMolluskGame> {
  Vector2 position;
  Vector2 size;
  Vector2 velocity = Vector2.zero();
  final bool isStone;
  bool isFalling = false;

  GameBlock(this.position, this.size, this.isStone);

  void hit(Vector2 birdVelocity) {
    velocity = birdVelocity * 0.5;
    isFalling = true;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Координата Y пересчитана под высоту новой земли 22
    if (!isFalling && position.y < 22.0 - size.y / 2) {
      bool supported = false;
      for (final other in gameRef.children.whereType<GameBlock>()) {
        if (other != this && 
            (other.position.x - position.x).abs() < (size.x + other.size.x) / 2.2 &&
            other.position.y > position.y && 
            (other.position.y - position.y).abs() <= (size.y + other.size.y) / 2 + 0.2) {
          supported = true;
          break;
        }
      }
      if (!supported) isFalling = true;
    }

    if (isFalling) {
      velocity.y += 14.0 * dt; 
      position += velocity * dt;

      for (final pig in gameRef.children.whereType<MolluskMaksim>()) {
        if ((position - pig.position).length < (size.x + size.y) / 3) {
          pig.hit(velocity); // Блок раздавил Максима Рыбалкина
        }
      }

      if (position.y >= 22.0 - size.y / 2) {
        position.y = 22.0 - size.y / 2;
        velocity = Vector2.zero();
        isFalling = false;
      }
      
      if (position.x < 34.0 && position.y >= 22.0) {
        removeFromParent(); // Упал в воду между скалами
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final center = gameRef.worldToScreen(position);
    final sSize = Vector2(
      (size.x / AngryMolluskGame.worldWidth) * gameRef.canvasSize.x,
      (size.y / AngryMolluskGame.worldHeight) * gameRef.canvasSize.y,
    );

    final paint = Paint()
      ..color = isStone ? const Color(0xFFB0BEC5) : const Color(0xFFFFB74D) 
      ..style = PaintingStyle.fill;
    
    final borderPaint = Paint()
      ..color = isStone ? const Color(0xFF455A64) : const Color(0xFFD84315)
      ..style = PaintingStyle.stroke
      ..strokeWidth = gameRef.canvasSize.x * 0.003;

    final rect = Rect.fromCenter(center: Offset(center.x, center.y), width: sSize.x, height: sSize.y);
    canvas.drawRect(rect, paint);
    canvas.drawRect(rect, borderPaint);

    // Мультяшные линии текстур волокон дерева и сколов кирпича
    if (!isStone) {
      final woodPaint = Paint()..color = const Color(0xFFE65100)..strokeWidth = 1.5;
      canvas.drawLine(Offset(rect.left + 5, rect.top + sSize.y * 0.3), Offset(rect.right - 5, rect.top + sSize.y * 0.3), woodPaint);
      canvas.drawLine(Offset(rect.left + 5, rect.top + sSize.y * 0.7), Offset(rect.right - 5, rect.top + sSize.y * 0.7), woodPaint);
    } else {
      final stonePaint = Paint()..color = const Color(0xFF37474F)..strokeWidth = 2;
      canvas.drawLine(Offset(rect.left + sSize.x * 0.3, rect.top), Offset(rect.left + sSize.x * 0.3, rect.bottom), stonePaint);
      canvas.drawLine(Offset(rect.left + sSize.x * 0.7, rect.top), Offset(rect.left + sSize.x * 0.7, rect.bottom), stonePaint);
    }
  }
}

