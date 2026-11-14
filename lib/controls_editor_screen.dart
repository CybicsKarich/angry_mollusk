import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ControlsEditorScreen extends StatefulWidget {
  const ControlsEditorScreen({super.key});

  @override
  State<ControlsEditorScreen> createState() => _ControlsEditorScreenState();
}

class _ControlsEditorScreenState extends State<ControlsEditorScreen> {
  // Стандартные координаты (в долях от 0.0 до 1.0)
  static const double _defLeftX = 0.05;
  static const double _defLeftY = 0.78;
  static const double _defRightX = 0.17;
  static const double _defRightY = 0.78;
  static const double _defJumpX = 0.85;
  static const double _defJumpY = 0.78;
  static const double _defScale = 1.0;

  double _leftX = _defLeftX;
  double _leftY = _defLeftY;
  double _rightX = _defRightX;
  double _rightY = _defRightY;
  double _jumpX = _defJumpX;
  double _jumpY = _defJumpY;
  double _scale = _defScale;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedControls();
  }

  Future<void> _loadSavedControls() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _leftX = prefs.getDouble('ctrl_left_x') ?? _defLeftX;
      _leftY = prefs.getDouble('ctrl_left_y') ?? _defLeftY;
      _rightX = prefs.getDouble('ctrl_right_x') ?? _defRightX;
      _rightY = prefs.getDouble('ctrl_right_y') ?? _defRightY;
      _jumpX = prefs.getDouble('ctrl_jump_x') ?? _defJumpX;
      _jumpY = prefs.getDouble('ctrl_jump_y') ?? _defJumpY;
      _scale = prefs.getDouble('ctrl_scale') ?? _defScale;
      _isLoading = false;
    });
  }

  // Сохраняем текущие позиции и размер, затем возвращаемся в настройки
  Future<void> _applyAndExit() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('ctrl_left_x', _leftX);
    await prefs.setDouble('ctrl_left_y', _leftY);
    await prefs.setDouble('ctrl_right_x', _rightX);
    await prefs.setDouble('ctrl_right_y', _rightY);
    await prefs.setDouble('ctrl_jump_x', _jumpX);
    await prefs.setDouble('ctrl_jump_y', _jumpY);
    await prefs.setDouble('ctrl_scale', _scale);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  // Сбрасываем кнопки в начальное положение и удаляем кастомные координаты
  Future<void> _resetToDefault() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('ctrl_left_x');
    await prefs.remove('ctrl_left_y');
    await prefs.remove('ctrl_right_x');
    await prefs.remove('ctrl_right_y');
    await prefs.remove('ctrl_jump_x');
    await prefs.remove('ctrl_jump_y');
    await prefs.remove('ctrl_scale');

    setState(() {
      _leftX = _defLeftX;
      _leftY = _defLeftY;
      _rightX = _defRightX;
      _rightY = _defRightY;
      _jumpX = _defJumpX;
      _jumpY = _defJumpY;
      _scale = _defScale;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double btnSize = 64.0 * _scale;

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F0F14),
        body: Center(child: CircularProgressIndicator(color: Colors.orange)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF14141E), // Макет тёмного зала 6 уровня
      body: Stack(
        children: [
          // Сетка на фоне для удобного выравнивания кнопок
          Positioned.fill(
            child: CustomPaint(painter: _GridBackgroundPainter()),
          ),

          // Полоса пола для наглядности границ арены
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: size.height * 0.14,
            child: Container(
              color: const Color(0xFF1E1E24),
              alignment: Alignment.center,
              child: const Text(
                "ПЕРЕТАСКИВАЙТЕ КНОПКИ ПАЛЬЦЕМ ПО ЭКРАНУ",
                style: TextStyle(color: Colors.white30, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
            ),
          ),

          // ВЕРХНЯЯ ПАНЕЛЬ УПРАВЛЕНИЯ РЕДАКТОРОМ
          Positioned(
            top: 14,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.85),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white24, width: 1.5),
              ),
              child: Row(
                children: [
                  // Кнопка ОТКЛОНИТЬ (сброс в исходное положение)
                  ElevatedButton.icon(
                    onPressed: _resetToDefault,
                    icon: const Icon(Icons.refresh_rounded, size: 18, color: Colors.white),
                    label: const Text("ОТКЛОНИТЬ", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Ползунок размера от 50% до 150%
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "РАЗМЕР КНОПОК: ${(_scale * 100).round()}%",
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 28,
                          child: Slider(
                            value: _scale,
                            min: 0.5,
                            max: 1.5,
                            divisions: 20, // Шаг по 5%
                            activeColor: Colors.orange,
                            inactiveColor: Colors.white24,
                            onChanged: (val) => setState(() => _scale = val),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Кнопка ПРИМЕНИТЬ (сохранить и выйти в настройки)
                  ElevatedButton.icon(
                    onPressed: _applyAndExit,
                    icon: const Icon(Icons.check_rounded, size: 18, color: Colors.white),
                    label: const Text("ПРИМЕНИТЬ", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 1. ПЕРЕТАСКИВАЕМАЯ КНОПКА «ВЛЕВО»
          _buildDraggableButton(
            screenSize: size,
            btnSize: btnSize,
            normX: _leftX,
            normY: _leftY,
            icon: Icons.arrow_back_rounded,
            label: "ВЛЕВО",
            onDrag: (newX, newY) => setState(() {
              _leftX = newX;
              _leftY = newY;
            }),
          ),

          // 2. ПЕРЕТАСКИВАЕМАЯ КНОПКА «ВПРАВО»
          _buildDraggableButton(
            screenSize: size,
            btnSize: btnSize,
            normX: _rightX,
            normY: _rightY,
            icon: Icons.arrow_forward_rounded,
            label: "ВПРАВО",
            onDrag: (newX, newY) => setState(() {
              _rightX = newX;
              _rightY = newY;
            }),
          ),

          // 3. ПЕРЕТАСКИВАЕМАЯ КНОПКА «ПРЫЖОК»
          _buildDraggableButton(
            screenSize: size,
            btnSize: btnSize,
            normX: _jumpX,
            normY: _jumpY,
            icon: Icons.arrow_upward_rounded,
            label: "ПРЫЖОК",
            color: Colors.orange,
            onDrag: (newX, newY) => setState(() {
              _jumpX = newX;
              _jumpY = newY;
            }),
          ),
        ],
      ),
    );
  }

    Widget _buildDraggableButton({
    required Size screenSize,
    required double btnSize,
    required double normX,
    required double normY,
    required IconData icon,
    required String label,
    required Function(double, double) onDrag,
    Color color = Colors.blueGrey,
  }) {
    return Positioned(
      left: normX * screenSize.width,
      top: normY * screenSize.height,
      child: GestureDetector(
        onPanUpdate: (details) {
          // Пересчитываем сдвиг пальца в проценты от экрана с защитой от выхода за края
          double nextX = (normX * screenSize.width + details.delta.dx) / screenSize.width;
          double nextY = (normY * screenSize.height + details.delta.dy) / screenSize.height;

          double maxX = (screenSize.width - btnSize) / screenSize.width;
          double maxY = (screenSize.height - btnSize) / screenSize.height;

          onDrag(
            nextX.clamp(0.0, maxX.clamp(0.0, 1.0)),
            nextY.clamp(0.14, maxY.clamp(0.14, 1.0)), // Не даём залезть на верхнюю панель
          );
        },
        child: Container(
          width: btnSize,
          height: btnSize,
          decoration: BoxDecoration(
            color: color.withOpacity(0.85),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 4))],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: btnSize * 0.48),
              if (btnSize >= 48)
                Text(
                  label,
                  style: TextStyle(color: Colors.white, fontSize: btnSize * 0.14, fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GridBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 1.0;

    const double step = 32.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

