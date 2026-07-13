import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart' as flame_comp;
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart' hide Wallet;

// Главный экран-виджет, который запускает игру и содержит оверлей победы
class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Наш GameWidget со встроенным мультяшным окном победы
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
                      border: Border.all(color: Colors.orange, width: 4), // Сочная оранжевая обводка
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // Сжимаем окошко под контент
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
                              // Закрываем черное окно и выходим обратно в меню уровней
                              game.overlays.remove('VictoryMenu');
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'К УРОВНЯМ',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
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

// Движок игры
class AngryMolluskGame extends Forge2DGame {
  AngryMolluskGame() : super(gravity: Vector2(0, 15.0));

  late Slingshot slingshot;
  List<Bunnyhop> birdsQueue = [];
  Bunnyhop? currentBird;
  bool levelCleared = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Красивые декорации заднего плана (Небо, Солнце, Вода)
    add(BackgroundDecoration());
    
    // Острова (Левый под рогатку, Правый под замок)
    add(IslandBoundary(Vector2(0, 11), Vector2(12, 16)));
    add(IslandBoundary(Vector2(22, 11), Vector2(50, 16)));

    // Коричневая рогатка
    slingshot = Slingshot(Vector2(7, 11));
    add(slingshot);

    // Подключаем стабильный контроллер жестов тача
    add(DragController());

