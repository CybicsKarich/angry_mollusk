import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart'; // Пакет для управления экраном и системными панелями
import 'package:audioplayers/audioplayers.dart';

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
                          _buildMenuButton('УРОВНИ', Icons.play_arrow_rounded, Colors.orange, () {}),
                          _buildMenuButton('ДОСТИЖЕНИЯ', Icons.emoji_events_rounded, Colors.amber, () {}),
                          _buildMenuButton('ДОПОЛНИТЕЛЬНО', Icons.extension_rounded, Colors.purple, () {}),
                          _buildMenuButton('НАСТРОЙКИ', Icons.settings_rounded, Colors.grey, _openSettings),
                        ],
                      ),
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
