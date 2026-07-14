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
                              // Перезапускаем уровень, просто заново открывая GameScreen
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
          
          // Рабочая кнопка паузы
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
  AngryMolluskGame() : super();

  late Slingshot slingshot;
  List<Bunnyhop> birdsQueue = [];
  Bunnyhop? currentBird;
  bool levelCleared = false;
  bool levelFailed = false;
  bool spawnCompleted = false;

  static const double worldWidth = 60.0;
  static const double worldHeight = 30.0;

    @override
  Future<void> onLoad() async {
    await super.onLoad();

    // ЖЕЛЕЗНОЕ ИСПРАВЛЕНИЕ: Добавляем мир и камеру Flame на сцену, чтобы объекты появились на экране!
    add(world);
    add(camera);
    // НАСТРОЙКА КАМЕРЫ: Наводим объектив на центр нашего игрового мира (30, 15)
    camera.viewfinder.position = Vector2(30, 15);
    // Настраиваем зум, чтобы весь мир шириной 60 метров чётко вписался в экран смартфона
    camera.viewfinder.anchor = Anchor.center;
    camera.viewfinder.zoom = canvasSize.x / worldWidth;


    // Задний фон крепим к корню
    add(BackgroundDecoration());
    
    // Все физические объекты теперь правильно прописываем в world
    world.add(IslandBoundary(Vector2(0, 22), Vector2(14, 30)));   
    world.add(IslandBoundary(Vector2(34, 22), Vector2(60, 30)));  

    slingshot = Slingshot(Vector2(8, 22));
    world.add(slingshot);

    add(DragController());

    // Создаем 3 птиц Баннихопов в очередь внутри world
    for (int i = 0; i < 3; i++) {
      final startX = 5.0 - (i * 2.0);
      final startY = i == 0 ? 20.0 : 21.2; 
      final bird = Bunnyhop(Vector2(startX, startY), i == 0);
      birdsQueue.add(bird);
      world.add(bird);
    }
    currentBird = birdsQueue.first;

    _buildLevelStructures();
  }


    void _buildLevelStructures() {
    // Каменные опоры (серые)
    world.add(GameBlock(Vector2(38, 20.5), Vector2(1.2, 3.0), true));
    world.add(GameBlock(Vector2(42, 20.5), Vector2(1.2, 3.0), true));
    world.add(GameBlock(Vector2(46, 20.5), Vector2(1.2, 3.0), true));
    world.add(GameBlock(Vector2(50, 20.5), Vector2(1.2, 3.0), true));
    
    // Каменные перекрытия
    world.add(GameBlock(Vector2(42, 18.5), Vector2(6.8, 1.0), true));
    world.add(GameBlock(Vector2(48, 18.5), Vector2(5.5, 1.0), true));

    // Деревянные стены первого этажа
    world.add(GameBlock(Vector2(40, 15.5), Vector2(1.0, 5.0), false));
    world.add(GameBlock(Vector2(45, 15.5), Vector2(1.0, 5.0), false));
    world.add(GameBlock(Vector2(49, 15.5), Vector2(1.0, 5.0), false));

    // Деревянный потолок
    world.add(GameBlock(Vector2(44.5, 12.5), Vector2(11.0, 1.2), false));

    // Верхняя башня
    world.add(GameBlock(Vector2(42.5, 10.0), Vector2(0.8, 3.8), false));
    world.add(GameBlock(Vector2(46.5, 10.0), Vector2(0.8, 3.8), false));
    world.add(GameBlock(Vector2(44.5, 7.5), Vector2(5.0, 1.2), false));

    // Свиньи Максимы
    world.add(MolluskMaksim(Vector2(42.5, 16.5)));   
    world.add(MolluskMaksim(Vector2(47.0, 16.5)));   
    world.add(MolluskMaksim(Vector2(44.5, 10.0)));  

    spawnCompleted = true;
  }

  void loadNextBird() {
    if (birdsQueue.isNotEmpty) {
      birdsQueue.removeAt(0);
      if (birdsQueue.isNotEmpty) {
        currentBird = birdsQueue.first;
        currentBird!.jumpToSlingshot(Vector2(8, 20.0));
      } else {
        currentBird = null; 
        // Если птицы кончились, а свиньи ещё живы — запускаем триггер проигрыша через 2 секунды проверки
        Future.delayed(const Duration(seconds: 2), () {
          final pigsLeft = world.children.whereType<MolluskMaksim>().length;
          if (pigsLeft > 0 && !levelCleared && !levelFailed) {
            levelFailed = true;
            overlays.add('GameOverMenu');
          }
        });
      }
    }
  }

  double _timeElapsed = 0.0; // Счётчик времени со старта уровня

  @override
  void update(double dt) {
    super.update(dt);
    if (!spawnCompleted) return;

    // Считаем время, прошедшее с запуска уровня
    _timeElapsed += dt;
    // Твой совет: Если прошло меньше 5 секунд, проверку на победу даже не начинаем!
    if (_timeElapsed < 5.0) return;
    
    final pigCount = world.children.whereType<MolluskMaksim>().length;
    if (pigCount == 0 && !levelCleared && !levelFailed) {
      levelCleared = true;
      overlays.add('VictoryMenu');
    }
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

// АНИМАЦИЯ: Солнце крутится, облака плывут
class BackgroundDecoration extends Component with HasGameRef<AngryMolluskGame> {
  double sunRotation = 0.0;
  double cloudOffset1 = 0.0;
  double cloudOffset2 = 0.0;

  @override
  void update(double dt) {
    super.update(dt);
    sunRotation += 0.4 * dt; 
    cloudOffset1 += 12.0 * dt; 
    cloudOffset2 += 6.0 * dt;  
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

    // НАСТОЯЩЕЕ СОЛНЦЕ С КРАСИВЫМИ ТРЕУГОЛЬНЫМИ ЛУЧАМИ СЛЕВА
    final sunCenter = Offset(size.x * 0.15, size.y * 0.2);
    final sunRadius = size.y * 0.09;
    
    canvas.save();
    canvas.translate(sunCenter.dx, sunCenter.dy); 
    canvas.rotate(sunRotation);
    
    final rayPaint = Paint()..color = const Color(0xFFFFF59D).withValues(alpha: 0.4)..style = PaintingStyle.fill;
    final rayPath = Path();
    int rayCount = 8;
    for (int i = 0; i < rayCount; i++) {
      double angle = (i * 2 * pi) / rayCount;
      double nextAngle = angle + (pi / rayCount);
      rayPath.moveTo(0, 0);
      rayPath.lineTo(cos(angle) * sunRadius * 2.2, sin(angle) * sunRadius * 2.2);
      rayPath.lineTo(cos(nextAngle) * sunRadius * 1.5, sin(nextAngle) * sunRadius * 1.5);
      rayPath.close();
    }
    canvas.drawPath(rayPath, rayPaint);
    canvas.restore();
    
    canvas.drawCircle(sunCenter, sunRadius, Paint()..color = const Color(0xFFFBC02D)); 

    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.85);
    
    double c1X = (size.x * 0.3 + cloudOffset1) % (size.x + 200) - 100;
    canvas.drawCircle(Offset(c1X, size.y * 0.15), 30, cloudPaint);
    canvas.drawCircle(Offset(c1X + 30, size.y * 0.13), 40, cloudPaint);
    canvas.drawCircle(Offset(c1X + 70, size.y * 0.15), 35, cloudPaint);

    double c2X = (size.x * 0.7 + cloudOffset2) % (size.x + 200) - 100;
    canvas.drawCircle(Offset(c2X, size.y * 0.22), 25, cloudPaint);
    canvas.drawCircle(Offset(c2X + 30, size.y * 0.2), 35, cloudPaint);

        // Опустили уровень воды пониже (теперь она занимает последние 15% экрана снизу)
    canvas.drawRect(Rect.fromLTWH(0, size.y * 0.83, size.x, size.y * 0.02), Paint()..color = const Color(0xFF29B6F6));
    canvas.drawRect(Rect.fromLTWH(0, size.y * 0.85, size.x, size.y * 0.15), Paint()..color = const Color(0xFF0288D1));
  }
}

