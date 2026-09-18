import 'dart:math';
import 'package:flutter/material.dart';
import 'audio_manager.dart';
import 'main.dart';
import 'package:flutter/scheduler.dart';

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
      backgroundColor: const Color(0xFF040407), 
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 4), // Уменьшили отступ сверху с 12 до 4
            const Text(
              "ГЛАВА VI: ЛОГОВО ДОНА МОЛЛЮСКА",
              style: TextStyle(
                fontSize: 18, // Уменьшили шрифт с 22 до 18 для экономии места
                fontWeight: FontWeight.w900,
                color: Color(0xFF455A64),
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 6), // Уменьшили отступ до 6

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    if (_currentFrame >= 1) _buildBadFrame1(), 
                    if (_currentFrame >= 2) const SizedBox(width: 12),
                    if (_currentFrame >= 2) _buildBadFrame2(), 
                    if (_currentFrame >= 3) const SizedBox(width: 12),
                    if (_currentFrame >= 3) _buildBadFrame3(), 
                  ],
                ),
              ),
            ),

            // ИСПРАВЛЕНО: Минимальные отступы кнопки для устранения Overflow
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0, top: 2.0),
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
        hasHole: false,
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

  Widget _buildBadFrame2() {
  return Expanded(
    child: _buildAdvanced3DFrame(
      hasHole: false,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(bottom: 22, right: 8, child: _buildDonMollusk(68)),

          // ВАНЯ И ВСЕ ЕГО ЭФФЕКТЫ ТАБЛЕТКИ СОБРАНЫ В ОДИН СТАК С ОБЩИМ ЦЕНТРОМ
          Positioned(
            bottom: 22, left: 32, // Четкое позиционирование Шерифа на полу кадра
            child: SizedBox(
              width: 80, height: 80, // Контейнер для центрирования
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 1. Синяя шипастая аура (Строго НАД уровнем пола за спиной Вани)
                  Transform.rotate(
                    angle: _sparkTimer * 12.0,
                    child: CustomPaint(
                      size: const Size(76, 76),
                      painter: _RageAuraPainter(pulseTimer: _sparkTimer),
                    ),
                  ),
                  // 2. Синие молнии
                  CustomPaint(
                    size: const Size(80, 80),
                    painter: _LightningSparkPainter(randSeed: (_sparkTimer * 60).toInt()),
                  ),
                  // 3. Желтые звездочки
                  CustomPaint(
                    size: const Size(84, 84),
                    painter: _FlyingStarsPainter(randSeed: (_sparkTimer * 30).toInt()),
                  ),
                  // 4. Сам Ваня Баннихоп поверх всех слоев эффектов
                  _buildCharacter('assets/images/bunnyhop.png', 48),
                ],
              ),
            ),
          ),

          // Текстовые облачка кадра
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
      hasHole: true, // ТОЧЕЧНО: Активируем дыру в потолке и темно-синее небо на 3 кадре!
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(bottom: 12, right: 8, child: _buildDonMollusk(64)),

          // ФИЗИЧЕСКОЕ ПАДЕНИЕ ПЛИТЫ СВЕРХУ НА ВАНЮ
          AnimatedBuilder(
            animation: _fallAnimation,
            builder: (context, child) {
              final fallValue = _fallAnimation.value;
              return Stack(
                children: [
                  // Серый блок крыши летит с высоты 160 вниз на пол (координата 22)
                  Positioned(
                    bottom: 160 - (fallValue * 138), 
                    left: 26, 
                    child: Container(
                      width: 60, height: 42, 
                      decoration: BoxDecoration(
                        color: const Color(0xFF455A64), 
                        border: Border.all(color: Colors.black, width: 1.8),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  // Осколки
                  Positioned(bottom: 130 - (fallValue * 110), left: 28 - (fallValue * 12), child: Transform.rotate(angle: fallValue * pi * 4, child: _buildFallingDebris(6, 10))),
                  Positioned(bottom: 150 - (fallValue * 130), left: 50 + (fallValue * 18), child: Transform.rotate(angle: -fallValue * pi * 3, child: _buildFallingDebris(8, 8))),
                ],
              );
            },
          ),

          // Прячем Ваню под плиту в финале падения
          if (_debrisController.value < 0.85)
            Positioned(bottom: 22, left: 32, child: _buildCharacter('assets/images/bunnyhop.png', 48)),

          Positioned(
            top: 25, left: 6, right: 6,
            child: CustomPaint(
              painter: SpeechBubblePainter(tailXFactor: 0.75), 
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
    width: double.infinity,
    constraints: const BoxConstraints(maxWidth: 240),
    height: 38, // Уменьшено с 46 до 38 для полного исключения overflow
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        backgroundColor: _currentFrame == 3 ? Colors.grey.shade700 : const Color(0xFFB71C1C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {
        if (_currentFrame < 3) {
          setState(() => _currentFrame++);
          
          if (_currentFrame == 2) {
            AudioManager.playRage(); 
          }
          if (_currentFrame == 3) {
            AudioManager.playCastleCollapse();
            _debrisController.forward(from: 0.0);
          }
        } else {
          print("Кнопка 'КОНЕЦ' заблокирована. Проектируем экран Плохого Финала.");
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, 
        children: [
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _currentFrame == 3 ? "КОНЕЦ (ЗАБЛОКИРОВАНО)" : "ДАЛЬШЕ", 
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ), 
          const SizedBox(width: 6), 
          Icon(_currentFrame == 3 ? Icons.lock_rounded : Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white),
        ],
      ),
    ),
  );
}


  // ЗАМЕНИТЬ ТОЧЕЧНО МЕТОД _buildAdvanced3DFrame В LIB/LEVEL6_BAD_ROUTE_SCREEN.DART:
Widget _buildAdvanced3DFrame({required Widget child, required bool hasHole}) {
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
          // Гранитный фон стен тронного зала
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
          
          // Если на 3 кадре крыша обрушилась — прорисовываем глубокий синий проём неба
          if (hasHole)
            Positioned(
              top: 0, left: 30, right: 30, height: 18,
              child: Container(color: const Color(0xFF0D1B2A)), 
            ),

          Positioned(
            top: 0, left: 0, right: 0, 
            child: CustomPaint(
              size: const Size(double.infinity, 35), 
              painter: _CeilingPainter(drawHole: hasHole), // Передаём флаг дыры в рисовальщик потолка
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

// ЗАМЕНИТЬ ТОЧЕЧНО В LIB/LEVEL6_COMIC_SCREEN.DART:
class _CeilingPainter extends CustomPainter {
  final bool drawHole;
  _CeilingPainter({required this.drawHole});

  @override
  void paint(Canvas canvas, Size size) {
    final ceilPaint = Paint()..color = const Color(0xFF15151D)..style = PaintingStyle.fill;
    final beamPaint = Paint()..color = const Color(0xFF09090D)..style = PaintingStyle.stroke..strokeWidth = 2.2;
    
    if (!drawHole) {
      // Сплошной потолок: линии сходятся НА ПЕРЕДНЕМ плане и расширяются ВДАЛЬ
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), ceilPaint);
      for (int i = 0; i <= 6; i++) {
        // ОБРАТНАЯ ПЕРСПЕКТИВА: Старт из сжатого центра на переднем плане, уход в широкие края вдаль
        canvas.drawLine(Offset(size.width * 0.5, 0), Offset(size.width * (i / 6), size.height), beamPaint);
      }
    } else {
      // КРЫША ОБВАЛИЛАСЬ: Пролом расширяется вглубь, левый и правый уцелевшие куски сужаются к переду
      final leftPath = Path()
        ..moveTo(0, 0)..lineTo(size.width * 0.42, 0)
        ..lineTo(size.width * 0.35, size.height)..lineTo(0, size.height)..close();
      canvas.drawPath(leftPath, ceilPaint);
      canvas.drawPath(leftPath, beamPaint);

      final rightPath = Path()
        ..moveTo(size.width * 0.58, 0)..lineTo(size.width, 0)
        ..lineTo(size.width, size.height)..lineTo(size.width * 0.65, size.height)..close();
      canvas.drawPath(rightPath, ceilPaint);
      canvas.drawPath(rightPath, beamPaint);
    }
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), beamPaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}



// ЗАМЕНИТЬ ТОЧЕЧНО В LIB/LEVEL6_COMIC_SCREEN.DART:
class _FloorTilesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final tilePaint = Paint()..color = const Color(0xFF1E1E24)..style = PaintingStyle.fill;
    final linePaint = Paint()..color = const Color(0xFF111114)..style = PaintingStyle.stroke..strokeWidth = 1.6;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), tilePaint);
    
    // Горизонтальные плиты: сужаются (уплотняются) к нижнему краю экрана
    for (int i = 0; i < 5; i++) {
      double hY = size.height * (0.8 - (i * i * 0.8 / 16));
      canvas.drawLine(Offset(0, hY), Offset(size.width, hY), linePaint);
    }
    // Вертикальные швы: ОБРАТНЫЙ ВЕЕР (расширяются от низа к верху)
    for (int i = 0; i <= 12; i++) {
      canvas.drawLine(Offset(size.width * (i / 12), 0), Offset(size.width * (0.3 + (i * 0.4 / 12)), size.height), linePaint);
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

// =========================================================================
  // ИСПРАВЛЕHО: АНАТОМИЧЕСКАЯ СБОРКА БОССА ВПЛОТHУЮ К ТЕЛУ И БЕЗ КРАСHОГО ПЯТHА
  // =========================================================================
  Widget _buildDonMollusk(double size) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // 🐙 1. ЩУПАЛЬЦА СТАЛИ НА КАПЛЮ БОЛЬШЕ (size * 0.28) И ЗАЛЕЗАЮТ ПОД ЗЕЛЁHЫЙ КРУГ
          Positioned(bottom: size * 0.24, left: size * 0.04, child: Transform.rotate(angle: -0.3, child: CustomPaint(size: Size(size * 0.28, size * 0.58), painter: _DetailedTentaclePainter(isLeft: true)))),
          Positioned(top: size * 0.06, left: size * 0.12, child: Transform.rotate(angle: -1.3, child: CustomPaint(size: Size(size * 0.25, size * 0.53), painter: _DetailedTentaclePainter(isLeft: true)))),
          Positioned(top: size * 0.06, right: size * 0.12, child: Transform.rotate(angle: 1.3, child: CustomPaint(size: Size(size * 0.25, size * 0.53), painter: _DetailedTentaclePainter(isLeft: false)))),
          Positioned(bottom: size * 0.24, right: size * 0.04, child: Transform.rotate(angle: 0.4, child: CustomPaint(size: Size(size * 0.28, size * 0.58), painter: _DetailedTentaclePainter(isLeft: false)))),

          // 🐷 2. ИСПРАВЛЕНО: УШКИ СТАЛИ ПОДЛИННЕЕ (ОВАЛЫ) И ЗАЛЕЗАЮТ ПРЯМО НА ТЕЛО БОССА
          Positioned(
            top: size * 0.10, left: size * 0.08, 
            child: Transform.rotate(
              angle: -0.2,
              child: Container(
                width: size * 0.18, height: size * 0.26, // Сделали уши длинными вытянутыми овалами
                decoration: BoxDecoration(
                  color: const Color(0xFF689F38),
                  borderRadius: BorderRadius.circular(size * 0.09), // Скругление под длинный овал
                  border: Border.all(color: Colors.black, width: 1.8),
                ),
                child: Center(child: Container(width: size * 0.08, height: size * 0.14, decoration: BoxDecoration(color: const Color(0xFF558B2F), borderRadius: BorderRadius.circular(size * 0.05)))),
              ),
            ),
          ),
          Positioned(
            top: size * 0.10, right: size * 0.08, 
            child: Transform.rotate(
              angle: 0.2,
              child: Container(
                width: size * 0.18, height: size * 0.26, 
                decoration: BoxDecoration(
                  color: const Color(0xFF689F38),
                  borderRadius: BorderRadius.circular(size * 0.09),
                  border: Border.all(color: Colors.black, width: 1.8),
                ),
                child: Center(child: Container(width: size * 0.08, height: size * 0.14, decoration: BoxDecoration(color: const Color(0xFF558B2F), borderRadius: BorderRadius.circular(size * 0.05)))),
              ),
            ),
          ),

          // 🦀 3. ДВЕ НИЖНИЕ КЛЕШНИ: Идут строго ВВЕРХ, одинаковые полукругом и залезают на подложку
          Positioned(
            bottom: size * 0.16, left: -size * 0.02,
            child: Transform.rotate(angle: -0.1, child: CustomPaint(size: Size(size * 0.34, size * 0.34), painter: _DetailedCrabClawPainter(isOpen: false))),
          ),
          Positioned(
            bottom: size * 0.16, right: -size * 0.02,
            child: Transform.rotate(angle: 0.1, child: CustomPaint(size: Size(size * 0.34, size * 0.34), painter: _DetailedCrabClawPainter(isOpen: false))),
          ),

          // 🦀 4. ВЕРХНЯЯ КЛЕШНЯ: Тоже идёт строго вверх по центру макушки головы
          Positioned(
            top: -size * 0.12, left: size * 0.33,
            child: CustomPaint(size: Size(size * 0.34, size * 0.34), painter: _DetailedCrabClawPainter(isOpen: true)),
          ),

          // ИСПРАВЛЕНО: Красное пятно крови и обрубок полностью УДАЛЕНЫ с тела Босса по ТЗ!

          // 🟢 5. ЦЕНТРАЛЬНОЕ ЗЕЛИКОВОЕ ТЕЛО БОССА (Ложится ПОВЕРХ всех залезших конечностей)
          Container(
            width: size * 0.70,
            height: size * 0.70,
            decoration: BoxDecoration(
              color: const Color(0xFF558B2F),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF1B5E20), width: 2.2),
              boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 2))],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/maksim_boss.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF558B2F)), 
              ),
            ),
          ),
        ],
      ),
    );
  }

