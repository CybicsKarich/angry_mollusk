import 'package:flutter/material.dart';

class GoodEndingScreen extends StatefulWidget {
  const GoodEndingScreen({super.key});

  @override
  State<GoodEndingScreen> createState() => _GoodEndingScreenState();
}

class _GoodEndingScreenState extends State<GoodEndingScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFD7CCC8),
      body: Center(child: Text("Заглушка: Кабинет Шерифа на закате (Хороший финал)")),
    );
  }
}
