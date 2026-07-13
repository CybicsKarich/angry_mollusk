import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide Wallet;

// Главный экран-виджет, который запускает игру и содержит оверлей победы
class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(
            game: AngryMolluskGame(),
            overlayBuilderMap: {
              'VictoryMenu': (BuildContext context, AngryMolluskGame game) {
                return Center(
                  child: Container(
                    width: 340,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.85), // Чёрный мультяшный фон
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange, width: 4), // Оранжевая обводка
                      boxShadow: const [
                        BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 5)),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'ТЫ ПОБЕДИЛ, КРАСАВЧИК!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
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
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text(
                              'К УРОВНЯМ',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            },
          ),
          Positioned(
            top: 16,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, size: 32, color: Colors.white),
              style: IconButton.styleFrom(backgroundColor: Colors.black45),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}

// Главный движок игры
class AngryMolluskGame extends FlameGame with DragCallbacks {
  late Slingshot slingshot;
  List<Bunnyhop> birdsQueue = [];
  Bunnyhop? currentBird;
  bool levelCleared = false;

  // Размеры виртуального мира в метрах
  static const double worldWidth = 50.0;
  static const double worldHeight = 25.0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Декоративный фон
    add(BackgroundDecoration());

    // Добавляем острова (Левый под рогатку, Правый под замок)
    add(IslandBoundary(Vector2(0, 16), Vector2(14, 25)));  
    add(IslandBoundary(Vector2(24, 16), Vector2(50, 25))); 

    // Ставим рогатку
    slingshot = Slingshot(Vector2(8, 16));
    add(slingshot);

    // Подключаем стабильный контроллер жестов тача
    add(DragController());

    // Очередь из 3 Баннихопов
    for (int i = 0; i < 3; i++) {
      final startX = 5.0 - (i * 2.0);
      final startY = i == 0 ? 14.5 : 15.2; 
      final bird = Bunnyhop(Vector2(startX, startY), i == 0);
      birdsQueue.add(bird);
      add(bird);
    }
    currentBird = birdsQueue.first;

    // СТРОИМ ЗАМОК ИЗ КАРТИНКИ
    // Нижние каменные опоры (серые)
    add(GameBlock(Vector2(29, 14.5), Vector2(1.2, 3.0), true));
    add(GameBlock(Vector2(33, 14.5), Vector2(1.2, 3.0), true));
    add(GameBlock(Vector2(37, 14.5), Vector2(1.2, 3.0), true));
    add(GameBlock(Vector2(41, 14.5), Vector2(1.2, 3.0), true));
    
    // Каменные перекрытия сверху опор
    add(GameBlock(Vector2(33, 12.5), Vector2(6.8, 1.0), true));
    add(GameBlock(Vector2(39, 12.5), Vector2(5.5, 1.0), true));

    // Деревянные стены первого этажа (коричневые)
    add(GameBlock(Vector2(31, 9.5), Vector2(1.0, 5.0), false));
    add(GameBlock(Vector2(36, 9.5), Vector2(1.0, 5.0), false));
    add(GameBlock(Vector2(40, 9.5), Vector2(1.0, 5.0), false));

    // Деревянный потолок первого этажа
    add(GameBlock(Vector2(35.5, 6.5), Vector2(11.0, 1.2), false));

    // Верхняя деревянная башня
    add(GameBlock(Vector2(33.5, 4.0), Vector2(0.8, 3.8), false));
    add(GameBlock(Vector2(37.5, 4.0), Vector2(0.8, 3.8), false));
    add(GameBlock(Vector2(35.5, 1.5), Vector2(5.0, 1.2), false));