// =========================================================================
// КЛАСС 1: ВЫСОКОДЕТАЛИЗИРОВАННЫЙ РИСОВАЛЬЩИК ЩУПАЛЬЦА ОСЬМИНОГА С ПРИСОСКАМИ
// =========================================================================
class _DetailedTentaclePainter extends CustomPainter {
  final bool isLeft;
  _DetailedTentaclePainter({required this.isLeft});

    @override
  void paint(Canvas canvas, Size size) {
    final tentaclePaint = Paint()..color = const Color(0xFF0288D1)..style = PaintingStyle.fill;
    final strokePaint = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 1.6;
    final suctionPaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    final suctionHolePaint = Paint()..color = const Color(0xFF01579B)..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    final path = Path();
    path.moveTo(w * 0.5, h);
    // ИСПРАВЛЕНО: Сильные радиальные кубические кривые для красивого круглого изгиба щупальца!
    path.cubicTo(isLeft ? -w * 0.7 : w * 1.7, h * 0.7, isLeft ? w * 0.1 : w * 0.9, h * 0.2, w * 0.5, 0);
    path.lineTo(w * 0.7, 0);
    path.cubicTo(isLeft ? w * 0.3 : w * 0.7, h * 0.2, isLeft ? -w * 0.4 : w * 1.4, h * 0.7, w * 0.8, h);
    path.close();

    canvas.drawPath(path, tentaclePaint);
    canvas.drawPath(path, strokePaint);

        // ПРОРАБОТКА: Расставляем присоски, сделав их на каплю МЕНЬШЕ для детализации
    for (int i = 1; i <= 6; i++) {
      double factor = i * 0.14;
      double cx = isLeft ? w * (0.32 - factor * 0.15) : w * (0.68 + factor * 0.15);
      double cy = h * factor;
      
      // ИСПРАВЛЕHО: Уменьшили базовый радиус присосок с 3.4 до 2.2!
      double radius = 2.2 - (i * 0.15); 
      
      if (radius > 0.6) {
        canvas.drawCircle(Offset(cx, cy), radius, suctionPaint);
        canvas.drawCircle(Offset(cx, cy), radius, strokePaint..strokeWidth = 0.4);
        canvas.drawCircle(Offset(cx, cy), radius * 0.4, suctionHolePaint);
      }
    }
  }


  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
// =========================================================================
// КЛАСС 2: УЛЬТРА-ПРОРАБОТАНHЫЕ КРАБОВЫЕ КЛЕШHИ (СУСТАВЫ, ЗАЖИМЫ И ЗУБЦЫ)
// =========================================================================
class _DetailedCrabClawPainter extends CustomPainter {
  final bool isOpen;
  _DetailedCrabClawPainter({required this.isOpen});

