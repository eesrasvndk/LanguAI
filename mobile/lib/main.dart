import 'package:flutter/material.dart';
import 'package:langu_ai/screens/onboarding_screen.dart';

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
      theme: ThemeData.dark(), // Koyu tema varsayılan olsun
      home: const OnboardingScreen(), // İlk açılan ekran bu olsun
    );
  }
}