    // РАССТАВЛЯЕМ СВИНЕЙ МАКСИМОВ С ТОЧНОСТЬЮ КАК НА ФОТО
    add(MolluskMaksim(Vector2(33, 10.5)));   
    add(MolluskMaksim(Vector2(38, 10.5)));   
    add(MolluskMaksim(Vector2(35.5, 4.0)));  
  }

  void loadNextBird() {
    if (birdsQueue.isNotEmpty) {
      birdsQueue.removeAt(0);
      if (birdsQueue.isNotEmpty) {
        currentBird = birdsQueue.first;
        currentBird!.jumpToSlingshot(Vector2(8, 14.5));
      } else {
        currentBird = null; 
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Проверка на победу
    final pigCount = children.whereType<MolluskMaksim>().length;
    if (pigCount == 0 && !levelCleared) {
      levelCleared = true;
      overlays.add('VictoryMenu');
    }
  }

  // Конвертация игровых метров в пиксели экрана при рисовании
  Vector2 worldToScreen(Vector2 worldPos) {
    return Vector2(
      (worldPos.x / worldWidth) * canvasSize.x,
      (worldPos.y / worldHeight) * canvasSize.y,
    );
  }
}

// Контроллер жестов
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

// Задний план: Небо, Солнце, Вода
class BackgroundDecoration extends Component with HasGameRef<AngryMolluskGame> {
  @override
  void render(Canvas canvas) {
    final size = gameRef.canvasSize;
    
    final skyPaint = Paint()..shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF4FC3F7), Color(0xFFE1F5FE)],
    ).createShader(Offset.zero & size.toSize());
    canvas.drawRect(Offset.zero & size.toSize(), skyPaint);

    canvas.drawCircle(Offset(size.x * 0.8, size.y * 0.18), size.y * 0.1, Paint()..color = const Color(0xFFFFF176));

    final waterPaint = Paint()..color = const Color(0xFF1565C0);
    canvas.drawRect(Rect.fromLTWH(0, size.y * 0.75, size.x, size.y * 0.25), waterPaint);
  }
}

// Класс Островов
class IslandBoundary extends Component with HasGameRef<AngryMolluskGame> {
  final Vector2 start;
  final Vector2 end;

  IslandBoundary(this.start, this.end);

  @override
  void render(Canvas canvas) {
    final pStart = gameRef.worldToScreen(start);
    final pEnd = gameRef.worldToScreen(end);

    final paintGround = Paint()..color = const Color(0xFF795548);
    canvas.drawRect(Rect.fromLTRB(pStart.x, pStart.y, pEnd.x, pEnd.y), paintGround);

    final paintGrass = Paint()..color = const Color(0xFF4CAF50);
    canvas.drawRect(Rect.fromLTWH(pStart.x, pStart.y, pEnd.x - pStart.x, gameRef.canvasSize.y * 0.02), paintGrass);
  }
}

// Визуальный класс Рогатки
class Slingshot extends Component with HasGameRef<AngryMolluskGame> {
  final Vector2 worldPos;
  Slingshot(this.worldPos);