    // Создаем 3 птиц Баннихопов в очередь
    for (int i = 0; i < 3; i++) {
      final startX = 5.0 - (i * 1.8);
      final startY = i == 0 ? 10.0 : 10.5;
      final bird = Bunnyhop(Vector2(startX, startY), i == 0);
      birdsQueue.add(bird);
      add(bird);
    }
    currentBird = birdsQueue.first;
  }

  // Подкатываем следующую птицу на рогатку, когда предыдущая запущенна
  void loadNextBird() {
    if (birdsQueue.isNotEmpty) {
      birdsQueue.removeAt(0);
      if (birdsQueue.isNotEmpty) {
        currentBird = birdsQueue.first;
        currentBird!.jumpToSlingshot(Vector2(7, 10));
      } else {
        currentBird = null;
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Проверка на победу: если свиней на карте не осталось
    final pigCount = world.children.whereType<MolluskMaksim>().length;
    if (pigCount == 0 && !levelCleared) {
      levelCleared = true;
      overlays.add('VictoryMenu');
    }

    // Если блоки еще не построены — строим замок
    if (world.children.whereType<GameBlock>().isEmpty) {
      _buildLevelStructures();
    }
  }

  void _buildLevelStructures() {
    // Нижние каменные опоры
    add(GameBlock(Vector2(28, 10.0), Vector2(1, 2), true));
    add(GameBlock(Vector2(31, 10.0), Vector2(1, 2), true));
    add(GameBlock(Vector2(34, 10.0), Vector2(1, 2), true));
    add(GameBlock(Vector2(37, 10.0), Vector2(1, 2), true));
    
    // Каменные перекрытия
    add(GameBlock(Vector2(31, 8.5), Vector2(5, 1), true));
    add(GameBlock(Vector2(35.5, 8.5), Vector2(4, 1), true));

    // Деревянные стены первого этажа
    add(GameBlock(Vector2(29.5, 6.5), Vector2(0.8, 3), false));
    add(GameBlock(Vector2(33.5, 6.5), Vector2(0.8, 3), false));
    add(GameBlock(Vector2(36.5, 6.5), Vector2(0.8, 3), false));

    // Деревянный потолок
    add(GameBlock(Vector2(33, 4.5), Vector2(9, 1), false));

    // Верхняя деревянная будка
    add(GameBlock(Vector2(31.5, 3.0), Vector2(0.6, 2), false));
    add(GameBlock(Vector2(34.5, 3.0), Vector2(0.6, 2), false));
    add(GameBlock(Vector2(33, 1.5), Vector2(4, 1), false));

    // Расстановка свиней Максимов Рыбалкиных
    add(MolluskMaksim(Vector2(31.5, 7.0)));
    add(MolluskMaksim(Vector2(35.0, 7.0)));
    add(MolluskMaksim(Vector2(33.0, 3.0)));
  }
}

// Контроллер жестов, использующий корректные localEndPosition координаты для Flame 1.x
class DragController extends Component with DragCallbacks, HasGameRef<AngryMolluskGame> {
  @override
  void onDragUpdate(DragUpdateEvent event) {
    final currentBird = gameRef.currentBird;
    if (currentBird != null && currentBird.isReadyForLaunch && !currentBird.isLaunched) {
      // Преобразуем координаты экрана во внутриигровые метры физического мира
      final worldPos = gameRef.screenToWorld(event.localEndPosition);
      currentBird.dragTo(worldPos);
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

// Задний план
class BackgroundDecoration extends Component with HasGameRef<AngryMolluskGame> {
  @override
  void render(Canvas canvas) {
    final size = gameRef.canvasSize;
    
    // Небо
    final skyPaint = Paint()..shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF4FC3F7), Color(0xFFE1F5FE)],
    ).createShader(Offset.zero & size.toSize());
    canvas.drawRect(Offset.zero & size.toSize(), skyPaint);

    // Солнце
    canvas.drawCircle(Offset(size.x * 0.8, size.y * 0.2), 40, Paint()..color = const Color(0xFFFFF176));

    // Вода
    final waterPaint = Paint()..color = const Color(0xFF1565C0);
    canvas.drawRect(Rect.fromLTWH(0, size.y * 0.8, size.x, size.y * 0.2), waterPaint);
  }
}

// Физические острова
class IslandBoundary extends BodyComponent {
  final Vector2 start;
  final Vector2 end;

  IslandBoundary(this.start, this.end);

  @override
  Body createBody() {
    final bodyDef = BodyDef(type: BodyType.static);
    final body = world.createBody(bodyDef);
    
    final shape = PolygonShape();
    final vertices = [
      start,
      Vector2(end.x, start.y),
      end,
      Vector2(start.x, end.y),
    ];
    shape.set(vertices);
    body.createFixture(FixtureDef(shape, friction: 0.7));
    return body;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paintGround = Paint()..color = const Color(0xFF795548);
    canvas.drawRect(Rect.fromLTRB(start.x, start.y, end.x, end.y), paintGround);

    final paintGrass = Paint()..color = const Color(0xFF4CAF50);
    canvas.drawRect(Rect.fromLTWH(start.x, start.y, end.x - start.x, 0.4), paintGrass);
  }
}

// Столбик рогатки
class Slingshot extends flame_comp.PositionComponent {
  final Vector2 initialPosition;
  Slingshot(this.initialPosition) {
    position = initialPosition;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paintFork = Paint()..color = const Color(0xFF5D4037)..strokeWidth = 0.3;
    canvas.drawLine(const Offset(0, 0), const Offset(0, 2.5), paintFork);
    canvas.drawLine(const Offset(0, 0), const Offset(-0.6, -1.2), paintFork);
    canvas.drawLine(const Offset(0, 0), const Offset(0.6, -1.2), paintFork);
  }
}

// Разрушаемые строительные блоки (Камень / Дерево)
class GameBlock extends BodyComponent {
  final Vector2 size;
  final Vector2 spawnPos;
  final bool isStone;

  GameBlock(this.spawnPos, this.size, this.isStone);

  @override
  Body createBody() {
    final bodyDef = BodyDef(type: BodyType.dynamic, position: spawnPos);
    final body = world.createBody(bodyDef);
    final shape = PolygonShape()..setAsBox(size.x / 2, size.y / 2, Vector2.zero(), 0);
    
    body.createFixture(FixtureDef(
      shape,
      density: isStone ? 2.5 : 0.8,
      friction: 0.5,
      restitution: 0.05,
    ));
    return body;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()
      ..color = isStone ? const Color(0xFF9E9E9E) : const Color(0xFFFFB74D)
      ..style = PaintingStyle.fill;
    
    final borderPaint = Paint()
      ..color = isStone ? const Color(0xFF616161) : const Color(0xFFE65100)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.08;

    final rect = Rect.fromCenter(center: Offset.zero, width: size.x, height: size.y);
    canvas.drawRect(rect, paint);
    canvas.drawRect(rect, borderPaint);
  }
}

// Класс Баннихопа
class Bunnyhop extends BodyComponent<AngryMolluskGame> {
  final Vector2 startPos;
  bool isReadyForLaunch = false;
  bool isLaunched = false;
  Vector2? dragPosition;
  flame_comp.Sprite? birdSprite;

  Bunnyhop(this.startPos, this.isReadyForLaunch);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    try {
      birdSprite = await game.loadSprite('images/bunnyhop.png');
    } catch (e) {
      debugPrint("Текстура bunnyhop.png пока не добавлена: $e");
    }
  }

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      type: isReadyForLaunch ? BodyType.kinematic : BodyType.static,
      position: startPos,
    );
    final body = world.createBody(bodyDef);
    final shape = CircleShape()..radius = 0.9;
    body.createFixture(FixtureDef(shape, density: 1.2, restitution: 0.25));
    return body;
  }

  void jumpToSlingshot(Vector2 targetPos) {
    body.setType(BodyType.kinematic);
    body.setTransform(targetPos, 0);
    isReadyForLaunch = true;
  }

  void dragTo(Vector2 target) {
    final slingCenter = game.slingshot.position - Vector2(0, 0.5);
    var dir = target - slingCenter;
    
    // Ограничиваем максимальное натяжение без использования scaleTo
    if (dir.length > 2.5) {
      dir = dir.normalized() * 2.5;
    }
    
    dragPosition = slingCenter + dir;
    body.setTransform(dragPosition!, 0);
  }

  void launch() {
    isLaunched = true;
    body.setType(BodyType.dynamic);
    final slingCenter = game.slingshot.position - Vector2(0, 0.5);
    final launchVector = slingCenter - body.position;
    body.applyLinearImpulse(launchVector * 18.0);
    dragPosition = null;

    // С задержкой в 3 секунды подкатываем следующую птицу
    Future.delayed(const Duration(seconds: 3), () {
      if (game.isMounted) {
        game.loadNextBird();
      }
    });
  }

  @override
  void render(Canvas canvas) {
    // 1. Отрисовка КРАСНОЙ РЕЗИНКИ рогатки при натяжении
    if (dragPosition != null && isReadyForLaunch && !isLaunched) {
      final slingLeft = game.slingshot.position + Vector2(-0.5, -1.0) - body.position;
      final slingRight = game.slingshot.position + Vector2(0.5, -1.0) - body.position;
      final paintRubber = Paint()..color = Colors.red..strokeWidth = 0.15;
      
      canvas.drawLine(Offset(slingLeft.x, slingLeft.y), Offset.zero, paintRubber);
      canvas.drawLine(Offset(slingRight.x, slingRight.y), Offset.zero, paintRubber);
    }

    super.render(canvas);
    
    // 2. Рисуем Красную подложку-круг
    final redBase = Paint()..color = Colors.red;
    canvas.drawCircle(Offset.zero, 0.9, redBase);

    // 3. Рисуем поверх круглую фотографию Баннихопа
    if (birdSprite != null) {
      birdSprite!.render(
        canvas,
        position: Vector2(-0.9, -0.9),
        size: Vector2(1.8, 1.8),
      );
    }

    // 4. Отрисовка траектории белыми точками
    if (dragPosition != null && isReadyForLaunch && !isLaunched) {
      final slingCenter = game.slingshot.position - Vector2(0, 0.5);
      final velocity = (slingCenter - body.position) * 18.0;
      final dotsPaint = Paint()..color = Colors.white;

      for (int i = 1; i < 14; i++) {
        double t = i * 0.07;
        double x = body.position.x + velocity.x * t;
        double y = body.position.y + velocity.y * t + 0.5 * 15.0 * t * t;
        canvas.drawCircle(Offset(x - body.position.x, y - body.position.y), 0.1, dotsPaint);
      }
    }
  }
}

