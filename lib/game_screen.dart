import 'dart:math';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart' hide Wallet;

// Главный экран-виджет, который будет запускать игру
class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: AngryMolluskGame()),
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
    // Рендерится автоматически через кастомный компонент
    add(BackgroundDecoration());

    // Добавляем острова: левый (для рогатки) и правый (для мишени)
    add(IslandBoundary(Vector2(0, 11), Vector2(12, 16)));  // Левый
    add(IslandBoundary(Vector2(22, 11), Vector2(50, 16))); // Правый

    // Ставим рогатку на левом острове
    slingshot = Slingshot(Vector2(7, 11));
    add(slingshot);

    // Очередь из 3 птиц Баннихопов
    for (int i = 0; i < 3; i++) {
      final bird = Bunnyhop(Vector2(4.0 - (i * 2.5), i == 0 ? 11.0 : 14.5), i == 0);
      birdsQueue.add(bird);
      add(bird);
    }
    currentBird = birdsQueue.first;

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
  void update(double dt) {
    super.update(dt);
    
    // Проверяем, остались ли живые свиньи на карте
    final pigCount = world.children.whereType<MolluskMaksim>().length;
    if (pigCount == 0 && !levelCleared) {
      levelCleared = true;
      _showVictoryDialog();
    }
  }

  // Отрезанные жесты перетаскивания для натяжения резинки
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

  void _showVictoryDialog() {
    // Вывод мультяшного окна победы поверх Flame-сцены
    overlays.add('VictoryMenu');
  }
}

// Декоративный задний фон: Небо, Солнце, Облака, Вода
class BackgroundDecoration extends Component with HasGameRef<AngryMolluskGame> {
  @override
  void render(Canvas canvas) {
    final size = gameRef.canvasSize;
    
    // Небо (Градиент)
    final skyPaint = Paint()..shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [const Color(0xFF4FC3F7), const Color(0xFFE1F5FE)],
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
    // Рисуем землю скалы коричневым цветом
    final bodyPos = body.position;
    final paintGround = Paint()..color = const Color(0xFF795548);
    canvas.drawRect(Rect.fromLTRB(start.x, start.y, end.x, end.y), paintGround);

    // Трава на верхней кромке острова
    final paintGrass = Paint()..color = const Color(0xFF4CAF50);
    canvas.drawRect(Rect.fromLTWH(start.x, start.y, end.x - start.x, 0.4), paintGrass);
  }
}

// Класс Рогатки с красной резинкой
class Slingshot extends PositionComponent {
  Slingshot(Vector2 position) {
    this.position = position;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paintFork = Paint()..color = const Color(0xFF5D4037)..strokeWidth = 0.3;
    // Рисуем Y-образную рогатку
    canvas.drawLine(const Offset(0, 0), const Offset(0, 2), paintFork);
    canvas.drawLine(const Offset(0, 0), const Offset(-0.6, -1), paintFork);
    canvas.drawLine(const Offset(0, 0), const Offset(0.6, -1), paintFork);
  }
}

// КЛАСС ПТИЦЫ БАННИХОПА (С подложкой и траекторией)
class Bunnyhop extends BodyComponent with HasGameRef<AngryMolluskGame> {
  final Vector2 startPos;
  bool isReadyForLaunch = false;
  bool isLaunched = false;
  Vector2? dragPosition;

  Bunnyhop(this.startPos, this.isReadyForLaunch);

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      type: isReadyForLaunch ? BodyType.kinematic : BodyType.static,
      position: startPos,
    );
    final body = world.createBody(bodyDef);
    final shape = CircleShape()..radius = 0.9;
    body.createFixture(FixtureDef(shape, density: 1.0, restitution: 0.3));
    return body;
  }

  void dragTo(Vector2 target) {
    final slingCenter = gameRef.slingshot.position - Vector2(0, 1);
    var dir = target - slingCenter;
    if (dir.length > 2.5) {
      dir.scaleTo(2.5);
    }
    dragPosition = slingCenter + dir;
    body.setTransform(dragPosition!, 0);
  }

  void launch() {
    isLaunched = true;
    body.setType(BodyType.dynamic);
    final slingCenter = gameRef.slingshot.position - Vector2(0, 1);
    final launchVector = slingCenter - body.position;
    body.applyLinearImpulse(launchVector * 15.0);
    dragPosition = null;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Рисуем цветную подложку (Красный круг для Баннихопа)
    final redBase = Paint()..color = Colors.red;
    canvas.drawCircle(Offset.zero, 0.9, redBase);

    // Отрисовка траектории точками, если птица оттянута
    if (dragPosition != null && isReadyForLaunch && !isLaunched) {
      final slingCenter = gameRef.slingshot.position - Vector2(0, 1);
      final velocity = (slingCenter - body.position) * 15.0;
      final dotsPaint = Paint()..color = Colors.white;

      for (int i = 1; i < 15; i++) {
        double t = i * 0.08;
        // Формула параболы полета по закону физики гравитации
        double x = body.position.x + velocity.x * t;
        double y = body.position.y + velocity.y * t + 0.5 * 15.0 * t * t;
        canvas.drawCircle(Offset(x - body.position.x, y - body.position.y), 0.12, dotsPaint);
      }
    }
  }
}

