import 'dart:async';
import 'package:flutter/material.dart';
import 'main.dart'; // Для перехода в главное меню

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _opacityAnimation;

  bool _isGlitching = false; // Флаг для пасхального микро-глитча
  bool _navigated = false;   // Защита от двойного перехода

  @override
  void initState() {
    super.initState();

    // Плавное появление логотипа за 1.2 секунды
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _opacityAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();

    // На 2-й секунде запускаем скрытый глитч из идеальной концовки (длится 140 мс)
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (!mounted || _navigated) return;
      setState(() => _isGlitching = true);

      Future.delayed(const Duration(milliseconds: 140), () {
        if (!mounted || _navigated) return;
        setState(() => _isGlitching = false);
      });
    });

    // На 2.7 секунде плавно переводим игрока в главное меню
    Future.delayed(const Duration(milliseconds: 2700), () {
      _goToMainMenu();
    });
  }

  void _goToMainMenu() {
    if (_navigated || !mounted) return;
    _navigated = true;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => const MainMenuScreen(), // Твой экран главного меню
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF040407), // Глубокий угольно-чёрный фон
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _goToMainMenu, // Пропуск заставки по нажатию в любое место экрана
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Основной золотой логотип (или зелёный сдвиг во время микро-глитча)
            FadeTransition(
              opacity: _opacityAnimation,
              child: Transform.translate(
                offset: _isGlitching ? const Offset(-4.0, 1.5) : Offset.zero,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "KARRICK STUDIO",
                      style: TextStyle(
                        fontFamily: _isGlitching ? 'Courier New' : 'Georgia',
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: _isGlitching ? const Color(0xFF00FF66) : const Color(0xFFFFCC80),
                        letterSpacing: 3.5,
                        shadows: [
                          Shadow(
                            color: _isGlitching ? const Color(0xFF00C853) : Colors.black87,
                            blurRadius: _isGlitching ? 12 : 6,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: 110,
                      height: 1.5,
                      color: (_isGlitching ? const Color(0xFF00FF66) : const Color(0xFFFFCC80)).withOpacity(0.5),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "PRESENTS",
                      style: TextStyle(
                        fontFamily: _isGlitching ? 'Courier New' : 'Georgia',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _isGlitching ? const Color(0xFFB9F6CA) : Colors.white60,
                        letterSpacing: 6.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Вторая фантомная тень текста (появляется только в момент глитча для эффекта помех)
            if (_isGlitching)
              Transform.translate(
                offset: const Offset(4.5, -1.5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "KARRICK STUDIO",
                      style: TextStyle(
                        fontFamily: 'Courier New',
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFFF1744).withOpacity(0.5), // Красноватый сдвиг растра
                        letterSpacing: 3.5,
                      ),
                    ),
                    const SizedBox(height: 23.5),
                    Text(
                      "PRESENTS",
                      style: TextStyle(
                        fontFamily: 'Courier New',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFF1744).withOpacity(0.5),
                        letterSpacing: 6.0,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
