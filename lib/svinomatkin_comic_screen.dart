import 'dart:math';
import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'audio_manager.dart';
import 'main.dart';

// =========================================================================
// НАЧАЛЬНЫЙ КОМИКС 5 УРОВНЯ: ГЕНЕРАЛ СВИНOМАТКИН И ГРОЗОВАЯ ЦИТАДЕЛЬ
// =========================================================================
class SvinomatkinComicScreen extends StatefulWidget {
  const SvinomatkinComicScreen({super.key});

  @override
  State<SvinomatkinComicScreen> createState() => _SvinomatkinComicScreenState();
}

class _SvinomatkinComicScreenState extends State<SvinomatkinComicScreen> with SingleTickerProviderStateMixin {
  int _currentPage = 0; // 0 - Страница 1, 1 - Страница 2
  late AnimationController _rainController;
  final List<Offset> _rainDrops = [];
  final Random _rand = Random();

  @override
  void initState() {
    super.initState();
    // Контроллер для непрерывной анимации живого дождя
    _rainController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
    _rainController.addListener(() {
      if (mounted) setState(() {});
    });

    // Генерируем начальные капли дождя
    for (int i = 0; i < 40; i++) {
      _rainDrops.add(Offset(_rand.nextDouble() * 260, _rand.nextDouble() * 120 + 20));
    }
  }

  @override
  void dispose() {
    _rainController.dispose();
    super.dispose();
  }

  void _updateRain() {
    // Двигаем капли сверху вниз по диагонали (косой ливень)
    for (int i = 0; i < _rainDrops.length; i++) {
      double x = _rainDrops[i].dx + 1.2;
      double y = _rainDrops[i].dy + 4.5;
      // Если капля упала ниже травы (высота фрейма около 150), возвращаем её к тучам (top: 20-35)
      if (y > 140 || x > 260) {
        x = _rand.nextDouble() * 260;
        y = _rand.nextDouble() * 15 + 20; // Спавн строго под тучами
      }
      _rainDrops[i] = Offset(x, y);
    }
  }

