import 'dart:math';
import 'package:webview_flutter/webview_flutter.dart';
import 'game_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart'; // Пакет для управления экраном и системными панелями
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // Гарантируем инициализацию внутренних сервисов Flutter
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Фиксируем экран только в горизонтальном режиме (альбомная ориентация)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // 2. Включаем режим ImmersiveStick. Он прячет панели навигации и уведомлений.
  // Они откроются, только если пользователь проведет пальцем от края экрана, и закроются сами.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ANGRY MOLLUSK',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
      ),
      home: const MainMenuScreen(),
    );
  }
}

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

// ЗАМЕНИ СТАРУЮ СТРОКУ ОБЪЯВЛЕНИЯ КЛАССА НА ЭТУ:
class _MainMenuScreenState extends State<MainMenuScreen> with WidgetsBindingObserver {
  late AudioPlayer _audioPlayer;
  double _currentVolume = 0.5; // Громкость по умолчанию 50%

  @override
  void initState() {
    super.initState();
    // Включаем слежку за тем, свернули ли игру
    WidgetsBinding.instance.addObserver(this);
    
    _audioPlayer = AudioPlayer();
    _audioPlayer.setVolume(_currentVolume); // Задаем громкость
    _playBackgroundMusic();
  }

  // Этот метод ставит музыку на паузу, если игру свернули
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      _audioPlayer.pause(); // Игра свернута — пауза
    } else if (state == AppLifecycleState.resumed) {
      _audioPlayer.resume(); // Игра развернута — продолжаем
    }
  }

    Future<void> _playBackgroundMusic() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('music/bg_music.mp3'));
    } catch (e) {
      debugPrint("Музыка пока не загружена в ассеты: $e");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Выключаем слежку
    _audioPlayer.dispose();
    super.dispose();
  }

  // Метод для открытия экрана настроек
  void _openSettings() async {
    final updatedVolume = await Navigator.push<double>(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          initialVolume: _currentVolume,
          audioPlayer: _audioPlayer,
        ),
      ),
    );
    if (updatedVolume != null) {
      setState(() {
        _currentVolume = updatedVolume; // Сохраняем новую громкость
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0288D1), // Глубокий синий верх
              Color(0xFFB3E5FC), // Светло-голубой низ
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            // В горизонтальном режиме лучше использовать Row (строку), 
            // чтобы слева было красивое название, а справа сочные кнопки!
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Левая часть: Логотип и Подзаголовок
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'ANGRY MOLLUSK',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFD32F2F),
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              offset: Offset(3.0, 3.0),
                              blurRadius: 3.0,
                              color: Color(0xFF000000),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Баннихоп против Максима Рыбалкина',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),

                // Правая часть: Наш переставленный список кнопок
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SingleChildScrollView(
                      child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      // Кнопка УРОВНИ теперь открывает новый экран уровней
                       _buildMenuButton('УРОВНИ', Icons.play_arrow_rounded, Colors.orange, () {
                        Navigator.push(
                         context,
                        MaterialPageRoute(builder: (context) => const LevelsScreen()),
                            );
                          }),
                      const SizedBox(height: 16), // Вернули пробел 16
                      _buildMenuButton('ДОСТИЖЕНИЯ', Icons.emoji_events_rounded, Colors.amber, () {
                      Navigator.push(
                       context,
                        MaterialPageRoute(builder: (context) => const AchievementsScreen()),
                       );
                      }),
                        const SizedBox(height: 16), // Вернули пробел 16
                      _buildMenuButton('ДОПОЛНИТЕЛЬНО', Icons.extension_rounded, Colors.purple, () {
                      Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AdditionalScreen()),
                      );
                      }),
                      const SizedBox(height: 16), // Вернули пробел 16
                      _buildMenuButton('НАСТРОЙКИ', Icons.settings_rounded, Colors.grey, _openSettings),
                      ],
                     )
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(String text, IconData icon, Color color, VoidCallback onTap) { // <-- Добавили в конец
  return Container(
    width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 280),
      height: 52, // Чуть уменьшили высоту для лучшей посадки в горизонтальном режиме
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 24, color: Colors.white),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  final double initialVolume;
  final AudioPlayer audioPlayer;

  const SettingsScreen({
    super.key,
    required this.initialVolume,
    required this.audioPlayer,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late double _volume;

  @override
  void initState() {
    super.initState();
    _volume = widget.initialVolume;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0288D1), Color(0xFFB3E5FC)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'ГРОМКОСТЬ ЗВУКА',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                  ),
                  const SizedBox(height: 10),
                  Slider(
                    value: _volume,
                    min: 0.0,
                    max: 1.0,
                    activeColor: Colors.orange,
                    onChanged: (newValue) {
                      setState(() => _volume = newValue);
                      widget.audioPlayer.setVolume(_volume); // Меняем звук на лету
                    },
                  ),
                  Text('${(_volume * 100).toStringAsFixed(0)}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, _volume), // Кнопка назад
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    child: const Text('НАЗАД', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =========================================================================
// ПОЛНОСТЬЮ ОБНОВЛЕННЫЙ ЭКРАН УРОВНЕЙ 1-5 С КНОПКАМИ-СТРЕЛКАМИ И ЗВЕЗДАМИ
// =========================================================================
class LevelsScreen extends StatefulWidget {
  const LevelsScreen({super.key});

  @override
  State<LevelsScreen> createState() => _LevelsScreenState();
}

class _LevelsScreenState extends State<LevelsScreen> {
  // Контроллер для управления страницами PageView кнопками-стрелками
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Мультяшный задний фон (Небо)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF4FC3F7), Color(0xFFE1F5FE)],
              ),
            ),
          ),

          // 2. Декорации: Облака
          Positioned(
            top: 20,
            left: 50,
            child: Icon(Icons.cloud_rounded, size: 80, color: Colors.white.withOpacity(0.6)),
          ),
          Positioned(
            top: 40,
            right: 80,
            child: Icon(Icons.cloud_rounded, size: 100, color: Colors.white.withOpacity(0.5)),
          ),

          // 3. Декорации: Зеленые холмы
          Positioned(
            bottom: -30,
            left: -50,
            right: -50,
            child: Container(
              height: 120,
              decoration: const BoxDecoration(
                color: Color(0xFF81C784),
                borderRadius: BorderRadius.all(Radius.elliptical(500, 100)),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -20,
            right: -20,
            child: Container(
              height: 100,
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50),
                borderRadius: BorderRadius.all(Radius.elliptical(600, 100)),
              ),
            ),
          ),

          // 4. Основной игровой интерфейс
          SafeArea(
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 15),
                  
                  const Text(
                    'УРОВНИ',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFF57C00),
                      letterSpacing: 2,
                      shadows: [Shadow(offset: Offset(2.0, 2.0), blurRadius: 2.0, color: Colors.black26)],
                    ),
                  ),
                  
                  const Spacer(),

                  // ЗАМЕНИТЬ СТАРЫЙ SizedBox с PageView НА ЭТОТ КЛАССИЧЕСКИЙ БЛОК:
SizedBox(
  height: 150, 
  child: FutureBuilder<List<int>>(
    future: SharedPreferences.getInstance().then((prefs) => [
      prefs.getInt('level_1_stars') ?? 0,
      prefs.getInt('level_2_stars') ?? 0,
      prefs.getInt('level_3_stars') ?? 0,
      prefs.getInt('level_4_stars') ?? 0,
      prefs.getInt('level_5_stars') ?? 0, 
    ]),
    builder: (context, snapshot) {
      final stars = snapshot.data ?? [];
      
      // Условия хардкорного открытия уровней (минимум 2 звезды за прошлый)
      final bool isLvl2Open = stars[0] >= 2;
      final bool isLvl3Open = stars[1] >= 2;
      final bool isLvl4Open = stars[2] >= 2;
      final bool isLvl5Open = stars[3] >= 2;
      final bool isLvl6Open = stars[4] >= 2;

      return PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (index) => setState(() => _currentPage = index),
        children: [
          // СТРАНИЦА 1: УРОВНИ 1, 2, 3
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLevelCard('1', true), // 1 уровень открыт всегда
              const SizedBox(width: 24), 
              _buildLevelCard('2', isLvl2Open),
              const SizedBox(width: 24),
              _buildLevelCard('3', isLvl3Open),
            ],
          ),

                    // СТРАНИЦА 2: УРОВНИ 4, 5 И 6 (ИСПРАВЛЕНО: ТЕПЕРЬ СТРОГО ПО ПОРЯДКУ!)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLevelCard('4', isLvl4Open), 
              const SizedBox(width: 20), 
              
              _buildLevelCard('5', isLvl5Open),
              const SizedBox(width: 20),
              
              // ИКОНКА УРОВНЯ 6: Теперь замыкает ряд справа 
              _buildLevelCard('6', isLvl6Open), 
            ],
          ),
        ],
      );
    },
  ),
),


                  const Spacer(),

                  // ИСПРАВЛЕНО: ПАНЕЛЬ НАВИГАЦИИ С КНОПКАМИ ПО УГЛАМ
                  Padding(
                    padding: const EdgeInsets.only(left: 24, right: 24, bottom: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // СТРЕЛКА НАЗАД В ГЛАВНОЕ МЕНЮ (Всегда в левом углу)
                        Container(
                          decoration: const BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 3))]),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_rounded, size: 32, color: Colors.white),
                            style: IconButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.all(10)),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),

                        // ИСПРАВЛЕНО: УМНАЯ СТРЕЛКА ВПЕРЁД С ПРАВОЙ СТОРОНЫ (Скрывается на 2-й странице!)
                        if (_currentPage == 0)
                          Container(
                            decoration: const BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 3))]),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_forward_rounded, size: 32, color: Colors.white),
                              style: IconButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), padding: const EdgeInsets.all(10)),
                              onPressed: () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                            ),
                          )
                        else
                          const SizedBox(width: 52), // Заглушка, чтобы кнопка назад не прыгала
                      ],
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

  // ПОЛНОСТЬЮ ЗАМЕНИ СТАРЫЙ МЕТОД _buildLevelCard НА ЭТОТ ЦЕЛЬНЫЙ ВАРИАНТ:
