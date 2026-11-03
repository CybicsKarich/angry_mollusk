import 'dart:math';
import 'package:flutter/material.dart';
import 'audio_manager.dart';
import 'main.dart'; // Для доступа к HomeScreen / Трамплину титров, если понадобится

class Level6VictoryComicScreen extends StatefulWidget {
  const Level6VictoryComicScreen({super.key});

  @override
  State<Level6VictoryComicScreen> createState() => _Level6VictoryComicScreenState();
}

class _Level6VictoryComicScreenState extends State<Level6VictoryComicScreen> with TickerProviderStateMixin {
  int _currentFrame = 1; // Текущий видимый кадр (1, 2 или 3)
  
  // Для анимации полета Вани кругами на 3-м кадре
  late AnimationController _flightController;

  @override
  void initState() {
    super.initState();
    
    // Запускаем триумфальную музыку неба из нашего AudioManager
    AudioManager.playSkyFreedom();

    // Бесконечный цикл вращения на 10 секунд (затем анимация повторяется)
    _flightController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _flightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF040407), // Темный атмосферный фон экрана
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            const Text(
              "ФИНАЛ: ТРИУМФ ШЕРИФА",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFFFF9800), // Золотой оттенок победы
                letterSpacing: 2.5,
                shadows: [Shadow(color: Colors.black, blurRadius: 6, offset: Offset(2, 2))],
              ),
            ),
            const SizedBox(height: 12),

                        // ГЛАВНАЯ СЕТКА КОМИКСА: Кадры поочередно сменяют друг друга
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    // ЧАСТЬ 1: Обычный триумф (Кадры 1, 2, 3)
                    if (_currentFrame == 1) _buildFrame1(),
                    if (_currentFrame == 2) _buildFrame2(),
                    if (_currentFrame == 3) _buildFrame3(),
                    
                    // ЧАСТЬ 2: Скрытая Истинная концовка (Кадры 4, 5, 6)
                    if (_currentFrame == 4) _buildFrame4(),
                    if (_currentFrame == 5) _buildFrame5(),
                    if (_currentFrame == 6) _buildFrame6(),
                  ],
                ),
              ),
            ),


            // НИЖНЯЯ ПАНЕЛЬ С КНОПКОЙ НАВИГАЦИИ
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
  // КАДР 1: ВАНЯ С ЛЕВЫМ ТОТЕМOМ И "УМЕРШИЙ" МОЛЛЮСК С ПРАВОЙ СТОРОНЫ
  // =========================================================================
  Widget _buildFrame1() {
    return Expanded(
      child: _buildAdvanced3DFrame(
        isRoom: true, // Включает потолок и пол тронного зала
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Поверженный Дон Моллюск (справа)
            Positioned(
              bottom: 12, right: 8,
              child: Transform.scale(
                scale: 1.1,
                child: _buildDonMolluskDead(64),
              ),
            ),
            
            // Древний Тотем Гнева (стоит рядом с Ваней)
            Positioned(bottom: 22, left: 74, child: _buildGoldTotem(36)),
            
            // Ваня Баннихоп победитель (слева)
            Positioned(bottom: 22, left: 16, child: _buildCharacterBase('assets/images/bunnyhop.png', 56)),

            // Облачко слов Вани
            Positioned(
              top: 25, left: 6, right: 6,
              child: CustomPaint(
                painter: SpeechBubblePainter(tailXFactor: 0.25),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Всё кончено, Моллюск. Тотем наш. Наш род возвращается в небо!",
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

  // =========================================================================
  // КАДР 2: ВАНЯ ОДИН НА СОЛНЕЧНОМ ЛУГУ РЯДОМ С ТОТЕМOМ
  // =========================================================================
  Widget _buildFrame2() {
    return Expanded(
      child: _buildAdvanced3DFrame(
        isRoom: false, // Включает сочный мультяшный луг, солнце и облака
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Тотем Гнева стоит на лугу рядом с Ваней
            Positioned(bottom: 35, left: 72, child: _buildGoldTotem(34)),

            // Ваня стоит один на траве (слева)
            Positioned(bottom: 35, left: 24, child: _buildCharacterBase('assets/images/bunnyhop.png', 48)),

            // Радостные слова Вани
            Positioned(
              top: 25, left: 6, right: 6,
              child: CustomPaint(
                painter: SpeechBubblePainter(tailXFactor: 0.25),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Я смог сделать это, я победил Его! Наконец-то на лугу птицам можно вдохнуть полной грудью!",
                    style: TextStyle(fontSize: 8.2, fontWeight: FontWeight.bold, color: Colors.black, height: 1.15),
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
  // КАДР 3: ПОЛНОРАЗМЕРНЫЙ ВОЛНООБРАЗНЫЙ ПОЛЁТ ВАНЯ-ПТИЦЫ ПО ГОРИЗОНТАЛИ
  // =========================================================================
  Widget _buildFrame3() {
    return Expanded(
      child: _buildAdvanced3DFrame(
        isRoom: false, // Включает сочный луг, солнце и облака
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Тотем Гнева гордо стоит на траве внизу по центру
            Positioned(bottom: 35, left: 105, child: _buildGoldTotem(36)),

            // АНИМИРОВАННЫЙ ВАНЯ: Летит по горизонтали с изгибами
            AnimatedBuilder(
              animation: _flightController,
              builder: (context, child) {
                // progress идет от 0.0 до 1.0 за 10 секунд
                double progress = _flightController.value;

                // Перевод горизонтальной координаты X слева направо (от 10 до 210 пикселей)
                double posX = 10.0 + (progress * 200.0);

                // Вычисляем синусоидальный изгиб по вертикали Y (делает 3 полные волны за полет)
                double waveAngle = progress * pi * 6; 
                double originY = 85.0; // Базовая высота полета в небе
                double posY = originY + (sin(waveAngle) * 16.0); // Амплитуда изгиба вверх-вниз

                // Вычисляем угол наклона (производная синуса — косинус), чтобы Ваня наклонялся на волнах
                double tiltAngle = cos(waveAngle) * 0.25;

                return Positioned(
                  left: posX - 19,
                  top: posY - 19,
                  child: _buildCharacterBaseWithRotation(
                    'assets/images/bunnyhop.png', 
                    38, 
                    tiltAngle, // Динамический наклон птицы при движении по волне
                  ),
                );
              },
            ),

            // Облачко со словами Вани (центрировано сверху)
            Positioned(
              top: 20, left: 6, right: 6,
              child: CustomPaint(
                painter: SpeechBubblePainter(tailXFactor: 0.5),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  child: Text(
                    "Спустя столько лет птицы снова в небе! Полечу-ка я в свой любимый кабинет!",
                    style: TextStyle(fontSize: 7.8, fontWeight: FontWeight.bold, color: Colors.black, height: 1.15),
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

  Widget _buildFrame4() {
    return Expanded(
      child: _buildAdvanced3DFrame(
        isRoom: true, // Включает деревянный кабинет
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(bottom: 12, left: 34, child: _buildWoodenChair()),
            Positioned(bottom: 22, left: 35, child: _buildCharacterBase('assets/images/bunnyhop.png', 55)),
            Positioned(bottom: 2, left: 62, child: _buildWoodenTable()),
            
            Positioned(
              top: 25, left: 10, right: 10,
              child: CustomPaint(
                painter: SpeechBubblePainter(tailXFactor: 0.45),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                  child: Text(
                    "Обычное мирное дежурство в округе... Кофе отличный.",
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black),
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

  // КАДР 5 (Часть 2, Кадр 2): ВБЕГАЕТ СТИКМАН (ОДИН В ОДИН С 1 УРОВНЕМ)
  Widget _buildFrame5() {
    return Expanded(
      child: _buildAdvanced3DFrame(
        isRoom: true,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(bottom: 12, left: 18, child: _buildWoodenChair()),
            Positioned(bottom: 22, left: 19, child: _buildCharacterBase('assets/images/bunnyhop.png', 50)),
            Positioned(bottom: 2, left: 44, child: _buildWoodenTable()),
            Positioned(bottom: 4, right: 8, child: CustomPaint(size: const Size(26, 60), painter: StickmanSweatPainter())),
            
            Positioned(
              top: 15, left: 4, right: 4,
              child: CustomPaint(
                painter: SpeechBubblePainter(tailXFactor: 0.8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  child: Text(
                    "Шериф, беда! На лугах птиц завелись зелёные свиньи под предводительством Дона Молюска! Они грабят наши склады с виагрой!",
                    style: TextStyle(fontSize: 8.2, fontWeight: FontWeight.bold, color: Colors.black, height: 1.15),
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
  // КАДР 6: ТВ-МОНИТОР НА СТОЛЕ И ДОН МОЛЛЮСК С ЧАШКОЙ ЧАЯ (ФИНАЛ ИСТИНЫ)
  // =========================================================================
  Widget _buildFrame6() {
    final mediaSize = MediaQuery.of(context).size;

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black, width: 3.5),
          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 6, offset: Offset(0, 4))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. Глубокий мрак истинного тронного зала ложного бога
              Positioned.fill(child: Container(color: const Color(0xFF040407))),
              
              // 2. Векторные рельефы готического потолка и каменного пола
              Positioned(top: 0, left: 0, right: 0, child: CustomPaint(size: const Size(double.infinity, 35), painter: _CeilingPainter(drawHole: false))),
              Positioned(bottom: 0, left: 0, right: 0, child: CustomPaint(size: const Size(double.infinity, 24), painter: _FloorTilesPainter())),

              // 3. Божественный трон Дона Моллюска (развёрнут к столу с телевизором)
              Positioned(
                bottom: 12, 
                right: mediaSize.width * 0.08, 
                child: _buildAdvanced3DThrone(),
              ),

              // 4. Дон Моллюск в домашнем халате с чашкой чая (Новое чилл-фото)
              Positioned(
                bottom: 16, 
                right: mediaSize.width * 0.04, 
                child: _buildUltraDetailedDonMolluskChill(70),
              ),

              // 5. СТОЛ И ТЕЛЕВИЗОР (Слева перед Доном, транслирует зацикленный кабинет)
              Positioned(
                bottom: 2, 
                left: mediaSize.width * 0.05,
                child: SizedBox(
                  width: 120,
                  height: 80,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    clipBehavior: Clip.none,
                    children: [
                      // Ножки и столешница стола
                      Positioned(bottom: 0, left: 10, right: 10, child: Container(height: 28, decoration: BoxDecoration(color: const Color(0xFF3E2723), border: Border.all(color: Colors.black, width: 1.5)))),
                      Positioned(bottom: 26, left: 0, right: 0, child: Container(height: 5, decoration: BoxDecoration(color: const Color(0xFF4E342E), border: Border.all(color: Colors.black, width: 1.0)))),
                      
                      // 📺 СТАРЫЙ ТЕЛЕВИЗОР (ВНУТРИ НЕГО ИДЁТ ПЕТЛЯ ВАНЬКИ)
                      Positioned(
                        bottom: 31, 
                        left: 12,
                        child: Container(
                          width: 85,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFF212121),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF000000), width: 3.0),
                            boxShadow: const [
                              BoxShadow(color: Colors.cyanAccent, blurRadius: 12, spreadRadius: 1.5) // Свечение кинескопа в лицо боссу
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // МИНИАТЮРНЫЙ КАБИНЕТ ШЕРИФА ВНУТРИ ТВ
                              Positioned(bottom: 2, left: 6, child: Transform.scale(scale: 0.55, child: _buildWoodenChair())),
                              Positioned(bottom: 8, left: 12, child: _buildCharacterBase('assets/images/bunnyhop.png', 24)),
                              Positioned(bottom: 2, left: 26, child: Transform.scale(scale: 0.55, child: _buildWoodenTable())),
                              
                              // Голубоватый полупрозрачный свет экрана телевизора
                              Positioned.fill(child: Container(color: Colors.cyan.withOpacity(0.08))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  
                  
                  Widget _buildNavigationButton() {
    // На 6 кадре (финал идеальной концовки) кнопка перенаправляет в титры
    bool isTrueEndingFinal = _currentFrame == 6;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 260),
      height: 46,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF37474F),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () async {
          if (_currentFrame < 3) {
            // Обычное перелистывание кадров первой части
            setState(() => _currentFrame++);
          } 
          else if (_currentFrame == 3) {
            // КЛЮЧЕВАЯ КНОПКА КУЛЬМИНАЦИИ ЧАСТИ 1: Проверяем SharedPreferences
            bool isEligibleForTrueEnding = await MainMenuScreen.checkTrueEndingConditions();
            
            if (isEligibleForTrueEnding) {
              // ПУСКАЕМ В ИДЕАЛЬНУЮ КОНЦОВКУ: Плавно тушим триумф и включаем тему петли Моллюска!
              await AudioManager.switchToEternalLoopWithFade();
              setState(() {
                _currentFrame = 4; // Переключаем на Кадр 4 (Кабинет Части 2)
              });
            } else {
              // ОБЫЧНЫЙ ФИНАЛ: Зачищаем музыку и вылетаем в Главное Меню Уровней
              AudioManager.stopFinalComicAudio();
              if (context.mounted) {
                Navigator.pop(context);
              }
            }
          } 
          else if (_currentFrame < 6) {
            // Перелистывание кадров Части 2
            setState(() => _currentFrame++);
          } 
          else if (isTrueEndingFinal) {
            // ИСТИННЫЙ ФИНАЛ ИДЕАЛЬНОЙ КОНЦОВКИ: Полная зачистка и выход в меню
            AudioManager.stopFinalComicAudio();
            if (context.mounted) {
              Navigator.pop(context);
            }
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isTrueEndingFinal ? "КОНЕЦ ИГРЫ" : "ДАЛЬШЕ",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Icon(
              isTrueEndingFinal ? Icons.check_circle_outline_rounded : Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // РИСОВАЛЬЩИКИ ГЕОМЕТРИИ, АССЕТОВ И ДЕКОРАЦИЙ
  // =========================================================================

   Widget _buildAdvanced3DThrone() {
    return SizedBox(
      width: 40, height: 58,
      child: Stack(
        children: [
          Positioned(bottom: 4, left: 4, right: 4, child: Container(height: 54, decoration: BoxDecoration(color: const Color(0xFF3E2723), borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)), border: Border.all(color: const Color(0xFF1A0C00), width: 1.8)))),
          Positioned(bottom: 4, left: 0, child: Container(width: 5, height: 26, decoration: BoxDecoration(color: const Color(0xFF4E342E), border: Border.all(color: Colors.black, width: 0.8)))),
          Positioned(bottom: 4, right: 0, child: Container(width: 5, height: 26, decoration: BoxDecoration(color: const Color(0xFF4E342E), border: Border.all(color: Colors.black, width: 0.8)))),
          Positioned(bottom: 6, left: 3, right: 3, child: Container(height: 14, color: const Color(0xFF4E342E))),
          Positioned(bottom: 14, left: 4, right: 4, child: Container(height: 6, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFD32F2F), Color(0xFFFF5252), Color(0xFFB71C1C)]), borderRadius: BorderRadius.circular(2)))),
        ],
      ),
    );
  }

  Widget _buildUltraDetailedDonMolluskChill(double size) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Щупальца бездействуют на полу вокруг халата ложного бога
          Positioned(bottom: size * 0.24, left: size * 0.04, child: Transform.rotate(angle: -0.3, child: CustomPaint(size: Size(size * 0.28, size * 0.58), painter: _DetailedTentaclePainter(isLeft: true)))),
          Positioned(top: size * 0.06, left: size * 0.12, child: Transform.rotate(angle: -1.3, child: CustomPaint(size: Size(size * 0.25, size * 0.53), painter: _DetailedTentaclePainter(isLeft: true)))),
          Positioned(top: size * 0.06, right: size * 0.12, child: Transform.rotate(angle: 1.3, child: CustomPaint(size: Size(size * 0.25, size * 0.53), painter: _DetailedTentaclePainter(isLeft: false)))),
          Positioned(bottom: size * 0.24, right: size * 0.04, child: Transform.rotate(angle: 0.4, child: CustomPaint(size: Size(size * 0.28, size * 0.58), painter: _DetailedTentaclePainter(isLeft: false)))),

          // Мультяшные ушки Дона Моллюска
          Positioned(top: size * 0.10, left: size * 0.08, child: Transform.rotate(angle: -0.2, child: Container(width: size * 0.18, height: size * 0.26, decoration: BoxDecoration(color: const Color(0xFF689F38), borderRadius: BorderRadius.circular(size * 0.09), border: Border.all(color: Colors.black, width: 1.8),), child: Center(child: Container(width: size * 0.08, height: size * 0.14, decoration: BoxDecoration(color: const Color(0xFF558B2F), borderRadius: BorderRadius.circular(size * 0.05))))))),
          Positioned(top: size * 0.10, right: size * 0.08, child: Transform.rotate(angle: 0.2, child: Container(width: size * 0.18, height: size * 0.26, decoration: BoxDecoration(color: const Color(0xFF689F38), borderRadius: BorderRadius.circular(size * 0.09), border: Border.all(color: Colors.black, width: 1.8),), child: Center(child: Container(width: size * 0.08, height: size * 0.14, decoration: BoxDecoration(color: const Color(0xFF558B2F), borderRadius: BorderRadius.circular(size * 0.05))))))),

          // Боковые массивные клешни
          Positioned(bottom: size * 0.16, left: -size * 0.02, child: Transform.rotate(angle: -0.1, child: CustomPaint(size: Size(size * 0.34, size * 0.34), painter: _DetailedCrabClawPainter(isOpen: false)))),
          Positioned(bottom: size * 0.16, right: -size * 0.02, child: Transform.rotate(angle: 0.1, child: CustomPaint(size: Size(size * 0.34, size * 0.34), painter: _DetailedCrabClawPainter(isOpen: false)))),
          Positioned(top: -size * 0.12, left: size * 0.33, child: CustomPaint(size: Size(size * 0.34, size * 0.34), painter: _DetailedCrabClawPainter(isOpen: true))),

          // 🟢 ЦЕНТРАЛЬНОЕ ТЕЛО БОССА С НОВЫМ ЧИЛЛ-ФОТО (Где он пьёт чай в халате)
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
                'assets/images/maksim_boss_chill.png', // Новое фото расслабленного босса
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF558B2F)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterBase(String assetPath, double size) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFE53935),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 2.0),
      ),
      child: ClipOval(child: Image.asset(assetPath, fit: BoxFit.cover)),
    );
  }

  Widget _buildCharacterBaseWithRotation(String assetPath, double size, double rotationAngle) {
    return Transform.rotate(
      angle: rotationAngle,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFE53935),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 2.0),
        ),
        child: ClipOval(child: Image.asset(assetPath, fit: BoxFit.cover)),
      ),
    );
  }
} 

// =========================================================================
// КЛАССЫ ВЕКТОРНЫХ РИСОВАЛЬЩИКОВ (PAINTERS) ДЛЯ ПЕРВОЙ ЧАСТИ КОМИКСА
// =========================================================================

Widget _buildAdvanced3DFrame({required Widget child, required bool isRoom, bool hasHole = false}) {
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
          // Динамический выбор фона: гранитный тронный зал или мультяшное лазурное небо
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isRoom
                      ? [const Color(0xFF14141E), const Color(0xFF06060A)] // Тёмные стены замка
                      : [Colors.blue.shade300, Colors.lightBlue.shade100], // Солнечное небо птиц
                ),
              ),
            ),
          ),
          
          // ЕСЛИ ЭТО КОМНАТА ТРОННОГО ЗАЛА (Кадр 1)
          if (isRoom) ...[
            if (hasHole)
              Positioned(
                top: 0, left: 30, right: 30, height: 18,
                child: Container(color: const Color(0xFF0D1B2A)), 
              ),
            Positioned(
              top: 0, left: 0, right: 0, 
              child: CustomPaint(
                size: const Size(double.infinity, 35), 
                painter: _CeilingPainter(drawHole: hasHole),
              ),
            ),
            Positioned(
              bottom: 0, left: 0, right: 0, 
              child: CustomPaint(
                size: const Size(double.infinity, 24), 
                painter: _FloorTilesPainter(),
              ),
            ),
          ] 
          // ЕСЛИ ЭТО ЛУГ ПТИЦ (Кадры 2 и 3)
          else ...[
            // Яркое круглое солнце в углу кадра
            Positioned(
              top: -15, right: -15, 
              child: Container(width: 50, height: 50, decoration: const BoxDecoration(color: Color(0xFFFFF176), shape: BoxShape.circle)),
            ),
            // Пушистые белые облака на фоне
            Positioned(top: 15, left: 10, child: Icon(Icons.cloud_rounded, size: 24, color: Colors.white.withOpacity(0.5))),
            Positioned(top: 30, right: 35, child: Icon(Icons.cloud_rounded, size: 20, color: Colors.white.withOpacity(0.5))),
            // Сочный зеленый луг в основании кадра
            Positioned(
              bottom: 0, left: 0, right: 0, 
              child: Container(height: 35, color: const Color(0xFF4CAF50)),
            ),
          ],
          
          child, // Накладываем персонажей, тотем и текст поверх фона
        ],
      ),
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

    Widget _buildDonMolluskDead(double size) {
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
                'assets/images/maksim_boss_dead.png',
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

Widget _buildWoodenChair() {
    return SizedBox(
      width: 40,
      height: 50,
      child: Stack(
        children: [
          // Задние ножки переходящие в вертикальные стойки спинки (ИСПРАВЛЕНО: Занесли цвет внутрь!)
          Positioned(
            bottom: 0, left: 4, 
            child: Container(
              width: 3, height: 48, 
              decoration: BoxDecoration(
                color: const Color(0xFFF1D299),
                border: Border.all(color: const Color(0xFFC6A065), width: 0.5),
              ),
            ),
          ),
          Positioned(
            bottom: 0, right: 16, 
            child: Container(
              width: 3, height: 48, 
              decoration: BoxDecoration(
                color: const Color(0xFFF1D299),
                border: Border.all(color: const Color(0xFFC6A065), width: 0.5),
              ),
            ),
          ),
          
          // Верхняя горизонтальная планка спинки стула с фото
          Positioned(
            top: 2, left: 4, right: 16, 
            child: Container(
              height: 12, 
              decoration: BoxDecoration(
                color: const Color(0xFFE8C384), 
                borderRadius: BorderRadius.circular(1), 
                border: Border.all(color: const Color(0xFFB58F4B), width: 0.8),
              ),
            ),
          ),
          
          // Передние ножки стула (ИСПРАВЛЕНО: Занесли цвет внутрь!)
          Positioned(
            bottom: 0, left: 14, 
            child: Container(
              width: 3.5, height: 24, 
              decoration: BoxDecoration(
                color: const Color(0xFFF1D299),
                border: Border.all(color: const Color(0xFFC6A065), width: 0.5),
              ),
            ),
          ),
          Positioned(
            bottom: 0, right: 6, 
            child: Container(
              width: 3.5, height: 24, 
              decoration: BoxDecoration(
                color: const Color(0xFFF1D299),
                border: Border.all(color: const Color(0xFFC6A065), width: 0.5),
              ),
            ),
          ),
          
          // Горизонтальное сиденье стула (ИСПРАВЛЕНО: Занесли цвет внутрь!)
          Positioned(
            bottom: 22, left: 2, right: 4, 
            child: Container(
              height: 4, 
              decoration: BoxDecoration(
                color: const Color(0xFFE8C384), 
                borderRadius: BorderRadius.circular(1), 
                border: Border.all(color: const Color(0xFFB58F4B), width: 0.8),
              ),
            ),
          ),
          
          // Поперечные деревянные перекладины жесткости снизу с фото (Тут был только цвет, оставляем без изменений)
          Positioned(
            bottom: 8, left: 4, right: 16, 
            child: Container(height: 2.5, color: const Color(0xFFD6B274)),
          ),
        ],
      ),
    );
  }


    // ИСПРАВЛЕНО: МОНОЛИТНЫЙ ВЕКТОРНЫЙ СТОЛ ШЕРИФА СО ВСЕМИ БУМАГАМИ И КРУЖКОЙ ВНУТРИ!
  Widget _buildWoodenTable() {
    return SizedBox(
      width: 85,
      height: 65, // Увеличили общую высоту контейнера, чтобы кружка Sheriff помещалась во весь рост!
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. ДЕРЕВЯННЫЕ НОЖКИ СТОЛА (Высота 40, стоят в основании bottom: 0)
          // Ножка 1 
          Positioned(bottom: 0, left: 6, child: Container(width: 5, height: 40, decoration: BoxDecoration(color: const Color(0xFFF1D299), border: Border.all(color: const Color(0xFFC6A065), width: 0.5)))),
          // Ножка 2 (В тени)
          Positioned(bottom: 0, left: 22, child: Container(width: 4, height: 40, decoration: BoxDecoration(color: const Color(0xFFE2C08A)))), 
          // Ножка 3 (Дальняя правая)
          Positioned(bottom: 0, right: 26, child: Container(width: 4, height: 40, decoration: BoxDecoration(color: const Color(0xFFE2C08A)))), 
          // Ножка 4 
          Positioned(bottom: 0, right: 6, child: Container(width: 5, height: 40, decoration: BoxDecoration(color: const Color(0xFFF1D299), border: Border.all(color: const Color(0xFFC6A065), width: 0.5)))),
          
          // 2. СТОЛЕШНИЦА И ПОДСТОЛЬЕ (Высота от пола до 44 пикселей)
          // Массивное подстолье 
          Positioned(bottom: 35, left: 4, right: 4, child: Container(height: 8, decoration: BoxDecoration(color: const Color(0xFFE8C384), border: Border.all(color: const Color(0xFFB58F4B), width: 0.5)))),
          // Толстая гладкая столешница из светлой сосны по фотографии
          Positioned(bottom: 40, left: 0, right: 0, child: Container(height: 5, decoration: BoxDecoration(color: const Color(0xFFEDCD96), borderRadius: BorderRadius.circular(1), border: Border.all(color: const Color(0xFFC6A065), width: 1.0)))),
          
          // =========================================================================
          // 3. ПРЕДМЕТЫ НА СТОЛЕ: ЛЕЖАТ СТРОГО НА ПОВЕРХНОСТИ СТОЛЕШНИЦЫ (bottom: 44)
          // =========================================================================
          // Разбросанные бумаги рапортов
          Positioned(bottom: 44, left: 6, child: Transform.rotate(angle: -0.2, child: Container(width: 16, height: 10, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(1), border: Border.all(color: Colors.black45, width: 0.5))))),
          Positioned(bottom: 45, left: 16, child: Transform.rotate(angle: 0.1, child: Container(width: 14, height: 11, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(1), border: Border.all(color: Colors.black45, width: 0.5))))),
          
          // НАША ДЕТАЛИЗИРОВАННАЯ ЖЁЛТАЯ КРУЖКА ШЕРИФА С РУЧКОЙ ПО ФОТОГРАФИИ!
          Positioned(
            bottom: 44, right: 10, // Стоит чётко на крышке стола во весь свой рост!
            child: _buildSheriffCup(),
          ),
        ],
      ),
    );
  }

  // ВЕКТОРНЫЙ РИСОВАЛЬЩИК СТИКМАНА С ТВОЕЙ КАРТИНКИ (РУКА У ГОЛОВЫ + КРУПНЫЕ КАПЛИ ПОТА!)
class StickmanSweatPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2.2;
    final sweatPaint = Paint()..color = const Color(0xFF00E5FF)..style = PaintingStyle.fill; // Неоново-голубой пот

    // 1. Голова (Овал по твоему фото)
    canvas.drawOval(Rect.fromLTWH(size.width * 0.1, 0, size.width * 0.8, size.height * 0.28), bodyPaint);
    // Глаза-кружочки стикмана
    canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.1), 2.2, bodyPaint);
    canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.1), 2.2, bodyPaint);
    // Грустный рот-дуга по фото
    final mouthPath = Path()..addArc(Rect.fromLTWH(size.width * 0.3, size.height * 0.16, size.width * 0.4, 6), pi, pi);
    canvas.drawPath(mouthPath, bodyPaint);

    // 2. Позвоночник-линия
    double neckY = size.height * 0.28;
    double pelvisY = size.height * 0.65;
    canvas.drawLine(Offset(size.width * 0.5, neckY), Offset(size.width * 0.5, pelvisY), bodyPaint);

    // 3. Правая рука согнута на боку по фото
    final rightArm = Path()
      ..moveTo(size.width * 0.5, neckY + 4)
      ..lineTo(0, size.height * 0.4)
      ..lineTo(size.width * 0.35, size.height * 0.5);
    canvas.drawPath(rightArm, bodyPaint);

    // 4. Левая рука согнута у головы, вытирает пот (Точь-в-точь по твоему фото!)
    final leftArm = Path()
      ..moveTo(size.width * 0.5, neckY + 4)
      ..lineTo(size.width * 0.9, size.height * 0.32)
      ..lineTo(size.width * 0.72, size.height * 0.15);
    canvas.drawPath(leftArm, bodyPaint);

    // 5. Ноги стикмана расставлены от усталости
    canvas.drawLine(Offset(size.width * 0.5, pelvisY), Offset(size.width * 0.2, size.height), bodyPaint); // левая
    canvas.drawLine(Offset(size.width * 0.5, pelvisY), Offset(size.width * 0.8, size.height), bodyPaint); // правая
    // Стопы-палочки
    canvas.drawLine(Offset(size.width * 0.2, size.height), Offset(size.width * 0.05, size.height), bodyPaint);
    canvas.drawLine(Offset(size.width * 0.8, size.height), Offset(size.width * 0.95, size.height), bodyPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Widget _buildSheriffCup() {
    return SizedBox(
      width: 22,
      height: 18,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Большая круглая ручка кружки (ИСПРАВЛЕНО: Прижали плотно к правой границе, right: 0)
          Positioned(
            top: 3, right: 0,
            child: Container(
              width: 7, height: 11,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEB3B), 
                borderRadius: const BorderRadius.only(topRight: Radius.circular(5), bottomRight: Radius.circular(5)),
                border: Border.all(color: Colors.black, width: 0.8),
              ),
            ),
          ),
          // Внутреннее отверстие ручки (ИСПРАВЛЕНО: Сдвинули влево, right: 1)
          Positioned(
            top: 5, right: 1,
            child: Container(
              width: 3, height: 7,
              decoration: const BoxDecoration(
                color: Color(0xFFD7CCC8), 
                borderRadius: BorderRadius.only(topRight: Radius.circular(3), bottomRight: Radius.circular(3)),
              ),
            ),
          ),

          // 2. Массивное цилиндрическое тело кружки
          Positioned(
            top: 0, left: 0,
            child: Container(
              width: 16, height: 18,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEB3B), 
                borderRadius: const BorderRadius.all(Radius.circular(3)),
                border: Border.all(color: Colors.black, width: 1.0),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Text(
                    "Sheriff", 
                    style: TextStyle(fontSize: 3.5, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: -0.1),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
