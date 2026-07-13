import 'dart:math';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/components.dart';
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
          
          // Кнопка Назад в меню уровней в верхнем левом углу
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
class AngryMolluskGame extends Forge2DGame with DragCallbacks {
  AngryMolluskGame() : super(gravity: Vector2(0, 15.0));

  late Slingshot slingshot;
  List<Bunnyhop> birdsQueue = [];
  Bunnyhop? currentBird;
  bool levelCleared = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Настраиваем красивый задний фон (Небо, Солнце, Облака)
    add(BackgroundDecoration());

    // Добавляем острова: левый (для рогатки) и правый (для мишени)
    add(IslandBoundary(Vector2(0, 11), Vector2(12, 16)));  // Левый
    add(IslandBoundary(Vector2(22, 11), Vector2(50, 16))); // Правый

    // Ставим рогатку на левом острове
    slingshot = Slingshot(Vector2(7, 11));
    add(slingshot);

    // Сразу создаем 3 птиц на земле за рогаткой
    for (int i = 0; i < 3; i++) {
      // Первая птица сразу встает повыше, остальные ждут сзади в очереди
      final startX = 5.0 - (i * 1.8);
      final startY = i == 0 ? 10.0 : 10.5;
      final bird = Bunnyhop(Vector2(startX, startY), i == 0);
      birdsQueue.add(bird);
      add(bird);
    }
    currentBird = birdsQueue.first;
  }

  // Метод для логики прыжка следующей птицы в рогатку
  void loadNextBird() {
    if (birdsQueue.isNotEmpty) {
      birdsQueue.removeAt(0); // Удаляем улетевшую птицу из очереди
      if (birdsQueue.isNotEmpty) {
        currentBird = birdsQueue.first;
        // Запускаем красивый прыжок на рогатку
        currentBird!.jumpToSlingshot(Vector2(7, 10));
      } else {
        currentBird = null; // Птицы закончились!
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Проверяем, остались ли живые свиньи на карте
    final pigCount = world.children.whereType<MolluskMaksim>().length;
    if (pigCount == 0 && !levelCleared) {
      levelCleared = true;
      overlays.add('VictoryMenu');
    }

    // Построение уровня после полной инициализации физики
    if (world.children.whereType<GameBlock>().isEmpty) {
      _buildLevelStructures();
    }
  }

  void _buildLevelStructures() {
    // СТРОИМ ДОМ ИЗ КАРТИНКИ
    // Нижние каменные опоры (серые блоки)
    add(GameBlock(Vector2(28, 10.0), Vector2(1, 2), true));
    add(GameBlock(Vector2(31, 10.0), Vector2(1, 2), true));
    add(GameBlock(Vector2(34, 10.0), Vector2(1, 2), true));
    add(GameBlock(Vector2(37, 10.0), Vector2(1, 2), true));
    
    // Каменные перекрытия сверху опор
    add(GameBlock(Vector2(31, 8.5), Vector2(5, 1), true));
    add(GameBlock(Vector2(35.5, 8.5), Vector2(4, 1), true));

    // Деревянные стены первого этажа (коричневые)
    add(GameBlock(Vector2(29.5, 6.5), Vector2(0.8, 3), false));
    add(GameBlock(Vector2(33.5, 6.5), Vector2(0.8, 3), false));
    add(GameBlock(Vector2(36.5, 6.5), Vector2(0.8, 3), false));

    // Деревянная балка-потолок первого этажа
    add(GameBlock(Vector2(33, 4.5), Vector2(9, 1), false));

    // Деревянная верхушка башни
    add(GameBlock(Vector2(31.5, 3.0), Vector2(0.6, 2), false));
    add(GameBlock(Vector2(34.5, 3.0), Vector2(0.6, 2), false));
    add(GameBlock(Vector2(33, 1.5), Vector2(4, 1), false));

    // РАССТАВЛЯЕМ СВИНЕЙ МАКСИМОВ С ТОЧНОСТЬЮ КАК НА ФОТО
    add(MolluskMaksim(Vector2(31.5, 7.0))); // Левый нижний Максим
    add(MolluskMaksim(Vector2(35.0, 7.0))); // Правый нижний Максим
    add(MolluskMaksim(Vector2(33.0, 3.0))); // Верхний Максим на крыше
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (currentBird != null && currentBird!.isReadyForLaunch && !currentBird!.isLaunched) {
      currentBird!.dragTo(screenToWorld(event.canvasPosition));
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (currentBird != null && currentBird!.isReadyForLaunch && !currentBird!.isLaunched) {
      currentBird!.launch();
    }
  }
}

// Декоративный задний фон: Небо, Солнце, Вода
class BackgroundDecoration extends Component with HasGameRef<AngryMolluskGame> {
  @override
  void render(Canvas canvas) {
    final size = gameRef.canvasSize;
    
    // Небо (Гradiент)
    final skyPaint = Paint()..shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF4FC3F7), Color(0xFFE1F5FE)],
    ).createShader(Offset.zero & size.toSize());
    canvas.drawRect(Offset.zero & size.toSize(), skyPaint);

    // Солнце
    canvas.drawCircle(Offset(size.x * 0.8, size.y * 0.2), 40, Paint()..color = const Color(0xFFFFF176));

    // Вода (Океан внизу между скалами)
    final waterPaint = Paint()..color = const Color(0xFF1565C0);
    canvas.drawRect(Rect.fromLTWH(0, size.y * 0.8, size.x, size.y * 0.2), waterPaint);
  }
}