Widget _buildLevelCard(String levelNumber, bool isActive) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 85,
        height: 85,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFFCC80) : Colors.grey.shade400, 
          borderRadius: BorderRadius.circular(22), 
          border: Border.all(
            color: isActive ? const Color(0xFFE65100) : Colors.grey.shade600, 
            width: 4,
          ), 
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 5)),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            if (!isActive) return; // Жесткая блокировка клика сразу
            
            if (levelNumber == '1') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SheriffComicScreen()));
              return;
            }
            if (levelNumber == '4') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ComicIntroScreen()));
              return;
            }
             
            // ДОБАВИТЬ СРАЗУ ПОСЛЕ ПРОВЕРКИ НА levelNumber == '4':
            if (levelNumber == '5') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SvinomatkinComicScreen()));
              return;
            }

            if (levelNumber == '6') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const Level6ComicScreen()));
              return;
            }
            
            GameScreen gameScreenInstance = GameScreen();
            int targetLevel = int.tryParse(levelNumber) ?? 1;
            gameScreenInstance.gameInstance.currentLevel = targetLevel;
            gameScreenInstance.gameInstance.worldScrollX = 0.0;

            Navigator.push(context, MaterialPageRoute(builder: (context) => gameScreenInstance));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: EdgeInsets.zero, 
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          child: isActive 
              ? Center(
                  child: Text(
                    levelNumber, 
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Color(0xFFE65100)),
                  ),
                )
              : const Center(
                  child: Icon(Icons.lock_rounded, size: 38, color: Color(0xFF5D4037)),
                ),
        ),
      ),
      const SizedBox(height: 8),
             
      FutureBuilder<int>(
        future: SharedPreferences.getInstance().then((prefs) => prefs.getInt('level_${levelNumber}_stars') ?? 0),
        builder: (context, snapshot) {
          final int savedStars = snapshot.data ?? 0;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star_rounded, size: 22, color: savedStars >= 1 ? const Color(0xFFFFD54F) : Colors.grey),
              const SizedBox(width: 2),
              Icon(Icons.star_rounded, size: 26, color: savedStars >= 2 ? const Color(0xFFFFD54F) : Colors.grey), 
              const SizedBox(width: 2),
              Icon(Icons.star_rounded, size: 22, color: savedStars >= 3 ? const Color(0xFFFFD54F) : Colors.grey),
            ],
          );
        },
      ),
    ],
  );
}
}

// 1. ОБНОВЛЕННЫЙ ЭКРАН "ДОПОЛНИТЕЛЬНО" С ФИРМЕННОЙ ПОДПИСЬЮ ivandrop
class AdditionalScreen extends StatelessWidget {
  const AdditionalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.70,
          height: MediaQuery.of(context).size.height * 0.85,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF9C4),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFFBC02D), width: 6),
            boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 15, offset: Offset(0, 8))],
          ),
          child: Column(
            children: [
              const Text(
                "ДИСКЛЕЙМЕР",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFFD84315), letterSpacing: 1.5),
              ),
              const Divider(color: Color(0xFFFBC02D), thickness: 2, indent: 40, endIndent: 40),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    children: [
                      const Text(
                        "Парни, этот проект — чисто наш локальный прикол и дружеский угар! Я делал эту игру исключительно для того, чтобы мы вместе поржали с озвучки и разнесли пару замков, а не чтобы кого-то задеть или обидеть. Свиные ушки у Максимов — мультяшные, blocks камня и дерева — виртуальные, а наше уважение друг к другу и дружба — настоящие. Ребята, вы лучшие! Не обижайтесь на приколы, это всё любя и ради фана.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF3E2723), height: 1.4),
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: Color(0xFFFBC02D), thickness: 1.5),
                      const SizedBox(height: 8),
                      const Text(
                        "ПОПРОБУЙТЕ НАШИ ДРУГИЕ ИГРЫ:",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF5D4037), letterSpacing: 1.1),
                      ),
                      const SizedBox(height: 12),
                      
                      // Кнопка запускает локальный HTML-файл из памяти APK!
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9800),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        onPressed: () {
                          // Переходим на внутренний экран с браузером
                          SharedPreferences.getInstance().then((prefs) async {
                            await prefs.setBool('achievement_new_experience', true);
                          });
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const HtmlGameScreen()),
                          );
                        },
                        icon: const Icon(Icons.html_rounded, color: Colors.white, size: 24),
                        label: const Text("ИГРАТЬ В ОФФЛАЙНЕ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "IVANDROP",
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, fontStyle: FontStyle.italic, color: Colors.brown),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 50, height: 50,
                decoration: const BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle),
                child: RawMaterialButton(
                  shape: const CircleBorder(),
                  onPressed: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 26),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 2. НОВЫЙ ЭКРАН-ПЛЕЕР ДЛЯ ВСТРОЕННОЙ HTML ИГРЫ
class HtmlGameScreen extends StatefulWidget {
  const HtmlGameScreen({super.key});

  @override
  State<HtmlGameScreen> createState() => _HtmlGameScreenState();
}

class _HtmlGameScreenState extends State<HtmlGameScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    // Инициализируем контроллер встроенного браузера
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // Включаем JS, чтобы HTML игра работала корректно
      ..setBackgroundColor(Colors.black)
      ..loadFlutterAsset('assets/web/index.html'); // Загружаем твой локальный файл игры!
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Сверху делаем маленькую мультяшную панель, чтобы можно было выйти обратно в меню
      appBar: AppBar(
        title: const Text("ИГРА: IVANDROP", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFFBC02D),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context), // Выход в меню дисклеймера
        ),
      ),
      body: WebViewWidget(controller: _controller), // Рисуем HTML игру на весь экран смартфона!
    );
  }
}

