import 'package:flutter/material.dart';

class Level6BadRouteScreen extends StatelessWidget {
  const Level6BadRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "ПЛОХАЯ ЛИНИЯ (В РАЗРАБОТКЕ)",
              style: TextStyle(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Назад"),
            ),
          ],
        ),
      ),
    );
  }
}
