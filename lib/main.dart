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

                  // СВАЙП ПАНЕЛЬ С КАРТОЧКАМИ УРОВНЕЙ
                  SizedBox(
                    height: 150, 
                    child: PageView(
                      controller: _pageController,
                      physics: const BouncingScrollPhysics(),
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      children: [
                        
                        // СТРАНИЦА 1: УРОВНИ 1, 2, 3
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildLevelCard('1', true),
                            const SizedBox(width: 24), 
                            _buildLevelCard('2', true),
                            const SizedBox(width: 24),
                            _buildLevelCard('3', true),
                          ],
                        ),

                        // СТРАНИЦА 2: ИСПРАВЛЕНО! УРОВНИ 4 И 5 ОРАНЖЕВЫЕ СО ЗВЕЗДАМИ, НО ЗАБЛОКИРОВАННЫЕ
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildLevelCard('4', false), // false — пока выключает запуск физики
                            const SizedBox(width: 30),
                            _buildLevelCard('5', false), 
                          ],
                        ),
                      ],
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

  // УНИВЕРСАЛЬНЫЙ МЕТОД КАРТОЧЕК ДЛЯ ВСЕХ 5 УРОВНЕЙ
  Widget _buildLevelCard(String levelNumber, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 85,
          height: 85,
          decoration: BoxDecoration(
            color: const Color(0xFFFFCC80), 
            borderRadius: BorderRadius.circular(22), 
            border: Border.all(color: const Color(0xFFE65100), width: 4), 
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 5))],
          ),
          child: ElevatedButton(
            onPressed: () {
              // Если игрок нажал на 4 уровень — запускаем наш угарный сюжетный комикс!
              if (levelNumber == '4') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ComicIntroScreen()),
                );
                return;
              }
              
              if (!isActive) return; // 5 уровень пока заблокирован
              
              GameScreen gameScreenInstance = GameScreen();
              int targetLevel = int.tryParse(levelNumber) ?? 1;
              gameScreenInstance.gameInstance.currentLevel = targetLevel;
              gameScreenInstance.gameInstance.worldScrollX = 0.0;

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => gameScreenInstance),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            child: Text(
              levelNumber,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: Color(0xFFE65100), 
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
               
        // Звёзды теперь честно горят под всеми 5 карточками!
        FutureBuilder<int>(
          future: SharedPreferences.getInstance().then((prefs) {
            return prefs.getInt('level_${levelNumber}_stars') ?? 0;
          }),
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
    bool triumph = (s1 + s2 + s3) >= 9;

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
                                                    desc: "Пройди все 3 уровня\nна максимальные 3 звезды",
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
// КЛАСС МЕМНОГО СЮЖЕТНОГО КОМИКСА ИЗ 3-Х КАРТИНОК НА ВЕСЬ ЭКРАН
// =========================================================================
class ComicIntroScreen extends StatelessWidget {
  const ComicIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A24), // Стильный тёмный фон вокруг комикса
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            const Text(
              "ПРЕДЫСТОРИЯ УРОВНЯ 4",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.amber, letterSpacing: 1.5),
            ),
            const SizedBox(height: 12),

            // ГЛАВНАЯ СЕТКА КОМИКСА: 3 кадра, каждый занимает ровно 1/3 ширины экрана
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // КАДР 1: Заговор Максимов
                    Expanded(
                      child: _buildComicFrame(
                        child: Stack(
                          children: [
                            // Луг и холмы
                            Positioned(bottom: 0, left: 0, right: 0, child: Container(height: 45, color: const Color(0xFF4CAF50))),
                            // Три свиньи Максима (Используем иконки для гарантированной сборки)
                            const Positioned(bottom: 25, left: 15, child: Icon(Icons.gite_rounded, color: Colors.pink, size: 24)),
                            const Positioned(bottom: 12, left: 35, child: Icon(Icons.gite_rounded, color: Colors.pink, size: 28)),
                            const Positioned(bottom: 20, left: 60, child: Icon(Icons.gite_rounded, color: Colors.pink, size: 22)),
                            
                            // Облачко со словами по ТЗ (Хвостик указывает влево-вниз к свиньям)
                            Positioned(
                              top: 8, left: 4, right: 4,
                              child: CustomPaint(
                                painter: SpeechBubblePainter(isLeftTail: true),
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "Баннихоп достал ломать дома. Проучим его! Сделаем дом из бронированного стекла. Тогда он точно не сможет его сломать!",
                                    style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black, height: 1.1),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // КАДР 2: Подслушивание
                    Expanded(
                      child: _buildComicFrame(
                        child: Stack(
                          children: [
                            Positioned(bottom: 0, left: 0, right: 0, child: Container(height: 45, color: const Color(0xFF4CAF50))),
                            // Баннихоп повернут к нам слева
                            const Positioned(bottom: 15, left: 15, child: Icon(Icons.cruelty_free_rounded, color: Colors.amber, size: 32)),
                            // Три свиньи справа
                            const Positioned(bottom: 15, right: 15, child: Icon(Icons.gite_rounded, color: Colors.pink, size: 24)),

                            // Ругань свиней (Хвостик вправо к свиньям)
                            Positioned(
                              top: 12, right: 6, width: 65,
                              child: CustomPaint(
                                painter: SpeechBubblePainter(isLeftTail: false),
                                child: const Padding(
                                  padding: EdgeInsets.all(6.0),
                                  child: Text("!$?!%", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.red), textAlign: TextAlign.center),
                                ),
                              ),
                            ),

                            // Ответ Баннихопа (Хвостик влево к кролику)
                            Positioned(
                              bottom: 45, left: 6, width: 85,
                              child: CustomPaint(
                                painter: SpeechBubblePainter(isLeftTail: true),
                                child: const Padding(
                                  padding: EdgeInsets.all(6.0),
                                  child: Text("Ах проучить меня решили?", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black), textAlign: TextAlign.center),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // КАДР 3: Секретное оружие (Таблетки)
                    Expanded(
                      child: _buildComicFrame(
                        child: Stack(
                          children: [
                            Positioned(bottom: 0, left: 0, right: 0, child: Container(height: 45, color: const Color(0xFF4CAF50))),
                            // Баннихоп гордо стоит слева
                            const Positioned(bottom: 15, left: 10, child: Icon(Icons.cruelty_free_rounded, color: Colors.amber, size: 32)),
                            
                            // ВЕКТОРНАЯ КОРИЧНЕВАЯ СУМКА-МЕШОК ПЕРЕД НИМ
                            Positioned(
                              bottom: 12, right: 25,
                              child: Container(
                                width: 34, height: 26,
                                decoration: BoxDecoration(
                                  color: Colors.brown.shade700,
                                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12), bottomLeft: Radius.circular(6), bottomRight: Radius.circular(6)),
                                  border: Border.all(color: Colors.brown.shade900, width: 1.5),
                                ),
                                child: Stack(
                                  alignment: Alignment.topCenter,
                                  children: [
                                    // Завязка на мешке
                                    Container(width: 14, height: 3, color: Colors.amber.shade300),
                                  ],
                                ),
                              ),
                            ),

                            // ПАЧКА ТАБЛЕТОК НАВЕРХУ СУМКИ
                            Positioned(
                              bottom: 35, right: 28,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                decoration: BoxDecoration(color: Colors.blue.shade100, border: Border.all(color: Colors.blue.shade700, width: 1), borderRadius: BorderRadius.circular(2)),
                                child: const Text("ВИАГРА", style: TextStyle(fontSize: 5, fontWeight: FontWeight.bold, color: Colors.blue), textAlign: TextAlign.center),
                              ),
                            ),

                            // Слова Баннихопа
                            Positioned(
                              top: 15, left: 10, right: 10,
                              child: CustomPaint(
                                painter: SpeechBubblePainter(isLeftTail: true),
                                child: const Padding(
                                  padding: EdgeInsets.all(6.0),
                                  child: Text("А у меня вот это есть", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black), textAlign: TextAlign.center),
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
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                ),
                onPressed: () {
                  Navigator.pop(context); // Возвращает в меню уровней
                },
                child: const Text("ПОГНАЛИ!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

    Widget _buildComicFrame({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD), // Приятный небесный фон внутри кадра
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF000000), width: 3.5), // Жирная обводка рамок комикса
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 6, offset: Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Рисуем задний план: Облачка на небе кадра
            Positioned(top: 35, left: 10, child: Icon(Icons.cloud_queue_rounded, size: 24, color: Colors.white.withOpacity(0.4))),
            Positioned(top: 20, right: 15, child: Icon(Icons.cloud_queue_rounded, size: 30, color: Colors.white.withOpacity(0.4))),
            child,
          ],
        ),
      ),
    );
  }
}

// ВЕКТОРНЫЙ РИСОВАЛЬЩИК КЛАССИЧЕСКИХ РЕЧЕВЫХ ПУЗЫРЕЙ С ХВОСТИКАМИ ИЗ ТВОЕГО РЕФЕРЕНСА
class SpeechBubblePainter extends CustomPainter {
  final bool isLeftTail; // Куда направлен хвостик облачка — влево или вправо
  SpeechBubblePainter({required this.isLeftTail});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    final borderPaint = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 1.8;

    final path = Path();
    // Рисуем основное скругленное овальное облако рта
    path.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(10)));

    // Дорисовываем острый хвостик речевого облачка чётко по твоему фото-референсу!
    if (isLeftTail) {
      path.moveTo(size.width * 0.2, size.height);
      path.lineTo(size.width * 0.1, size.height + 8); // кончик хвостика уходит вниз-влево
      path.lineTo(size.width * 0.3, size.height);
    } else {
      path.moveTo(size.width * 0.8, size.height);
      path.lineTo(size.width * 0.9, size.height + 8); // кончик хвостика уходит вниз-вправо
      path.lineTo(size.width * 0.7, size.height);
    }

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


