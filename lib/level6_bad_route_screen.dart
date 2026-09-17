import 'dart:math';
import 'package:flutter/material.dart';
import 'audio_manager.dart';
import 'main.dart';

class Level6BadRouteScreen extends StatefulWidget {
  const Level6BadRouteScreen({super.key});

  @override
  State<Level6BadRouteScreen> createState() => _Level6BadRouteScreenState();
}

class _Level6BadRouteScreenState extends State<Level6BadRouteScreen> with TickerProviderStateMixin {
  int _currentFrame = 1; // 1 - Кадры 1 и 2 (Изначально вместе), 2 - Запуск Кадра 3 с обрушением
  late AnimationController _debrisController;
  late Animation<double> _fallAnimation;
  double _sparkTimer = 0.0;
  late final Ticker _sparkTicker;

  @override
  void initState() {
    super.initState();
    
    // 1. Контроллер для сочного падения глыбы на Ваню с эффектом удара
    _debrisController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300), 
    );
    
    _fallAnimation = CurvedAnimation(
      parent: _debrisController,
      curve: Curves.bounceOut, // Физический отскок плиты от пола после удара
    );

    // 2. Живой тикер для бешеного вращения поп-арт подложки и искр ярости Вани во 2-м кадре
    _sparkTicker = createTicker((elapsed) {
      if (mounted) {
        setState(() {
          _sparkTimer = elapsed.inMilliseconds / 1000.0;
        });
      }
    });
    _sparkTicker.start();
  }

  @override
  void dispose() {
    _debrisController.dispose();
    _sparkTicker.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF040407), // Мрак тронного зала
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            const Text(
              "ГЛАВА VI: ЛОГОВО ДОНА МОЛЛЮСКА",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF455A64),
                letterSpacing: 2.5,
                shadows: [Shadow(color: Colors.black, blurRadius: 6, offset: Offset(2, 2))],
              ),
            ),
            const SizedBox(height: 12),

            // ГЛАВНАЯ СЕТКА ПЛОХОЙ ЛИНИИ
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    // Кадр 1 и Кадр 2 горят изначально на экране со старта, убирая "дежавю"
                    _buildBadFrame1(), 
                    const SizedBox(width: 12),
                    _buildBadFrame2(), 
                    const SizedBox(width: 12),
                    
                    // Кадр 3 (Падение плиты) вылетает по кнопке "ДАЛЬШЕ"
                    if (_currentFrame >= 2) ...[
                      _buildBadFrame3(), 
                    ],
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: _buildNavigationButton(),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // ПЛОХАЯ ЛИНИЯ - КАДР 1: Взаимные обвинения и раскрытие слежки
  // =========================================================================
  Widget _buildBadFrame1() {
    return Expanded(
      child: _buildAdvanced3DFrame(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(bottom: 22, right: 10, child: Transform.scale(scale: 1.25, child: _buildThrone())),    
            Positioned(bottom: 22, right: 95, child: _buildGoldTotem(38)),
            Positioned(bottom: 22, left: 16, child: _buildCharacter('assets/images/bunnyhop.png', 56)),
            Positioned(bottom: 12, right: 8, child: _buildDonMollusk(68)),

            // Яростная тирада Вани
            Positioned(
              top: 18, left: 6, width: 105,
              child: CustomPaint(
                painter: SpeechBubblePainter(tailXFactor: 0.25),
                child: const Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    "Все свиньи разбиты, ты остался один! Тебе не скрыться за стенами замка, чудовище!",
                    style: TextStyle(fontSize: 7.2, fontWeight: FontWeight.bold, color: Colors.black, height: 1.15),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

            // Монолог Дона Моллюска о тотальной слежке
            Positioned(
              top: 70, right: 6, width: 110,
              child: CustomPaint(
                painter: SpeechBubblePainter(tailXFactor: 0.8),
                child: const Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    "Скрыться? Хрю-ха-ха! Глупая птица, я сам привёл тебя сюда. Я наблюдал за тобой каждую секунду! Я видел, как ты сидел в кабинете, как ты стрелял из рогатки, как ты общался со Свиноматкиным! Эх, славный был воин... Теперь ты понял, что я ждал тебя здесь и вот ты пришёл!",
                    style: TextStyle(fontSize: 6.2, fontWeight: FontWeight.bold, color: Colors.black, height: 1.1),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // ПЛОХАЯ ЛИНИЯ - КАДР 2: Потеря контроля, искры и аура таблетки
  // =========================================================================
  Widget _buildBadFrame2() {
    double birdX = 36.0;
    double birdY = 150.0; // Координаты Вани на полу (bottom: 22 пересчитано)
    double birdRadius = 22.0;

    return Expanded(
      child: _buildAdvanced3DFrame(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(bottom: 22, right: 8, child: _buildDonMollusk(68)),

            // БЕШЕНЫЕ ЭФФЕКТЫ ЯРОСТИ ТАБЛЕТКИ ВОКРУГ ШЕРИФА С КАРТИНКИ
            Stack(
              children: [
                // 1. Крутящаяся шипастая подложка поп-арт взрыва
                Positioned(
                  left: birdX - birdRadius,
                  bottom: birdY - birdRadius - 42,
                  child: Transform.rotate(
                    angle: _sparkTimer * 12.0,
                    child: CustomPaint(
                      size: Size(birdRadius * 4, birdRadius * 4),
                      painter: _RageAuraPainter(pulseTimer: _sparkTimer),
                    ),
                  ),
                ),
                // 2. Синие неоновые электрические разряды
                Positioned(
                  left: birdX - birdRadius - 10,
                  bottom: birdY - birdRadius - 52,
                  child: CustomPaint(
                    size: Size(birdRadius * 5, birdRadius * 5),
                    painter: _LightningSparkPainter(randSeed: (_sparkTimer * 60).toInt()),
                  ),
                ),
                // 3. Маленькие вылетающие жёлтые звёздочки
                Positioned(
                  left: birdX - birdRadius - 15,
                  bottom: birdY - birdRadius - 57,
                  child: CustomPaint(
                    size: Size(birdRadius * 5.5, birdRadius * 5.5),
                    painter: _FlyingStarsPainter(randSeed: (_sparkTimer * 30).toInt()),
                  ),
                ),
              ],
            ),

            // Ваня подошёл вплотную (left: 36 вместо 16)
            Positioned(bottom: 22, left: 36, child: _buildCharacter('assets/images/bunnyhop.png', 48)),

            // Вспышка гнева Вани
            Positioned(
              top: 15, left: 4, width: 110,
              child: CustomPaint(
                painter: SpeechBubblePainter(tailXFactor: 0.35),
                child: const Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    "Вот это у тебя план! Ничего сейчас он будет разрушен, как и твой замок и тотем гнева вместе с лугом придёт обратно птицам!",
                    style: TextStyle(fontSize: 7.2, fontWeight: FontWeight.bold, color: Colors.black, height: 1.15),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

            // Ответ Дона Моллюска, заманивающего в ловушку
            Positioned(
              top: 75, right: 4, width: 110,
              child: CustomPaint(
                painter: SpeechBubblePainter(tailXFactor: 0.75),
                child: const Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    "Разрушишь замок? Маленькая птица разгневалась. Как и твой дед сорок лет назад!",
                    style: TextStyle(fontSize: 7.2, fontWeight: FontWeight.bold, color: Colors.black, height: 1.1),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

    Widget _buildBadFrame3() {
    return Expanded(
      child: _buildAdvanced3DFrame(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(bottom: 12, right: 8, child: _buildDonMollusk(64)),

            // АНИМАЦИЯ ПАДЕНИЯ ТЯЖЕЛОЙ ГЛЫБЫ С ВРАЩЕНИЕМ ОСКОЛКОВ
            AnimatedBuilder(
              animation: _fallAnimation,
              builder: (context, child) {
                final fallValue = _fallAnimation.value;
                
                return Stack(
                  children: [
                    // Ваня Баннихоп стоит на месте кадра 2 (left: 36)
                    // Каменная глыба летит на него сверху и полностью НАКРЫВАЕТ на отметке bottom: 22
                    Positioned(
                      bottom: 160 - (fallValue * 138), // Летит с высоты 160 прямо на уровень пола (22)
                      left: 30, // Выровнена чётко по центру Вани, чтобы накрыть его целиком
                      child: Container(
                        width: 60, height: 42, // Широкий прямоугольник плиты, полностью закрывающий птицу
                        decoration: BoxDecoration(
                          color: const Color(0xFF455A64), // Тёмный могильный сланец крыши
                          border: Border.all(color: Colors.black, width: 1.8),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    
                    // Улетающий в левый край кадра осколок
                    Positioned(
                      bottom: 130 - (fallValue * 110), 
                      left: 32 - (fallValue * 16), 
                      child: Transform.rotate(
                        angle: fallValue * pi * 4,
                        child: _buildFallingDebris(6, 10),
                      ),
                    ),

                    // Отлетающий вправо к трону осколок
                    Positioned(
                      bottom: 150 - (fallValue * 130), 
                      left: 55 + (fallValue * 22), 
                      child: Transform.rotate(
                        angle: -fallValue * pi * 3,
                        child: _buildFallingDebris(8, 8),
                      ),
                    ),
                  ],
                );
              },
            ),

            // Ваня Баннихоп рисуется ПОД плитой (если fallValue маленький — его видно, когда плита упала — он скрыт)
            if (_debrisController.value < 0.85)
              Positioned(bottom: 22, left: 36, child: _buildCharacter('assets/images/bunnyhop.png', 48)),

            // Торжествующий крик Дона Моллюска (облачко Вани удалено)
            Positioned(
              top: 25, left: 6, right: 6,
              child: CustomPaint(
                painter: SpeechBubblePainter(tailXFactor: 0.75), // Хвостик указывает на Босса
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Хрю-ха-ха! Я так и думал! Жалкая птица!",
                    style: TextStyle(fontSize: 9.0, fontWeight: FontWeight.bold, color: Colors.red, height: 1.15),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButton() {
    return Container(
      width: double.infinity, constraints: const BoxConstraints(maxWidth: 240), height: 46,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _currentFrame == 2 ? Colors.grey.shade700 : const Color(0xFFB71C1C), // Боевой красный
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
        ),
        onPressed: () {
          if (_currentFrame < 2) {
            setState(() => _currentFrame = 2);
            AudioManager.playCastleCollapse(); // Мощный грохот крушения
            _debrisController.forward(from: 0.0); // Запуск точного падения глыбы
          } else {
            // КНОПКА КОНЕЦ СЕЙЧАС ЗАБЛОКИРОВАНА ДО СОЗДАНИЯ ЭКРАНА КОНЦОВКИ
            print("Кнопка 'КОНЕЦ' заблокирована. Проектируем экран Плохого Финала.");
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            Text(
              _currentFrame == 2 ? "КОНЕЦ (ЗАБЛОКИРОВАНО)" : "ДАЛЬШЕ", 
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)
            ), 
            const SizedBox(width: 8), 
            Icon(_currentFrame == 2 ? Icons.lock_rounded : Icons.arrow_forward_ios_rounded, size: 16, color: Colors.white)
          ]
        ),
      ),
    );
  }

  Widget _buildAdvanced3DFrame({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black, width: 3.5),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 6, offset: Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF14141E), Color(0xFF06060A)],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0, left: 0, right: 0, 
              child: CustomPaint(
                size: const Size(double.infinity, 35), 
                painter: _CeilingPainter(drawHole: false),
              ),
            ),
            Positioned(
              bottom: 0, left: 0, right: 0, 
              child: CustomPaint(
                size: const Size(double.infinity, 24), 
                painter: _FloorTilesPainter(),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildFallingDebris(double w, double h) {
    return Container(
      width: w, height: h,
      decoration: BoxDecoration(
        color: const Color(0xFF37474F),
        border: Border.all(color: Colors.black, width: 1),
      ),
    );
  }

  Widget _buildThrone() {
    return SizedBox(
      width: 40, height: 58,
      child: Stack(
        children: [
          Positioned(
            bottom: 4, left: 4, right: 4, 
            child: Container(
              height: 54, 
              decoration: BoxDecoration(
                color: const Color(0xFF3E2723), 
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)), 
                border: Border.all(color: const Color(0xFF1A0C00), width: 1.8),
              ),
            ),
          ),
          Positioned(bottom: 4, left: 0, child: Container(width: 5, height: 26, decoration: BoxDecoration(color: const Color(0xFF4E342E), border: Border.all(color: Colors.black, width: 0.8)))),
          Positioned(bottom: 4, right: 0, child: Container(width: 5, height: 26, decoration: BoxDecoration(color: const Color(0xFF4E342E), border: Border.all(color: Colors.black, width: 0.8)))),
          Positioned(bottom: 6, left: 3, right: 3, child: Container(height: 14, color: const Color(0xFF4E342E))),
          Positioned(bottom: 14, left: 4, right: 4, child: Container(height: 6, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFD32F2F), Color(0xFFFF5252), Color(0xFFB71C1C)]), borderRadius: BorderRadius.circular(2)))),
        ],
      ),
    );
  }

  Widget _buildGoldTotem(double size) {
    return SizedBox(
      width: size, height: size * 1.1,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(bottom: 0, child: Container(width: size * 0.75, height: size * 0.16, decoration: BoxDecoration(color: const Color(0xFF111116), borderRadius: BorderRadius.circular(2), border: Border.all(color: Colors.black, width: 1.5)))),
          Positioned(bottom: size * 0.14, child: Container(width: size * 0.14, height: size * 0.32, decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFE5A632), Color(0xFFFFD54F), Color(0xFFB57C1E)])))),
          Positioned(
            bottom: size * 0.38, 
            child: SizedBox(
              width: size * 1.05, height: size * 0.65,
              child: CustomPaint(painter: _WingsPainter()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacter(String assetPath, double size) {
    return Container(
      width: size, height: size, 
      decoration: BoxDecoration(color: const Color(0xFFE53935), shape: BoxShape.circle, border: Border.all(color: Colors.black, width: 2.0)), 
      child: ClipOval(child: Image.asset(assetPath, fit: BoxFit.cover)),
    );
  }
}

class _CeilingPainter extends CustomPainter {
  final bool drawHole;
  _CeilingPainter({required this.drawHole});

  @override
  void paint(Canvas canvas, Size size) {
    final ceilPaint = Paint()..color = const Color(0xFF15151D)..style = PaintingStyle.fill;
    final beamPaint = Paint()..color = const Color(0xFF09090D)..style = PaintingStyle.stroke..strokeWidth = 2.2;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), ceilPaint);
    for (int i = 0; i <= 6; i++) {
      canvas.drawLine(Offset(size.width * (i / 6), 0), Offset(size.width * 0.5, size.height), beamPaint);
    }
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), beamPaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FloorTilesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final tilePaint = Paint()..color = const Color(0xFF1E1E24)..style = PaintingStyle.fill;
    final linePaint = Paint()..color = const Color(0xFF111114)..style = PaintingStyle.stroke..strokeWidth = 1.6;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), tilePaint);
    
    for (int i = 0; i < 5; i++) {
      double hY = size.height * (0.2 + (i * i * 0.8 / 16));
      canvas.drawLine(Offset(0, hY), Offset(size.width, hY), linePaint);
    }
    for (int i = 0; i <= 12; i++) {
      canvas.drawLine(Offset(size.width * (0.3 + (i * 0.4 / 12)), 0), Offset(size.width * (i / 12), size.height), linePaint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WingsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final goldPaint = Paint()..color = const Color(0xFFFFD54F)..style = PaintingStyle.fill;
    final path = Path();
    path.moveTo(size.width * 0.5, size.height);
    path.cubicTo(size.width * 0.25, size.height * 0.8, -size.width * 0.2, size.height * 0.2, -size.width * 0.1, -size.height * 0.25); 
    path.cubicTo(size.width * 0.15, size.height * 0.2, size.width * 0.35, size.height * 0.5, size.width * 0.5, size.height * 0.35);
    path.cubicTo(size.width * 0.65, size.height * 0.5, size.width * 0.85, size.height * 0.2, size.width * 1.1, -size.height * 0.25); 
    path.cubicTo(size.width * 1.2, size.height * 0.2, size.width * 0.75, size.height * 0.8, size.width * 0.5, size.height);
    path.close();
    canvas.drawPath(path, goldPaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SpeechBubblePainter extends CustomPainter {
  final double tailXFactor;
  SpeechBubblePainter({required this.tailXFactor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    final borderPaint = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 1.8;
    final path = Path()..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(12)));
    double startX = size.width * tailXFactor;
    path.moveTo(startX - 6, size.height);
    path.lineTo(startX, size.height + 10); 
    path.lineTo(startX + 6, size.height);
    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RageAuraPainter extends CustomPainter {
  final double pulseTimer;
  _RageAuraPainter({required this.pulseTimer});

  @override
  void paint(Canvas canvas, Size size) {
    double birdRadius = size.width / 4;
    double center = size.width / 2;
    double pulse = 1.0 + (sin(pulseTimer * 15.0) * 0.08);

    final auraFill = Paint()..color = const Color(0xFF00E5FF)..style = PaintingStyle.fill;
    final auraBorder = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2.5;

    final auraPath = Path();
    int spikeCount = 12; 
    for (int i = 0; i < spikeCount; i++) {
      double angle = (i * pi * 2) / spikeCount;
      double currentRadius = (i % 2 == 0 ? birdRadius * 2.2 : birdRadius * 1.4) * pulse;
      double x = center + cos(angle) * currentRadius;
      double y = center + sin(angle) * currentRadius;
      if (i == 0) auraPath.moveTo(x, y); else auraPath.lineTo(x, y);
    }
    auraPath.close();
    canvas.drawPath(auraPath, auraFill);
    canvas.drawPath(auraPath, auraBorder);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _LightningSparkPainter extends CustomPainter {
  final int randSeed;
  _LightningSparkPainter({required this.randSeed});

  @override
  void paint(Canvas canvas, Size size) {
    double center = size.width / 2;
    double birdRadius = size.width / 5;
    final sparkPaint = Paint()..color = const Color(0xFF00E5FF)..strokeWidth = 2.0..style = PaintingStyle.stroke;

    final rand = Random(randSeed);
    for (int i = 0; i < 4; i++) {
      double sparkAngle = rand.nextDouble() * pi * 2;
      double startX = center + cos(sparkAngle) * (birdRadius * 2.2);
      double startY = center + sin(sparkAngle) * (birdRadius * 2.2);
      
      final sparkPath = Path()..moveTo(startX, startY);
      double cx = startX; double cy = startY;
      for (int step = 0; step < 2; step++) {
        cx += cos(sparkAngle) * 6 + (rand.nextDouble() * 4 - 2);
        cy += sin(sparkAngle) * 6 + (rand.nextDouble() * 4 - 2);
        sparkPath.lineTo(cx, cy);
      }
      canvas.drawPath(sparkPath, sparkPaint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _FlyingStarsPainter extends CustomPainter {
  final int randSeed;
  _FlyingStarsPainter({required this.randSeed});

  @override
  void paint(Canvas canvas, Size size) {
    double center = size.width / 2;
    double birdRadius = size.width / 5.5;
    final starPaint = Paint()..color = const Color(0xFFFFD54F)..style = PaintingStyle.fill;
    final starBorder = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 0.8;
    
    final starRand = Random(randSeed);
    for (int i = 0; i < 3; i++) {
      double starAngle = starRand.nextDouble() * pi * 2;
      double distanceFactor = birdRadius * (1.8 + starRand.nextDouble() * 1.5);
      Offset starPos = Offset(center + cos(starAngle) * distanceFactor, center + sin(starAngle) * distanceFactor);

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
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}



