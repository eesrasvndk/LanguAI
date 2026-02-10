import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'home_screen.dart';


class RegisterPage extends StatefulWidget {
  final String englishLevel;
  final String learningGoal;
  final List<String> interests;
  final int dailyTimeGoal;

  const RegisterPage({
    super.key,
    required this.englishLevel,
    required this.learningGoal,
    required this.interests,
    required this.dailyTimeGoal,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen hatalı alanları düzeltin."), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authService = AuthService();
    final error = await authService.register(
      username: _usernameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      englishLevel: widget.englishLevel, // Onboarding'den gelen veri
      learningGoal: widget.learningGoal,
      interests: widget.interests,
      dailyTimeGoal: widget.dailyTimeGoal,
    );

    setState(() => _isLoading = false);

    if (error == null && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? "Hata"), backgroundColor: Colors.red),
      );
    }
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // Sayfa bağımsız olduğu için AppBar geri tuşunu otomatik sağlar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white)
      ),
      body: Center( // İçeriği ortalıyoruz
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Hesabını Oluştur 🎉",
                  style: TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text("Profilin hazır! Kaydetmek için son adım.",
                  style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 30),

                // Dinamik Metod Çağrıları
                _buildField("Kullanıcı Adı", Icons.person, _usernameController),
                const SizedBox(height: 15),
                _buildField("E-Mail", Icons.email, _emailController, isEmail: true),
                const SizedBox(height: 15),
                _buildPasswordField(),
                const SizedBox(height: 30),

                _isLoading
                    ? const CircularProgressIndicator(color: Colors.purpleAccent)
                    : SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purpleAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                          ),
                          onPressed: _register,
                          child: const Text("KAYDI TAMAMLA 🚀",
                            style: TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                      ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Geri Dön", style: TextStyle(color: Colors.white54)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }


 // YARDIMCI METODLAR

  InputDecoration _inputDecoration(String hint, IconData icon) { // ınputları tek yerden degistirebilmek için yazıldı(DRY)
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      prefixIcon: Icon(icon, color: Colors.purpleAccent),
      filled: true,
      fillColor: Colors.grey[800],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  Widget _buildField(String hint, IconData icon, TextEditingController controller, {bool isEmail = false}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(hint, icon),
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      validator: (value) {
        if (value == null || value.isEmpty) return "$hint boş olamaz";
        if (isEmail && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return "Geçerli bir email adresi giriniz";
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration("Şifre", Icons.lock).copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.white54,
          ),
          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
        ),
      ),
      validator: (value) {
      if (value == null || value.isEmpty) return "Şifre boş olamaz";
      if (value.length < 8) return "Şifre en az 8 karakter olmalı";
      if (!value.contains(RegExp(r'[A-Z]'))) return "En az 1 büyük harf içermeli";
      if (!value.contains(RegExp(r'[0-9]'))) return "En az 1 rakam içermeli";
      
      final bannedSequences = ['012', '123', '234', '345', '456', '567', '678', '789'];
      for (var seq in bannedSequences) {
        if (value.contains(seq)) {
          return "Şifre ardışık sayı dizisi içeremez";
        }
      }

      return null;
    },
    );
  }

  @override
  void dispose() {  //controlerların işi bitince kapanması için dispose methodu yazıldı (memory mng)
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
