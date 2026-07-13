import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
              Color(0xFF0288D1), // Глубокий синий (водный стиль для Моллюска)
              Color(0xFFB3E5FC), // Светло-голубой низ
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                const Text(
                  'ANGRY MOLLUSK',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 46,
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

                const SizedBox(height: 10),

                const Text(
                  'Bunnyhop против Моллюска Максима',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                    letterSpacing: 1.2,
                  ),
                ),

                const Spacer(flex: 2),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      _buildMenuButton('УРОВНИ', Icons.play_arrow_rounded, Colors.orange),
                      const SizedBox(height: 16),
                      _buildMenuButton('ДОСТИЖЕНИЯ', Icons.emoji_events_rounded, Colors.amber),
                      const SizedBox(height: 16),
                      _buildMenuButton('НАСТРОЙКИ', Icons.settings_rounded, Colors.grey),
                      const SizedBox(height: 16),
                      _buildMenuButton('ДОПОЛНИТЕЛЬНО', Icons.extension_rounded, Colors.purple),
                    ],
                  ),
                ),

                const Spacer(flex: 3),
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
      constraints: const BoxConstraints(maxWidth: 320),
      height: 60,
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
        icon: Icon(icon, size: 28, color: Colors.white),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 20,
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