  @override
  Widget build(BuildContext context) {
    _updateRain();
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A10), // Тёмная мистическая подложка экрана
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text(
              _currentPage == 0 ? "ГЛАВА V: ПОДСТУПЫ К ЦИТАДЕЛИ" : "ГЛАВА V: ПОСЛЕДНИЙ РУБЕЖ",
              style: const TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.w900, 
                color: Color(0xFF7E57C2), // Фиолетовый оттенок под грозовое небо
                letterSpacing: 2.0,
                shadows: [Shadow(color: Colors.black, blurRadius: 4, offset: Offset(2, 2))],
              ),
            ),
            const SizedBox(height: 16),

            // СЕТКА КАДРОВ (3 кадра в ряд)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _currentPage == 0 
                  ? Row(children: [_buildFrame1(), const SizedBox(width: 12), _buildFrame2(), const SizedBox(width: 12), _buildFrame3()])
                  : Row(children: [_buildPage2Frame1(), const SizedBox(width: 12), _buildPage2Frame2(), const SizedBox(width: 12), _buildPage2Frame3()]),
              ),
            ),

            // НИЖНЯЯ ПАНЕЛЬ С КНОПКАМИ И СТРЕЛОЧКОЙ
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _currentPage == 0
                ? ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5E35B1), // Тёмно-фиолетовая кнопка
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      elevation: 6,
                    ),
                    onPressed: () => setState(() => _currentPage = 1), // Вперёд на Стр 2
                    icon: const Text("ВПЕРЁД", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    label: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 24),
                  )
                : // ПОЛНОСТЬЮ ЗАМЕНИТЬ КНОПКУ "В БОЙ!" ВНИЗУ SvinomatkinComicScreen НА ЭТУ:
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFFB71C1C), // Боевой кроваво-красный цвет
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
    elevation: 8,
  ),
  onPressed: () {
    Navigator.pop(context); // Закрываем экран комикса

    // ОФИЦИАЛЬНЫЙ СТАРТ ПЯТОГО УРОВНЯ ОДИН В ОДИН ПО ТВОЕМУ МЕТОДУ:
    GameScreen gameScreenInstance = GameScreen();
    gameScreenInstance.gameInstance.currentLevel = 5; // Запускаем 5 уровень!
    gameScreenInstance.gameInstance.worldScrollX = 0.0;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => gameScreenInstance),
    );
  },
  child: const Text("В БОЙ!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.2)),
),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // КАДРЫ СТРАНИЦЫ 1
  // =========================================================================
  Widget _buildFrame1() {
    return Expanded(
      child: _buildStormFrame(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Величественный монолитный замок Дона Моллюска на самом дальнем плане
            Positioned(bottom: 25, right: 12, child: _buildCastleBlock()),
            // Ваня Баннихоп стоит ОДИН (без шляпы и без сумки по ТЗ!)
            Positioned(bottom: 12, left: 16, child: _buildCharacterBase('assets/images/bunnyhop.png', 60)),
            Positioned(
              top: 25, left: 8, right: 8,
              child: CustomPaint(
                painter: ComicBubblePainter(tailX: 0.25),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Вот я и дошёл до замка Дона Молюска!", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black), textAlign: TextAlign.center),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrame2() {
    return Expanded(
      child: _buildStormFrame(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(bottom: 25, right: 12, child: _buildCastleBlock()),
            Positioned(bottom: 12, left: 6, child: _buildCharacterBase('assets/images/bunnyhop.png', 50)),
            // Появление Генерала Свиноматкина (В шлеме и с серой бородой!)
            // ТОЧЕЧНО ЗАМЕНИТЬ СТРОКУ В _buildFrame2:
            Positioned(bottom: 12, right: 110, child: _buildSvinomatkinCharacter(48)),
            Positioned(
              top: 10, left: 4, width: 105,
              child: CustomPaint(
                painter: ComicBubblePainter(tailX: 0.2),
                child: const Padding(padding: EdgeInsets.all(5.0), child: Text("Все твои братья разбиты! Ты остался один! Уйди с дороги, я иду к твоему боссу!", style: TextStyle(fontSize: 7.8, fontWeight: FontWeight.bold, color: Colors.black), textAlign: TextAlign.center)),
              ),
            ),
            // ЗАМЕНИТЬ ТОЛЬКО ОБЛАКО ГЕНЕРАЛА ВНУТРИ _buildFrame2:
Positioned(
  top: 56, right: 48, width: 100, // Опустили пониже и сдвинули левее к центру
  child: CustomPaint(
    painter: ComicBubblePainter(tailX: 0.25), // Хвостик чётко бьёт в Генерала
    child: const Padding(
      padding: EdgeInsets.all(6.0),
      child: Text(
        "Хрю-ха-ха! Шериф-младший, ты слишком далеко зашёл, но здесь твой путь закончится! Дон Молюск доверил мне охранять подступы к его замку, и я не сделаю ни шагу назад!", 
        style: TextStyle(fontSize: 6.8, fontWeight: FontWeight.bold, color: Colors.black, height: 1.15), 
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

  Widget _buildFrame3() {
    return Expanded(
      child: _buildStormFrame(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(bottom: 25, right: 12, child: _buildCastleBlock()),
            Positioned(bottom: 12, left: 6, child: _buildCharacterBase('assets/images/bunnyhop.png', 50)),
            Positioned(bottom: 12, right: 110, child: _buildSvinomatkinCharacter(48)),
            Positioned(
              top: 10, left: 4, right: 4,
              child: CustomPaint(
                painter: ComicBubblePainter(tailX: 0.2),
                child: const Padding(
                  padding: EdgeInsets.all(6.0),
                  child: Text("Стоп, шериф-младший? Погоди-ка, кого-то ты мне напоминаешь... Ах, это ты Генерал Свиноматкин! Это ты, сорок лет назад обманул моего деда - великого шерифа-старшего! Ты ослепил его дымовой завесой и выкрал Древний Тотем Гнева, как же я мог забыть про это, ну ничего я сегодня заберу тотем у свиней и освобожу луг птиц!", style: TextStyle(fontSize: 6.2, fontWeight: FontWeight.bold, color: Colors.black, height: 1.1), textAlign: TextAlign.center),
                ),
              ),
            ),
            // ЗАМЕНИТЬ ТОЛЬКО ЭТОТ БЛОК ВНУТРИ _buildFrame3 НА КОРРЕКТНЫЙ:
Positioned(
  bottom: 54, left: 10, right: 10,
  child: CustomPaint(
    painter: ComicBubblePainter(tailX: 0.45), // ИСПРАВЛЕНО: Убран лишний параметр!
    child: const Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Text(
        "О да, я помню твоего деда! Он был силён, но слишком доверчив! Без Тотема Гнева ваш род навсегда потерял способность парить в небесах. Вы упали на землю и стали бессильными! А наш босс забрал тотем себе!", 
        style: TextStyle(fontSize: 6.2, fontWeight: FontWeight.bold, color: Colors.red, height: 1.1), 
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
  // КАДРЫ СТРАНИЦЫ 2
  // =========================================================================
  Widget _buildPage2Frame1() {
    return Expanded(
      child: _buildStormFrame(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(bottom: 25, right: 12, child: _buildCastleBlock()),
            Positioned(bottom: 12, left: 6, child: _buildCharacterBase('assets/images/bunnyhop.png', 50)),
            Positioned(bottom: 12, right: 110, child: _buildSvinomatkinCharacter(48)),
            Positioned(
              top: 15, left: 6, width: 110,
              child: CustomPaint(
                painter: ComicBubblePainter(tailX: 0.25),
                child: const Padding(padding: EdgeInsets.all(5.0), child: Text("Сегодня тотем вернётся обратно к птицам, и все свиньи в страхе сбегут с луга птиц!", style: TextStyle(fontSize: 7.8, fontWeight: FontWeight.bold, color: Colors.black), textAlign: TextAlign.center)),
              ),
            ),
            // ЗАМЕНИТЬ ТОЛЬКО ОБЛАКО ГЕНЕРАЛА ВНУТРИ _buildPage2Frame1:
Positioned(
  top: 48, right: 48, width: 100, // Опустили и сдвинули левее вглубь кадра
  child: CustomPaint(
    painter: ComicBubblePainter(tailX: 0.3), 
    child: const Padding(
      padding: EdgeInsets.all(6.0), 
      child: Text(
        "Вот это у тебя фантазии, постоянно повторяешь про луг и тотем! Что осталась детская травма? Хрю-ха-ха!", 
        style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.bold, color: Colors.black), 
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

  Widget _buildPage2Frame2() {
    return Expanded(
      child: _buildComicFrame(
        isRoom: false,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Мрачный фон с замком
            Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF2A1B4E), Color(0xFF120A2A)])))),
            // Прорисовка туч на небе
            Positioned(top: -5, left: -10, right: -10, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Icon(Icons.cloud_rounded, size: 45, color: Colors.grey.shade700), Icon(Icons.cloud_rounded, size: 55, color: Colors.grey.shade800), Icon(Icons.cloud_rounded, size: 40, color: Colors.grey.shade700)])),
            // Отрисовка живых летящих капель дождя из туч
            ..._rainDrops.map((pos) => Positioned(left: pos.dx, top: pos.dy, child: Container(width: 1.0, height: 8, color: Colors.blue.shade100.withOpacity(0.4)))),
            Positioned(bottom: 0, left: 0, right: 0, child: Container(height: 20, color: const Color(0xFF2E7D32))), // Земля

            Positioned(bottom: 18, right: 10, child: _buildCastleBlock()),
            Positioned(bottom: 8, left: 4, child: _buildCharacterBase('assets/images/bunnyhop.png', 46)),
            Positioned(bottom: 8, right: 95, child: _buildSvinomatkinCharacter(44)),


            Positioned(
              top: 15, left: 4, width: 115,
              child: CustomPaint(
                painter: ComicBubblePainter(tailX: 0.2),
                child: const Padding(padding: EdgeInsets.all(4.0), child: Text("Свиноматкин, ты уже прожил своё, я сейчас разнесу твою крепость в щепки, и про травмы ты будешь говорить служа птицам!", style: TextStyle(fontSize: 7.0, fontWeight: FontWeight.bold, color: Colors.red), textAlign: TextAlign.center)),
              ),
            ),
            // ЗАМЕНИТЬ ТОЛЬКО ОБЛАКО ГЕНЕРАЛА ВНУТРИ _buildPage2Frame2:
Positioned(
  top: 48, right: 26, width: 105, // Опустили и приблизили к свинье
  child: CustomPaint(
    painter: ComicBubblePainter(tailX: 0.2), 
    child: const Padding(
      padding: EdgeInsets.all(6.0), 
      child: Text(
        "Я построил крепость из двойного камня, ты ни за что её не сломаешь!", 
        style: TextStyle(fontSize: 7.6, fontWeight: FontWeight.bold, color: Colors.black), 
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

  Widget _buildPage2Frame3() {
    return Expanded(
      child: _buildComicFrame(
        isRoom: false,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF2A1B4E), Color(0xFF120A2A)])))),
            Positioned(top: -5, left: -10, right: -10, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Icon(Icons.cloud_rounded, size: 45, color: Colors.grey.shade700), Icon(Icons.cloud_rounded, size: 55, color: Colors.grey.shade800), Icon(Icons.cloud_rounded, size: 40, color: Colors.grey.shade700)])),
            ..._rainDrops.map((pos) => Positioned(left: pos.dx, top: pos.dy, child: Container(width: 1.0, height: 8, color: Colors.blue.shade100.withOpacity(0.4)))),
            Positioned(bottom: 0, left: 0, right: 0, child: Container(height: 20, color: const Color(0xFF2E7D32))),

            // Рогатка стоит справа в полный рост, а Замка рядом НЕТ по ТЗ!
            Positioned(bottom: 20, left: 120, child: Container(width: 8, height: 28, decoration: BoxDecoration(color: const Color(0xFF4E342E), borderRadius: BorderRadius.circular(2)))),
            Positioned(bottom: 44, left: 113, child: Transform.rotate(angle: -0.4, child: Container(width: 6, height: 16, decoration: BoxDecoration(color: const Color(0xFF4E342E), borderRadius: BorderRadius.circular(1.5))))),
            Positioned(bottom: 44, left: 129, child: Transform.rotate(angle: 0.4, child: Container(width: 6, height: 16, decoration: BoxDecoration(color: const Color(0xFF4E342E), borderRadius: BorderRadius.circular(1.5))))),

            // ЗАМЕНИТЬ СТРОГО ЭТИ ДВЕ СТРОКИ РЕЗИНКИ ВНУТРИ _buildPage2Frame3:
// Нитка 1: Закреплена на самом верху левого рожка (bottom: 58)
Positioned(bottom: 58, left: 30, child: Transform.rotate(angle: 0.32, child: Container(width: 86, height: 3.5, color: const Color(0xFFD32F2F)))),
// Нитка 2: Закреплена на самом верху правого рожка (bottom: 58)
Positioned(bottom: 58, left: 45, child: Transform.rotate(angle: 0.26, child: Container(width: 84, height: 3.5, color: const Color(0xFFD32F2F)))),


            // Ваня Баннихоп сидит ОДИН в оттянутой рогатке (Слева, left: 12)
            Positioned(
              bottom: 24, left: 12,
              child: _buildCharacterBase('assets/images/bunnyhop.png', 62),
            ),

            Positioned(
              top: 20, left: 10, right: 10,
              child: CustomPaint(
                painter: ComicBubblePainter(tailX: 0.25),
                child: const Padding(padding: EdgeInsets.all(8.0), child: Text("Настало время последнего боя!", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black), textAlign: TextAlign.center)),
              ),
            ),
          ],
        ),
      ),
    );
  }

    // ПОЛНОСТЬЮ ЗАМЕНИТЬ МЕТОД _buildCastleBlock НА ЭТОТ ВАРИАНТ (ЕЩЁ НИЖЕ В ТРАВУ):
  Widget _buildCastleBlock() {
    return SizedBox(
      width: 95, 
      height: 120, 
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. ЦЕНТРАЛЬНАЯ МАССИВНАЯ ЦИТАДЕЛЬ (Опущена ниже — bottom: -16)
          Positioned(
            bottom: -16, left: 15, right: 15,
            child: Container(
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFF263238),
                border: Border.all(color: const Color(0xFF101418), width: 2),
              ),
              child: Stack(
                children: [
                 Positioned(
                    top: 20, left: 22, 
                    child: Container(
                      width: 16, height: 35, 
                      decoration: BoxDecoration(
                        color: const Color(0xFF111116), 
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)), 
                        border: Border.all(color: const Color(0xFF37474F), width: 1.5),
                      ),
                      child: Stack(
                        children: [
                          if (() {
                            // ТОЧЕЧНО ЗАМЕНИТЬ БЛОК ТАЙМЕРА ЩУПАЛЬЦА ВНУТРИ _buildCastleBlock НА ЭТОТ (4 СЕКУНДЫ):
final now = DateTime.now().millisecondsSinceEpoch;
final periodProgress = now % 4000; // Цикл изменён на 4 секунды по ТЗ
final isTimeToShow = periodProgress < 1200; 
final current4SecId = now ~/ 4000;
final hasChance = Random(current4SecId).nextBool(); // Шанс 50%
 
                            
                            return isTimeToShow && hasChance;
                          }())
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _WindowTentacleShadowPainter(), 
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

          // 2. ВЕРХУШКА ЦЕНТРАЛЬНОЙ БАШНИ: ЗУБЦЫ (bottom: 74)
          Positioned(
            bottom: 74, left: 11, right: 11,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (index) => Container(width: 14, height: 10, decoration: BoxDecoration(color: const Color(0xFF37474F), border: Border.all(color: const Color(0xFF101418), width: 1.5), borderRadius: const BorderRadius.only(topLeft: Radius.circular(2), topRight: Radius.circular(2))))),
            ),
          ),

          // 3. БАШНИ СЛЕВА И СПРАВА (Опущены ниже — bottom: -16)
          Positioned(
            bottom: -16, left: 0,
            child: Container(
              width: 22, height: 95,
              decoration: BoxDecoration(
                color: const Color(0xFF37474F),
                border: Border.all(color: const Color(0xFF101418), width: 2),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 4, offset: const Offset(-2, 0))],
              ),
              child: Stack(
                children: [
                  Positioned(top: 15, left: 6, child: Container(width: 6, height: 14, decoration: BoxDecoration(color: const Color(0xFF111116), borderRadius: BorderRadius.circular(1)))),
                  Positioned(top: 45, left: 6, child: Container(width: 6, height: 14, decoration: BoxDecoration(color: const Color(0xFF111116), borderRadius: BorderRadius.circular(1)))),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -16, right: 0,
            child: Container(
              width: 22, height: 95,
              decoration: BoxDecoration(
                color: const Color(0xFF37474F),
                border: Border.all(color: const Color(0xFF101418), width: 2),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 4, offset: const Offset(2, 0))],
              ),
              child: Stack(
                children: [
                  Positioned(top: 15, right: 6, child: Container(width: 6, height: 14, decoration: BoxDecoration(color: const Color(0xFF111116), borderRadius: BorderRadius.circular(1)))),
                  Positioned(top: 45, right: 6, child: Container(width: 6, height: 14, decoration: BoxDecoration(color: const Color(0xFF111116), borderRadius: BorderRadius.circular(1)))),
                ],
              ),
            ),
          ),

          // 4. ОСТРОКОНЕЧНЫЕ КРЫШИ-ШПИЛИ (bottom: 77)
          Positioned(
            bottom: 77, left: -2,
            child: CustomPaint(
              size: const Size(26, 30),
              painter: _CastleSpirePainter(color: const Color(0xFF1A237E)),
            ),
          ),
          Positioned(
            bottom: 77, right: -2,
            child: CustomPaint(
              size: const Size(26, 30),
              painter: _CastleSpirePainter(color: const Color(0xFF1A237E)),
            ),
          ),

          // ФЛАГШТОК (bottom: 105)
          Positioned(
            bottom: 105, left: 10,
            child: Container(width: 2, height: 12, color: const Color(0xFF455A64)),
          ),
          Positioned(
            bottom: 111, left: 12,
            child: Container(width: 10, height: 6, decoration: const BoxDecoration(color: Color(0xFFB71C1C), borderRadius: BorderRadius.only(topRight: Radius.circular(2), bottomRight: Radius.circular(2)))),
          ),
        ],
      ),
    );
  }


    // ПОЛНОСТЬЮ ЗАМЕНИТЬ МЕТОД _buildSvinomatkinCharacter НА ЭТОТ КОРРЕКТНЫЙ:
  Widget _buildSvinomatkinCharacter(double size) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Базовая круглая модель свиньи Максима
        Container(width: size, height: size, decoration: BoxDecoration(color: const Color(0xFF7CB342), shape: BoxShape.circle, border: Border.all(color: Colors.black, width: 2))),
        ClipOval(child: Image.asset('assets/images/maksim.png', width: size * 0.85, height: size * 0.85, fit: BoxFit.cover)),
        
        // Накатываем сверху шлем с вмятиной и сдвинутую бороду через наш метод
        _buildSvinomatkinEquipment(size),
      ],
    );
  }

  


    Widget _buildCharacterBase(String assetPath, double size) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: size, height: size, 
          decoration: BoxDecoration(
            color: const Color(0xFFE53935), 
            shape: BoxShape.circle, 
            border: Border.all(color: Colors.black, width: 2),
          ),
        ),
        ClipOval(
          child: Image.asset(assetPath, width: size * 0.85, height: size * 0.85, fit: BoxFit.cover),
        ),
      ],
    );
  }

  double ch(double size, double base) => (size / 50) * base;

  Widget _buildStormFrame({required Widget child}) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black, width: 3.5),
          boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 6, offset: Offset(0, 4))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF2A1B4E), Color(0xFF120A2A)])))),
              Positioned(top: -5, left: -10, right: -10, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Icon(Icons.cloud_rounded, size: 45, color: Colors.grey.shade700), Icon(Icons.cloud_rounded, size: 55, color: Colors.grey.shade800), Icon(Icons.cloud_rounded, size: 40, color: Colors.grey.shade700)])),
              ..._rainDrops.map((pos) => Positioned(left: pos.dx, top: pos.dy, child: Container(width: 1.0, height: 8, color: Colors.blue.shade100.withOpacity(0.35)))),
              Positioned(bottom: 0, left: 0, right: 0, child: Container(height: 20, color: const Color(0xFF2E7D32))),
              child,
            ],
          ),
        ),
      ),
    );
  }
    // ЗАМЕНИТЬ СТРОГО НА ЭТОТ ВАРИАНТ (БЕЗ ПОЛОСОК):
  Widget _buildSvinomatkinEquipment(double size) {
    return Positioned.fill(
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // 1. Каноничная круглая каска-полукруг свиней
          Positioned(
            top: -ch(size, 4.5),
            child: Container(
              width: size * 0.96,
              height: size * 0.44,
              decoration: BoxDecoration(
                color: const Color(0xFF78909C), 
                border: Border.all(color: const Color(0xFF263238), width: 1.8),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
            ),
          ),

          // 2. МАССИВНАЯ БОРОДА СДВИHУТА КОРРЕКТНО ЛЕВЕЕ
          Positioned(
            bottom: -ch(size, 16),
            left: -size * 0.42, 
            child: Image.asset(
              'assets/images/beard.png',
              width: size * 1.65,
              height: size * 0.78,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
} // <--- ВОТ ЭТА СКОБКА ТЕПЕРЬ СТРОГО ЗАКРЫВАЕТ КЛАСС _SvinomatkinComicScreenState!


// ДОБАВИТЬ В САМЫЙ КОНЕЦ ФАЙЛА lib/main.dart:
class _CastleSpirePainter extends CustomPainter {
  final Color color;
  _CastleSpirePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final border = Paint()..color = const Color(0xFF101418)..style = PaintingStyle.stroke..strokeWidth = 2.0;

    final path = Path();
    // Рисуем высокий готический треугольник крыши башни
    path.moveTo(size.width / 2, 0); // Пик шпиля
    path.lineTo(size.width, size.height); // Правое основание
    path.lineTo(0, size.height); // Левое основание
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, border);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ПОЛНОСТЬЮ ЗАМЕНИТЬ КЛАСС _WindowTentacleShadowPainter НА ЭТОТ РЕАЛИСТИЧНЫЙ ВАРИАНТ ПО ФОТО:
class _WindowTentacleShadowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Очень блёклый, полупрозрачный чёрный цвет тени (20% видимости)
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.20)
      ..style = PaintingStyle.fill; // Будем заливать всё тело для массивности

    final outlinePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // 1. ОТРИСОВКА МАССИВНОГО СТВОЛА ЩУПАЛЬЦА С КРУТЫМ ЗАВИТКОМ НА КОНЦЕ
    final bodyPath = Path();
    bodyPath.moveTo(w * 0.10, h); // Левый край основания
    
    // Плавный S-образный изгиб левой стороны тела
    bodyPath.cubicTo(w * 0.40, h * 0.70, w * 0.05, h * 0.40, w * 0.50, h * 0.15);
    // Закручивание кончика в спираль-улитку на самой макушке
    bodyPath.cubicTo(w * 0.75, h * 0.05, w * 0.85, h * 0.18, w * 0.65, h * 0.22);
    bodyPath.cubicTo(w * 0.55, h * 0.24, w * 0.50, h * 0.14, w * 0.60, h * 0.10);
    bodyPath.cubicTo(w * 0.70, h * 0.08, w * 0.68, h * 0.16, w * 0.62, h * 0.16); // Центр улитки
    
    // Идём обратно, формируя толщину правой стороны
    bodyPath.cubicTo(w * 0.35, h * 0.32, w * 0.65, h * 0.65, w * 0.55, h); // Правый край основания
    bodyPath.close();

    canvas.drawPath(bodyPath, shadowPaint);
    canvas.drawPath(bodyPath, outlinePaint);

    // 2. ОТРИСОВКА ВЫСТУПАЮЩИХ ПРИСОСОК ПО ВСЕМУ КОНТУРУ (КАК НА КАРТИНКЕ)
    // Метод рисует круглую присоску, слегка вылезающую за правый край тела
    void drawSuction(double cx, double cy, double radius) {
      canvas.drawCircle(Offset(cx, cy), radius, shadowPaint);
      canvas.drawCircle(Offset(cx, cy), radius, outlinePaint);
      // Внутреннее отверстие присоски (для узнаваемости текстуры с фото)
      canvas.drawCircle(
        Offset(cx, cy), 
        radius * 0.4, 
        Paint()..color = const Color(0xFF111116)..style = PaintingStyle.fill,
      );
    }

    // Расставляем присоски по ходу роста щупальца снизу вверх
    drawSuction(w * 0.55, h * 0.90, 2.5); // Крупная внизу
    drawSuction(w * 0.58, h * 0.76, 2.4);
    drawSuction(w * 0.54, h * 0.64, 2.2);
    drawSuction(w * 0.44, h * 0.52, 2.0);
    drawSuction(w * 0.36, h * 0.42, 1.8);
    drawSuction(w * 0.44, h * 0.32, 1.6);
    drawSuction(w * 0.55, h * 0.24, 1.4);
    
    // Мелкие присоски на самом завитковом кончике
    drawSuction(w * 0.68, h * 0.19, 1.1);
    drawSuction(w * 0.72, h * 0.12, 0.9);
    drawSuction(w * 0.65, h * 0.07, 0.7);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Обёртка кадра с ЖЕСТКИМ фоном солнца, облаков и травы (Задний фон уровня)
  Widget _buildComicFrame({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade300, Colors.lightBlue.shade100], 
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF000000), width: 3.5), 
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 6, offset: Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Рисуем яркое неподвижное солнце на фоне кадра
            Positioned(
              top: -15, right: -15,
              child: Container(width: 50, height: 50, decoration: const BoxDecoration(color: Color(0xFFFFF176), shape: BoxShape.circle)),
            ),
            // Рисуем пушистые белые облака на небе
            Positioned(top: 15, left: 10, child: Icon(Icons.cloud_rounded, size: 28, color: Colors.white.withOpacity(0.5))),
            Positioned(top: 30, right: 35, child: Icon(Icons.cloud_rounded, size: 22, color: Colors.white.withOpacity(0.5))),
            // Рисуем сочную зеленую траву луга в основании кадра
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                height: 35, 
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                ),
              ),
            ),
            child, 
          ],
        ),
      ),
    );
  }
