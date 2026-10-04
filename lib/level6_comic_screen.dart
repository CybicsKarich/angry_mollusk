import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'audio_manager.dart';
import 'main.dart';

class Level6GoodRouteScreen extends StatefulWidget {
  const Level6GoodRouteScreen({super.key});

  @override
  State<Level6GoodRouteScreen> createState() => _Level6GoodRouteScreenState();
}

class _Level6GoodRouteScreenState extends State<Level6GoodRouteScreen> with TickerProviderStateMixin {
  int _currentFrame = 1; // Текущий видимый кадр (1, 2 или 3)
  bool _isGameplayActive = false; // Переключатель: комикс -> живая арена боссфайта
  late AnimationController _debrisController;
  late Animation<double> _fallAnimation;
  
  // =========================================================================
  // 🎮 ПЕРЕМЕННЫЕ СОСТОЯНИЯ ТЕСТОВОГО ГЕЙМПЛЕЯ 6 УРОВНЯ
  // =========================================================================
  late final Ticker _gameLoopTicker;
  
 final double _groundYPercent = 0.73;

  // Физика Шерифа
  double _vanyaX = 0.15; 
  // ИСПРАВЛЕНО: Птица теперь сидит чётко на полу, а не парит в воздухе! (радиус 0.05)
  double _vanyaY = 0.73 - 0.05; 
  double _vanyaVx = 0.0;
  double _vanyaVy = 0.0;
  bool _vanyaIsJumping = false;
  int _vanyaHearts = 1; 
  
  bool _btnLeftPressed = false;
  bool _btnRightPressed = false;
  bool _btnJumpPressed = false;

  // ИСПРАВЛЕНО: Каменная баррикада смещена намного левее (на 0.45)
  bool _isBarricadeAlive = true; 
  final double _barricadeX = 0.45;

  // ИСПРАВЛЕНО: Дон Моллюск смещен на самый правый край зала (на 0.84)
  final double _bossX = 0.84;
  double _bossCurrentHp = 8.0; 
  final double _bossMaxHp = 8.0;

