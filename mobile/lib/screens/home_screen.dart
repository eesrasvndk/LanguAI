import 'package:flutter/material.dart';
import 'package:langu_ai/services/auth_service.dart';

import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("LanguAI Ana Sayfa"),
        backgroundColor: Colors.purpleAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authService = AuthService();
              await authService.logout();
              
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const  LoginScreen()),
              );
            },
          )
        ],
      ),
      body: const Center(
        child: Text(
          "Hoş Geldin! 👋\nBurası senin dil öğrenme merkezin.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}