import 'dart:math';
import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'main.dart';


class SheriffComicScreen extends StatefulWidget {
  const SheriffComicScreen({super.key});

  @override
  State<SheriffComicScreen> createState() => _SheriffComicScreenState();
}

class _SheriffComicScreenState extends State<SheriffComicScreen> {
  int _currentComicPage = 0; // 0 - кабинет, 1 - луг

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F14),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text(
              _currentComicPage == 0 ? "ИСТОРИЯ ШЕРИФА БАННИХОПА" : "ИСТОРИЯ ШЕРИФА: НА ЛУГУ",
              style: const TextStyle(
                fontSize: 22, 
                fontWeight: FontWeight.w900, 
                color: Color(0xFFFF9800), 
                letterSpacing: 1.5,
                shadows: [Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(2, 2))],
              ),
            ),
            const SizedBox(height: 16),

            // ГЛАВНАЯ СЕТКА КАДРОВ
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _currentComicPage == 0 
                  ? Row(children: [_buildPage1Frame1(), const SizedBox(width: 12), _buildPage1Frame2(), const SizedBox(width: 12), _buildPage1Frame3()])
                  : Row(children: [_buildPage2Frame1(), const SizedBox(width: 12), _buildPage2Frame2(), const SizedBox(width: 12), _buildPage2Frame3()]),
              ),
            ),

            // НАВИГАЦИЯ
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _currentComicPage == 0
                ? ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9800),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      elevation: 5,
                    ),
                    onPressed: () => setState(() => _currentComicPage = 1),
                    icon: const Text("ВПЕРЁД", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    label: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 24),
                  )
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9800),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                      elevation: 5,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      GameScreen gameScreenInstance = GameScreen();
                      gameScreenInstance.gameInstance.currentLevel = 1;
                      gameScreenInstance.gameInstance.worldScrollX = 0.0;
                      Navigator.push(context, MaterialPageRoute(builder: (context) => gameScreenInstance));
                    },
                    child: const Text("ПОГНАЛИ!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // КАДРЫ СТРАНИЦЫ 1 (В ДЕРЕВЯННОМ КАБИНЕТЕ)
  // =========================================================================
  Widget _buildPage1Frame1() {
    return Expanded(
      child: _buildComicFrame(
        isRoom: true,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(bottom: 12, left: 34, child: _buildWoodenChair()),
            // ЗАМЕНИТЬ ТОЛЬКО ЭТУ СТРОКУ В _buildPage1Frame1:
            Positioned(bottom: 22, left: 35, child: _buildCharacterSp('assets/images/bunnyhop.png', 55, isPig: false)),
           Positioned(bottom: 2, left: 62, child: _buildWoodenTable()),
            Positioned(
              top: 25, left: 10, right: 10,
              child: CustomPaint(
                painter: ComicBubblePainter(tailX: 0.45),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                  child: Text("Обычное мирное дежурство в округе... Кофе отличный.", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black), textAlign: TextAlign.center),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage1Frame2() {
    return Expanded(
      child: _buildComicFrame(
        isRoom: true,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(bottom: 12, left: 18, child: _buildWoodenChair()),
            // ЗАМЕНИТЬ ТОЛЬКО ЭТУ СТРОКУ В _buildPage1Frame2:
            Positioned(bottom: 22, left: 19, child: _buildCharacterSp('assets/images/bunnyhop.png', 50, isPig: false)),
            Positioned(bottom: 2, left: 44, child: _buildWoodenTable()),
            Positioned(bottom: 4, right: 8, child: CustomPaint(size: const Size(26, 60), painter: StickmanSweatPainter())),
            Positioned(
              top: 15, left: 4, right: 4,
              child: CustomPaint(
                painter: ComicBubblePainter(tailX: 0.8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  child: Text("Шериф, беда! На лугах птиц завелись зелёные свиньи под предводительством Дона Молюска! Они грабят наши склады с виагрой!", style: TextStyle(fontSize: 8.2, fontWeight: FontWeight.bold, color: Colors.black, height: 1.15), textAlign: TextAlign.center),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

    Widget _buildPage1Frame3() {
    return Expanded(
      child: _buildComicFrame(
        isRoom: true,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ТОЧЕЧНО ЗАМЕНИТЬ КООРДИНАТУ В _buildPage1Frame3:
Positioned(
  bottom: 2, // Опустили пониже, ближе к нижнему краю пола
  left: 115, 
  child: CustomPaint(
    size: const Size(22, 10), 
    painter: _SecretMouthShadowPainter(),
  ),
),
            Positioned(
              bottom: 10, left: 8,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    // ЗАМЕНИТЬ ТОЛЬКО ЭТУ СТРОКУ В _buildPage1Frame3:
                  child: _buildCharacterSp('assets/images/bunnyhop.png', 75, isPig: false),
                  ),
                  // КОВБОЙСКАЯ ШЛЯПА ВШИТА В КОД КАДРА СЕРДЦЕМ СТЕКА
                  Positioned(
                    top: 0,
                    child: SizedBox(
                      width: 55, height: 25,
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Container(width: 32, height: 14, decoration: const BoxDecoration(color: Color(0xFF795548), borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)))),
                          Positioned(bottom: 3, child: Container(width: 52, height: 5, decoration: BoxDecoration(color: const Color(0xFF6D4C41), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFF4E342E), width: 0.8)))),
                          Positioned(bottom: 7, child: Container(width: 31, height: 2, decoration: BoxDecoration(color: const Color(0xFF212121), borderRadius: BorderRadius.circular(1)))),
                          Positioned(top: 2, child: Stack(alignment: Alignment.center, children: [Icon(Icons.star_rounded, color: Colors.blueGrey.shade100, size: 14), Container(width: 4, height: 4, decoration: const BoxDecoration(color: Color(0xFFFFFFFF), shape: BoxShape.circle))])),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // КОЖАНАЯ СУМКА ВШИТА В КОД КАДРА СЕРДЦЕМ СТЕКА
            Positioned(
              bottom: -2, left: 62,
              child: SizedBox(
                width: 50, height: 50,
                child: Stack(
                  children: [
                   Positioned(bottom: 0, left: 4, right: 4, child: Container(width: 42, height: 40, decoration: BoxDecoration(color: const Color(0xFF8D4F37), borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16), bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)), border: Border.all(color: const Color(0xFF4A2711), width: 2.0)))),
                    Positioned(bottom: 2, left: 6, child: Container(width: 3, height: 26, color: const Color(0xFF6E331B))),
                    Positioned(bottom: 2, right: 6, child: Container(width: 3, height: 26, color: const Color(0xFF6E331B))),
                    Positioned(top: 10, left: 8, right: 8, child: Container(height: 6, decoration: const BoxDecoration(color: Color(0xFF6E331B), borderRadius: BorderRadius.all(Radius.circular(4))))),
                    Positioned(top: 14, left: 24, child: Container(width: 2, height: 20, decoration: BoxDecoration(color: const Color(0xFF4A2711), borderRadius: BorderRadius.circular(1)))),
                    Positioned(top: 33, left: 23, child: Container(width: 4, height: 4, decoration: const BoxDecoration(color: Color(0xFF3E1E0A), shape: BoxShape.circle))),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 25, left: 10, right: 10,
              child: CustomPaint(
                painter: ComicBubblePainter(tailX: 0.35),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Пора расхлебать это дерьмо и проучить этих свиней!", style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.black), textAlign: TextAlign.center),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // КАДРЫ СТРАНИЦЫ 2 (НА ЗЕЛЁНОМ ЛУГУ)
  // =========================================================================
  Widget _buildPage2Frame1() {
    return Expanded(
      child: _buildComicFrame(
        isRoom: false,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              bottom: 10, left: 25,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  // ЗАМЕНИТЬ ТОЛЬКО ЭТУ СТРОКУ В _buildPage2Frame1:
                  Padding(padding: const EdgeInsets.only(top: 10), child: _buildCharacterSp('assets/images/bunnyhop.png', 65, isPig: false)),
                  // ШЛЯПА ВШИТА В КОД КАДРА СЕРДЦЕМ СТЕКА
                  Positioned(
                    top: 0,
                    child: SizedBox(
                      width: 55, height: 25,
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Container(width: 32, height: 14, decoration: const BoxDecoration(color: Color(0xFF795548), borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)))),
                          Positioned(bottom: 3, child: Container(width: 52, height: 5, decoration: BoxDecoration(color: const Color(0xFF6D4C41), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFF4E342E), width: 0.8)))),
                          Positioned(bottom: 7, child: Container(width: 31, height: 2, decoration: BoxDecoration(color: const Color(0xFF212121), borderRadius: BorderRadius.circular(1)))),
                          Positioned(top: 2, child: Stack(alignment: Alignment.center, children: [Icon(Icons.star_rounded, color: Colors.blueGrey.shade100, size: 14), Container(width: 4, height: 4, decoration: const BoxDecoration(color: Color(0xFFFFFFFF), shape: BoxShape.circle))])),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(bottom: 8, right: 35, child: _buildBlisterWidget()),
            Positioned(
              top: 25, left: 8, right: 8,
              child: CustomPaint(
                painter: ComicBubblePainter(tailX: 0.35),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  child: Text("Так... Следы ведут сюда. Ошмётки упаковок повсюду. Свиньи где-то рядом...", style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Colors.black, height: 1.15), textAlign: TextAlign.center),
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
            // 1. Еле заметная маленькая тень скрученного щупальца на синем небе рядом с солнцем
            Positioned(
              top: 10,
              right: 45, // Рядом с солнцем
              child: CustomPaint(
                size: const Size(25, 35),
                painter: _TentacleSkyShadowPainter(),
              ),
            ),

            // 2. Деревянная рогатка на заднем фоне луга
            Positioned(bottom: 20, left: 95, child: Container(width: 8, height: 26, decoration: BoxDecoration(color: const Color(0xFF4E342E), borderRadius: BorderRadius.circular(2)))),
            Positioned(bottom: 42, left: 88, child: Transform.rotate(angle: -0.4, child: Container(width: 6, height: 16, decoration: BoxDecoration(color: const Color(0xFF4E342E), borderRadius: BorderRadius.circular(1.5))))),
            Positioned(bottom: 42, left: 104, child: Transform.rotate(angle: 0.4, child: Container(width: 6, height: 16, decoration: BoxDecoration(color: const Color(0xFF4E342E), borderRadius: BorderRadius.circular(1.5))))),
            Positioned(bottom: 54, left: 86, child: Container(width: 26, height: 4, decoration: BoxDecoration(color: const Color(0xFFD32F2F), borderRadius: BorderRadius.circular(1)))),

            // 3. Ваня в ШЛЯПЕ подходит слева
            Positioned(
              bottom: 10, left: 6,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: _buildCharacterSp('assets/images/bunnyhop.png', 52, isPig: false),
                  ),
                 Positioned(
                    top: 0,
                    child: SizedBox(
                      width: 55, height: 25,
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Container(width: 32, height: 14, decoration: const BoxDecoration(color: Color(0xFF795548), borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)))),
                          Positioned(bottom: 3, child: Container(width: 52, height: 5, decoration: BoxDecoration(color: const Color(0xFF6D4C41), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFF4E342E), width: 0.8)))),
                          Positioned(bottom: 7, child: Container(width: 31, height: 2, decoration: BoxDecoration(color: const Color(0xFF212121), borderRadius: BorderRadius.circular(1)))),
                          Positioned(top: 2, child: Stack(alignment: Alignment.center, children: [Icon(Icons.star_rounded, color: Colors.blueGrey.shade100, size: 14), Container(width: 4, height: 4, decoration: const BoxDecoration(color: Color(0xFFFFFFFF), shape: BoxShape.circle))])),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 4. Две свиньи Максима сидят у рогатки справа
            Positioned(bottom: 10, right: 38, child: _buildCharacterSp('assets/images/maksim.png', 44, isPig: true)),
            Positioned(bottom: 10, right: 8, child: _buildCharacterSp('assets/images/maksim.png', 44, isPig: true)),

            // Блистеры виагры на кадре
            Positioned(bottom: 6, left: 40, child: Transform.rotate(angle: 0.2, child: _buildBlisterWidget())),
            Positioned(bottom: 4, right: 46, child: Transform.rotate(angle: -0.1, child: _buildBlisterWidget())), 

            // 5. Два облака диалогов
           Positioned(
              top: 15, left: 6, width: 95,
              child: CustomPaint(
                painter: ComicBubblePainter(tailX: 0.25),
                child: const Padding(padding: EdgeInsets.all(5.0), child: Text("Я нашёл вас!", style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Colors.black), textAlign: TextAlign.center)),
              ),
            ),
            Positioned(
              top: 35, right: 6, width: 135,
              child: CustomPaint(
                painter: ComicBubblePainter(tailX: 0.8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 6),
                  child: Text("О, Шериф припёрся! Ну что, таблеточки-то тю-тю! Наш босс станет бессмертным, и ты нас ни за что не достанешь - мы построили неприступную крепость!", style: TextStyle(fontSize: 7.2, fontWeight: FontWeight.bold, color: Colors.black, height: 1.1), textAlign: TextAlign.center),
                ),
              ),
            ),
            Positioned(
              bottom: 60, left: 10, right: 10,
              child: CustomPaint(
                painter: ComicBubblePainter(tailX: 0.2),
                child: const Padding(padding: EdgeInsets.all(5.0), child: Text("Вы совершили главную ошибку в жизни, зайдя на луг птиц и начав воровать мои таблетки!", style: TextStyle(fontSize: 7.6, fontWeight: FontWeight.bold, color: Colors.red), textAlign: TextAlign.center)),
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
            // ПОЛНОСТЬЮ ЗАМЕНИТЬ СОДЕРЖИМОЕ Stack ВНУТРИ _buildPage2Frame3 НА ЭТОТ КОРРЕКТНЫЙ ВАРИАНТ:
// 1. КОРИЧНЕВАЯ РОГАТКА СДВИГНУТА ВПРАВО И ВИДНА ПОЛНОСТЬЮ (left: 120)
// Рукоять рогатки (вертикальный ствол стоит на траве)
Positioned(bottom: 20, left: 120, child: Container(width: 8, height: 28, decoration: BoxDecoration(color: const Color(0xFF4E342E), borderRadius: BorderRadius.circular(2)))),
// Левый рожок (прижат к стволу)
Positioned(bottom: 44, left: 113, child: Transform.rotate(angle: -0.4, child: Container(width: 6, height: 16, decoration: BoxDecoration(color: const Color(0xFF4E342E), borderRadius: BorderRadius.circular(1.5))))),
// Правый рожок (прижат к стволу)
Positioned(bottom: 44, left: 129, child: Transform.rotate(angle: 0.4, child: Container(width: 6, height: 16, decoration: BoxDecoration(color: const Color(0xFF4E342E), borderRadius: BorderRadius.circular(1.5))))),

// ЗАМЕНИТЬ СТРОГО ЭТИ ДВЕ СТРОКИ РЕЗИНКИ ВНУТРИ _buildPage2Frame3:
// Нитка 1: привязана к самому верху левого рожка (bottom: 58, left: 35) и натянута к Ване
Positioned(bottom: 58, left: 35, child: Transform.rotate(angle: 0.32, child: Container(width: 82, height: 4, color: const Color(0xFFD32F2F)))),
// Нитка 2: привязана к самому верху правого рожка (bottom: 58, left: 45) и натянута к Ване
Positioned(bottom: 58, left: 45, child: Transform.rotate(angle: 0.28, child: Container(width: 84, height: 4, color: const Color(0xFFD32F2F)))),

// 3. ВАНЯ БАННИХОП И ШЛЯПА СМЕЩЕНЫ ДИКО ВЛЕВО И СИДЯТ НА КРАСНОЙ НИТКЕ (left: 12)
Positioned(
  bottom: 24, // Сидит прямо в седле натянутой резинки, чуть приподнятый над травой
  left: 12,   // Смещён в самый левый край кадра!
  child: Stack(
    alignment: Alignment.topCenter,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 10),
        child: _buildCharacterSp('assets/images/bunnyhop.png', 62, isPig: false),
      ),
      // Ковбойская шляпа шерифа вшита в код кадра
      Positioned(
        top: 0,
        child: SizedBox(
          width: 55, height: 25,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(width: 32, height: 14, decoration: const BoxDecoration(color: Color(0xFF795548), borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)))),
              Positioned(bottom: 3, child: Container(width: 52, height: 5, decoration: BoxDecoration(color: const Color(0xFF6D4C41), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFF4E342E), width: 0.8)))),
             Positioned(bottom: 7, child: Container(width: 31, height: 2, decoration: BoxDecoration(color: const Color(0xFF212121), borderRadius: BorderRadius.circular(1)))),
              Positioned(top: 2, child: Stack(alignment: Alignment.center, children: [Icon(Icons.star_rounded, color: Colors.blueGrey.shade100, size: 14), Container(width: 4, height: 4, decoration: const BoxDecoration(color: Color(0xFFFFFFFF), shape: BoxShape.circle))])),
            ],
          ),
        ),
      ),
    ],
  ),
),

// 4. ОБЛАЧКО СЛОВ (Центрировано по кадру, висит красиво над всей этой сценой)
Positioned(
  top: 20, 
  left: 10, 
  right: 10,
  child: CustomPaint(
    painter: ComicBubblePainter(tailX: 0.25), // Хвостик указывает левее, прямо на оттянутого Ваню!
    child: const Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        "Посмотрим, какую крепость вы построили!", 
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black), 
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

    Widget _buildBlisterWidget() {
    return Container(
      width: 22, height: 22,
      decoration: BoxDecoration(
        color: const Color(0xFFCFD8DC), 
        borderRadius: BorderRadius.circular(4), 
        border: Border.all(color: const Color(0xFF78909C), width: 0.8),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(top: 2, left: 2, child: Container(width: 5, height: 7, decoration: BoxDecoration(color: const Color(0xFF29B6F6), borderRadius: BorderRadius.circular(2)))),
          Positioned(top: 2, right: 2, child: Container(width: 5, height: 7, decoration: BoxDecoration(color: const Color(0xFF29B6F6), borderRadius: BorderRadius.circular(2)))),
          Positioned(bottom: 2, left: 2, child: Container(width: 5, height: 7, decoration: BoxDecoration(color: const Color(0xFF29B6F6), borderRadius: BorderRadius.circular(2)))),
          Positioned(bottom: 2, right: 2, child: Container(width: 5, height: 7, decoration: BoxDecoration(color: const Color(0xFF29B6F6), borderRadius: BorderRadius.circular(2)))),
        ],
      ),
    );
  }
} // <--- ВОТ ЭТА СКОБКА ТЕПЕРЬ СТРОГО ЗАКРЫВАЕТ КЛАСС _SheriffComicScreenState!

    // Векторный сборщик стула со спинкой из светлой сосны по твоей фотографии
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






  Widget _buildCharacterSp(String assetPath, double size, {required bool isPig}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: size, height: size,
          decoration: BoxDecoration(
            color: isPig ? const Color(0xFF7CB342) : const Color(0xFFE53935),
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

  // ПОЛНОСТЬЮ ЗАМЕНИ СТАРЫЙ МЕТОД _buildComicFrame НА ЭТОТ КОРРЕКТНЫЙ:
Widget _buildComicFrame({required Widget child, required bool isRoom}) {
  return Container(
    decoration: BoxDecoration(
      // Если это кабинет (isRoom = true) — красим в бежевый, если луг (isRoom = false) — в яркое небо
      color: isRoom ? const Color(0xFFD7CCC8) : Colors.blue.shade300,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.black, width: 3.5),
      boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 6, offset: Offset(0, 4))],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          // ЕСЛИ ЭТО ЛУГ (ВТОРАЯ СТРАНИЦА): Отрисовываем солнце, облака и сочную траву луга в основании
          if (!isRoom) ...[
            // Яркое круглое солнце в углу кадра
            Positioned(top: -15, right: -15, child: Container(width: 50, height: 50, decoration: const BoxDecoration(color: Color(0xFFFFF176), shape: BoxShape.circle))),
            // Облака на небе
            Positioned(top: 15, left: 10, child: Icon(Icons.cloud_rounded, size: 24, color: Colors.white.withOpacity(0.5))),
            Positioned(top: 30, right: 35, child: Icon(Icons.cloud_rounded, size: 20, color: Colors.white.withOpacity(0.5))),
            // Сочный зеленый луг в самом низу кадра
            Positioned(bottom: 0, left: 0, right: 0, child: Container(height: 35, color: const Color(0xFF4CAF50))),
          ],
          
          // ЕСЛИ ЭТО КАБИНЕТ (ПЕРВАЯ СТРАНИЦА): Рисуем только коричневый деревянный пол кабинета
          if (isRoom)
            Positioned(bottom: 0, left: 0, right: 0, child: Container(height: 16, color: const Color(0xFF8D6E63))),
            
          child, // Поверх фона накладываются сами персонажи и диалоги
        ],
      ),
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

// РИСОВАЛЬЩИК РЕЧЕВЫХ ПУЗЫРЕЙ ДЛЯ КОМИКСА ШЕРИФА (С ХВОСТИКАМИ СНИЗУ)
class ComicBubblePainter extends CustomPainter {
  final double tailX; // Позиция хвостика по оси X
  ComicBubblePainter({required this.tailX});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    final borderPaint = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 1.8;

    final path = Path()..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(10)));
    
    // Хвостик облачка указывает строго вниз на макушку говорящего персонажа!
    double sx = size.width * tailX;
    path.moveTo(sx - 5, size.height);
    path.lineTo(sx, size.height + 8);
    path.lineTo(sx + 5, size.height);

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
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


// ПОЛНОСТЬЮ ЗАМЕНИТЬ СТАРЫЙ КЛАСС _SecretMouthShadowPainter НА ЭТОТ КОРРЕКТНЫЙ:
class _SecretMouthShadowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Еле-еле заметная тень на полу кабинета (прозрачность 15%)
    final shadowPaint = Paint()
      ..color = const Color(0xFF5D4037).withOpacity(0.15)
      ..style = PaintingStyle.fill;
    
    // 1. ВЫРАЗИТЕЛЬНЫЕ ЗЛОВЕЩИЕ РОМБЫ ГЛАЗ, УХОДЯЩИЕ ВНИЗ В СЕРЕДИНУ (ЭФФЕКТ ЯРОСТИ)
    // Левый глаз-ромб
    final leftEyePath = Path();
    leftEyePath.moveTo(size.width * 0.22, size.height * 0.05); // Верхняя точка
    leftEyePath.lineTo(size.width * 0.32, size.height * 0.15); // Правый угол
    leftEyePath.lineTo(size.width * 0.26, size.height * 0.38); // Нижняя точка, уходящая к центру
    leftEyePath.lineTo(size.width * 0.16, size.height * 0.20); // Левый угол
    leftEyePath.close();
    canvas.drawPath(leftEyePath, shadowPaint);

    // Правый глаз-ромб (зеркальный левому)
    final rightEyePath = Path();
    rightEyePath.moveTo(size.width * 0.78, size.height * 0.05); // Верхняя точка
    rightEyePath.lineTo(size.width * 0.84, size.height * 0.20); // Правый угол
    rightEyePath.lineTo(size.width * 0.74, size.height * 0.38); // Нижняя точка, уходящая к центру
    rightEyePath.lineTo(size.width * 0.68, size.height * 0.15); // Левый угол
    rightEyePath.close();
    canvas.drawPath(rightEyePath, shadowPaint);

    // 2. ШИРОКАЯ И ПЛОСКАЯ ПИКСЕЛЬНАЯ УЛЫБКА ИЗ КВАДРАТИКОВ (ДУГА ОПУЩЕНА, ОНА СТАЛА ШИРЕ)
    int teethCount = 7; // Сделали 7 зубов, чтобы растянуть оскал шире во всю горизонталь
    double toothSize = 1.4; 

    for (int i = 0; i < teethCount; i++) {
      // Растягиваем зубы от самого левого до правого края (от 0.08 до 0.92)
      double offsetX = (size.width * 0.08) + (i * (size.width * 0.84 / (teethCount - 1)));
      
      // ИСПРАВЛЕНО: Уменьшили прогиб дуги (умножаем всего на 0.15 вместо 0.35), улыбка стала широкой и плоской
      double progress = i / (teethCount - 1);
      double offsetY = size.height * 0.50 + (sin(progress * pi) * (size.height * 0.15));
      
      canvas.drawRect(Rect.fromLTWH(offsetX, offsetY, toothSize, toothSize), shadowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


class _TentacleSkyShadowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Цвет неба blue.shade300. Делаем тень щупальца еле видимой, чуть темнее лазури
    final shadowPaint = Paint()
      ..color = Colors.blue.shade400.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    // Красивый S-образный изгиб скрученного щупальца осьминога по твоему референсу
    path.moveTo(size.width * 0.5, size.height);
    path.cubicTo(
      size.width * 0.1, size.height * 0.7,
      size.width * 0.9, size.height * 0.4,
      size.width * 0.5, size.height * 0.1,
    );
    path.cubicTo(
      size.width * 0.3, size.height * 0.0,
      size.width * 0.1, size.height * 0.2,
      size.width * 0.3, size.height * 0.3,
    );
    canvas.drawPath(path, shadowPaint);

    // Добавляем микроскопические присоски вдоль изгиба
    final dotPaint = Paint()..color = Colors.blue.shade400.withOpacity(0.3)..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.6), 1.2, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.45), 1.0, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.4, size.height * 0.2), 0.8, dotPaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ClawCloudShadowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Облако белое полупрозрачное. Тень на нем делаем чуть сероватой для едва заметного контраста
    final shadowPaint = Paint()..color = const Color(0x22455A64)..style = PaintingStyle.fill;
    
    // Рисуем крошечный горизонтальный силуэт клешни медали SECRET
    double cw = size.width;
    double ch = size.height;
    
    // Тело клешни
    canvas.drawOval(Rect.fromLTWH(0, ch * 0.2, cw * 0.6, ch * 0.6), shadowPaint);
    // Длинный верхний щипец, вытянутый вперед горизонтально
    final topClaw = Path()
      ..moveTo(cw * 0.5, ch * 0.3)
      ..cubicTo(cw * 0.7, -ch * 0.2, cw * 0.9, ch * 0.1, cw, ch * 0.3)
      ..lineTo(cw * 0.7, ch * 0.4)
      ..close();
    canvas.drawPath(topClaw, shadowPaint);
    // Нижний встречный щипец
    final bottomClaw = Path()
      ..moveTo(cw * 0.5, ch * 0.7)
      ..cubicTo(cw * 0.7, ch * 1.2, cw * 0.9, ch * 0.8, cw * 0.95, ch * 0.6)
      ..lineTo(cw * 0.7, ch * 0.6)
      ..close();
    canvas.drawPath(bottomClaw, shadowPaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
