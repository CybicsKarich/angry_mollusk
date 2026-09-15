import 'dart:math';
import 'package:flutter/material.dart';
import 'audio_manager.dart';

class Level6ComicScreen extends StatefulWidget {
  const Level6ComicScreen({super.key});

  @override
  State<Level6ComicScreen> createState() => _Level6ComicScreenState();
}

class _Level6ComicScreenState extends State<Level6ComicScreen> {
  int _currentFrame = 1; // Текущий видимый кадр (1, 2 или 3)

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

            // ГЛАВНАЯ СЕТКА: Пошаговое появление кадров Хорошей Линии
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    if (_currentFrame >= 1) _buildFrame1(),
                    if (_currentFrame >= 2) const SizedBox(width: 12),
                    if (_currentFrame >= 2) _buildFrame2(),
                    if (_currentFrame >= 3) const SizedBox(width: 12),
                    if (_currentFrame >= 3) _buildFrame3(),
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
  // ХОРОШАЯ ЛИНИЯ - КАДР 1: Спокойствие шерифа против ухмылки босса
  // =========================================================================
  Widget _buildFrame1() {
    return Expanded(
      child: _buildAdvanced3DFrame(
        hasHole: false,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(bottom: 22, right: 10, child: Transform.scale(scale: 1.25, child: _buildThrone())),    
            Positioned(bottom: 22, right: 95, child: _buildGoldTotem(38)),
            Positioned(bottom: 22, left: 16, child: _buildCharacter('assets/images/bunnyhop.png', 56)),

            // Облачко слов Вани
            Positioned(
              top: 20, left: 6, width: 105,
              child: CustomPaint(
                painter: SpeechBubblePainter(tailXFactor: 0.25),
                child: const Padding(
                  padding: EdgeInsets.all(6.0),
                  child: Text(
                    "Творя власть на лугу птиц окончена, Моллюск. Отдай тотем гнева, освободи луг и мы закончим это.",
                    style: TextStyle(fontSize: 7.2, fontWeight: FontWeight.bold, color: Colors.black, height: 1.15),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

            // Ответ Дона Моллюска
            Positioned(
              top: 75, right: 6, width: 110,
              child: CustomPaint(
                painter: SpeechBubblePainter(tailXFactor: 0.8),
                child: const Padding(
                  padding: EdgeInsets.all(6.0),
                  child: Text(
                    "Ты слишком самоуверен для того, кто ползает по земле! Жалкая птица. Я следил за тобой с самого первого дня твоего путешествия, видел все твои битвы, я думал ты прибежишь сюда в ярости!",
                    style: TextStyle(fontSize: 6.8, fontWeight: FontWeight.bold, color: Colors.black, height: 1.1),
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
  // ХОРОШАЯ ЛИНИЯ - КАДР 2: Спокойное разоблачение планов босса
  // =========================================================================
  Widget _buildFrame2() {
    return Expanded(
      child: _buildAdvanced3DFrame(
        hasHole: false,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(bottom: 22, left: 12, child: _buildCharacter('assets/images/bunnyhop.png', 48)),
            Positioned(bottom: 12, right: 8, child: _buildDonMollusk(68)),

            // Ваня парирует психологическое давление
            Positioned(
              top: 20, left: 4, width: 110,
              child: CustomPaint(
                painter: SpeechBubblePainter(tailXFactor: 0.25),
                child: const Padding(
                  padding: EdgeInsets.all(6.0),
                  child: Text(
                    "Я видел все твои знаки и тени. Но они меня не напугали, а лишь привели к твоей двери. Твой план провалился.",
                    style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.bold, color: Colors.black, height: 1.15),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

            // Взрыв эмоций Дона Моллюска
            Positioned(
              top: 72, right: 4, width: 110,
              child: CustomPaint(
                painter: SpeechBubblePainter(tailXFactor: 0.75),
                child: const Padding(
                  padding: EdgeInsets.all(6.0),
                  child: Text(
                    "Ах ты наглая птица! Ты думаешь, раз выжил и разрушил все постройки, то сможешь одолеть меня?! Хрю-выкуси!",
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

  // =========================================================================
  // ХОРОШАЯ ЛИНИЯ - КАДР 3: Дырка в потолке, падение обломков ПЕРЕД Ваней
  // =========================================================================
  Widget _buildFrame3() {
    return Expanded(
      child: _buildAdvanced3DFrame(
        hasHole: true, // ВКЛЮЧАЕТ ТЕМНО-СИНЕЕ НЕБО И ДЫРУ В КРЫШЕ
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Каменная глыба-баррикада упала строго по центру между ними
            Positioned(
              bottom: 20, left: 62,
              child: Container(
                width: 25, height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFF37474F),
                  border: Border.all(color: Colors.black, width: 1.5),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            
            Positioned(bottom: 22, left: 12, child: _buildCharacter('assets/images/bunnyhop.png', 48)),
            Positioned(bottom: 12, right: 8, child: _buildDonMollusk(64)),

            // Анимация летящих вниз мелких осколков потолка
            Positioned(bottom: 65, left: 68, child: _buildFallingDebris(6, 10)),
            Positioned(bottom: 85, left: 74, child: _buildFallingDebris(8, 8)),

            Positioned(
              top: 25, left: 6, right: 6,
              child: CustomPaint(
                painter: SpeechBubblePainter(tailXFactor: 0.25),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Похоже твой замок разваливается сам, Моллюск! Ничего, сейчас я его доломаю и убью тебя!",
                    style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Colors.black, height: 1.15),
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
          backgroundColor: _currentFrame == 3 ? Colors.grey.shade700 : const Color(0xFF37474F), 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
        ),
        onPressed: () {
          if (_currentFrame < 3) {
            setState(() => _currentFrame++);
            // При переходе на 3-й кадр бахает звук обрушения потолка
            if (_currentFrame == 3) {
              AudioManager.playCastleCollapse();
            }
          } else {
            // КНОПКА ПОГНАЛИ СЕЙЧАС ЗАБЛОКИРОВАНА
            print("Кнопка 'ПОГНАЛИ!' заблокирована. Проектируем Action-битву.");
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            Text(
              _currentFrame == 3 ? "ПОГНАЛИ! (ЗАБЛОКИРОВАНО)" : "ДАЛЬШЕ", 
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)
            ), 
            const SizedBox(width: 8), 
            Icon(_currentFrame == 3 ? Icons.lock_rounded : Icons.arrow_forward_ios_rounded, size: 16, color: Colors.white)
          ]
        ),
      ),
    );
  }

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
            
            // Если крыша обвалилась — рисуем тёмно-синее ночное небо в проёме
            if (hasHole)
              Positioned(
                top: 0, left: 45, right: 45, height: 18,
                child: Container(color: const Color(0xFF0D1B2A)), 
              ),

            // Потолок с поддержкой отрисовки дыры
            Positioned(
              top: 0, left: 0, right: 0, 
              child: CustomPaint(
                size: const Size(double.infinity, 35), 
                painter: _CeilingPainter(drawHole: hasHole),
              ),
            ),

            // 3D-плитка пола
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
        color: const Color(0xFF455A64),
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

  Widget _buildDonMollusk(double size) {
    return SizedBox(
      width: size, height: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned(top: size * 0.10, left: size * 0.08, child: Transform.rotate(angle: -0.2, child: Container(width: size * 0.18, height: size * 0.26, decoration: BoxDecoration(color: const Color(0xFF689F38), borderRadius: BorderRadius.circular(size * 0.09), border: Border.all(color: Colors.black, width: 1.8)), child: Center(child: Container(width: size * 0.08, height: size * 0.14, decoration: BoxDecoration(color: const Color(0xFF558B2F), borderRadius: BorderRadius.circular(size * 0.05))))))),
          Positioned(top: size * 0.10, right: size * 0.08, child: Transform.rotate(angle: 0.2, child: Container(width: size * 0.18, height: size * 0.26, decoration: BoxDecoration(color: const Color(0xFF689F38), borderRadius: BorderRadius.circular(size * 0.09), border: Border.all(color: Colors.black, width: 1.8)), child: Center(child: Container(width: size * 0.08, height: size * 0.14, decoration: BoxDecoration(color: const Color(0xFF558B2F), borderRadius: BorderRadius.circular(size * 0.05))))))),
          Container(
            width: size * 0.70, height: size * 0.70,
            decoration: BoxDecoration(color: const Color(0xFF558B2F), shape: BoxShape.circle, border: Border.all(color: const Color(0xFF1B5E20), width: 2.2)),
            child: ClipOval(child: Image.asset('assets/images/maksim_boss.png', fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: const Color(0xFF558B2F)))),
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
    
    if (!drawHole) {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), ceilPaint);
      for (int i = 0; i <= 6; i++) {
        canvas.drawLine(Offset(size.width * (i / 6), 0), Offset(size.width * 0.5, size.height), beamPaint);
      }
    } else {
      // Левая уцелевшая часть крыши (образует рваный левый край дыры)
      final leftPath = Path()
        ..moveTo(0, 0)..lineTo(size.width * 0.35, 0)
        ..lineTo(size.width * 0.38, size.height)..lineTo(0, size.height)..close();
      canvas.drawPath(leftPath, ceilPaint);
      canvas.drawPath(leftPath, beamPaint);

      // Правая уцелевшая часть крыши (образует рваный правый край дыры)
      final rightPath = Path()
        ..moveTo(size.width * 0.65, 0)..lineTo(size.width, 0)
        ..lineTo(size.width, size.height)..lineTo(size.width * 0.62, size.height)..close();
      canvas.drawPath(rightPath, ceilPaint);
      canvas.drawPath(rightPath, beamPaint);
    }
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), beamPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
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


