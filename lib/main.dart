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
    ]),
    builder: (context, snapshot) {
      final stars = snapshot.data ?? [];
      
      // Условия хардкорного открытия уровней (минимум 2 звезды за прошлый)
      final bool isLvl2Open = stars[0] >= 2;
      final bool isLvl3Open = stars[1] >= 2;
      final bool isLvl4Open = stars[2] >= 2;
      final bool isLvl5Open = stars[3] >= 2;

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

          // СТРАНИЦА 2: УРОВНИ 4 И 5
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLevelCard('4', isLvl4Open), 
              const SizedBox(width: 30),
              _buildLevelCard('5', isLvl5Open && false), // 5 уровень заблокирован намертво по ТЗ
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
                          desc: "Пройди все 4 уровня\nна максимальные 3 звезды",
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
                            
                            // Опустили большой объём текста ниже, прямо к головам персонажей!
                            Positioned(
                              top: 28, left: 6, right: 6,
                              child: CustomPaint(
                                painter: SpeechBubblePainter(tailXFactor: 0.5, tailGoesUp: false),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                  child: Text(
                                    "Баннихоп уже достал, постоянно ломает наши дома. А давай-ка его проучим! Сделаем дом из бронированного стекла. Тогда он точно не сможет его сломать!",
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
                                  child: Text("Ах проучить меня решили?", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black), textAlign: TextAlign.center),
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
                  child: Text("Шериф, беда! На окраинах завелись зелёные свиньи под предводительством Дона Молюска! Они грабят наши склады с виагрой!", style: TextStyle(fontSize: 8.2, fontWeight: FontWeight.bold, color: Colors.black, height: 1.15), textAlign: TextAlign.center),
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
                  child: Text("Так... Следы ведут на этот луг. Ошмётки упаковок повсюду. Свиньи где-то рядом...", style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Colors.black, height: 1.15), textAlign: TextAlign.center),
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
            // ЗАМЕНИТЬ ТОЛЬКО БЛОК РОГАТКИ ВНУТРИ _buildPage2Frame2 НА ЭТОТ:
// 1. Рукоять рогатки (вертикальный ствол)
Positioned(bottom: 20, left: 95, child: Container(width: 8, height: 26, decoration: BoxDecoration(color: const Color(0xFF4E342E), borderRadius: BorderRadius.circular(2)))),
// 2. Левый рожок (прижат вплотную к рукояти на высоте bottom: 42)
Positioned(bottom: 42, left: 88, child: Transform.rotate(angle: -0.4, child: Container(width: 6, height: 16, decoration: BoxDecoration(color: const Color(0xFF4E342E), borderRadius: BorderRadius.circular(1.5))))),
// 3. Правый рожок (прижат вплотную к рукояти на высоте bottom: 42)
Positioned(bottom: 42, left: 104, child: Transform.rotate(angle: 0.4, child: Container(width: 6, height: 16, decoration: BoxDecoration(color: const Color(0xFF4E342E), borderRadius: BorderRadius.circular(1.5))))),
// 4. Красная толстая нитка-резинка (ровно на вершинах рожков)
Positioned(bottom: 54, left: 86, child: Container(width: 26, height: 4, decoration: BoxDecoration(color: const Color(0xFFD32F2F), borderRadius: BorderRadius.circular(1)))),


            // Ваня в ШЛЯПЕ подходит слева (Шляпа полностью вшита в код кадра)
            Positioned(
              bottom: 10, left: 6,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    // ЗАМЕНИТЬ ТОЛЬКО ЭТУ СТРОКУ В _buildPage2Frame2:
                   child: _buildCharacterSp('assets/images/bunnyhop.png', 52, isPig: false),
                  ),
                  Positioned(
                    top: 0,
                    child: SizedBox(
                      width: 55,
                      height: 25,
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
                              decoration: BoxDecoration(color: const Color(0xFF6D4C41), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFF4E342E), width: 0.8)),
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
                                Container(
                                  width: 4, height: 4, 
                                  decoration: const BoxDecoration(color: Color(0xFFFFFFFF), shape: BoxShape.circle),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Две свиньи Максима сидят у рогатки справа
            Positioned(bottom: 10, right: 38, child: _buildCharacterSp('assets/images/maksim.png', 44, isPig: true)),
            Positioned(bottom: 10, right: 8, child: _buildCharacterSp('assets/images/maksim.png', 44, isPig: true)),

            // Блистеры виагры на кадре (1 в траве, 2-й лежит строго у ног свиньи)
            Positioned(bottom: 6, left: 40, child: Transform.rotate(angle: 0.2, child: _buildBlisterWidget())),
            Positioned(bottom: 4, right: 46, child: Transform.rotate(angle: -0.1, child: _buildBlisterWidget())), 

            // Два облака диалогов: Сначала Ваня, потом Свинья
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
            // Ответ Вани под облаком свиньи
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

// 2. ДВЕ ДЛИННЫЕ КРАСНЫЕ НИТИ РЕЗИНКИ (Тянутся от рожков вправо НАЛЕВО к оттянутому Ване)
// Верхняя нить от левого рожка к Ване
Positioned(bottom: 43, left: 40, child: Transform.rotate(angle: 0.20, child: Container(width: 76, height: 4, color: const Color(0xFFD32F2F)))),
// Нижняя нить от правого рожка к Ване
Positioned(bottom: 40, left: 40, child: Transform.rotate(angle: 0.16, child: Container(width: 88, height: 4, color: const Color(0xFFD32F2F)))),

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