// Физический класс Максима
class MolluskMaksim extends BodyComponent<AngryMolluskGame> with ContactCallbacks {
  final Vector2 spawnPos;
  flame_comp.Sprite? pigSprite;

  MolluskMaksim(this.spawnPos);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    try {
      pigSprite = await game.loadSprite('images/maksim.png');
    } catch (e) {
      debugPrint("Текстура maksim.png пока не добавлена: $e");
    }
  }

  @override
  Body createBody() {
    final bodyDef = BodyDef(type: BodyType.dynamic, position: spawnPos);
    final body = world.createBody(bodyDef);
    final shape = CircleShape()..radius = 1.0;
    body.createFixture(FixtureDef(shape, density: 0.6, restitution: 0.1, friction: 0.5));
    return body;
  }

  @override
  void beginContact(Object other, Contact contact) {
    super.beginContact(other, contact);
    final velocity = body.linearVelocity.length;
    // Уничтожается от хорошего удара птицы или от падения Каменного блока
    if (velocity > 1.2 || (other is GameBlock && other.isStone)) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // 1. Рисуем Зелёную подложку-круг
    final greenBase = Paint()..color = Colors.green;
    canvas.drawCircle(Offset.zero, 1.0, greenBase);

    // 2. Рисуем поверх круглую фотографию Максима Рыбалкина
    if (pigSprite != null) {
      pigSprite!.render(
        canvas,
        position: Vector2(-1.0, -1.0),
        size: Vector2(2.0, 2.0),
      );
    }
  }
}


