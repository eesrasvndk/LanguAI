import 'package:flutter/material.dart';
import 'package:langu_ai/services/auth_service.dart';

import 'home_screen.dart';
import 'onboarding_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  Future<void> _login() async {
    // Önce form geçerli mi kontrol et
    if (!_formKey.currentState!.validate()) {
      return; // Hata varsa dur, API'ye gitme.
    }

    setState(() => _isLoading = true);
    
    final authService = AuthService();
    String? error = await authService.login(_emailController.text, _passwordController.text);
    
    setState(() => _isLoading = false);

    if (error == null) {
      if(mounted) {
         Navigator.of(context).pushReplacement(
           MaterialPageRoute(builder: (context) => const HomeScreen())
         );
      }
    } else {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.smart_toy, size: 80, color: Colors.purpleAccent),
              const SizedBox(height: 20),
              const Text("LanguAI", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              
              TextFormField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.emailAddress, // @ işareti klavyede çıkar
                textInputAction: TextInputAction.next,    // İleri tuşu
                decoration: _inputDecoration("Email", Icons.email),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Lütfen email adresinizi girin";
                    }
                    // Email format kontrolü (Regex)
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return "Geçerli bir email adresi değil";
                    }
                    return null;
                  },
                ),

              const SizedBox(height: 10),


              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                style: const TextStyle(color: Colors.white),
                textInputAction: TextInputAction.done, // Tamam tuşu
                  decoration: _inputDecoration("Şifre", Icons.lock).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white54,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Lütfen şifrenizi girin";
                    }
                    return null;
                  },
                ),

              const SizedBox(height: 20),

        //giriş buttonu
              _isLoading 
                  ? const CircularProgressIndicator(color: Colors.purpleAccent) 
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purpleAccent, 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                        ),
                        child: const Text("GİRİŞ YAP", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
        
              const SizedBox(height: 20),
              
              //hesap oluştur
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Hesabın yok mu? ", style: TextStyle(color: Colors.white70)),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const OnboardingScreen()
                        ));
                      },
                      child: const Text("Hemen Oluştur", style: TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold)),
                   )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

// Kod tekrarını önlemek için tasarım metodu
  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38),
      prefixIcon: Icon(icon, color: Colors.purpleAccent),
      filled: true,
      fillColor: Colors.grey[900], // Biraz daha koyu gri
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      errorBorder: OutlineInputBorder( // Hata olunca çerçeve kırmızı olsun
        borderRadius: BorderRadius.circular(10), 
        borderSide: const BorderSide(color: Colors.redAccent)
      ),
    );
  }
}