  @override
  void initState() {
    super.initState();
    _debrisController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), 
    );
    
    _fallAnimation = CurvedAnimation(
      parent: _debrisController,
      curve: Curves.bounceOut,
    );

    // Главный движковый тикер игрового процесса (60 кадров в секунду)
    _gameLoopTicker = createTicker((elapsed) {
      if (_isGameplayActive && mounted) {
        _updatePhysics(0.016); // Фиксированный шаг dt (~16 мс)
      }
    });
    _gameLoopTicker.start();
  }

  // ЗАМЕНИТЬ СТРОГО ТОЧЕЧНО ТЕЛО МЕТОДА _updatePhysics:
  void _updatePhysics(double dt) {
    setState(() {
      // ИСПРАВЛЕНО: Линия реального пола опущена до 0.86, чтобы Ваня стоял чётко на плитке!
      const double realGroundY = 0.86;

      // 1. Горизонтальный бег Шерифа ногами по плитке пола
      if (_btnLeftPressed) {
        _vanyaVx = -0.26; 
      } else if (_btnRightPressed) {
        _vanyaVx = 0.26; 
      } else {
        _vanyaVx = 0.0; 
      }

      _vanyaX += _vanyaVx * dt;

      // 2. Вертикальная гравитация и ЕЩЁ МЕНЬШИЙ ПРЫЖОК (Идеальная средняя высота)
      if (_vanyaIsJumping) {
        _vanyaVy += 1.9 * dt; // Плотная гравитация
        _vanyaY += _vanyaVy * dt;

        // Фиксация приземления на реальный пол (с учётом радиуса Вани 0.05)
        if (_vanyaY >= realGroundY - 0.05) {
          _vanyaY = realGroundY - 0.05;
          _vanyaVy = 0.0;
          _vanyaIsJumping = false;
        }
      } else {
        // УБРАН НИЖНИЙ БАРЬЕР: Ваня больше ни обо что не спотыкается и бегает СТРОГО по полу!
        _vanyaY = realGroundY - 0.05;
      }

      // Зажимаем Шерифа в жесткие рамки экрана по горизонтали
      if (_vanyaX < 0.02) _vanyaX = 0.02;
      if (_vanyaX > 0.94) _vanyaX = 0.94;

      // 3. ИСПРАВЛЕНО ГЕHИАЛЬHО: Коллизией обладает ТОЛЬКО САМА баррикада! 
      // Никаких невидимых стен до неба. Через неё можно перепрыгнуть или пройти НАД ней!
      if (_isBarricadeAlive) {
        double баррикадаW = 0.025; // Соответствует её UI-ширине
        double баррикадаH = 0.16;  // Соответствует её UI-высоте
        double bLeft = _barricadeX;
        double bRight = _barricadeX + 0.035;
        double bTop = realGroundY - баррикадаH; // Верхняя грань куба на полу

        // Проверяем пересечение с физическим телом блока
        if (_vanyaX >= bLeft - 0.02 && _vanyaX <= bRight && _vanyaY >= bTop - 0.04) {
          
          // А) Если Ваня ПАДАЕТ СВЕРХУ — он честно приземляется НА баррикаду и может стоять НАД ней!
          if (_vanyaVy > 0 && _vanyaY < bTop + 0.02) {
            _vanyaY = bTop - 0.05; // Встаем ножками на крышу блока
            _vanyaVy = 0.0;
            _vanyaIsJumping = false;
          } 
          // Б) Если он бежит сбоку по полу — он просто упирается в неё, как в препятствие
          else if (_vanyaY > bTop - 0.02) {
            _vanyaX = _vanyaVx > 0 ? bLeft - 0.021 : bRight + 0.001;
          }
        }
      }

      // 4. СТОЛКНОВЕНИЕ С ГИГАНТСКИМ ДОНОМ НА САМОМ ПРАВОМ КРАЮ
      double dx = _vanyaX - _bossX;
      double dy = _vanyaY - (realGroundY - 0.12);
      double distance = sqrt(dx * dx + dy * dy);

      if (distance < 0.11 && _bossCurrentHp > 0) {
        // Чёткий слэм прыжком по макушке головы Дона
        if (_vanyaVy > 0 && _vanyaY < realGroundY - 0.03) {
          _bossCurrentHp -= 1.0; 
          AudioManager.playPigHit(); 
          
          // Мягкий и динамичный отскок назад влево
          _vanyaVx = -0.32;
          _vanyaVy = -0.42; 
          _vanyaIsJumping = true;
          _vanyaX -= 0.06; 
        } else {
          // Удар в бок — минус жизнь и аккуратный респавн на пол у левого края
          if (_vanyaHearts > 0) {
            _vanyaHearts--;
            AudioManager.playMiss();
            _vanyaX = 0.15;
            _vanyaY = realGroundY - 0.05;
          }
        }
      }
    });
  }



  @override
  void dispose() {
    _gameLoopTicker.dispose();
    _debrisController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // ЕCЛИ НАЖАТA КHОПКА ПОГНАЛИ — ВКЛЮЧАЕМ ЖИВУЮ БОЕВУЮ АРЕНУ
    if (_isGameplayActive) {
      return _buildLiveGameplayArena();
    }

    // ИНАЧЕ — ИГРОК ПРОСМАТРИВАЕТ ТРИ КАДРА ПРЕДЫСТОРИИ
    return Scaffold(
      backgroundColor: const Color(0xFF040407), 
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 4), 
            const Text(
              "ГЛАВА VI: ЛОГОВО ДОНА МОЛЛЮСКА",
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.w900,
                color: Color(0xFF455A64),
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 6),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    if (_currentFrame >= 1) _buildGoodFrame1(),
                    if (_currentFrame >= 2) const SizedBox(width: 12),
                    if (_currentFrame >= 2) _buildGoodFrame2(),
                    if (_currentFrame >= 3) const SizedBox(width: 12),
                    if (_currentFrame >= 3) _buildGoodFrame3(),
                  ],
                ),
              ),
            ),

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
  // ХОРОШАЯ ЛИНИЯ - КАДР 1: Спокойствие шерифа против ухмылки босса
  // =========================================================================
  Widget _buildGoodFrame1() {
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
  Widget _buildGoodFrame2() {
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

  Widget _buildGoodFrame3() {
    return Expanded(
      child: _buildAdvanced3DFrame(
        hasHole: true, // ВКЛЮЧАЕТ ТЕМНО-СИНЕЕ НЕБО И ДЫРУ В КРЫШЕ
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(bottom: 22, left: 12, child: _buildCharacter('assets/images/bunnyhop.png', 48)),
            Positioned(bottom: 12, right: 8, child: _buildDonMollusk(64)),

            // =================================================================
            // НОВЫЙ БЛОК: АНИМИРОВАННЫЕ ОБЛОМКИ С ФИЗИКОЙ ОТСКОКА
            // =================================================================
            AnimatedBuilder(
              animation: _fallAnimation,
              builder: (context, child) {
                // fallValue идет от 0.0 (наверху) до 1.0 (на полу) с эффектом отскока
                final fallValue = _fallAnimation.value;
                
                return Stack(
                  children: [
                    // 1. Главная каменная глыба-баррикада
                    Positioned(
                      // Падает с высоты 150 вниз и останавливается на координате 20 (на полу)
                      bottom: 150 - (fallValue * 130), 
                      left: 62,
                      child: Container(
                        width: 25, height: 45,
                        decoration: BoxDecoration(
                          color: const Color(0xFF37474F),
                          border: Border.all(color: Colors.black, width: 1.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    
                    // 2. Мелкий осколок 1 (летит с вращением и отлетает влево)
                    Positioned(
                      bottom: 140 - (fallValue * 120), 
                      left: 68 - (fallValue * 12), // Смещается влево при падении
                      child: Transform.rotate(
                        angle: fallValue * pi * 4, // Реалистично крутится (нужен import 'dart:math'; - он у тебя есть)
                        child: _buildFallingDebris(6, 10),
                      ),
                    ),

                    // 3. Мелкий осколок 2 (летит с другой скоростью и отлетает вправо)
                    Positioned(
                      bottom: 160 - (fallValue * 140), 
                      left: 74 + (fallValue * 18), // Смещается вправо
                      child: Transform.rotate(
                        angle: -fallValue * pi * 3, // Крутится в обратную сторону
                        child: _buildFallingDebris(8, 8),
                      ),
                    ),
                  ],
                );
              },
            ),

            // Облачко слов Вани (остается без изменений)
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

    // =========================================================================
  // ⚡ ЖИВАЯ ИНТЕРАКТИВНАЯ АРЕНА ХОРОШЕГО ПУТИ (КНОПКИ, СЕРДЦА, БОСС, ФИЗИКА)
  // =========================================================================
  Widget _buildLiveGameplayArena() {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF020204),
      body: Stack(
        children: [
          // 🏛️ А) ФОН ТРОННОГО ЗАЛА В ОБРАТНОЙ ПЕРСПЕКТИВЕ (БЕЗ ТРОНА И ТОТЕМA)
          Positioned.fill(
            child: CustomPaint(
              painter: _EndingRoomBackgroundPainter(hasHole: true, showLightning: false),
              child: Stack(
                children: [
                  Positioned(top: 0, left: 0, right: 0, child: CustomPaint(size: const Size(double.infinity, 35), painter: _CeilingPainter(drawHole: true))),
                  Positioned(bottom: 0, left: 0, right: 0, child: CustomPaint(size: const Size(double.infinity, 24), painter: _FloorTilesPainter())),

                  if (_isBarricadeAlive)
                    Positioned(
                      bottom: 24, 
                      left: size.width * _barricadeX,
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _isBarricadeAlive = false);
                          AudioManager.playBlockBreak(true);
                        },
                        child: Container(
                          width: size.width * 0.025, // Уменьшили длину
                          height: size.height * 0.16, // Сделали аккуратнее по высоте
                          decoration: BoxDecoration(
                            color: const Color(0xFF37474F),
                            border: Border.all(color: Colors.black, width: 1.8),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),

                  if (_bossCurrentHp > 0)
                    Positioned(
                      bottom: 22, 
                      left: size.width * _bossX,
                      child: Transform.scale(
                        scale: 2.8, 
                        child: _buildDonMollusk(52),
                      ),
                    ),

                  // 🔴 КРУГЛЫЙ ШЕРИФ С НАШЕЙ УПРАВЛЯЕМОЙ ФИЗИКОЙ
                  Positioned(
                    left: _vanyaX * size.width,
                    top: _vanyaY * size.height,
                    child: _buildCharacter('assets/images/bunnyhop.png', 46),
                  ),
                ],
              ),
            ),
          ),

          // 📜 Б) ВЕРХНЯЯ ПАНЕЛЬ: КНОПКА ПАУЗЫ, СЕРДЦА ЖИЗНЕЙ И КЛЁШНЫЙ HP-БАР БОССА
          Positioned(
            top: 14, left: 16, right: 16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Пауза и Сердечки жизней под ней в левом верхнем углу
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ТОЧЕЧНО ЗАМЕНИТЬ ИКОНКУ ПАУЗЫ ВНУТРИ _buildLiveGameplayArena:
                    IconButton(
                      style: IconButton.styleFrom(backgroundColor: Colors.black45, padding: const EdgeInsets.all(6)),
                      icon: const Icon(Icons.pause_rounded, color: Colors.white, size: 22),
                      onPressed: () {
                        // ИСПРАВЛЕНО: Вместо вылета открываем оригинальное PauseMenu из game_screen.dart!
                        // Создаём временный контекст-заглушку, чтобы вызвать твоё оригинальное меню оверлеев
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            // Вызываем точно такое же по дизайну меню паузы, как в game_screen.dart!
                            return Center(
                              child: Container(
                                width: 280,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.orange, width: 4),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'ПАУЗА',
                                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2, decoration: TextDecoration.none),
                                    ),
                                    const SizedBox(height: 20),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 44,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                        onPressed: () => Navigator.pop(context), // ПРОДОЛЖИТЬ
                                        child: const Text('ПРОДОЛЖИТЬ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 44,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                        onPressed: () {
                                          // ЗАНОВО: сбрасываем арену
                                          Navigator.pop(context);
                                          setState(() {
                                            _vanyaX = 0.15;
                                            _vanyaY = _groundYPercent - 0.05;
                                            _bossCurrentHp = 8.0;
                                            _isBarricadeAlive = true;
                                            _vanyaHearts = 1;
                                          });
                                        },
                                        child: const Text('ЗАНОВО', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 44,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                        onPressed: () {
                                          Navigator.pop(context); // закрываем паузу
                                          AudioManager.stopLevelAudioAndPlayMenu();
                                          Navigator.pop(context); // выходим в меню уровней
                                        },
                                        child: const Text('В МЕНЮ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 6),
                    // Ряд маленьких сердечек под паузой по твоему ТЗ
                    Row(
                      children: List.generate(
                        _vanyaHearts > 0 ? _vanyaHearts : 1,
                        (index) => Padding(
                          padding: const EdgeInsets.only(right: 3.0),
                          child: Icon(
                            Icons.favorite_rounded,
                            color: _vanyaHearts > 0 ? const Color(0xFFE53935) : Colors.grey,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const Spacer(),

                // Кислотно-зелёный ХП-бар Дона Моллюска (8 ХП) в векторных клешнях
                if (_bossCurrentHp > 0)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Левая векторная клешня зажима шкалы
                      CustomPaint(size: const Size(20, 20), painter: _DetailedCrabClawPainter(isOpen: true)),
                      const SizedBox(width: 4),
                      // Сама кислотно-зелёная полоска здоровья босса
                      Container(
                        width: 140, height: 14,
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFF1B5E20), width: 1.5),
                        ),
                        child: Stack(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: 140 * (_bossCurrentHp / _bossMaxHp),
                              color: const Color(0xFF00E676), // Кислотно-зеленый неон
                            ),
                            Center(
                              child: Text(
                                "${_bossCurrentHp.toInt()} / 8 HP",
                                style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Правая векторная клешня зажима шкалы
                      CustomPaint(size: const Size(20, 20), painter: _DetailedCrabClawPainter(isOpen: false)),
                    ],
                  ),
              ],
            ),
          ),

          // 🕹️ В) ИНТЕРФЕЙС УПРАВЛЕНИЯ ПО НАШЕМУ УГОВОРУ
          // Левая рука: Две полупрозрачные серые стрелки движения в нижнем левом углу
          Positioned(
            bottom: 16, left: 20,
            child: Row(
              children: [
                // Стрелка НАЗАД (Левее)
                GestureDetector(
                  onTapDown: (_) => setState(() => _btnLeftPressed = true),
                  onTapUp: (_) => setState(() => _btnLeftPressed = false),
                  onTapCancel: () => setState(() => _btnLeftPressed = false),
                  child: Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                      color: _btnLeftPressed ? const Color(0xAAFF1744) : Colors.white12,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white60, width: 1.5),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
                  ),
                ),
                const SizedBox(width: 16),
                // Стрелка ВПЕРЁД (Правее)
                GestureDetector(
                  onTapDown: (_) => setState(() => _btnRightPressed = true),
                  onTapUp: (_) => setState(() => _btnRightPressed = false),
                  onTapCancel: () => setState(() => _btnRightPressed = false),
                  child: Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                      color: _btnRightPressed ? const Color(0xAAFF1744) : Colors.white12,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white60, width: 1.5),
                    ),
                    child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
          ),

           Positioned(
            bottom: 16, right: 24,
            child: GestureDetector(
              // ЗАМЕНИТЬ СТРОГО ТОЧЕЧНО ВНУТРИ КНОПКИ ПРЫЖКА (ПРАВАЯ РУКА):
              onTapDown: (_) {
                if (!_vanyaIsJumping) {
                  setState(() {
                    _btnJumpPressed = true;
                    _vanyaIsJumping = true;
                    
                    // ИСПРАВЛЕНО: Импульс прыжка уменьшен до средних -4.1! Высота идеальна
                    if (_btnRightPressed) {
                      _vanyaVy = -4.1; 
                      _vanyaVx = 0.26; // Прыжок плавно подхватывает зажатую стрелку ВПЕРЁД
                    } else if (_btnLeftPressed) {
                      _vanyaVy = -4.1;
                      _vanyaVx = -0.26; // Прыжок плавно подхватывает зажатую стрелку НАЗАД
                    } else {
                      _vanyaVy = -3.9; // Небольшой прыжок строго вверх на месте
                    }
                  });
                }
              },
              onTapUp: (_) => setState(() => _btnJumpPressed = false),
              onTapCancel: () => setState(() => _btnJumpPressed = false),
              child: Container(
                width: 58, height: 58,
                decoration: BoxDecoration(
                  color: _btnJumpPressed ? const Color(0xAAFF1744) : Colors.white12,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white60, width: 1.8),
                ),
                child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 26),
              ),
            ),
          ),

          // Экран триумфа, если тестовый босс полностью повержен
          if (_bossCurrentHp <= 0)
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.9), 
            borderRadius: BorderRadius.circular(16), 
            border: Border.all(color: Colors.orange, width: 2),
          ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("ТЫ УБИЛ БОССА!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.amber)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                      onPressed: () {
                        AudioManager.stopLevelAudioAndPlayMenu();
                        Navigator.pop(context);
                      },
                      child: const Text("В МЕНЮ УРОВНЕЙ", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // =========================================================================
  // РАЗБЛОКИРОВАННАЯ КНОПКА НАВИГАЦИИ С КОРОТКОЙ НАДПИСЬЮ «КОНЕЦ»
  // =========================================================================
  Widget _buildNavigationButton() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 240),
      height: 38, 
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          backgroundColor: const Color(0xFF37474F), 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () {
          if (_currentFrame < 3) {
            setState(() => _currentFrame++);
            
            if (_currentFrame == 3) {
              AudioManager.playCastleCollapse();
              _debrisController.forward(from: 0.0);
            }
          } else {
            // Кнопка полностью РАЗБЛОКИРОВАНА и запускает живой тест геймплея арены!
            AudioManager.startCastleDrops(); 
            setState(() {
              _isGameplayActive = true;
            });
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _currentFrame == 3 ? "КОНЕЦ" : "ДАЛЬШЕ", 
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ), 
            const SizedBox(width: 6), 
            Icon(_currentFrame == 3 ? Icons.play_circle_filled_rounded : Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white),
          ],
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
            if (hasHole)
              Positioned(
                top: 0, left: 45, right: 45, height: 18,
                child: Container(color: const Color(0xFF0D1B2A)), 
              ),
            Positioned(top: 0, left: 0, right: 0, child: CustomPaint(size: const Size(double.infinity, 35), painter: _CeilingPainter(drawHole: hasHole))),
            Positioned(bottom: 0, left: 0, right: 0, child: CustomPaint(size: const Size(double.infinity, 24), painter: _FloorTilesPainter())),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildFallingDebris(double w, double h) {
    return Container(
      width: w, height: h,
      decoration: BoxDecoration(color: const Color(0xFF455A64), border: Border.all(color: Colors.black, width: 1)),
    );
  }

  Widget _buildThrone() {
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

  Widget _buildGoldTotem(double size) {
    return SizedBox(
      width: size, height: size * 1.1,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(bottom: 0, child: Container(width: size * 0.75, height: size * 0.16, decoration: BoxDecoration(color: const Color(0xFF111116), borderRadius: BorderRadius.circular(2), border: Border.all(color: Colors.black, width: 1.5)))),
          Positioned(bottom: size * 0.14, child: Container(width: size * 0.14, height: size * 0.32, decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFE5A632), Color(0xFFFFD54F), Color(0xFFB57C1E)])))),
          Positioned(bottom: size * 0.38, child: SizedBox(width: size * 1.05, height: size * 0.65, child: CustomPaint(painter: _WingsPainter()))),
        ],
      ),
    );
  }

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

  // ЗАМЕНИТЬ СТРОГО ТОЧЕЧНО В КОНЦЕ КЛАССА СОСТОЯНИЯ (МЕТОД _buildCharacter):
  Widget _buildCharacter(String assetPath, double size) {
    return Container(
      width: size, 
      height: size, 
      decoration: BoxDecoration(
        color: assetPath.contains('bunnyhop') ? const Color(0xFFE53935) : const Color(0xFF7CB342), 
        shape: BoxShape.circle, 
        border: Border.all(color: Colors.black, width: 2.0),
      ), 
      child: ClipOval(
        child: Image.asset(assetPath, fit: BoxFit.cover),
      ),
    );
  }
} // <--- ЗАКРЫТИЕ КЛАССА СОСТОЯНИЯ ЭКРАНА СТРАНИЦЫ _Level6GoodRouteScreenState

// ЗАМЕНИТЬ СТРОГО ТОЧЕЧНО В САМОМ КОНЦЕ ФАЙЛА (КЛАСС _CeilingPainter):
class _CeilingPainter extends CustomPainter {
  final bool drawHole;
  _CeilingPainter({required this.drawHole});

  @override
  void paint(Canvas canvas, Size size) {
    final ceilPaint = Paint()..color = const Color(0xFF15151D)..style = PaintingStyle.fill;
    final beamPaint = Paint()..color = const Color(0xFF09090D)..style = PaintingStyle.stroke..strokeWidth = 2.2;
    
    if (!drawHole) {
      // Сплошной потолок
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), ceilPaint);
      for (int i = 0; i <= 6; i++) {
        canvas.drawLine(Offset(size.width * 0.5, 0), Offset(size.width * (i / 6), size.height), beamPaint);
      }
    } else {
      // Крыша обвалилась
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
  bool shouldRepaint(covariant _CeilingPainter oldDelegate) => true;
}



class _FloorTilesPainter extends CustomPainter {
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
    path.cubicTo(isLeft ? -w * 0.7 : w * 1.7, h * 0.7, isLeft ? w * 0.1 : w * 0.9, h * 0.2, w * 0.5, 0);
    path.lineTo(w * 0.7, 0);
    path.cubicTo(isLeft ? w * 0.3 : w * 0.7, h * 0.2, isLeft ? -w * 0.4 : w * 1.4, h * 0.7, w * 0.8, h);
    path.close();

    canvas.drawPath(path, tentaclePaint);
    canvas.drawPath(path, strokePaint);

    for (int i = 1; i <= 6; i++) {
      double factor = i * 0.14;
      double cx = isLeft ? w * (0.32 - factor * 0.15) : w * (0.68 + factor * 0.15);
      double cy = h * factor;
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

class _DetailedCrabClawPainter extends CustomPainter {
  final bool isOpen;
  _DetailedCrabClawPainter({required this.isOpen});

  @override
  void paint(Canvas canvas, Size size) {
    final clawPaint = Paint()..color = const Color(0xFF2E6F22)..style = PaintingStyle.fill;
    final strokePaint = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 1.6;
    final w = size.width;
    final h = size.height;

    final jointPath = Path()
      ..moveTo(w * 0.4, h)..lineTo(w * 0.3, h * 0.6)
      ..lineTo(w * 0.7, h * 0.6)..lineTo(w * 0.6, h)..close();
    canvas.drawPath(jointPath, clawPaint);
    canvas.drawPath(jointPath, strokePaint);

    final mainClawPath = Path()
      ..moveTo(w * 0.3, h * 0.6)
      ..cubicTo(w * 0.05, h * 0.4, w * 0.1, 0, w * 0.5, 0)
      ..lineTo(w * 0.45, h * 0.2)
      ..cubicTo(w * 0.3, h * 0.3, w * 0.35, h * 0.5, w * 0.7, h * 0.6)..close();
    canvas.drawPath(mainClawPath, clawPaint);
    canvas.drawPath(mainClawPath, strokePaint);

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

    final toothPaint = Paint()..color = Colors.white70..style = PaintingStyle.fill;
    canvas.drawTriangle(Offset(w * 0.38, h * 0.25), Offset(w * 0.34, h * 0.28), Offset(w * 0.42, h * 0.29), toothPaint);
    canvas.drawTriangle(Offset(w * 0.46, h * 0.32), Offset(w * 0.42, h * 0.35), Offset(w * 0.48, h * 0.36), toothPaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EndingRoomBackgroundPainter extends CustomPainter {
  final bool hasHole;
  final bool showLightning;
  _EndingRoomBackgroundPainter({required this.hasHole, required this.showLightning});

  @override
  void paint(Canvas canvas, Size size) {
    final wallPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF14141E), Color(0xFF06060A)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), wallPaint);

    if (hasHole) {
      final skyRect = Rect.fromLTWH(size.width * 0.25, 0, size.width * 0.5, 25);
      canvas.drawRect(skyRect, Paint()..color = const Color(0xFF0D1B2A));
      if (showLightning) {
        canvas.drawRect(skyRect, Paint()..color = Colors.white.withOpacity(0.85));
      }
    }
  }
  @override
  bool shouldRepaint(covariant _EndingRoomBackgroundPainter oldDelegate) => true;
}

// ТОЧЕЧНО ВСТАВИТЬ В САМЫЙ КОНЕЦ ФАЙЛА ПОСЛЕ ВСЕХ КЛАССОВ И РИСОВАЛЬЩИКОВ:

extension _Level6CanvasTriangleExt on Canvas {
  void drawTriangle(Offset p1, Offset p2, Offset p3, Paint paint) {
    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..close();
    drawPath(path, paint);
    
    // Контрастный чёрный контур на каждый зубчик для бритвенной чёткости
    drawPath(path, Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 0.5);
  }
}

  