// Острова
class IslandBoundary extends Component with HasGameRef<AngryMolluskGame> {
  final Vector2 start;
  final Vector2 end;

  IslandBoundary(this.start, this.end);

  @override
  void render(Canvas canvas) {
    // Рисуем скалу (коричневая база) прямо в координатах мира (в метрах)
    canvas.drawRect(Rect.fromLTRB(start.x, start.y, end.x, end.y), Paint()..color = const Color(0xFF6D4C41));

    // ТЕКСТУРИРОВАНИЕ СКАЛЫ: Добавляем темные прослойки земли для детализации
    final layerPaint = Paint()..color = const Color(0xFF4E342E)..strokeWidth = 0.1; // толщина в метрах
    canvas.drawLine(Offset(start.x, start.y + 1.0), Offset(end.x, start.y + 1.2), layerPaint);
    canvas.drawLine(Offset(start.x, start.y + 3.0), Offset(end.x, start.y + 2.8), layerPaint);

    // МУЛЬТЯШНАЯ ЗУБЧАТАЯ ТРАВА СВЕРХУ
    final paintGrass = Paint()..color = const Color(0xFF4CAF50);
    canvas.drawRect(Rect.fromLTWH(start.x, start.y, end.x - start.x, 0.4), paintGrass);
    
    // Рисуем маленькие треугольные зубчики травы
    final grassPath = Path();
    for (double x = start.x; x < end.x; x += 0.3) {
      grassPath.moveTo(x, start.y + 0.35);
      grassPath.lineTo(x + 0.15, start.y + 0.6);
      grassPath.lineTo(x + 0.3, start.y + 0.35);
    }
    canvas.drawPath(grassPath, paintGrass);
  }
} // СКОБКА ЗАКРЫТА! Теперь синтаксис не ломает остальные классы

