import 'dart:math';
import 'package:flutter/material.dart';
import 'audio_manager.dart';

class Level6Case07Screen extends StatefulWidget {
  const Level6Case07Screen({super.key});

  @override
  State<Level6Case07Screen> createState() => _Level6Case07ScreenState();
}

class _Level6Case07ScreenState extends State<Level6Case07Screen> with SingleTickerProviderStateMixin {
  late AnimationController _tickerController;
  double _endingTimer = 0.0;
  final List<Offset> _castleFloorDrops = List.generate(3, (i) => Offset(400.0 / 2 + (i * 12 - 12), 0));

  @override
  void initState() {
    super.initState();
    // Включаем непрерывные капли замка на старте экрана дела №07
    AudioManager.startCastleDrops();

    // Запускаем непрерывный тикер времени для плавной анимации падающих капель
    _tickerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(() {
        setState(() {
          _endingTimer += 0.016; // Шаг анимации
        });
      });
    _tickerController.repeat();
  }

  @override
  void dispose() {
    _tickerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const double realGroundY = 0.88; // Твой каноничный уровень пола

    // Рассчитываем вспышку улыбки и глаз Дона Моллюска по синусоиде времени
    double bossGlow = (sin(_endingTimer * pi * 1.5) + 1.0) / 2.0;
    // Зажимаем прозрачность в рамки от 0.03 (едва видно) до 0.22 (мистический силуэт)
    double targetOpacity = 0.03 + (bossGlow * 0.19);

    return Scaffold(
      backgroundColor: const Color(0xFF020204), // Абсолютная темнота вокруг зала
      body: Stack(
        children: [
          // 🏛️ 1. ГЛАВНЫЙ ЗАЛ КРЕПОСТИ НА ВЕСЬ ЭКРАН В ОБРАТНОЙ ПЕРСПЕКТИВЕ
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF14141E), Color(0xFF06060A)],
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Потолок с проломом крыши в обратной перспективе
                  Positioned(top: 0, left: 0, right: 0, child: CustomPaint(size: const Size(double.infinity, 35), painter: _Case07CeilingPainter(drawHole: true))),
                  // 3D-плитка пола в обратной перспективе
                  Positioned(bottom: 0, left: 0, right: 0, child: CustomPaint(size: const Size(double.infinity, 24), painter: _Case07FloorTilesPainter())),

                  // 🐙 2. НА ЗАДНЕМ ПЛАНЕ В ТЕМНОТЕ КУЛЬТОВАЯ ВСПЫХИВАЮЩАЯ УЛЫБКА И ГЛАЗА ДОНА
                  Positioned(
                    bottom: size.height * 0.32, 
                    right: size.width * 0.22,
                    child: Opacity(
                      opacity: targetOpacity, 
                      child: CustomPaint(
                        size: const Size(85, 40),
                        painter: _Case07MolluskSmilePainter(),
                      ),
                    ),
                  ),

                  // 🤠 3. СУПЕР ДЕТАЛИЗИРОВАННАЯ КОВБОЙСКАЯ ШЛЯПА ШЕРИФА В ЦЕНТРЕ ПОЛА
                  Positioned(
                    bottom: 24, 
                    left: size.width * 0.5 - 20, // Чётко по центру под проломом крыши
                    child: CustomPaint(
                      size: const Size(40, 24),
                      painter: _Case07DetailedSheriffHatPainter(),
                    ),
                  ),

                  // 💧 4. ОДИНОЧНЫЕ КАПЛИ ДОЖДЯ, ПАДАЮЩИЕ С НЕБА ПРЯМО НА ШЛЯПУ ПО ОЧЕРЕДИ
                  ..._castleFloorDrops.asMap().entries.map((entry) {
                    int index = entry.key;
                    double floorY = size.height * realGroundY;
                    
                    // Реалистичный асинхронный расчет падения капли по времени
                    double dropProgress = (_endingTimer * 1.5 + (index * 0.33)) % 1.0;
                    double liveDropY = 35.0 + (dropProgress * (floorY - 35.0 - 12.0));
                    
                    return Positioned(
                      left: size.width * 0.5 - 6 + (index * 6 - 6), 
                      top: liveDropY,
                      child: Container(
                        width: 1.6, 
                        height: 4.5, 
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(dropProgress > 0.94 ? 0.0 : 0.35), 
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // 📜 5. ИСПРАВЛЕНО: ДВЕ НАДПИСИ «КОНЕЦ» И «ДЕЛО №07» НАВЕРХУ ПОД ПОТОЛКОМ
          Positioned(
            left: 24, right: 24, top: 42, 
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "КОНЕЦ",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFFB71C1C), letterSpacing: 3.5, decoration: TextDecoration.none),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white10, width: 0.8)),
                  child: const Text(
                    "Дело №07: Шериф объявлен пропавшим без вести на лугу свиней. Расследование прекращено.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'serif', fontSize: 11.0, fontWeight: FontWeight.bold, color: Colors.white70, height: 1.35, decoration: TextDecoration.none),
                  ),
                ),
              ],
            ),
          ),

          // 🏠 6. КНОПКА ВОЗВРАТА СМЕЩЕНА ЛЕВЕЕ В НИЖНИЙ УГОЛ СМАРТФОНА
          Positioned(
            bottom: 16, 
            left: 24, 
            child: SizedBox(
              width: 155, height: 38,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF37474F), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 4,
                ),
                onPressed: () {
                  AudioManager.stopLevelAudioAndPlayMenu();
                  Navigator.pop(context); 
                },
                icon: const Icon(Icons.home_rounded, color: Colors.white, size: 16),
                label: const Text("В МЕНЮ УРОВНЕЙ", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// ВЕКТОРНЫЕ СТРУКТУРЫ РИСОВАЛЬЩИКОВ ДЛЯ ЭКРАНА СМЕРТИ ДЕЛА №07
// =========================================================================
class _Case07CeilingPainter extends CustomPainter {
  final bool drawHole;
  _Case07CeilingPainter({required this.drawHole});

  @override
  void paint(Canvas canvas, Size size) {
    final ceilPaint = Paint()..color = const Color(0xFF15151D)..style = PaintingStyle.fill;
    final beamPaint = Paint()..color = const Color(0xFF09090D)..style = PaintingStyle.stroke..strokeWidth = 2.2;
    
    if (drawHole) {
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Case07FloorTilesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final tilePaint = Paint()..color = const Color(0xFF1E1E24)..style = PaintingStyle.fill;
    final linePaint = Paint()..color = const Color(0xFF111114)..style = PaintingStyle.stroke..strokeWidth = 1.6;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), tilePaint);
    
    for (int i = 0; i < 5; i++) {
      double hY = size.height * (0.8 - (i * i * 0.8 / 16));
      canvas.drawLine(Offset(0, hY), Offset(size.width, hY), linePaint);
    }
    for (int i = 0; i <= 12; i++) {
      canvas.drawLine(Offset(size.width * (i / 12), 0), Offset(size.width * (0.3 + (i * 0.4 / 12)), size.height), linePaint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ЗАМЕНИТЬ СТРОГО ТОЧЕЧНО ДВА КЛАССА В САМОМ КОНЦЕ ФАЙЛА LIB/LEVEL6_CASE07_SCREEN.DART:

class _Case07MolluskSmilePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Делаем цвет зубов и глаз чуть приглушеннее, чтобы босс казался темнее и мрачнее
    final whitePaint = Paint()..color = Colors.white.withOpacity(0.85)..style = PaintingStyle.fill;

    // 1. ДВА ЗЛОБНЫХ ГЛАЗА-РОМБА ДОНА МОЛЛЮСКА
    final leftEye = Path()
      ..moveTo(size.width * 0.18, 0)
      ..lineTo(size.width * 0.32, size.height * 0.22)
      ..lineTo(size.width * 0.24, size.height * 0.48)
      ..lineTo(size.width * 0.10, size.height * 0.22)
      ..close();
    canvas.drawPath(leftEye, whitePaint);

    final rightEye = Path()
      ..moveTo(size.width * 0.82, 0)
      ..lineTo(size.width * 0.90, size.height * 0.22)
      ..lineTo(size.width * 0.76, size.height * 0.48)
      ..lineTo(size.width * 0.68, size.height * 0.22)
      ..close();
    canvas.drawPath(rightEye, whitePaint);

    // 2. ИСПРАВЛЕНО ТОЧЕЧНО: Дуга очертания лица полностью УДАЛЕНА сквозь весь метод!

    // 3. ЗУБЫ-КВАДРАТИКИ, ВЫСТРОЕННЫЕ ПО ЛИНИИ УЛЫБКИ СКВОЗЬ МРАК
    int teethCount = 7;
    for (int i = 0; i < teethCount; i++) {
      double offsetX = (size.width * 0.10) + (i * (size.width * 0.80 / (teethCount - 1)));
      double progress = i / (teethCount - 1);
      double offsetY = size.height * 0.64 + (sin(progress * pi) * (size.height * 0.14));
      
      canvas.drawRect(Rect.fromLTWH(offsetX, offsetY, 2.0, 2.0), whitePaint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Case07DetailedSheriffHatPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final hatPaint = Paint()..color = const Color(0xFF795548)..style = PaintingStyle.fill;
    final brimPaint = Paint()..color = const Color(0xFF5D4037)..style = PaintingStyle.fill;
    final ribbonPaint = Paint()..color = const Color(0xFF212121)..style = PaintingStyle.fill; 
    final borderPaint = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 1.4;
    final starPaint = Paint()..color = const Color(0xFFFFD54F)..style = PaintingStyle.fill; 

    canvas.save();
    // ИСПРАВЛЕНО ТОЧЕЧНО: Центрируем шляпу и удаляем наклон canvas.rotate, чтобы она лежала строго ГОРИЗОНТАЛЬНО!
    canvas.translate(size.width / 2, size.height / 2);

    // 1. Широкие ровные ковбойские поля шляпы
    final brimPath = Path()
      ..moveTo(-size.width * 0.6, 4)
      ..cubicTo(-size.width * 0.3, 2, size.width * 0.3, 2, size.width * 0.6, 4)
      ..lineTo(size.width * 0.5, 7)
      ..cubicTo(size.width * 0.2, 5, -size.width * 0.2, 5, -size.width * 0.5, 7)
      ..close();
    canvas.drawPath(brimPath, brimPaint);
    canvas.drawPath(brimPath, borderPaint);

    // 2. Высокая тулья шляпы шерифа
    final hatPath = Path()
      ..moveTo(-12, 2)
      ..lineTo(-9, -10)
      ..cubicTo(-5, -15, 5, -15, 9, -10)
      ..lineTo(12, 2)
      ..close();
    canvas.drawPath(hatPath, hatPaint);
    canvas.drawPath(hatPath, borderPaint);

    // 3. Черная ковбойская лента
    final ribbonRect = Rect.fromLTWH(-11.5, -1, 23, 3);
    canvas.drawRect(ribbonRect, ribbonPaint);
    canvas.drawRect(ribbonRect, borderPaint..strokeWidth = 0.5);

    // 4. Полноценная золотая звезда шерифа по центру
    final starPath = Path()
      ..moveTo(0, -9)
      ..lineTo(1.8, -5)
      ..lineTo(5.5, -5)
      ..lineTo(2.2, -2.5)
      ..lineTo(3.8, 1.5)
      ..lineTo(0, -1)
      ..lineTo(-3.8, 1.5)
      ..lineTo(-2.2, -2.5)
      ..lineTo(-5.5, -5)
      ..lineTo(-1.8, -5)
      ..close();
    canvas.drawPath(starPath, starPaint);
    canvas.drawPath(starPath, borderPaint..strokeWidth = 0.5);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