// =========================================================================
// КЛАСС КОСМИЧЕСКОГО ЭКРАНА ДОСТИЖЕНИЙ С БЕСКОНЕЧНЫМИ АНИМАЦИЯМИ ВНУТРИ КРУГОВ
// =========================================================================
class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  
  bool isFirstBloodUnlocked = false;
  bool isSniperUnlocked = false;
  bool isTriumphUnlocked = false;
  bool isSecretChestUnlocked = false; // 4 ачивка
  bool isNewExperienceUnlocked = false; // 5 ачивка

  // Генерируем случайные смещения для хаотичного полета монеток в ачивке IvanDrop
  final List<Offset> _coinOffsets = List.generate(6, (i) {
    final r = Random(i * 15);
    return Offset(r.nextDouble() * 60 - 30, r.nextDouble() * 60 - 30);
  });

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(); 

    _loadAchievementsStatus();
  }

  Future<void> _loadAchievementsStatus() async {
    final prefs = await SharedPreferences.getInstance();
    
    final firstBlood = prefs.getBool('achievement_first_blood') ?? false;
    final sniper = prefs.getBool('achievement_sniper') ?? false;
    final secretChest = prefs.getBool('achievement_secret_chest') ?? false;
    final newExp = prefs.getBool('achievement_new_experience') ?? false;
    
    int s1 = prefs.getInt('level_1_stars') ?? 0;
    int s2 = prefs.getInt('level_2_stars') ?? 0;
    int s3 = prefs.getInt('level_3_stars') ?? 0;
    int s4 = prefs.getInt('level_4_stars') ?? 0;
    bool triumph = (s1 + s2 + s3 + s4) >= 12;

    setState(() {
      isFirstBloodUnlocked = firstBlood;
      isSniperUnlocked = sniper;
      isTriumphUnlocked = triumph;
      isSecretChestUnlocked = secretChest;
      isNewExperienceUnlocked = newExp;
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFF0A0E17), 
        child: Stack(
          children: [
            ...List.generate(40, (index) {
              final random = Random(index);
              return Positioned(
                top: random.nextDouble() * MediaQuery.of(context).size.height,
                left: random.nextDouble() * MediaQuery.of(context).size.width,
                child: Container(
                  width: random.nextDouble() * 3 + 1,
                  height: random.nextDouble() * 3 + 1,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(random.nextDouble() * 0.7 + 0.3),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),

            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    const Text(
                      "МЕНЮ ДОСТИЖЕНИЙ",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 2.0,
                        shadows: [Shadow(color: Colors.blueAccent, blurRadius: 10)],
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // ПЕРВЫЙ РЯД АЧИВОК (1, 2, 3)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAchievementCircle(
                          title: "Первая Кровь",
                          desc: "Убей самую первую\nсвинью на 1 уровне",
                          isUnlocked: isFirstBloodUnlocked,
                          child: AnimatedBuilder(
                            animation: _animController,
                            builder: (context, _) {
                              double scale = 1.0 + (sin(_animController.value * pi * 4) * 0.12);
                              return Container(
                                color: Colors.blue.shade900,
                                child: Center(
                                  child: Transform.scale(
                                    scale: scale,
                                    child: const Icon(Icons.opacity, color: Colors.greenAccent, size: 55),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 35),
                        _buildAchievementCircle(
                          title: "Снайпер",
                          desc: "Пройди любой уровень,\nпотратив всего 1 птицу",
                          isUnlocked: isSniperUnlocked,
                          child: AnimatedBuilder(
                            animation: _animController,
                            builder: (context, _) {
                              double targetSize = 85.0 - (sin(_animController.value * pi * 2).abs() * 15.0);
                              return Container(
                                color: const Color(0xFF1B5E20), 
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Transform.translate(
                                          offset: const Offset(-12, -14),
                                          child: Transform.rotate(
                                            angle: -0.2,
                                            child: Container(width: 8, height: 12, decoration: const BoxDecoration(color: Color(0xFF0D3211), shape: BoxShape.circle)),
                                          ),
                                        ),
                                        Transform.translate(
                                          offset: const Offset(12, -14),
                                          child: Transform.rotate(
                                            angle: 0.2,
                                            child: Container(width: 8, height: 12, decoration: const BoxDecoration(color: Color(0xFF0D3211), shape: BoxShape.circle)),
                                          ),
                                        ),
                                        Container(width: 36, height: 36, decoration: const BoxDecoration(color: Color(0xFF0D3211), shape: BoxShape.circle)),
                                      ],
                                    ),
                                    SizedBox(
                                      width: targetSize,
                                      height: targetSize,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Container(decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.redAccent, width: 1.5))),
                                          Container(width: targetSize * 0.6, height: targetSize * 0.6, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.redAccent, width: 1.5))),
                                          Container(width: 2.0, height: targetSize * 1.1, color: Colors.redAccent),
                                          Container(width: targetSize * 1.1, height: 2.0, color: Colors.redAccent),
                                          Container(width: 16, height: 16, color: const Color(0xFF1B5E20)),
                                          Container(width: 5, height: 5, decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 35),
                        _buildAchievementCircle(
                          title: "Триумф",
                          desc: "Пройди все 5 уровней\nна максимальные 3 звезды",
                          isUnlocked: isTriumphUnlocked,
                          child: AnimatedBuilder(
                            animation: _animController,
                            builder: (context, _) {
                              return Container(
                                color: Colors.purple.shade900,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    const Text("💪", style: TextStyle(fontSize: 26)),
                                    Transform.rotate(
                                      angle: _animController.value * pi * 2,
                                      child: Stack(
                                        children: List.generate(8, (i) {
                                          double angle = (i * pi / 4);
                                          return Transform.translate(
                                            offset: Offset(cos(angle) * 32, sin(angle) * 32),
                                            child: const Icon(Icons.star_rounded, color: Colors.amber, size: 12),
                                          );
                                        }),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // ВТОРОЙ РЯД АЧИВОК (4, 5)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                                                // 4 КРУГ: КРОВОЖАДНАЯ МЕСТЬ (Эпичный Ardor-стиль, квадратные зубы с кариесом!)
                        _buildAchievementCircle(
                          title: isSecretChestUnlocked ? "Кровожадная месть" : "SECRET",
                          desc: isSecretChestUnlocked ? "Ты раскрыл тайну\nскрытого сундука!" : "???",
                          isUnlocked: isSecretChestUnlocked,
                          child: AnimatedBuilder(
                            animation: _animController,
                            builder: (context, _) {
                              double cycle = (_animController.value * 2) % 1.0; 
                              bool isVisible = cycle < 0.55; 
                              
                              // Клешня работает аккуратно снизу и не лезет на зубы
                              double clawY = isVisible ? (45 - (cycle * 25)) : 55; 
                              double clawOpenFactor = isVisible ? (sin(cycle * pi * 4).abs()) : 0.0;

                              return Container(
                                color: const Color(0xFF050101), // Почти чёрный зловещий фон
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    
                                    // А) ЗЛОВЕЩИЙ ОСКАЛ И ГЛАЗА ARDOR GAMING
                                    if (isVisible)
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          // 1. Светящиеся демонические глаза Ardor
                                          Transform.translate(
                                            offset: const Offset(-14, -26),
                                            child: Transform.rotate(
                                              angle: 0.3,
                                              child: Container(
                                                width: 14, height: 5,
                                                decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.red.shade900, blurRadius: 6, spreadRadius: 3)]),
                                              ),
                                            ),
                                          ),
                                          Transform.translate(
                                            offset: const Offset(14, -26),
                                            child: Transform.rotate(
                                              angle: -0.3,
                                              child: Container(
                                                width: 14, height: 5,
                                                decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.red.shade900, blurRadius: 6, spreadRadius: 3)]),
                                              ),
                                            ),
                                          ),
                                          
                                          // 2. ИСПРАВЛЕНО: Сплошная челюсть с квадратными потрескавшимися зубами!
                                          Transform.translate(
                                            offset: const Offset(0, -6),
                                            child: CustomPaint(
                                              size: const Size(60, 20),
                                              painter: ScaryMouthPainter(),
                                            ),
                                          ),
                                        ],
                                      ),

                                    // Б) НАСТОЯЩАЯ МОНОЛИТНАЯ ЗЕЛЁНАЯ КЛЕШНЯ КРАБА
                                    Transform.translate(
                                      offset: Offset(0, clawY),
                                      child: CustomPaint(
                                        size: const Size(40, 50),
                                        painter: CrabClawPainter(openFactor: clawOpenFactor),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),     
                        const SizedBox(width: 35),

                        // 5 КРУГ: НОВЫЙ ОПЫТ (Клик по IvanDrop во вкладке Дополнительно)
                        _buildAchievementCircle(
                          title: "Новый опыт",
                          desc: "Во вкладке дополнительно\nоткройте игру ivandrop",
                          isUnlocked: isNewExperienceUnlocked,
                          child: AnimatedBuilder(
                            animation: _animController,
                            builder: (context, _) {
                              return Container(
                                color: Colors.black, // Строго чёрный фон по твоему ТЗ
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // По центру красными буквами написано название игры
                                    const Text(
                                      "ivandrop",
                                      style: TextStyle(color: Colors.redAccent, fontSize: 15, fontWeight: FontWeight.bold),
                                    ),
                                    // Вокруг в хаотичном порядке летают маленькие золотые монетки
                                    ...List.generate(_coinOffsets.length, (i) {
                                      double animFactor = sin((_animController.value * pi * 2) + i);
                                      return Transform.translate(
                                        offset: Offset(_coinOffsets[i].dx * animFactor, _coinOffsets[i].dy * animFactor),
                                        child: const Icon(Icons.monetization_on_rounded, color: Colors.amber, size: 10),
                                      );
                                    }),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                style: IconButton.styleFrom(backgroundColor: Colors.white12),
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Конструктор-сборщик круглого элемента ачивки
  Widget _buildAchievementCircle({
    required String title,
    required String desc,
    required bool isUnlocked,
    required Widget child,
  }) {
    return Column(
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isUnlocked ? const Color(0xFFFFCC80) : Colors.grey.shade700, 
              width: 5,
            ),
            boxShadow: [
              BoxShadow(
                color: isUnlocked ? Colors.orange.withOpacity(0.3) : Colors.transparent, 
                blurRadius: 12,
              ),
            ],
          ),
          child: ClipOval(
            child: isUnlocked 
                ? child 
                : Container(
                    color: Colors.grey.shade800,
                    child: Icon(Icons.lock_rounded, color: Colors.grey.shade500, size: 40),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 15, 
            fontWeight: FontWeight.bold,
            color: isUnlocked ? const Color(0xFFFFCC80) : Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          desc,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade400, height: 1.2),
        ),
      ],
    );
  }
}

// КЛАСС ДЛЯ ВЕКТОРНОГО РИСОВАНИЯ НАСТОЯЩЕЙ КРАБЬЕЙ КЛЕШНИ С ФОТОГРАФИИ
class CrabClawPainter extends CustomPainter {
  final double openFactor; // отвечает за сжатие/раскрытие щипцов
  CrabClawPainter({required this.openFactor});

  @override
  void paint(Canvas canvas, Size size) {
    // Краски: тёмно-зелёная для базы и ярко-зелёная для верхних щипцов
    final basePaint = Paint()..color = const Color(0xFF1B4314)..style = PaintingStyle.fill;
    final clawPaint = Paint()..color = const Color(0xFF2E6F22)..style = PaintingStyle.fill;
    final borderPaint = Paint()..color = const Color(0xFF0D240A)..style = PaintingStyle.stroke..strokeWidth = 1.2;

    // 1. Рисуем нижнее массивное основание (сустав краба)
    canvas.drawOval(Rect.fromLTWH(size.width * 0.25, size.height * 0.5, size.width * 0.5, size.height * 0.4), basePaint);
    canvas.drawOval(Rect.fromLTWH(size.width * 0.25, size.height * 0.5, size.width * 0.5, size.height * 0.4), borderPaint);

    // 2. Центральное тело клешни (монолитный кокон)
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.15, size.height * 0.3, size.width * 0.7, size.height * 0.35), const Radius.circular(6)),
      clawPaint
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.15, size.height * 0.3, size.width * 0.7, size.height * 0.35), const Radius.circular(6)),
      borderPaint
    );

    // 3. ЛЕВАЯ СТВОРКА ЩИПЦА (Большой загнутый верхний крюк с фотографии)
    canvas.save();
    // Сдвигаем точку вращения в место соединения створок (левый верхний край базы)
    canvas.translate(size.width * 0.25, size.height * 0.35);
    canvas.rotate(-openFactor * 0.35); // вращаем створку для раскрытия клешни
    
    final leftHookPath = Path()
      ..moveTo(0, 0)
      ..cubicTo(-size.width * 0.3, -size.height * 0.2, -size.width * 0.2, -size.height * 0.5, size.width * 0.25, -size.height * 0.5) // закругление крюка
      ..lineTo(size.width * 0.2, -size.height * 0.35)
      ..cubicTo(size.width * 0.05, -size.height * 0.35, -size.width * 0.05, -size.height * 0.15, size.width * 0.1, 0)
      ..close();
    
    canvas.drawPath(leftHookPath, clawPaint);
    canvas.drawPath(leftHookPath, borderPaint);
    canvas.restore();

    // 4. ПРАВАЯ СТВОРКА ЩИПЦА (Нижний зажимающий палец с фотографии)
    canvas.save();
    // Точка вращения правого щипца (правый верхний край базы)
    canvas.translate(size.width * 0.75, size.height * 0.35);
    canvas.rotate(openFactor * 0.35); // вращаем в противоположную сторону
    
    final rightHookPath = Path()
      ..moveTo(0, 0)
      ..cubicTo(size.width * 0.2, -size.height * 0.15, size.width * 0.1, -size.height * 0.4, -size.width * 0.25, -size.height * 0.45)
      ..lineTo(-size.width * 0.15, -size.height * 0.3)
      ..cubicTo(-size.width * 0.05, -size.height * 0.3, size.width * 0.02, -size.height * 0.15, -size.width * 0.1, 0)
      ..close();
    
    canvas.drawPath(rightHookPath, clawPaint);
    canvas.drawPath(rightHookPath, borderPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// КЛАСС ДЛЯ РИСОВАНИЯ УЛЫБКИ, СФОРМИРОВАННОЙ СТРОГО ИЗ САМИХ КРОШЕЧНЫХ ЗУБИКОВ (БЕЗ ЛИНИИ ГУБ)
class ScaryMouthPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Малозаметный графитовый цвет для маленьких зубиков
    final toothPaint = Paint()
      ..color = const Color(0xFF424242) 
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0xFF212121)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    int teethCount = 7; // Чуть увеличили плотность, чтобы дуга зубов смотрелась цельнее
    double toothW = size.width / (teethCount + 1);
    double toothH = 4.5; // Маленькая высота зубиков

    // ИСПРАВЛЕНО: Линия улыбки полностью удалена! Рисуем только зубы, выстроенные в форме улыбки
    for (int i = 0; i < teethCount; i++) {
      // Центрируем ряд зубов по ширине
      double offsetX = (size.width - (teethCount * toothW)) / 2 + (i * toothW);
      
      // Вычисляем высоту зуба по синусоидальной дуге, чтобы сами зубы образовали оскал
      double progress = i / (teethCount - 1);
      double offsetY = size.height * 0.2 + (sin(progress * pi) * (size.height * 0.45));

      final rect = Rect.fromLTWH(offsetX, offsetY, toothW - 1.5, toothH);
      
      canvas.drawRect(rect, toothPaint);
      canvas.drawRect(rect, borderPaint);

      // Маленькая точка кариеса на одном из центральных зубиков для жути
      if (i == 3) {
        final cariesPaint = Paint()..color = const Color(0xFF1A0A0A)..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(rect.center.dx, rect.bottom - 1.2), 0.6, cariesPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =========================================================================
// ПОЛНЫЙ ЦЕЛЬНЫЙ КЛАСС КОМИКСА: 3 МАКСИМА НА ВСЕХ КАДРАХ, СУМКА И ОБЛАЧКА
// =========================================================================
class ComicIntroScreen extends StatelessWidget {
  const ComicIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F14), // Глубокий темный фон вокруг комикса
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text(
              "ПРЕДЫСТОРИЯ УРОВНЯ 4",
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.w900, 
                color: Color(0xFFFF9800), 
                letterSpacing: 2.0,
                shadows: [Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(2, 2))],
              ),
            ),
            const SizedBox(height: 16),

            // ГЛАВНАЯ СЕТКА КОМИКСА: 3 крупных кадра в один ряд
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    
                   // ПОЛНОСТЬЮ ЗАМЕНИТЬ КОД КАДРА 1 НА ЭТОТ КОРРЕКТНЫЙ ВАРИАНТ:
// КАДР 1: ТРИ МАКСИМА ЗАМЫШЛЯЮТ ПЛАН
Expanded(
  child: _buildComicFrame(
    child: Stack(
      alignment: Alignment.center,
      children: [
        // ТРИ КРУПНЫХ МАКСИМА (Зелёные свиньи с лицом Максима Рыбалкина)
        Positioned(
          bottom: 10, left: 10,
          child: _buildCharacterImage('assets/images/maksim.png', 55, isPig: true),
        ),
        Positioned(
          bottom: -5, left: 45,
          child: _buildCharacterImage('assets/images/maksim.png', 65, isPig: true),
        ),
        Positioned(
          bottom: 12, left: 90,
          child: _buildCharacterImage('assets/images/maksim.png', 50, isPig: true),
        ),
        
        // Большой объём текста над головами персонажей
        Positioned(
          top: 28, left: 6, right: 6,
          child: CustomPaint(
            painter: SpeechBubblePainter(tailXFactor: 0.5, tailGoesUp: false),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Text(
                "Баннихоп уже близко к замку нашего босса. Надо что-то придумать! Сделаем крепость из бронированного стекла. Тогда он точно не сможет её сломать!",
                style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Colors.black, height: 1.15),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    ),
  ),
),
const SizedBox(width: 12),


                    // КАДР 2: БАННИХОП ПОДФИГЕВАЕТ ОТ НАГЛОСТИ (ИСПРАВЛЕНО: ТЕПЕРЬ ТУТ 3 СВИНЬИ!)
                    Expanded(
                      child: _buildComicFrame(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // 1. ВЕРХНИЙ СТЭК ДЛЯ ТЕНИ (Закрывается сразу под ней!)
        Stack(
          children: [
            Positioned(
              top: 21,  // Координаты чётко под левое облако на небе
              left: 14, 
              child: CustomPaint(
                size: const Size(14, 8), 
                painter: _ClawCloudShadowPainter(),
              ),
            ),
          ],
        ),
                            // ВАНЯ БАННИХОП (Птица с перьями и лицом Вани, крупный, слева повернут к нам)
                            Positioned(
                              bottom: 10, left: 12,
                              child: _buildCharacterImage('assets/images/bunnyhop.png', 75, isPig: false),
                            ),
                            
                            // ИСПРАВЛЕНО: Ровно три наглые свиньи Максима стоят справа!
                            Positioned(
                              bottom: 10, right: 8,
                              child: _buildCharacterImage('assets/images/maksim.png', 45, isPig: true),
                            ),
                            Positioned(
                              bottom: -2, right: 38,
                              child: _buildCharacterImage('assets/images/maksim.png', 50, isPig: true),
                            ),
                            Positioned(
                              bottom: 14, right: 68,
                              child: _buildCharacterImage('assets/images/maksim.png', 42, isPig: true),
                            ),

                            // Ругань свиней чуть ниже, строго над их головами справа
                            Positioned(
                              top: 45, right: 10, width: 70,
                              child: CustomPaint(
                                painter: SpeechBubblePainter(tailXFactor: 0.75, tailGoesUp: false),
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(r"!$?!%", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.red), textAlign: TextAlign.center),
                                ),
                              ),
                            ),

                            // Ответ Вани Баннихопа пониже, строго над его головой
                            Positioned(
                              top: 35, left: 10, width: 110,
                              child: CustomPaint(
                                painter: SpeechBubblePainter(tailXFactor: 0.25, tailGoesUp: false),
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text("Ах вот вы что задумали!", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black), textAlign: TextAlign.center),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // КАДР 3: ДОСТАЁТ СЕКРЕТНУЮ ПАЧКУ СИНИХ ТАБЛЕТОК
                    Expanded(
                      child: _buildComicFrame(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Крупный Ваня Баннихоп гордо стоит слева
                            Positioned(
                              bottom: 10, left: 10,
                              child: _buildCharacterImage('assets/images/bunnyhop.png', 80, isPig: false),
                            ),
                            
                            // БОЛЬШАЯ ПОДВИГНУТАЯ КОЖАНАЯ СУМКА-ТОРБА ПО ФОТО (С затяжками и ремнями!)
                                                        // 3. БОЛЬШАЯ ОЧЕНЬ ДЕТАЛИЗИРОВАННАЯ КОЖАНАЯ СУМКА-ТОРБА (С КЛАПАНОМ И ПРЯЖКОЙ)
                            Positioned(
                              bottom: -2, left: 52, // Вплотную к Ване
                              child: SizedBox(
                                width: 50,
                                height: 50,
                                child: Stack(
                                  children: [
                                    // Главное расширяющееся к низу тело сумки из матовой коричневой кожи
                                    Positioned(
                                      bottom: 0, left: 4, right: 4,
                                      child: Container(
                                        width: 42, height: 40,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF8D4F37), // Основной цвет кожи
                                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16), bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
                                          border: Border.all(color: const Color(0xFF4A2711), width: 2.0),
                                        ),
                                      ),
                                    ),
                                    // Тёмные боковые складки мешка для придания объёма
                                    Positioned(
                                      bottom: 2, left: 6, child: Container(width: 3, height: 26, color: const Color(0xFF6E331B)),
                                    ),
                                    Positioned(
                                      bottom: 2, right: 6, child: Container(width: 3, height: 26, color: const Color(0xFF6E331B)),
                                    ),
                                    // Мягкие верхние складки у горловины
                                    Positioned(
                                      top: 10, left: 8, right: 8,
                                      child: Container(
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF6E331B), 
                                          borderRadius: BorderRadius.all(Radius.circular(4)),
                                        ),
                                      ),
                                    ),
                                    // НАКЛАДНОЙ КЛАПАН-КРЫШКА СВЕРХУ (По фото кожаных торб)
                                    Positioned(
                                      top: 13, left: 10, right: 10,
                                      child: Container(
                                        height: 18,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF753A22), // чуть темнее основы
                                          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                          border: Border.all(color: const Color(0xFF4A2711), width: 1.5),
                                        ),
                                      ),
                                    ),
                                    // КРУГЛАЯ ЗОЛОТАЯ ПРЯЖКА-ЗАСТЁЖКА НА КЛАПАНЕ
                                    Positioned(
                                      top: 24, left: 22,
                                      child: Container(
                                        width: 6, height: 6,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFD54F), // золото
                                          shape: BoxShape.circle,
                                          border: Border.all(color: const Color(0xFF4A2711), width: 1.2),
                                        ),
                                      ),
                                    ),
                                    // Свисающий завязанный кожаный шнурок-затяжка
                                    Positioned(
                                      top: 29, left: 24,
                                      child: Container(
                                        width: 2, height: 12,
                                        decoration: BoxDecoration(color: const Color(0xFF4A2711), borderRadius: BorderRadius.circular(1)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                                                        // ИСПРАВЛЕНО: СТИЛЬНЫЙ БЛИСТЕР С ТАБЛЕТКАМИ СТРОГО ПО ФОТОГРАФИИ!
                            Positioned(
                              bottom: 30, left: 60, // Оставили размер, сделали чуть пошире и побольше под 4 капсулы
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFCFD8DC), // Серебристо-металлический цвет блистера
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFF78909C), width: 1.2),
                                  boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 3, offset: Offset(0, 2))],
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    
                                    // 1. Металлическая текстура (сетка пупырышек на фоне по фотографии)
                                    Opacity(
                                      opacity: 0.25,
                                      child: GridView.count(
                                        crossAxisCount: 4,
                                        physics: const NeverScrollableScrollPhysics(),
                                        children: List.generate(16, (i) => Container(
                                          margin: const EdgeInsets.all(0.5),
                                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                        )),
                                      ),
                                    ),

                                    // 2. ЧЕТЫРЕ ОБЪЁМНЫЕ СИНИЕ ТАБЛЕТКИ (Расположены ровно по углам палетки как на фото)
                                    // Топ-левая капсула
                                    Positioned(
                                      top: 3, left: 4,
                                      child: Container(width: 8, height: 11, decoration: BoxDecoration(color: const Color(0xFF29B6F6), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFF0288D1), width: 0.8))),
                                    ),
                                    // Топ-правая капсула
                                    Positioned(
                                      top: 3, right: 4,
                                      child: Container(width: 8, height: 11, decoration: BoxDecoration(color: const Color(0xFF29B6F6), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFF0288D1), width: 0.8))),
                                    ),
                                    // Нижняя-левая капсула
                                    Positioned(
                                      bottom: 3, left: 4,
                                      child: Container(width: 8, height: 11, decoration: BoxDecoration(color: const Color(0xFF29B6F6), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFF0288D1), width: 0.8))),
                                    ),
                                    // Нижняя-правая капсула
                                    Positioned(
                                      bottom: 3, right: 4,
                                      child: Container(width: 8, height: 11, decoration: BoxDecoration(color: const Color(0xFF29B6F6), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFF0288D1), width: 0.8))),
                                    ),

                                    // 3. ПОЛНОЦЕННАЯ НАДПИСЬ "ВИАГРА" СТРОГО ПО ЦЕНТРУ БЛИСТЕРА ПО КРАСАТЕ
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.85),
                                        borderRadius: BorderRadius.circular(2),
                                        border: Border.all(color: const Color(0xFF01579B), width: 0.5),
                                      ),
                                      child: const Text(
                                        "ВИАГРА",
                                        style: TextStyle(fontSize: 5.5, fontWeight: FontWeight.w900, color: Color(0xFF01579B), letterSpacing: 0.2),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),



                            // Опустили слова Вани пониже, строго над его головой
                            Positioned(
                              top: 35, left: 15, width: 115,
                              child: CustomPaint(
                                painter: SpeechBubblePainter(tailXFactor: 0.25, tailGoesUp: false),
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text("А у меня вот это есть", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black), textAlign: TextAlign.center),
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

            // КНОПКА ПОГНАЛИ СНИЗУ КОМИКСА
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9800),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                  elevation: 5,
                ),
                 onPressed: () {
                Navigator.pop(context); // Закрываем экран комикса

                // ИСПРАВЛЕНО: Прямой и честный старт Четвёртого уровня прямо из комикса!
                GameScreen gameScreenInstance = GameScreen();
                gameScreenInstance.gameInstance.currentLevel = 4;
                gameScreenInstance.gameInstance.worldScrollX = 0.0;

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => gameScreenInstance),
                );
              },
              child: const Text("ПОГНАЛИ!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Сборщик персонажей: накладывает лица пацанов на круглые мультяшные тела
  Widget _buildCharacterImage(String assetPath, double size, {required bool isPig}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: isPig ? const Color(0xFF7CB342) : const Color(0xFFE53935), 
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 2),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 3))],
          ),
          child: isPig 
              ? null 
              : const Align(
                  alignment: Alignment.centerRight,
                  child: Icon(Icons.linear_scale_rounded, color: Color(0xFFB71C1C), size: 14), 
                ),
        ),
        ClipOval(
          child: Image.asset(
            assetPath,
            width: size * 0.85,
            height: size * 0.85,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
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
}


                                      


// ПРОДВИНУТЫЙ ВЕКТОРНЫЙ ХУДОЖНИК ОБЛАЧЕК МЫСЛЕЙ (С ХВОСТИКАМИ НАПРАВЛЕННЫМИ ВНИЗ)
class SpeechBubblePainter extends CustomPainter {
  final double tailXFactor; // Смещение хвостика по оси X (от 0.0 до 1.0)
  final bool tailGoesUp;    // Куда смотрит хвост (в нашей схеме false — смотрит строго вниз на героя)
  
  SpeechBubblePainter({required this.tailXFactor, required this.tailGoesUp});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    final borderPaint = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 1.8;

    final path = Path();
    // Овальное тело пузыря слов
    path.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(12)));

    // Рисуем хвостик облачка, который тянется вниз строго к макушке Вани или Максима
    double startX = size.width * tailXFactor;
    path.moveTo(startX - 6, size.height);
    path.lineTo(startX, size.height + 10); // кончик указывает вниз на персонажа
    path.lineTo(startX + 6, size.height);

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

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