// Высокая деревянная рогатка
class Slingshot extends Component with HasGameRef<AngryMolluskGame> {
  final Vector2 worldPos;
  Slingshot(this.worldPos);

  @override
  void render(Canvas canvas) {
    // Рисуем в метрах мира
    const thickness = 0.3; 

    final paintFork = Paint()..color = const Color(0xFF4E342E)..strokeWidth = thickness;
    final paintHighlight = Paint()..color = const Color(0xFF8D6E63)..strokeWidth = thickness * 0.3;
    
    // Стойка и рожки рогатки (рисуются локально от её worldPos, так как Flame сам сдвинет матрицу)
    canvas.drawLine(const Offset(0, -0.1), const Offset(0, 3.0), paintFork);
    canvas.drawLine(const Offset(0, -0.1), const Offset(0, 3.0), paintHighlight);

    final leftHorn = const Offset(-0.8, -1.8);
    final rightHorn = const Offset(0.8, -1.8);

    canvas.drawLine(const Offset(0, -0.2), leftHorn, paintFork);
    canvas.drawLine(const Offset(0, -0.2), rightHorn, paintFork);
  }
}

// Класс Баннихопа
class Bunnyhop extends PositionComponent with HasGameRef<AngryMolluskGame> {
  // Переменную position удаляем отсюда, так как она теперь встроена в PositionComponent!
  final Vector2 startPos;
  bool isReadyForLaunch;
  bool isLaunched = false;
  Vector2? dragPosition;
  Sprite? birdSprite;

  Vector2 velocity = Vector2.zero();
  static const double gravity = 14.0;

  // ОБНОВЛЕННЫЙ КОНСТРУКТОР: Задаем позицию, размер (1.8 на 1.8 метра) и центрируем птицу
  Bunnyhop(this.startPos, this.isReadyForLaunch) {
    this.position = Vector2.copy(startPos);
    this.size = Vector2(1.8, 1.8);
    this.anchor = Anchor.center;
  }

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
    final slingCenter = gameRef.slingshot.worldPos - Vector2(0, 2.5);
    var dir = target - slingCenter;
    if (dir.length > 2.8) {
      dir = dir.normalized() * 2.8;
    }
    dragPosition = slingCenter + dir;
    position = dragPosition!;
  }

  void launch() {
    isLaunched = true;
    final slingCenter = gameRef.slingshot.worldPos - Vector2(0, 2.5);
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

      for (final pig in gameRef.world.children.whereType<MolluskMaksim>()) {
        if ((position - pig.position).length < 2.0) {
          pig.hit(velocity); 
        }
      }

      for (final block in gameRef.world.children.whereType<GameBlock>()) {
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
    final radius = size.x / 2;

    // КРАСНАЯ РЕЗИНКА РОГАТКИ БЕЗ СДВИГОВ И КОНСТАНТ
    if (dragPosition != null && isReadyForLaunch && !isLaunched) {
      final leftHorn = gameRef.slingshot.worldPos + Vector2(-0.8, -1.8) - position;
      final rightHorn = gameRef.slingshot.worldPos + Vector2(0.8, -1.8) - position;
      final paintRubber = Paint()..color = const Color(0xFFD32F2F)..strokeWidth = 0.15; // Толщина резинки в метрах
      
      canvas.drawLine(Offset(leftHorn.x, leftHorn.y), Offset.zero, paintRubber);
      canvas.drawLine(Offset(rightHorn.x, rightHorn.y), Offset.zero, paintRubber);
    }

    // Сочный красный круг-подложка
    canvas.drawCircle(Offset.zero, radius, Paint()..color = const Color(0xFFE53935));

    // Накладываем спрайт лица Баннихопа по центру
    if (birdSprite != null) {
      birdSprite!.render(canvas, position: Vector2(-radius, -radius), size: Vector2(radius * 2, radius * 2));
    }

    // Траектория полёта маленькими точками
    if (dragPosition != null && isReadyForLaunch && !isLaunched) {
      final slingCenter = gameRef.slingshot.worldPos - Vector2(0, 2.5);
      final simVelocity = (slingCenter - position) * 7.5;
      final dotsPaint = Paint()..color = Colors.white;

      for (int i = 1; i < 12; i++) {
        double t = i * 0.12;
        double x = simVelocity.x * t;
        double y = simVelocity.y * t + 0.5 * gravity * t * t;
        canvas.drawCircle(Offset(x, y), 0.08, dotsPaint); // Точки размером 8 сантиметров в мире игры
      }
    }
  }
}