// Класс Островов (Земля с отвесными скалами и зеленой травой)
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

// Класс Рогатки
class Slingshot extends PositionComponent {
  Slingshot(Vector2 position) {
    this.position = position;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Рисуем Y-образную деревянную рогатку
    final paintFork = Paint()..color = const Color(0xFF5D4037)..strokeWidth = 0.3;
    canvas.drawLine(const Offset(0, 0), const Offset(0, 2.5), paintFork);
    canvas.drawLine(const Offset(0, 0), const Offset(-0.6, -1.2), paintFork);
    canvas.drawLine(const Offset(0, 0), const Offset(0.6, -1.2), paintFork);
  }
}

// КЛАСС ИГРОВОГО БЛОКА (Дерево / Камень)
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
      restitution: 0.05, // Чтобы блоки реалистично оседали, а не прыгали
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

// КЛАСС ПТИЦЫ БАННИХОПА (С цветной подложкой, траекторией, натяжением и фотографией)
class Bunnyhop extends BodyComponent with HasGameRef<AngryMolluskGame> {
  final Vector2 startPos;
  bool isReadyForLaunch = false;
  bool isLaunched = false;
  Vector2? dragPosition;
  Sprite? birdSprite;

  Bunnyhop(this.startPos, this.isReadyForLaunch);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    try {
      // Подтягиваем круглую фотку Баннихопа из твоих ассетов
      birdSprite = await game.loadSprite('images/bunnyhop.png');
    } catch (e) {
      debugPrint("Фотография bunnyhop.png ещё не найдена в ассетах: $e");
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

  // Прыжок птицы на рогатку из очереди ожидания
  void jumpToSlingshot(Vector2 targetPos) {
    body.setType(BodyType.kinematic);
    body.setTransform(targetPos, 0);
    isReadyForLaunch = true;
  }

  void dragTo(Vector2 target) {
    final slingCenter = gameRef.slingshot.position - Vector2(0, 0.5);
    var dir = target - slingCenter;
    // Ограничиваем длину натяжения резинки до 2.5 метров
    if (dir.length > 2.5) {
      dir.scaleTo(2.5);
    }
    dragPosition = slingCenter + dir;
    body.setTransform(dragPosition!, 0);
  }

  void launch() {
    isLaunched = true;
    body.setType(BodyType.dynamic);
    final slingCenter = gameRef.slingshot.position - Vector2(0, 0.5);
    final launchVector = slingCenter - body.position;
    // Импульс полета зависит от силы натяжения
    body.applyLinearImpulse(launchVector * 18.0);
    dragPosition = null;

    // Ровно через 3 секунды после запуска подкатываем следующую птицу
    Future.delayed(const Duration(seconds: 3), () {
      if (gameRef.isMounted) {
        gameRef.loadNextBird();
      }
    });
  }

  @override
  void render(Canvas canvas) {
    // 1. Отрисовка КРАСНОЙ РЕЗИНКИ рогатки при натяжении (сзади птицы)
    if (dragPosition != null && isReadyForLaunch && !isLaunched) {
      final slingLeft = gameRef.slingshot.position + Vector2(-0.5, -1.0) - body.position;
      final slingRight = gameRef.slingshot.position + Vector2(0.5, -1.0) - body.position;
      final paintRubber = Paint()..color = Colors.red..strokeWidth = 0.15;
      
      canvas.drawLine(Offset(slingLeft.x, slingLeft.y), Offset.zero, paintRubber);
      canvas.drawLine(Offset(slingRight.x, slingRight.y), Offset.zero, paintRubber);
    }

    super.render(canvas);
    
    // 2. Рисуем цветную подложку (Красный круг для Баннихопа)
    final redBase = Paint()..color = Colors.red;
    canvas.drawCircle(Offset.zero, 0.9, redBase);

    // 3. Рисуем поверх круга саму фотку Баннихопа
    if (birdSprite != null) {
      birdSprite!.render(
        canvas,
        position: Vector2(-0.9, -0.9),
        size: Vector2(1.8, 1.8),
      );
    }

    // 4. Отрисовка траектории полета маленькими белыми точками
    if (dragPosition != null && isReadyForLaunch && !isLaunched) {
      final slingCenter = gameRef.slingshot.position - Vector2(0, 0.5);
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

// КЛАСС СВИНЬИ МАКСИМА (С подложкой, фотографией и уничтожением от ударов)
class MolluskMaksim extends BodyComponent with ContactCallbacks, HasGameRef<AngryMolluskGame> {
  final Vector2 spawnPos;
  Sprite? pigSprite;

  MolluskMaksim(this.spawnPos);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    try {
      // Подтягиваем круглую фотку Максима из твоих ассетов
      pigSprite = await game.loadSprite('images/maksim.png');
    } catch (e) {
      debugPrint("Фотография maksim.png ещё не найдена в ассетах: $e");
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
    // Уничтожение от хорошего удара птицы или падения тяжелых камней сверху
    if (velocity > 1.2 || (other is GameBlock && other.isStone)) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // 1. Зелёная подложка-круг для Максима Рыбалкина
    final greenBase = Paint()..color = Colors.green;
    canvas.drawCircle(Offset.zero, 1.0, greenBase);

    // 2. Накладываем фотографию Максима прямо на зелёный круг
    if (pigSprite != null) {
      pigSprite!.render(
        canvas,
        position: Vector2(-1.0, -1.0),
        size: Vector2(2.0, 2.0),
      );
    }
  }
}