// КЛАСС СВИНЬИ МАКСИМА (Умирает с одного сильного удара)
class MolluskMaksim extends BodyComponent with ContactCallbacks {
  final Vector2 spawnPos;

  MolluskMaksim(this.spawnPos);

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
    // Если скорость столкновения достаточная — свинья исчезает
    removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Зелёная подложка-круг для Максима Рыбалкина
    final greenBase = Paint()..color = Colors.green;
    canvas.drawCircle(Offset.zero, 1.0, greenBase);
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
      density: isStone ? 2.0 : 0.8,
      friction: 0.4,
      restitution: 0.1,
    ));
    return body;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Настраиваем цвета блоков: серый для камня, оранжево-коричневый для дерева
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

// КЛАСС ПТИЦЫ БАННИХОПА (С цветной подложкой, траекторией и фотографией)
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
      // Загружаем круглую фотографию Баннихопа из твоих ассетов
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
    body.createFixture(FixtureDef(shape, density: 1.0, restitution: 0.3));
    return body;
  }

  void dragTo(Vector2 target) {
    final slingCenter = gameRef.slingshot.position - Vector2(0, 1);
    var dir = target - slingCenter;
    if (dir.length > 2.5) {
      dir.scaleTo(2.5);
    }
    dragPosition = slingCenter + dir;
    body.setTransform(dragPosition!, 0);
  }

  void launch() {
    isLaunched = true;
    body.setType(BodyType.dynamic);
    final slingCenter = gameRef.slingshot.position - Vector2(0, 1);
    final launchVector = slingCenter - body.position;
    body.applyLinearImpulse(launchVector * 15.0);
    dragPosition = null;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // 1. Рисуем цветную подложку (Красный круг для модели Баннихопа)
    final redBase = Paint()..color = Colors.red;
    canvas.drawCircle(Offset.zero, 0.9, redBase);

    // 2. Накладываем фотографию Баннихопа прямо поверх красного круга
    if (birdSprite != null) {
      birdSprite!.render(
        canvas,
        position: Vector2(-0.9, -0.9), // Смещаем в угол, чтобы центрировать по кругу
        size: Vector2(1.8, 1.8),       // Размер равен диаметру круга
      );
    }

    // 3. Отрисовка траектории маленькими белыми точками при натяжении резинки
    if (dragPosition != null && isReadyForLaunch && !isLaunched) {
      final slingCenter = gameRef.slingshot.position - Vector2(0, 1);
      final velocity = (slingCenter - body.position) * 15.0;
      final dotsPaint = Paint()..color = Colors.white;

      for (int i = 1; i < 15; i++) {
        double t = i * 0.08;
        // Математический расчет параболы полета с учетом гравитации уровня
        double x = body.position.x + velocity.x * t;
        double y = body.position.y + velocity.y * t + 0.5 * 15.0 * t * t;
        canvas.drawCircle(Offset(x - body.position.x, y - body.position.y), 0.12, dotsPaint);
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
      // Загружаем круглую фотографию Максима из твоих ассетов
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
    // Настраиваем физику: свинья довольно плотная, но упругая
    body.createFixture(FixtureDef(shape, density: 0.6, restitution: 0.1, friction: 0.5));
    return body;
  }

  @override
  void beginContact(Object other, Contact contact) {
    super.beginContact(other, contact);
    
    // Считаем силу удара по относительной скорости объектов при столкновении
    final velocity = body.linearVelocity.length;
    
    // Если скорость удара больше 1.5 метров в секунду (это исключает уничтожение от мелких покачиваний постройки),
    // или если на свинью падает тяжелый Каменный Блок (isStone == true), Максим уничтожается
    if (velocity > 1.5 || (other is GameBlock && other.isStone)) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // 1. Зелёная подложка-круг для модели Максима Рыбалкина
    final greenBase = Paint()..color = Colors.green;
    canvas.drawCircle(Offset.zero, 1.0, greenBase);

    // 2. Накладываем фотографию Максима прямо поверх зелёного круга
    if (pigSprite != null) {
      pigSprite!.render(
        canvas,
        position: Vector2(-1.0, -1.0),
        size: Vector2(2.0, 2.0),
      );
    }
  }
}