class MolluskMaksim extends PositionComponent with HasGameRef<AngryMolluskGame> {
  // Переменную position удаляем отсюда, она теперь системная!
  Vector2 velocity = Vector2.zero();
  Sprite? pigSprite;
  bool isFalling = false; 

  // ОБНОВЛЕННЫЙ КОНСТРУКТОР: Задаем позицию, размер свиньи в метрах и центрируем её
  MolluskMaksim(Vector2 startPos) {
    this.position = Vector2.copy(startPos);
    this.size = Vector2(2.0, 2.0);
    this.anchor = Anchor.center;
  }

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

      if (position.y >= 22.0) {
        removeFromParent(); 
      }
    } else {
      bool standOnBlock = false;
      for (final block in gameRef.world.children.whereType<GameBlock>()) {
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
    final radius = size.x / 2;

    // Зелёный круг-подложка
    canvas.drawCircle(Offset.zero, radius, Paint()..color = const Color(0xFF4CAF50));

    // Накладываем спрайт лица Максима Рыбалкина по центру
    if (pigSprite != null) {
      pigSprite!.render(canvas, position: Vector2(-radius, -radius), size: Vector2(radius * 2, radius * 2));
    }
  }
}

class GameBlock extends PositionComponent with HasGameRef<AngryMolluskGame> {
  // Переменные position и size удаляем, они теперь наследуются из PositionComponent!
  Vector2 velocity = Vector2.zero();
  final bool isStone;
  bool isFalling = false;

  // ОБНОВЛЕННЫЙ КОНСТРУКТОР: Заполняем системные position, size и центрируем блок замка
  GameBlock(Vector2 spawnPos, Vector2 blockSize, this.isStone) {
    this.position = Vector2.copy(spawnPos);
    this.size = Vector2.copy(blockSize);
    this.anchor = Anchor.center;
  }

  void hit(Vector2 birdVelocity) {
    velocity = birdVelocity * 0.5;
    isFalling = true;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!isFalling && position.y < 22.0 - size.y / 2) {
      bool supported = false;
      for (final other in gameRef.world.children.whereType<GameBlock>()) {
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

      for (final otherBlock in gameRef.world.children.whereType<GameBlock>()) {
        if (otherBlock != this && !otherBlock.isFalling) {
          if ((position.x - otherBlock.position.x).abs() < (size.x + otherBlock.size.x) / 2 &&
              (position.y - otherBlock.position.y).abs() < (size.y + otherBlock.size.y) / 2) {
            otherBlock.hit(velocity * 0.8); 
          }
        }
      }

      for (final pig in gameRef.world.children.whereType<MolluskMaksim>()) {
        if ((position - pig.position).length < (size.x + size.y) / 3) {
          pig.hit(velocity); 
        }
      }

      if (position.y >= 22.0 - size.y / 2) {
        position.y = 22.0 - size.y / 2;
        velocity = Vector2.zero();
        isFalling = false;
      }
      
      if (position.x < 34.0 && position.y >= 22.0) {
        removeFromParent(); 
      }
    }
  }

    @override
  void render(Canvas canvas) {
    // Настраиваем цвета материалов
    final paint = Paint()
      ..color = isStone ? const Color(0xFFB0BEC5) : const Color(0xFFFFB74D) 
      ..style = PaintingStyle.fill;
    
    final borderPaint = Paint()
      ..color = isStone ? const Color(0xFF455A64) : const Color(0xFFD84315)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.08; // Толщина обводки блока в метрах

    // Строим прямоугольник от центра локальных координат
    final rect = Rect.fromCenter(center: Offset.zero, width: size.x, height: size.y);
    canvas.drawRect(rect, paint);
    canvas.drawRect(rect, borderPaint);

    // Добавляем текстурные мультяшные линии детализации
    if (!isStone) {
      final woodPaint = Paint()..color = const Color(0xFFE65100)..strokeWidth = 0.03;
      canvas.drawLine(Offset(rect.left + 0.1, rect.top + size.y * 0.3), Offset(rect.right - 0.1, rect.top + size.y * 0.3), woodPaint);
      canvas.drawLine(Offset(rect.left + 0.1, rect.top + size.y * 0.7), Offset(rect.right - 0.1, rect.top + size.y * 0.7), woodPaint);
    } else {
      final stonePaint = Paint()..color = const Color(0xFF37474F)..strokeWidth = 0.03;
      canvas.drawLine(Offset(rect.left + size.x * 0.3, rect.top + 0.1), Offset(rect.left + size.x * 0.3, rect.bottom - 0.1), stonePaint);
      canvas.drawLine(Offset(rect.left + size.x * 0.7, rect.top + 0.1), Offset(rect.left + size.x * 0.7, rect.bottom - 0.1), stonePaint);
    }
  }
}

