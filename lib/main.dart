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
                      _buildMenuButton('ДОСТИЖЕНИЯ', Icons.emoji_events_rounded, Colors.amber, () {}),
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

// ЭКРАН ВЫБОРА УРОВНЕЙ
class LevelsScreen extends StatelessWidget {
  const LevelsScreen({super.key});

    Future<int> _loadLevel1Stars() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('level_1_stars') ?? 0; 
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

          // 2. Декорации: Мультяшные круглые облака на небе
          Positioned(
            top: 20,
            left: 50,
            child: Icon(Icons.cloud_rounded, size: 80, color: Colors.white.withValues(alpha: 0.6)),
          ),
          Positioned(
            top: 40,
            right: 80,
            child: Icon(Icons.cloud_rounded, size: 100, color: Colors.white.withValues(alpha: 0.5)),
          ),

          // 3. Декорации: Мультяшные зеленые холмы и трава внизу экрана
          Positioned(
            bottom: -30,
            left: -50,
            right: -50,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF81C784), // Светло-зеленый холм
                borderRadius: const BorderRadius.all(Radius.elliptical(500, 100)),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -20,
            right: -20,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50), // Насыщенная зеленая трава ближе к нам
                borderRadius: const BorderRadius.all(Radius.elliptical(600, 100)),
              ),
            ),
          ),

          // 4. Основной игровой интерфейс поверх декораций
          SafeArea(
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 15),
                  
                  // Верхняя плашка с мультяшной надписью
                  const Text(
                    'УРОВНИ 1-3',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFF57C00), // Сочный оранжевый
                      letterSpacing: 2,
                      shadows: [
                        Shadow(offset: Offset(2.0, 2.0), blurRadius: 2.0, color: Colors.black26),
                      ],
                    ),
                  ),
                  
                  const Spacer(),

                  // Ряд с большими мультяшными кнопками уровней
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLevelCard(context, '1'),
                      const SizedBox(width: 30), // Пробел между квадратами уровней
                      _buildLevelCard(context, '2'),
                      const SizedBox(width: 30),
                      _buildLevelCard(context, '3'),
                    ],
                  ),

                  const Spacer(),

                  // Мультяшная круглая кнопка Назад в левом нижнем углу
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 3)),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, size: 36, color: Colors.white),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: const EdgeInsets.all(12),
                          ),
                          onPressed: () => Navigator.pop(context),
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

  // Вспомогательный метод для создания большой карточки уровня со звездами
  Widget _buildLevelCard(BuildContext context, String levelNumber) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Большой скругленный квадрат уровня
        Container(
          width: 85,
          height: 85,
          decoration: BoxDecoration(
            color: const Color(0xFFFFCC80), // Приятный мультяшный желто-оранжевый цвет
            borderRadius: BorderRadius.circular(22), // Сильное скругление для мультяшности
            border: Border.all(color: const Color(0xFFE65100), width: 4), // Толстая темная обводка
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 5)), // Объемная тень под кубиком
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
  // Если игрок нажимает на Уровень 1 — запускаем экран нашей игры
  if (levelNumber == '1') {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GameScreen()),
    );
  }
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
                color: Color(0xFFE65100), // Цвет цифры совпадает с обводкой
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        
                const SizedBox(height: 8),
        
        // ИСПРАВЛЕНО: Звёзды теперь динамически зажигаются жёлтым из памяти телефона для Уровня 1!
        FutureBuilder<int>(
          future: SharedPreferences.getInstance().then((prefs) {
            // Если это карточка первого уровня, достаем его рекорд. Для остальных уровней пока возвращаем 0.
            if (levelNumber == '1') {
              return prefs.getInt('level_1_stars') ?? 0;
            }
            return 0;
          }),
          builder: (context, snapshot) {
            final int savedStars = snapshot.data ?? 0;

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Левая звезда (желтая, если рекорда хватает на 1, 2 или 3 звезды)
                Icon(
                  Icons.star_rounded, 
                  size: 22, 
                  color: savedStars >= 1 ? const Color(0xFFFFD54F) : Colors.grey,
                ),
                const SizedBox(width: 2),
                
                // Центральная звезда (чуть больше, загорается если выбито 2 или 3 звезды)
                Icon(
                  Icons.star_rounded, 
                  size: 26, 
                  color: savedStars >= 2 ? const Color(0xFFFFD54F) : Colors.grey,
                ), 
                const SizedBox(width: 2),
                
                // Правая звезда (загорается только при идеальном прохождении на 3 звезды)
                Icon(
                  Icons.star_rounded, 
                  size: 22, 
                  color: savedStars >= 3 ? const Color(0xFFFFD54F) : Colors.grey,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

// КЛАСС ЭКРАНА "ДОПОЛНИТЕЛЬНО" С ДИСКЛЕЙМЕРОМ ДЛЯ ДРУЗЕЙ
class AdditionalScreen extends StatelessWidget {
  const AdditionalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54, // Затемняем фон главного меню
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.65, // Удобная ширина прямоугольника
          height: MediaQuery.of(context).size.height * 0.80, // Удобная высота
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF9C4), // Нежно-жёлтый мультяшный фон
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFFBC02D), width: 6), // Золотая рамка
            boxShadow: const [
              BoxShadow(color: Colors.black45, blurRadius: 15, offset: Offset(0, 8)),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Шапка окна
              const Text(
                "ДИСКЛЕЙМЕР",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFD84315), // Сочный оранжево-красный
                  letterSpacing: 1.2,
                ),
              ),
              const Divider(color: Color(0xFFFBC02D), thickness: 2, indent: 40, endIndent: 40),
              
              // Твой доработанный текст извинений
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Парни, этот проект — чисто наш локальный прикол и дружеский угар! Я делал эту игру исключительно для того, чтобы мы вместе поржали с озвучки и разнесли пару замков, а не чтобы кого-то задеть или обидеть. Свиные ушки у Максимов — мультяшные, блоки камня и дерева — виртуальные, а наше уважение друг к другу и дружба — настоящие. Ребята, вы лучшие! Не обижайтесь на приколы, это всё любя и ради фана.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723), // Читаемый тёмно-коричневый цвет
                    height: 1.4, // Комфортный межстрочный интервал
                  ),
                ),
              ),
              
              // КНОПКА НАЗАД (Круглая зеленая кнопка со стрелкой влево)
              Container(
                width: 55,
                height: 55,
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50), // Зелёный цвет кнопки
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 3))],
                ),
                child: RawMaterialButton(
                  shape: const CircleBorder(),
                  onPressed: () {
                    Navigator.pop(context); // Намертво закрывает окно и возвращает в меню!
                  },
                  child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 28),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