      @override
  void paint(Canvas canvas, Size size) {
    final clawPaint = Paint()..color = const Color(0xFF2E6F22)..style = PaintingStyle.fill;
    final strokePaint = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 1.6;
    
    final w = size.width;
    final h = size.height;

    // 1. Прочный сустав-основание лапы (локоть)
    final jointPath = Path()
      ..moveTo(w * 0.4, h)
      ..lineTo(w * 0.3, h * 0.6)
      ..lineTo(w * 0.7, h * 0.6)
      ..lineTo(w * 0.6, h)
      ..close();
    canvas.drawPath(jointPath, clawPaint);
    canvas.drawPath(jointPath, strokePaint);

    // 2. ИСПРАВЛЕНО: Правая створка зажима в виде идеального налитого полукруга
    final mainClawPath = Path()
      ..moveTo(w * 0.3, h * 0.6)
      ..cubicTo(w * 0.05, h * 0.4, w * 0.1, 0, w * 0.5, 0)
      ..lineTo(w * 0.45, h * 0.2)
      ..cubicTo(w * 0.3, h * 0.3, w * 0.35, h * 0.5, w * 0.7, h * 0.6)
      ..close();
    canvas.drawPath(mainClawPath, clawPaint);
    canvas.drawPath(mainClawPath, strokePaint);

    // 3. ИСПРАВЛЕНО: Левая створка зажима тоже идет плавным полукругом
    final movingFingerPath = Path();
    if (isOpen) {
      movingFingerPath.moveTo(w * 0.45, h * 0.25);
      movingFingerPath.cubicTo(w * 0.75, h * 0.1, w * 0.95, h * 0.2, w * 0.85, h * 0.5);
      movingFingerPath.lineTo(w * 0.6, h * 0.45);
    } else {
      movingFingerPath.moveTo(w * 0.42, h * 0.15);
      movingFingerPath.cubicTo(w * 0.65, h * 0.2, w * 0.75, h * 0.35, w * 0.65, h * 0.55);
      movingFingerPath.lineTo(w * 0.52, h * 0.42);
    }
    movingFingerPath.close();
    canvas.drawPath(movingFingerPath, clawPaint);
    canvas.drawPath(movingFingerPath, strokePaint);

    // 4. ТЕКСТУРА: Ровно 2 мелких острых зубца
    final toothPaint = Paint()..color = Colors.white70..style = PaintingStyle.fill;
    canvas.drawTriangle(Offset(w * 0.38, h * 0.25), Offset(w * 0.34, h * 0.28), Offset(w * 0.42, h * 0.29), toothPaint);
    canvas.drawTriangle(Offset(w * 0.46, h * 0.32), Offset(w * 0.42, h * 0.35), Offset(w * 0.48, h * 0.36), toothPaint);
  }



  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =========================================================================
// ВЕКТОРНЫЙ ХУДОЖНИК ЩУПАЛЬЦА С КРУГЛЫМИ ПРИСОСКАМИ ИЗНУТРИ
// =========================================================================
class _MolluskTentacleWithSuctionsPainter extends CustomPainter {
  final bool isLeft;
  _MolluskTentacleWithSuctionsPainter({required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final tentaclePaint = Paint()..color = const Color(0xFF0288D1)..style = PaintingStyle.fill;
    final strokePaint = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 1.5;
    final suctionPaint = Paint()..color = Colors.white70..style = PaintingStyle.fill;
    final suctionHolePaint = Paint()..color = const Color(0xFF01579B)..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width * 0.5, size.height);
    path.cubicTo(isLeft ? 0.0 : size.width, size.height * 0.6, isLeft ? size.width * 0.1 : size.width * 0.9, size.height * 0.2, size.width * 0.5, 0);
    path.lineTo(size.width * 0.8, 0);
    path.cubicTo(isLeft ? size.width * 0.4 : size.width * 0.6, size.height * 0.2, isLeft ? size.width * 0.3 : size.width * 0.7, size.height * 0.6, size.width * 0.8, size.height);
    path.close();

    canvas.drawPath(path, tentaclePaint);
    canvas.drawPath(path, strokePaint);

    // РАССЧИТЫВАЕМ И ОТРИСОВЫВАЕМ ПРИСОСКИ:
    final suctionStrokePaint = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 0.5;

    for (int i = 1; i < 5; i++) {
      double hFactor = i * 0.22;
      double sx = isLeft ? size.width * 0.25 : size.width * 0.75;
      canvas.drawCircle(Offset(sx, size.height * hFactor), 3.0, suctionPaint);
      canvas.drawCircle(Offset(sx, size.height * hFactor), 3.0, suctionStrokePaint);
      canvas.drawCircle(Offset(sx, size.height * hFactor), 1.2, suctionHolePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =========================================================================
// ХЕЛПЕР-РАСШИРЕНИЕ ДЛЯ УДОБНОЙ ОТРИСОВКИ ТРЕУГОЛЬНЫХ ЗУБЬЕВ КЛЕШНИ
// =========================================================================
extension _CanvasTriangleExt on Canvas {
  void drawTriangle(Offset p1, Offset p2, Offset p3, Paint paint) {
    final path = Path()..moveTo(p1.dx, p1.dy)..lineTo(p2.dx, p2.dy)..lineTo(p3.dx, p3.dy)..close();
    drawPath(path, paint);
    // Накладываем тонкий контрастный чёрный контур на каждый зубчик
    drawPath(path, Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 0.5);
  }
}