  @override
  void render(Canvas canvas) {
    final center = gameRef.worldToScreen(worldPos);
    final thickness = gameRef.canvasSize.x * 0.008;

    final paintFork = Paint()..color = const Color(0xFF5D4037)..strokeWidth = thickness;
    canvas.drawLine(Offset(center.x, center.y), Offset(center.x, center.y + gameRef.canvasSize.y * 0.12), paintFork);
    canvas.drawLine(Offset(center.x, center.y), Offset(center.x - gameRef.canvasSize.x * 0.015, center.y - gameRef.canvasSize.y * 0.05), paintFork);
    canvas.drawLine(Offset(center.x, center.y), Offset(center.x + gameRef.canvasSize.x * 0.015, center.y - gameRef.canvasSize.y * 0.05), paintFork);
  }
}

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
    try {
      birdSprite = await gameRef.loadSprite('images/bunnyhop.png');
    } catch (e) {
      debugPrint("bunnyhop.png пока отсутствует: $e");
    }
  }

  void jumpToSlingshot(Vector2 target) {
    position = Vector2.copy(target);
    isReadyForLaunch = true;
  }

  void dragTo(Vector2 target) {
    final slingCenter = gameRef.slingshot.worldPos - Vector2(0, 0.5);
    var dir = target - slingCenter;
    if (dir.length > 2.5) {
      dir = dir.normalized() * 2.5;
    }
    dragPosition = slingCenter + dir;
    position = dragPosition!;
  }

  void launch() {
    isLaunched = true;
    final slingCenter = gameRef.slingshot.worldPos - Vector2(0, 0.5);
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

      // Проверяем столкновения со свиньями
      for (final pig in gameRef.children.whereType<MolluskMaksim>()) {
        if ((position - pig.position).length < 1.8) {
          pig.hit(velocity); 
        }
      }

      // Проверяем столкновения со строительными блоками
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

    if (dragPosition != null && isReadyForLaunch && !isLaunched) {
      final sCenter = gameRef.worldToScreen(gameRef.slingshot.worldPos - Vector2(0, 0.5));
      final paintRubber = Paint()..color = Colors.red..strokeWidth = gameRef.canvasSize.x * 0.005;
      canvas.drawLine(Offset(sCenter.x - 10, sCenter.y), Offset(screenPos.x, screenPos.y), paintRubber);
      canvas.drawLine(Offset(sCenter.x + 10, sCenter.y), Offset(screenPos.x, screenPos.y), paintRubber);
    }

    canvas.drawCircle(Offset(screenPos.x, screenPos.y), radius, Paint()..color = Colors.red);

    if (birdSprite != null) {
      birdSprite!.render(
        canvas,
        position: Vector2(screenPos.x - radius, screenPos.y - radius),
        size: Vector2(radius * 2, radius * 2),
      );
    }

    if (dragPosition != null && isReadyForLaunch && !isLaunched) {
      final slingCenter = gameRef.slingshot.worldPos - Vector2(0, 0.5);
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

// КЛАСС СВИНЬИ С ФИЗИКОЙ ПАДЕНИЯ И ГРАВИТАЦИЕЙ
class MolluskMaksim extends Component with HasGameRef<AngryMolluskGame> {
  Vector2 position;
  Vector2 velocity = Vector2.zero();
  Sprite? pigSprite;
  bool isFalling = true;

  MolluskMaksim(Vector2 startPos) : position = Vector2.copy(startPos);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    try {
      pigSprite = await gameRef.loadSprite('images/maksim.png');
    } catch (e) {
      debugPrint("maksim.png пока отсутствует: $e");
    }
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

      if (position.y >= 16.0) {
        position.y = 16.0;
        velocity = Vector2.zero();
        isFalling = false;
        removeFromParent(); 
      }

      if (position.x < 24.0 && position.y >= 16.0) {
        removeFromParent(); 
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final screenPos = gameRef.worldToScreen(position);
    final radius = gameRef.canvasSize.x * 0.025;

    canvas.drawCircle(Offset(screenPos.x, screenPos.y), radius, Paint()..color = Colors.green);

    if (pigSprite != null) {
      pigSprite!.render(
        canvas,
        position: Vector2(screenPos.x - radius, screenPos.y - radius),
        size: Vector2(radius * 2, radius * 2),
      );
    }
  }
}

// КЛАСС СТРОИТЕЛЬНОГО БЛОКА С ЧЕСТНОЙ ГРАВИТАЦИЕЙ И РАЗРУШЕНИЕМ
class GameBlock extends Component with HasGameRef<AngryMolluskGame> {
  Vector2 position;
  Vector2 size;
  Vector2 velocity = Vector2.zero();
  final bool isStone;
  bool isFalling = false;

  GameBlock(this.position, this.size, this.isStone);

  void hit(Vector2 birdVelocity) {
    velocity = birdVelocity * 0.4;
    isFalling = true;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!isFalling && position.y < 16.0 - size.y / 2) {
      bool supported = false;
      for (final other in gameRef.children.whereType<GameBlock>()) {
        if (other != this && 
            (other.position.x - position.x).abs() < (size.x + other.size.x) / 3 &&
            other.position.y > position.y && 
            (other.position.y - position.y).abs() <= (size.y + other.size.y) / 2 + 0.2) {
          supported = true;
          break;
        }
      }
      if (!supported) {
        isFalling = true;
      }
    }

    if (isFalling) {
      velocity.y += 14.0 * dt; 
      position += velocity * dt;

      for (final pig in gameRef.children.whereType<MolluskMaksim>()) {
        if ((position - pig.position).length < (size.x + size.y) / 3) {
          pig.hit(velocity); 
        }
      }

      if (position.y >= 16.0 - size.y / 2) {
        position.y = 16.0 - size.y / 2;
        velocity = Vector2.zero();
        isFalling = false;
      }
      
      if (position.x < 24.0 && position.y >= 16.0) {
        removeFromParent();
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
      ..color = isStone ? const Color(0xFF9E9E9E) : const Color(0xFFFFB74D)
      ..style = PaintingStyle.fill;
    
    final borderPaint = Paint()
      ..color = isStone ? const Color(0xFF616161) : const Color(0xFFE65100)
      ..style = PaintingStyle.stroke
      ..strokeWidth = gameRef.canvasSize.x * 0.002;

    final rect = Rect.fromCenter(center: Offset(center.x, center.y), width: sSize.x, height: sSize.y);
    canvas.drawRect(rect, paint);
    canvas.drawRect(rect, borderPaint);
  }
}

