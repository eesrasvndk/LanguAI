import 'package:flutter/material.dart';
import 'package:langu_ai/screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LanguAI',
      theme: ThemeData.dark(),
      home: const LoginScreen(), // İlk açılan ekran bu olsun
    );
  }
}
