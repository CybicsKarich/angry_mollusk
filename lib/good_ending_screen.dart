import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'audio_manager.dart'; // Для полной очистки аудиосистем при выходе

class GoodEndingScreen extends StatefulWidget {
  const GoodEndingScreen({super.key});

  @override
  State<GoodEndingScreen> createState() => _GoodEndingScreenState();
}

class _GoodEndingScreenState extends State<GoodEndingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();
    // Анимация плавного появления текста рапорта статистики через 1.5 секунды
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _textOpacity = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    
    // Запускаем появление текста с небольшой задержкой, чтобы игрок успел рассмотреть закат
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // Асинхронный загрузчик накопленной в геймплее статистики Karrick Studio
  Future<Map<String, int>> _loadGameStats() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'birds': prefs.getInt('stats_birds_launched') ?? 0,
      'blocks': prefs.getInt('stats_blocks_destroyed') ?? 0,
      'pigs': prefs.getInt('stats_pigs_defeated') ?? 0,
    };
  }

    @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF1A0A05), // Мрачно-багровая подложка
      body: Stack(
        child: FutureBuilder<Map<String, int>>(
          future: _loadGameStats(),
          builder: (context, snapshot) {
            final stats = snapshot.data ?? {'birds': 0, 'blocks': 0, 'pigs': 0};

            return Stack(
              children: [
                // 1. ЗАДНИЙ ПЛАН: УЮТНЫЙ ДЕРЕВЯННЫЙ КАБИНЕТ В ЛУЧАХ БАГРЯНОГО ЗАКАТА
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF8B4F30), // Верх стен озарён заходящим солнцем
                          Color(0xFF3E1F15), // Тёмные углы внизу
                        ],
                      ),
                    ),
                  ),
                ),

                // Ровный плоский пол кабинета Шерифа Вани без искажений
                Positioned(
                  bottom: 0, left: 0, right: 0, height: 32,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF5D4037), // Массивные доски паркета
                      border: Border(top: BorderSide(color: Color(0xFF3E2723), width: 2.5)),
                    ),
                  ),
                ),

                // 2. ДЕКОРАЦИИ КАБИНЕТА: СТОЛ, СТУЛ, РАПОРТЫ И КРУЖКА ШЕРИФА С КОФЕ
                // Деревянный рабочий стул
                Positioned(bottom: 22, left: media.width * 0.14, child: _buildWoodenChair()),
                
                // 🤠 ВАНЯ БАННИХОП СИДИТ ЗА СТОЛОМ В ШЛЯПЕ (БЕЗ СЛОВ, НА СВОЁМ ДЕЖУРСТВЕ)
                Positioned(
                  bottom: 34, left: media.width * 0.14 + 10,
                  child: SizedBox(
                    width: 60, height: 75,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        // Круглое красное тело птицы
                        Container(
                          width: 52, height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE53935),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 2.2),
                          ),
                          child: ClipOval(child: Image.asset('assets/images/bunnyhop.png', fit: BoxFit.cover)),
                        ),
                        // Ковбойская ковбойская шляпа из твоего кода на макушке Шерифа
                        Positioned(top: 12, child: _buildSheriffHat()),
                      ],
                    ),
                  ),
                ),

                // Массивный рабочий стол с бумагами
                Positioned(bottom: 4, left: media.width * 0.22, child: _buildWoodenTableWithReports()),

                // 3. ПЕРЕДНИЙ ПЛАН: АККУРАТНЫЙ SERIF-ТЕКСТ РАПОРТА СТАТИСТИКИ КАРРИК
                Center(
                  child: FadeTransition(
                    opacity: _textOpacity,
                    child: Container(
                      width: media.width * 0.50,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFDE7).withOpacity(0.06), // Едва заметное свечение по центру
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "KARRICK STUDIO",
                            style: TextStyle(
                              fontFamily: 'Georgia', // Serif-шрифт с засечками
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFFFCC80), // Золотисто-закатный оттенок бренда
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Спасибо за прохождение игры!\nНадеюсь, увидимся снова!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: Colors.white70, // Исправленный константный цвет
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(width: 80, height: 1.5, color: const Color(0xFFFFCC80).withOpacity(0.4)),
                          const SizedBox(height: 16),
                          
                          // БЛОК ИНФОГРАФИКИ НАКОПЛЕННЫХ ДАННЫХ
                          _buildStatRow("Запущено птиц из рогатки:", stats['birds']!),
                          const SizedBox(height: 8),
                          _buildStatRow("Уничтожено укреплений свиней:", stats['blocks']!),
                          const SizedBox(height: 8),
                          _buildStatRow("Убито зелёных свиней:", stats['pigs']!),
                          
                          const SizedBox(height: 28),
                          
                          // СОМНЕВАЮЩИЙСЯ ЖЁЛТЫЙ ЗНАК ФИНАЛА ПО ТЗ
                          const Text(
                            "КОНЕЦ?",
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFFFD54F), // Сочно-жёлтый цвет интриги
                              letterSpacing: 4.0,
                              shadows: [Shadow(color: Colors.black87, blurRadius: 4, offset: Offset(2, 2))],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // КНОПКА ВОЗВРАЩЕНИЯ В ГЛАВНОЕ МЕНЮ
                          SizedBox(
                            width: 200, height: 40,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5D4037),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10), 
                                  side: const BorderSide(color: Colors.black, width: 1.5),
                                ),
                                elevation: 4,
                              ),
                              onPressed: () {
                                AudioManager.stopFinalComicAudio();
                                Navigator.of(context).popUntil((route) => route.isFirst); // Мгновенный сброс стейтов и вылет на Главный Экран
                              },
                              child: const Text(
                                "В ГЛАВНОЕ МЕНЮ", 
                                style: TextStyle(fontFamily: 'Georgia', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }


  // Строка вывода конкретного параметра статистики
  Widget _buildStatRow(String label, int value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Georgia', fontSize: 12, color: Colors.white70)),
        Text(
          value.toString(),
          style: const TextStyle(fontFamily: 'Georgia', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFFFCC80)),
        ),
      ],
    );
  }

    Widget _buildSheriffHat() {
    return SizedBox(
      width: 55, height: 25,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: 32, height: 14, 
            decoration: const BoxDecoration(
              color: Color(0xFF795548), 
              borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
            ),
          ),
          Positioned(
            bottom: 3,
            child: Container(
              width: 52, height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFF6D4C41), 
                borderRadius: BorderRadius.circular(4), 
                border: Border.all(color: const Color(0xFF4E342E), width: 0.8),
              ),
            ),
          ),
          Positioned(
            bottom: 7, 
            child: Container(
              width: 31, height: 2, 
              decoration: BoxDecoration(color: const Color(0xFF212121), borderRadius: BorderRadius.circular(1)),
            ),
          ),
          Positioned(
            top: 2,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.star_rounded, color: Colors.blueGrey.shade100, size: 14),
                Container(width: 4, height: 4, decoration: const BoxDecoration(color: Color(0xFFFFFFFF), shape: BoxShape.circle)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWoodenChair() {
    return SizedBox(
      width: 40, height: 50,
      child: Stack(
        children: [
          Positioned(bottom: 0, left: 4, child: Container(width: 3, height: 48, decoration: BoxDecoration(color: const Color(0xFFF1D299), border: Border.all(color: const Color(0xFFC6A065), width: 0.5)))),
          Positioned(bottom: 0, right: 16, child: Container(width: 3, height: 48, decoration: BoxDecoration(color: const Color(0xFFF1D299), border: Border.all(color: const Color(0xFFC6A065), width: 0.5)))),
          Positioned(top: 2, left: 4, right: 16, child: Container(height: 12, decoration: BoxDecoration(color: const Color(0xFFE8C384), borderRadius: BorderRadius.circular(1), border: Border.all(color: const Color(0xFFB58F4B), width: 0.8)))),
          Positioned(bottom: 0, left: 14, child: Container(width: 3.5, height: 24, decoration: BoxDecoration(color: const Color(0xFFF1D299), border: Border.all(color: const Color(0xFFC6A065), width: 0.5)))),
          Positioned(bottom: 0, right: 6, child: Container(width: 3.5, height: 24, decoration: BoxDecoration(color: const Color(0xFFF1D299), border: Border.all(color: const Color(0xFFC6A065), width: 0.5)))),
          Positioned(bottom: 22, left: 2, right: 4, child: Container(height: 4, decoration: BoxDecoration(color: const Color(0xFFE8C384), borderRadius: BorderRadius.circular(1), border: Border.all(color: const Color(0xFFB58F4B), width: 0.8)))),
          Positioned(bottom: 8, left: 4, right: 16, child: Container(height: 2.5, color: const Color(0xFFD6B274))),
        ],
      ),
    );
  }

  Widget _buildWoodenTableWithReports() {
    return SizedBox(
      width: 85, height: 65,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(bottom: 0, left: 6, child: Container(width: 5, height: 40, decoration: BoxDecoration(color: const Color(0xFFF1D299), border: Border.all(color: const Color(0xFFC6A065), width: 0.5)))),
          Positioned(bottom: 0, left: 22, child: Container(width: 4, height: 40, decoration: const BoxDecoration(color: Color(0xFFE2C08A)))),
          Positioned(bottom: 0, right: 26, child: Container(width: 4, height: 40, decoration: const BoxDecoration(color: Color(0xFFE2C08A)))),
          Positioned(bottom: 0, right: 6, child: Container(width: 5, height: 40, decoration: BoxDecoration(color: const Color(0xFFF1D299), border: Border.all(color: const Color(0xFFC6A065), width: 0.5)))),
          Positioned(bottom: 35, left: 4, right: 4, child: Container(height: 8, decoration: BoxDecoration(color: const Color(0xFFE8C384), border: Border.all(color: const Color(0xFFB58F4B), width: 0.5)))),
          Positioned(bottom: 40, left: 0, right: 0, child: Container(height: 5, decoration: BoxDecoration(color: const Color(0xFFEDCD96), borderRadius: BorderRadius.circular(1), border: Border.all(color: const Color(0xFFC6A065), width: 1.0)))),

          // Разбросанные бумаги рапортов на столе Шерифа Вани
          Positioned(bottom: 44, left: 6, child: Transform.rotate(angle: -0.2, child: Container(width: 16, height: 10, decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(1), border: Border.all(color: Colors.black45, width: 0.5))))),
          Positioned(bottom: 45, left: 18, child: Transform.rotate(angle: 0.1, child: Container(width: 14, height: 11, decoration: BoxDecoration(color: Colors.white.withOpacity(0.85), borderRadius: BorderRadius.circular(1), border: Border.all(color: Colors.black45, width: 0.5))))),

                    // Наша жёлтая кружка с надписью Sheriff
          Positioned(
            bottom: 44, right: 8,
            child: SizedBox(
              width: 22, height: 18,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(top: 3, right: 0, child: Container(width: 7, height: 11, decoration: BoxDecoration(color: const Color(0xFFFFEB3B), borderRadius: const BorderRadius.only(topRight: Radius.circular(5), bottomRight: Radius.circular(5)), border: Border.all(color: Colors.black, width: 0.8)))),
                  Positioned(top: 5, right: 1, child: Container(width: 3, height: 7, decoration: const BoxDecoration(color: Color(0xFFD7CCC8), borderRadius: BorderRadius.only(topRight: Radius.circular(3), bottomRight: Radius.circular(3))))),
                  Positioned(
                    top: 0, left: 0,
                    child: Container(
                      width: 16, height: 18,
                      decoration: BoxDecoration(color: const Color(0xFFFFEB3B), borderRadius: BorderRadius.circular(3), border: Border.all(color: Colors.black, width: 1.0)),
                      child: const Center(
                        child: Text(
                          "Sheriff", // ИСПРАВЛЕНО: Добавлен каноничный микро-текст на кружку
                          style: TextStyle(fontSize: 3.2, fontWeight: FontWeight.w900, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} // Класс состояния полностью закрыт


