import 'package:flutter/material.dart';
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
  await SystemChrome.setEnabledSystemU someMode(SystemUiMode.immersiveSticky);

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

class _MainMenuScreenState extends State<MainMenuScreen> {
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _playBackgroundMusic();
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
    _audioPlayer.dispose();
    super.dispose();
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
                          _buildMenuButton('УРОВНИ', Icons.play_arrow_rounded, Colors.orange),
                          const SizedBox(height: 12),
                          _buildMenuButton('ДОСТИЖЕНИЯ', Icons.emoji_events_rounded, Colors.amber),
                          const SizedBox(height: 12),
                          // Переставили: теперь третья кнопка — Дополнительно
                          _buildMenuButton('ДОПОЛНИТЕЛЬНО', Icons.extension_rounded, Colors.purple),
                          const SizedBox(height: 12),
                          // Переставили: теперь четвертая кнопка — Настройки
                          _buildMenuButton('НАСТРОЙКИ', Icons.settings_rounded, Colors.grey),
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

  Widget _buildMenuButton(String text, IconData icon, Color color) {
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
        onPressed: () {
          debugPrint('Нажата кнопка: $text');
        },
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