// =========================================================================
// ИHТЕРАКТИВНЫЙ 3D-КОМИКС ГЛАВЫ VI: ЛОГОВО ЗЕЛЁHОГО ДОHА МОЛЛЮСКА
// =========================================================================
class Level6ComicScreen extends StatefulWidget {
  const Level6ComicScreen({super.key});

  @override
  State<Level6ComicScreen> createState() => _Level6ComicScreenState();
}

class _Level6ComicScreenState extends State<Level6ComicScreen> {
  int _currentFrame = 1; // 1, 2 или 3 кадр
  int _selectedChoice = 0; // 0 - нет выбора, 1 - жёсткий, 2 - мягкий

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

            // ГЛАВHАЯ СЕТКА: ВСЕ КАДРЫ ИМЕЮТ ПOЛНОЦЕHHЫЙ 3D ЗАДHИЙ ФOН И ДЕТАЛИЗАЦИЮ
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
  // КАДР 1: ВХОД В ЗАМОК, ТЕМHОТА И СКРЫТАЯ УЛЫБКА
  // =========================================================================
  Widget _buildFrame1() {
    return Expanded(
      child: _buildAdvanced3DFrame(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Скрытая мистическая улыбка слежки
            Positioned(
              bottom: 50, right: 30,
              child: Opacity(
                opacity: 0.06, // ЕЩЁ СИЛЬHЕЕ ЗАТЕMНИЛИ (Буквально еле-еле видно!)
                child: CustomPaint(
                  size: const Size(60, 28),
                  painter: _CastleSecretMouthPainter(),
                ),
              ),
            ),
            // ИСПРАВЛЕHО: Трон увеличен за счёт изменения масштаба Positioned
            Positioned(bottom: 22, right: 10, child: Transform.scale(scale: 1.25, child: _buildAdvanced3DThrone())),    
            // ИСПРАВЛЕHО: Отодвинули Тотем Гнева левее к Ване (right: 95 вместо 70)
            Positioned(bottom: 22, right: 95, child: _buildGoldTotemFromPhoto(38)),
            Positioned(bottom: 22, left: 16, child: _buildCharacterBase('assets/images/bunnyhop.png', 56, false)),

            Positioned(
              top: 25, left: 6, right: 6,
              child: CustomPaint(
                painter: SpeechBubblePainter(tailXFactor: 0.25, tailGoesUp: false),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Дон Молюск! Все твои свиньи убиты! Где же ты спрятался, выйди ко мне.",
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
  // КАДР 2: ЭПИЧНЫЙ ВЫХОД ЗЕЛЁHОГО БOССА (ЗАСЛОHЕHИЕ ТРOНА)
  // =========================================================================
  Widget _buildFrame2() {
    return Expanded(
      child: _buildAdvanced3DFrame(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Трон и тотем уходят в глубокую тень позади гигантского осьминога
            Positioned(bottom: 22, right: 15, child: Opacity(opacity: 0.25, child: _buildAdvanced3DThrone())),
            Positioned(bottom: 22, right: 70, child: Opacity(opacity: 0.20, child: _buildGoldTotemFromPhoto(38))),
            
            Positioned(bottom: 22, left: 12, child: _buildCharacterBase('assets/images/bunnyhop.png', 48, false)),
            
            // ВЫХОДИТ УЛЬТРА-ПРОРАБОТАННЫЙ ЗЕЛЁНЫЙ БОСС ДОН МОЛЛЮСК
            Positioned(bottom: 12, right: 8, child: _buildUltraDetailedDonMollusk(72)),

            Positioned(
              top: 15, left: 20, right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(color: Colors.black87, border: Border.all(color: Colors.red.shade900, width: 0.8)),
                child: const Text("ШАГИ ИЗ ТЕМHОТЫ...", style: TextStyle(color: Colors.redAccent, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1.1), textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // КАДР 3: ИНТЕРАКТИВНЫЙ ДИАЛОГ С ВЫБОРОМ РЕПЛИК В РАМОЧКАХ
  // =========================================================================
  Widget _buildFrame3() {
    return Expanded(
      child: _buildAdvanced3DFrame(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(bottom: 22, left: 12, child: _buildCharacterBase('assets/images/bunnyhop.png', 48, false)),
            Positioned(bottom: 12, right: 8, child: _buildUltraDetailedDonMollusk(68)),

            // Черные рамочки выбора Вани
            if (_selectedChoice == 0)
              Positioned(
                top: 15, left: 4, right: 4,
                child: Column(
                  children: [
                    _buildChoiceBox("Вот ты где! Сдавайся чудовище! Твоё время пришло!", 1),
                    const SizedBox(height: 6),
                    _buildChoiceBox("Давай по-хорошему. отдай Древний Тотем Гнева, оставь склады с таблетками в покое и уйди слуга птиц навсегда.", 2),
                  ],
                ),
              ),

            // Моментальные лорные ответы Дона Моллюска в зависимости от выбора
            if (_selectedChoice == 1)
              Positioned(
                top: 25, left: 6, right: 6,
                child: CustomPaint(
                  painter: SpeechBubblePainter(tailXFactor: 0.8, tailGoesUp: false),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Хрю-ха-ха! Сдаться тебе? Жалкая птица! Не на того напал!",
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black, height: 1.15),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),

            if (_selectedChoice == 2)
              Positioned(
                top: 14, left: 4, right: 4,
                child: CustomPaint(
                  painter: SpeechBubblePainter(tailXFactor: 0.8, tailGoesUp: false),
                  child: const Padding(
                    padding: EdgeInsets.all(7.0),
                    child: Text(
                      "По-хорошему? Ты слишком вежлив для птицы, потерявшей способность летать. Этим предметом мы лишили ваш род неба! И ты думаешь, я отдам его просто так?",
                      style: TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold, color: Colors.black, height: 1.12),
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
  // УЛЬТРА-ДЕТАЛИЗИРОВАННЫЙ ЗЕЛЁНЫЙ БОСС ДОН МОЛЛЮСК (МАКСИМАЛЬНАЯ АНАТОМИЯ)
  // =========================================================================
  Widget _buildUltraDetailedDonMollusk(double size) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // 🐙 1. СИHИЕ ЩУПАЛЬЦА С ПРИСОСКАМИ: Распределены веером по кругу из-за спины
          Positioned(bottom: size * 0.16, left: -size * 0.16, child: Transform.rotate(angle: -0.6, child: CustomPaint(size: Size(size * 0.28, size * 0.65), painter: _DetailedTentaclePainter(isLeft: true)))),
          Positioned(top: -size * 0.08, left: -size * 0.10, child: Transform.rotate(angle: -1.2, child: CustomPaint(size: Size(size * 0.24, size * 0.60), painter: _DetailedTentaclePainter(isLeft: true)))),
          Positioned(top: -size * 0.08, right: -size * 0.10, child: Transform.rotate(angle: 1.2, child: CustomPaint(size: Size(size * 0.24, size * 0.60), painter: _DetailedTentaclePainter(isLeft: false)))),
          Positioned(bottom: size * 0.16, right: -size * 0.16, child: Transform.rotate(angle: 0.6, child: CustomPaint(size: Size(size * 0.28, size * 0.65), painter: _DetailedTentaclePainter(isLeft: false)))),

          // 🐷 2. СВИНЫЕ УШКИ: Идеально круглые, растут прямо из головы-круга
          Positioned(top: size * 0.14, left: size * 0.06, child: Container(width: size * 0.16, height: size * 0.16, decoration: BoxDecoration(color: const Color(0xFF689F38), shape: BoxShape.circle, border: Border.all(color: Colors.black, width: 1.6)))),
          Positioned(top: size * 0.14, right: size * 0.06, child: Container(width: size * 0.16, height: size * 0.16, decoration: BoxDecoration(color: const Color(0xFF689F38), shape: BoxShape.circle, border: Border.all(color: Colors.black, width: 1.6)))),

          // 🦀 3. ДВЕ НИЖНИЕ КЛЕШНИ: Прорисованные крабовые щипцы по бокам основания
          Positioned(
            bottom: size * 0.04, left: -size * 0.08,
            child: CustomPaint(size: Size(size * 0.36, size * 0.36), painter: _DetailedCrabClawPainter(isOpen: false)),
          ),
          Positioned(
            bottom: size * 0.04, right: -size * 0.08,
            child: CustomPaint(size: Size(size * 0.36, size * 0.36), painter: _DetailedCrabClawPainter(isOpen: false)),
          ),

          // 🦀 4. ВЕРХНЯЯ КЛЕШНЯ: Сидит грозно прямо на макушке по центру головы
          Positioned(
            top: -size * 0.15, left: size * 0.32,
            child: CustomPaint(size: Size(size * 0.36, size * 0.36), painter: _DetailedCrabClawPainter(isOpen: true)),
          ),

          // =========================================================================
          // 🩸 5. ИСПРАВЛЕНО: ЧЁТКИЙ ОСНОВНОЙ СТВОЛ (РОВНО ПОЛОВИНА ЛАПЫ) И ПЯТНО КРОВИ
          // =========================================================================
          Positioned(
            top: size * 0.32, left: -size * 0.07,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Обрубок ствола лапы (половина от основания)
                Container(
                  width: size * 0.12, height: size * 0.14,
                  decoration: BoxDecoration(
                    color: const Color(0xFF33691E), // Темно-зеленое мясо лапы
                    border: Border.all(color: Colors.black, width: 1.6),
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), bottomLeft: Radius.circular(4)),
                  ),
                  child: Center(
                    // Торчащая белая кость внутри раны для детализации
                    child: Container(width: 4, height: 6, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(1))),
                  ),
                ),
                // Кровавое пятно, накладывающееся прямо на зелёный круг тела Босса
                Positioned(
                  right: -5, top: 2,
                  child: Container(
                    width: 11, height: 11,
                    decoration: const BoxDecoration(
                      color: Color(0xFFC62828), // Пятно крови синдиката
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 🟢 6. ЦЕНТРАЛЬНОЕ ЗЕЛИКОВОЕ ТЕЛО БОССА (Перекрывает корни всех лап)
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

    // Плавный S-образный анатомический изгиб щупальца осьминога
    final path = Path();
    path.moveTo(w * 0.5, h);
    path.cubicTo(isLeft ? -w * 0.2 : w * 1.2, h * 0.65, isLeft ? w * 0.2 : w * 0.8, h * 0.25, w * 0.5, 0);
    path.lineTo(w * 0.8, 0);
    path.cubicTo(isLeft ? w * 0.5 : w * 0.5, h * 0.25, isLeft ? w * 0.2 : w * 0.8, h * 0.65, w * 0.8, h);
    path.close();

    canvas.drawPath(path, tentaclePaint);
    canvas.drawPath(path, strokePaint);

    // ПРОРАБОТКА: Расставляем 6 круглых присосок с отверстиями по внешнему контуру лапы
    for (int i = 1; i <= 6; i++) {
      double factor = i * 0.15;
      double cx = isLeft ? w * (0.28 - factor * 0.1) : w * (0.72 + factor * 0.1);
      double cy = h * factor;
      double radius = 3.2 - (i * 0.2); // Сужаются к кончику лапы
      
      if (radius > 1.0) {
        canvas.drawCircle(Offset(cx, cy), radius, suctionPaint);
        canvas.drawCircle(Offset(cx, cy), radius, strokePaint..strokeWidth = 0.5);
        // Внутреннее отверстие присоски для узнаваемости текстуры осьминога
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

    // 1. Рисуем прочный сустав-основание лапы (локоть краба)
    final jointPath = Path()
      ..moveTo(w * 0.4, h)
      ..lineTo(w * 0.3, h * 0.6)
      ..lineTo(w * 0.7, h * 0.6)
      ..lineTo(w * 0.6, h)
      ..close();
    canvas.drawPath(jointPath, clawPaint);
    canvas.drawPath(jointPath, strokePaint);

    // 2. Рисуем неподвижный ПРАВЫЙ зажимающий палец клешни с зубцами
    final mainClawPath = Path()
      ..moveTo(w * 0.3, h * 0.6)
      ..cubicTo(w * 0.05, h * 0.4, w * 0.1, 0, w * 0.5, 0) // Острый кончик лапы
      ..lineTo(w * 0.45, h * 0.2)
      ..cubicTo(w * 0.3, h * 0.3, w * 0.35, h * 0.5, w * 0.7, h * 0.6)
      ..close();
    canvas.drawPath(mainClawPath, clawPaint);
    canvas.drawPath(mainClawPath, strokePaint);

    // 3. Рисуем подвижный ЛЕВЫЙ зажимающий палец клешни (открывается по флагу)
    final movingFingerPath = Path();
    if (isOpen) {
      // Широко раскрытый зловещий зажим щипцов лапы
      movingFingerPath.moveTo(w * 0.45, h * 0.25);
      movingFingerPath.cubicTo(w * 0.75, h * 0.1, w * 0.95, h * 0.2, w * 0.85, h * 0.5);
      movingFingerPath.lineTo(w * 0.6, h * 0.45);
    } else {
      // Смыкающийся плотный зажим
      movingFingerPath.moveTo(w * 0.42, h * 0.15);
      movingFingerPath.cubicTo(w * 0.65, h * 0.2, w * 0.75, h * 0.35, w * 0.65, h * 0.55);
      movingFingerPath.lineTo(w * 0.52, h * 0.42);
    }
    movingFingerPath.close();
    canvas.drawPath(movingFingerPath, clawPaint);
    canvas.drawPath(movingFingerPath, strokePaint);

    // 4. ТЕКСТУРА: Вырезаем ровно 2 мелких острых зубца на внутренних гранях щипцов
    final toothPaint = Paint()..color = Colors.white70..style = PaintingStyle.fill;
    canvas.drawTriangle(Offset(w * 0.38, h * 0.25), Offset(w * 0.34, h * 0.28), Offset(w * 0.42, h * 0.29), toothPaint);
    canvas.drawTriangle(Offset(w * 0.46, h * 0.32), Offset(w * 0.42, h * 0.35), Offset(w * 0.48, h * 0.36), toothPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

  // =========================================================================
  // МАКСИМАЛЬНО ДЕТАЛИЗИРОВАННЫЙ ЗАДНИЙ ФОН: 3D ПЛИТКА И ГОТИЧЕСКИЕ СВОДЫ КРЫШИ
  // =========================================================================
  Widget _buildAdvanced3DFrame({required Widget child}) {
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
            children: [
              // Тёмный гранитный фон стен тронного зала
              Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF14141E), Color(0xFF06060A)])))),
              
              // 📐 1. РЕЛЬЕФНАЯ ГОТИЧЕСКАЯ КРЫША ЗАМКА: Балки сходятся в 3D перспективу
              Positioned(top: 0, left: 0, right: 0, child: CustomPaint(size: const Size(double.infinity, 35), painter: _CastleCeiling3DPainter())),

              // 🧱 2. РЕЛЬЕФНАЯ КАМЕННАЯ ПЛИТКА НА ПОЛУ: Швы расходятся веером для глубины
              Positioned(bottom: 0, left: 0, right: 0, child: CustomPaint(size: const Size(double.infinity, 24), painter: _CastleFloorTilesPainter())),
              
              child,
            ],
          ),
        ),
      ),
    );
  }

  // Интерактивный кубик выбора фраз
  Widget _buildChoiceBox(String text, int choiceId) {
    return GestureDetector(
      onTap: () => setState(() => _selectedChoice = choiceId),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A0F),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.red.shade900.withOpacity(0.5), width: 1.2),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 7.2, fontWeight: FontWeight.w600, height: 1.1), textAlign: TextAlign.center),
      ),
    );
  }

  Widget _buildNavigationButton() {
    if (_currentFrame == 3 && _selectedChoice == 0) {
      return const SizedBox(height: 46, child: Center(child: Text("ВЫБЕРИТЕ ОТВЕТ ВАHЯ ДЛЯ ПРОДОЛЖЕHИЯ СЮЖЕTA", style: TextStyle(color: Colors.redAccent, fontSize: 9.5, fontWeight: FontWeight.bold, letterSpacing: 1.1))));
    }
    return Container(
      width: double.infinity, constraints: const BoxConstraints(maxWidth: 240), height: 46,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF37474F), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        onPressed: () {
          if (_currentFrame < 3) {
            setState(() => _currentFrame++);
          } else {
            if (_selectedChoice == 1) {
              // Переход на вторую страницу плохой концовки
            } else if (_selectedChoice == 2) {
              // Переход на вторую страницу хорошего пути к битве
            }
          }
        },
        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text("ДАЛЬШЕ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)), SizedBox(width: 8), Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.white)]),
      ),
    );
  }

  // Вспомогательные лорные элементы
  Widget _buildCastleToner() => Container(width: 35, height: 50, decoration: const BoxDecoration(color: Color(0xFF25252D), borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8))));
  
  Widget _buildAdvanced3DThrone() {
    return SizedBox(
      width: 40, height: 58,
      child: Stack(
        children: [
          Positioned(bottom: 4, left: 4, right: 4, child: Container(height: 54, decoration: BoxDecoration(color: const Color(0xFF3E2723), borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)), border: Border.all(color: const Color(0xFF1A0C00), width: 1.8)))),
                    // Левый подлокотник (ИСПРАВЛЕHО: цвет перенесён внутрь decoration)
          Positioned(
            bottom: 4, left: 0, 
            child: Container(
              width: 5, height: 26, 
              decoration: BoxDecoration(
                color: const Color(0xFF4E342E),
                border: Border.all(color: Colors.black, width: 0.8),
              ),
            ),
          ),
          // Правый подлокотник (ИСПРАВЛЕHО: цвет перенесён внутрь decoration)
          Positioned(
            bottom: 4, right: 0, 
            child: Container(
              width: 5, height: 26, 
              decoration: BoxDecoration(
                color: const Color(0xFF4E342E),
                border: Border.all(color: Colors.black, width: 0.8),
              ),
            ),
          ),
          Positioned(bottom: 6, left: 3, right: 3, child: Container(height: 14, color: const Color(0xFF4E342E))),
          
          // 🔴 МЯГКАЯ КРАСHАЯ ПОДУШКА-ПОДЛОЖКА НА СИДЕНЬЕ
          Positioned(bottom: 14, left: 4, right: 4, child: Container(height: 6, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFD32F2F), Color(0xFFFF5252), Color(0xFFB71C1C)]), borderRadius: BorderRadius.circular(2)))),
        ],
      ),
    );
  }

    Widget _buildGoldTotemFromPhoto(double size) {
    return SizedBox(
      width: size, 
      height: size * 1.1,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Чёрный квадратный постамент-основание по фотографии
          Positioned(
            bottom: 0, 
            child: Container(
              width: size * 0.75, 
              height: size * 0.16, 
              decoration: BoxDecoration(
                color: const Color(0xFF111116), 
                borderRadius: BorderRadius.circular(2), 
                border: Border.all(color: Colors.black, width: 1.5),
              ),
            ),
          ),
          // Стройная золотая ножка статуи
          Positioned(
            bottom: size * 0.14, 
            child: Container(
              width: size * 0.14, 
              height: size * 0.32, 
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFE5A632), Color(0xFFFFD54F), Color(0xFFB57C1E)],
                ),
              ),
            ),
          ),
          // Величественные раскинутые золотые крылья орла
          Positioned(
            bottom: size * 0.38, 
            child: CustomPaint(
              size: Size(size * 1.05, size * 0.65), 
              painter: _GoldWingsPainter(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterBase(String assetPath, double size, bool isPig) {
    return Container(
      width: size, 
      height: size, 
      decoration: BoxDecoration(
        color: const Color(0xFFE53935), 
        shape: BoxShape.circle, 
        border: Border.all(color: Colors.black, width: 2.0),
      ), 
      child: ClipOval(
        child: Image.asset(assetPath, fit: BoxFit.cover),
      ),
    );
  }
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

    // Расставляем четкие круглые присоски по ходу изгиба щупальца
    for (int i = 1; i < 5; i++) {
      double hFactor = i * 0.22;
      double sx = isLeft ? size.width * 0.25 : size.width * 0.75;
      canvas.drawCircle(Offset(sx, size.height * hFactor), 3.0, suctionPaint);
      canvas.drawCircle(Offset(sx, size.height * hFactor), 3.0, strokePaint..strokeWidth = 0.5);
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

// =========================================================================
// КЛАССЫ РЕЛЬЕФНЫХ ХУДОЖНИКОВ ДЛЯ 3D ОКРУЖЕНИЯ ТРОННОГО ЗАЛА
// =========================================================================

class _GoldWingsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final goldPaint = Paint()
      // ИСПРАВЛЕHО: Идеальное сияющее золото без коричневой грязи!
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFF176), Color(0xFFFFD54F), Color(0xFFFFC107), Color(0xFFFFD54F)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()..color = const Color(0xFF795548)..style = PaintingStyle.stroke..strokeWidth = 1.0;

    final path = Path();
    path.moveTo(size.width * 0.5, size.height);
    path.cubicTo(size.width * 0.35, size.height * 0.6, size.width * 0.15, size.height * 0.3, 0, 0); 
    path.cubicTo(size.width * 0.18, size.height * 0.4, size.width * 0.38, size.height * 0.65, size.width * 0.5, size.height * 0.45);
    path.cubicTo(size.width * 0.62, size.height * 0.65, size.width * 0.82, size.height * 0.4, size.width * 1.0, 0); 
    path.cubicTo(size.width * 0.85, size.height * 0.3, size.width * 0.65, size.height * 0.6, size.width * 0.5, size.height);
    path.close();

    canvas.drawPath(path, goldPaint);
    canvas.drawPath(path, strokePaint);

    for (int i = 1; i < 6; i++) {
      double f = i * 0.08;
      canvas.drawLine(Offset(size.width * (0.5 - f), size.height * (0.5 + f)), Offset(size.width * (0.1 + f), size.height * (0.15 + f)), strokePaint);
      canvas.drawLine(Offset(size.width * (0.5 + f), size.height * (0.5 + f)), Offset(size.width * (0.9 - f), size.height * (0.15 + f)), strokePaint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ИСПРАВЛЕHО: 3D-плитка пола уходит глубоко вдаль и вытянута вперёд!
class _CastleFloorTilesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final tilePaint = Paint()..color = const Color(0xFF1E1E24)..style = PaintingStyle.fill;
    final linePaint = Paint()..color = const Color(0xFF111114)..style = PaintingStyle.stroke..strokeWidth = 1.6;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), tilePaint);

    // Многочисленные горизонтальные стыки плит, сужающиеся к горизонту (вверх)
    for (int i = 0; i < 5; i++) {
      double hY = size.height * (0.2 + (i * i * 0.8 / 16));
      canvas.drawLine(Offset(0, hY), Offset(size.width, hY), linePaint);
    }

    // Вертикальные швы плит, расходящиеся экстремальным 3D-веером вперёд
    int linesCount = 12; // Сделали плитку более частой и детальной
    for (int i = 0; i <= linesCount; i++) {
      double topX = size.width * (0.3 + (i * 0.4 / linesCount)); // Схождение вдалеке
      double bottomX = size.width * (i / linesCount);            // Расширение вблизи
      canvas.drawLine(Offset(topX, 0), Offset(bottomX, size.height), linePaint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ИСПРАВЛЕHО: Готическая крыша со сводами и окнами-бойницами на стыке
class _CastleCeiling3DPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final ceilPaint = Paint()..color = const Color(0xFF15151D)..style = PaintingStyle.fill;
    final beamPaint = Paint()..color = const Color(0xFF09090D)..style = PaintingStyle.stroke..strokeWidth = 2.2;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), ceilPaint);

    // Массивные балки перекрытия, сходящиеся к центру
    for (int i = 0; i <= 6; i++) {
      double startX = size.width * (i / 6);
      canvas.drawLine(Offset(startX, 0), Offset(size.width * 0.5, size.height), beamPaint);
    }
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), beamPaint);

    // ДЕКОР: Отрисовываем маленькие узкие окна-бойницы замка на линии горизонта (внизу крыши)
    final windowPaint = Paint()..color = const Color(0xFF09090E)..style = PaintingStyle.fill;
    double winW = 6;
    double winH = 14;
    for (int i = 1; i < 4; i++) {
      double winX = size.width * (0.25 * i) - (winW / 2);
      Rect winRect = Rect.fromLTWH(winX, size.height - winH - 2, winW, winH);
      canvas.drawRRect(RRect.fromRectAndRadius(winRect, const Radius.circular(2)), windowPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(winRect, const Radius.circular(2)), beamPaint..strokeWidth = 1.0);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =========================================================================
// ИСПРАВЛЕНО: СКРЫТЫЙ СЛЕДЯЩИЙ ОСКАЛ (ДВА ГЛАЗА-РОМБА + ПРОРАБОТАННАЯ ДУГА ЛИЦА)
// =========================================================================
class _CastleSecretMouthPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final whitePaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    final linePaint = Paint()..color = Colors.white.withOpacity(0.4)..style = PaintingStyle.stroke..strokeWidth = 1.2;

    // 1. ДВА ГЛАЗА-РОМБА ВЕРХНЕЙ СЛЕДКИ
    // Левый глаз
    final leftEye = Path()
      ..moveTo(size.width * 0.20, 0)
      ..lineTo(size.width * 0.32, size.height * 0.2)
      ..lineTo(size.width * 0.24, size.height * 0.45)
      ..lineTo(size.width * 0.12, size.height * 0.2)
      ..close();
    canvas.drawPath(leftEye, whitePaint);

    // Правый глаз
    final rightEye = Path()
      ..moveTo(size.width * 0.80, 0)
      ..lineTo(size.width * 0.88, size.height * 0.2)
      ..lineTo(size.width * 0.76, size.height * 0.45)
      ..lineTo(size.width * 0.68, size.height * 0.2)
      ..close();
    canvas.drawPath(rightEye, whitePaint);

    // 2. ПРОРАБОТАННАЯ ОКРУГЛАЯ ДУГА ЛИЦА ЗЛОДЕЯ (Тонкий контур подбородка босса)
    final faceOutline = Path()
      ..moveTo(size.width * 0.02, size.height * 0.1)
      ..cubicTo(size.width * 0.1, size.height * 0.95, size.width * 0.9, size.height * 0.95, size.width * 0.98, size.height * 0.1);
    canvas.drawPath(faceOutline, linePaint);

    // 3. ПИКСЕЛЬНАЯ УЛЫБКА ИЗ ЗУБОВ-КВАДРАТИКОВ ПОВАЛЕННАЯ НА ДУГУ
    int teethCount = 7;
    for (int i = 0; i < teethCount; i++) {
      double offsetX = (size.width * 0.08) + (i * (size.width * 0.84 / (teethCount - 1)));
      double progress = i / (teethCount - 1);
      double offsetY = size.height * 0.62 + (sin(progress * pi) * (size.height * 0.15));
      
      canvas.drawRect(Rect.fromLTWH(offsetX, offsetY, 1.8, 1.8), whitePaint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
