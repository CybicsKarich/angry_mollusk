import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'audio_manager.dart'; // Для очистки вечных плееров Моллюска при выходе

class TrueEndingScreen extends StatefulWidget {
  const TrueEndingScreen({super.key});

  @override
  State<TrueEndingScreen> createState() => _TrueEndingScreenState();
}

class _TrueEndingScreenState extends State<TrueEndingScreen> with TickerProviderStateMixin {
  late AnimationController _glitchController;
  late AnimationController _textController;
  
  bool _isTvPowerOnSequence = true; // Эффект ослепляющего включения кинескопа
  double _tvLineHeight = 0.0;       // Сжатие экрана в полосу на старте
  double _tvWidth = 0.0;
  
  // Для динамического шума и подёргивания букв растра
  final Random _crtRand = Random();
  double _glitchOffset = 0.0;
  bool _showCRTNoise = true;

  @override
  void initState() {
    super.initState();
    
    // 1. Анимация включения старого ЭЛТ-телевизора Дона Моллюска
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _tvLineHeight = 4.0; // Сначала экран — тонкая неоновая нить
        _tvWidth = 1.0;
      });
      
          Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      setState(() {
        _tvLineHeight = 4.0;
        _tvWidth = 1.0;
      });
      
      Future.delayed(const Duration(milliseconds: 250), () {
        if (!mounted) return;
        setState(() {
          _isTvPowerOnSequence = false;
        });
        AudioManager.startCastleDrops(); 
      });
    });


    // 2. Бешеный цикличный таймер для глитчей и горизонтальных помех кинескопа
    _glitchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    )..addListener(() {
        setState(() {
          _glitchOffset = _crtRand.nextDouble() * 1.8 - 0.9;
          _showCRTNoise = _crtRand.nextDouble() < 0.85;
        });
      })..repeat();

    // 3. Контроллер плавного появления строк хакерского терминала
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..forward();
  }

  @override
  void dispose() {
    _glitchController.dispose();
    _textController.dispose();
    super.dispose();
  }

  // Загрузчик честных данных симуляции из SharedPreferences
  Future<Map<String, int>> _loadTrueStats() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'birds': prefs.getInt('stats_birds_launched') ?? 0,
      'pills': prefs.getInt('stats_pills_consumed') ?? 0,
      'pigs': prefs.getInt('stats_pigs_defeated') ?? 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    // Режим «Вспышки выключающегося / включающегося ТВ»
    if (_isTvPowerOnSequence) {
      return Scaffold(
        backgroundColor: const Color(0xFF020204),
        body: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _tvWidth * media.width,
            height: _tvLineHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.cyanAccent.withOpacity(0.8), blurRadius: 15, spreadRadius: 2)
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF040407), // Кромешная тьма комнаты Дона
      body: FutureBuilder<Map<String, int>>(
          future: _loadTrueStats(),
          builder: (context, snapshot) {
            final stats = snapshot.data ?? {'birds': 0, 'pills': 0, 'pigs': 0};


            return Stack(
              children: [
                // 📺 СЛОЙ 1: ХАКЕРСКАЯ МАТРИЦА С БЕГУЩИМИ ПОЛОСАМИ РАСТРА КИНЕСКОПА
                Positioned.fill(
                  child: CustomPaint(
                    painter: _CRTMatrixBackgroundPainter(
                      noiseSeed: _glitchOffset,
                      drawLines: _showCRTNoise,
                    ),
                  ),
                ),

                // Скрытая тень кукловода: Векторный Дон Моллюск лениво пьёт чай на заднем плане в углу экрана
                Positioned(
                  bottom: -10,
                  right: media.width * 0.02,
                  child: Opacity(
                    opacity: 0.04, // Едва заметный, призрачный силуэт Бога симуляции
                    child: Transform.scale(
                      scale: 1.8,
                      child: _buildMolluskBackgroundSilhuette(),
                    ),
                  ),
                ),

                                // 📺 СЛОЙ 2: ТВОЙ ФИРМЕННЫЙ ЯДОВИТО-ЗЕЛЁНЫЙ ТЕКСТ ПО ТЗ С ГЛИТЧ-ЭФФЕКТОМ
                Center(
                  child: Transform.translate(
                    offset: Offset(_glitchOffset * 0.5, 0), // Лёгкое подёргивание букв от наводок тока
                    child: Container(
                      width: media.width * 0.60,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.cyan.withOpacity(0.01), // Лёгкий оттенок люминофора
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: FadeTransition(
                        opacity: _textController,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Твой зафиксированный бренд
                            const Text(
                              "KARRICK STUDIO",
                              style: TextStyle(
                                fontFamily: 'Courier New', // Настоящий моноширинный пиксельный шрифт
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00FF66), // Ядовито-зелёный неон
                                letterSpacing: 2.5,
                                shadows: [Shadow(color: Color(0xFF00C853), blurRadius: 8)],
                              ),
                            ),
                            const SizedBox(height: 14),
                            
                            const Text(
                              "Спасибо за прохождение игры!\nНадеюсь, увидимся снова!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Courier New',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFB9F6CA), // Смягчённый зелёный растр
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(width: 120, height: 1.0, color: const Color(0xFF00FF66).withOpacity(0.25)),
                            const SizedBox(height: 16),

                            // СТАТИСТИКА ИГРЫ СТРОГО ПО ТВОЕМУ ТОЧНОМУ ШАБЛОНУ
                            _buildCRTStatLine("• Запущено птиц из рогатки:", stats['birds']!),
                            const SizedBox(height: 8),
                            _buildCRTStatLine("• Потрачено капсул Виагры:", stats['pills']!),
                            const SizedBox(height: 8),
                            _buildCRTStatLine("• Убито зелёных свиней:", stats['pigs']!),

                            const SizedBox(height: 32),

                            
                            const Text(
                              "КОНЕЦ.",
                              style: TextStyle(
                                fontFamily: 'Courier New',
                                fontSize: 34,
                                fontWeight: FontWeight.w900, // ИСПРАВЛЕНО: w900 вместо несуществующего black
                                color: Color(0xFFFF1744), // Кроваво-красный неон смерти цикла
                                letterSpacing: 5.0,
                                shadows: [Shadow(color: Color(0xFFD50000), blurRadius: 10)],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // КНОПКА СБРОСА И ПЕРЕЗАГРУЗКИ МАТРИЦЫ КИНЕСКОПА
                            SizedBox(
                              width: 220,
                              height: 38,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFF00FF66), width: 1.5),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  backgroundColor: const Color(0xFF00FF66).withOpacity(0.04),
                                ),
                                onPressed: () {
                                  // Полностью зачищаем вечные капли Моллюска и вылетаем в корень на Трамплин
                                  AudioManager.stopFinalComicAudio();
                                  Navigator.of(context).popUntil((route) => route.isFirst); 
                                },
                                child: const Text(
                                  "В главное меню",
                                  style: TextStyle(
                                    fontFamily: 'Courier New',
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF00FF66),
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
    );
  }

  // Построение зелёной строки терминала
  Widget _buildCRTStatLine(String label, int value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Courier New', fontSize: 11, color: Color(0xFFB9F6CA))),
        Text(
          value.toString(),
          style: const TextStyle(fontFamily: 'Courier New', fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF00FF66), shadows: [Shadow(color: Color(0xFF00C853), blurRadius: 4)]),
        ),
      ],
    );
  }

  // Силуэт Дона Моллюска с чашкой чая из Части 2, скрытый в темноте за растром
  Widget _buildMolluskBackgroundSilhuette() {
    return SizedBox(
      width: 70,
      height: 70,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Тело халата
          Container(
            width: 50, height: 50,
            decoration: const BoxDecoration(color: Colors.white10, shape: BoxShape.circle),
          ),
          // Два ромбовидных глаза ложного бога тускло горят сквозь ЭЛТ-шум
          Positioned(
            top: 24, left: 18,
            child: Transform.rotate(angle: 0.3, child: Container(width: 8, height: 3, color: const Color(0xFF00FF66).withOpacity(0.3))),
          ),
          Positioned(
            top: 24, right: 18,
            child: Transform.rotate(angle: -0.3, child: Container(width: 8, height: 3, color: const Color(0xFF00FF66).withOpacity(0.3))),
          ),
        ],
      ),
    );
  }
} // Класс состояния полностью закрыт

// =========================================================================
// ШЕЙДЕРНЫЙ PAINTER: ВОГНУТАЯ МАТРИЦА КИНЕСКОПА, ЛУЧИ И ГОРИЗОНТАЛЬНЫЙ РАСТР
// =========================================================================
class _CRTMatrixBackgroundPainter extends CustomPainter {
  final double noiseSeed;
  final bool drawLines;
  _CRTMatrixBackgroundPainter({required this.noiseSeed, required this.drawLines});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = const Color(0xFF00FF66).withOpacity(0.025) // Тончайшие нити лучей ЭЛТ
      ..strokeWidth = 1.0;

    // 1. Отрисовка горизонтальных линий телевизионной развёртки растра
    if (drawLines) {
      for (double y = 0; y < size.height; y += 3.5) {
        // Добавляем микро-смещение по фазе шума для эффекта живого мерцания кинескопа
        double shiftY = y + (noiseSeed * 0.4);
        canvas.drawLine(Offset(0, shiftY), Offset(size.width, shiftY), linePaint);
      }
    }

    // 2. ЭФФЕКТ СФЕРИЧЕСКОГО ВОГНУТОГО КИНЕСКОПА (Виньетка старого ТВ по краям)
    final Rect matrixRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final Paint vignettePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.85,
        colors: [
          Colors.transparent,
          const Color(0xFF00FF66).withOpacity(0.015), // Легкий зелёный люминофор по центру
          Colors.black.withOpacity(0.75),             // Глубокое сферическое затемнение по углам трубки
          Colors.black,
        ],
        stops: const [0.0, 0.4, 0.85, 1.0],
      ).createShader(matrixRect);

    canvas.drawRect(matrixRect, vignettePaint);
  }

  @override
  bool shouldRepaint(covariant _CRTMatrixBackgroundPainter oldDelegate) => true;
}

                
