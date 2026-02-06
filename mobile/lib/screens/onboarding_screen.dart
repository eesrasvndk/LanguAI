import 'package:flutter/material.dart';
import 'package:langu_ai/screens/home_screen.dart';

import '../services/auth_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Sayfa Kontrolcüsü (İleri-Geri gitmek için)
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  // --- TOPLANACAK VERİLER ---
  String? _selectedLevel;
  String? _selectedGoal;
  List<String> _selectedInterests = [];
  int _dailyTime = 15;
  
  // Form Kontrolcüleri (Son sayfa için)
  //etiket(degisken tanimlama) satırları
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // --- SEÇENEKLER ---
  final List<Map<String, String>> _levels = [
    {"label": "Başlangıç (A1)", "value": "A1"},
    {"label": "Temel (A2)", "value": "A2"},
    {"label": "Orta (B1)", "value": "B1"},
    {"label": "İleri (B2+)", "value": "B2"},
  ];

  final List<Map<String, dynamic>> _goals = [
    {"label": "İş & Kariyer", "value": "WORK", "icon": Icons.business_center},
    {"label": "Seyahat", "value": "TRAVEL", "icon": Icons.flight},
    {"label": "Eğitim / Sınav", "value": "EXAM", "icon": Icons.school},
    {"label": "Hobi / Beyin Egzersizi", "value": "HOBBY", "icon": Icons.sports_esports},
  ];

  final List<String> _interestsOptions = [
    "Technology", "Sports", "Cinema", "Science", "Music", "Art", "Business", "Gaming"
  ];

  // --- FONKSİYONLAR ---

  void _nextPage() {
    // Doğrulama: Seçim yapmadan geçirmeyelim
    if (_currentPage == 0 && _selectedLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen bir seviye seçin.")));
      return;
    }
    if (_currentPage == 1 && _selectedGoal == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen bir hedef seçin.")));
      return;
    }
    
    _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    setState(() {
      _currentPage++;
    });
  }

  Future<void> _register() async {
    // Form validasyonu (Boş mu dolu mu kontrolü)
    if (_usernameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen tüm alanları doldurun.")));
       return;
    }

    setState(() => _isLoading = true);

    final authService = AuthService();
    
    // DEĞİŞİKLİK BURADA: Artık bool değil, String? (hata mesajı) bekliyoruz
    String? errorMessage = await authService.register(
      username: _usernameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      englishLevel: _selectedLevel!,
      learningGoal: _selectedGoal!,
      interests: _selectedInterests,
      dailyTimeGoal: _dailyTime,
    );

    setState(() => _isLoading = false);

    // Eğer errorMessage NULL ise, hata yok demektir (BAŞARILI)
    if (errorMessage == null) {
      // Kayıt başarılı, direkt ana sayfaya git
      if (mounted) { // 'mounted' kontrolü, sayfa kapanmışsa hata almamak içindir
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()), 
        );
      }
    } else {
      // Hata var, mesajı göster
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Hata: $errorMessage"),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900], // Koyu Tema
      body: SafeArea(
        child: Column(
          children: [
            // Üstteki İlerleme Çubuğu
            LinearProgressIndicator(
              value: (_currentPage + 1) / 4,
              backgroundColor: Colors.grey[800],
              color: Colors.purpleAccent,
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Elle kaydırmayı engelle (Butonla geçsin)
                children: [
                  _buildStep1Level(),
                  _buildStep2Goal(),
                  _buildStep3Interests(),
                  _buildStep4Form(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- SAYFA TASARIMLARI ---

  // ADIM 1: SEVİYE SEÇİMİ
  Widget _buildStep1Level() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("İngilizce Seviyen Nedir?", style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ..._levels.map((level) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () {
                setState(() => _selectedLevel = level["value"]);
              },
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: _selectedLevel == level["value"] ? Colors.purpleAccent : Colors.grey[800],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white24)
                ),
                child: Row(
                  children: [
                    Text(level["label"]!, style: const TextStyle(color: Colors.white, fontSize: 18)),
                    const Spacer(),
                    if (_selectedLevel == level["value"]) const Icon(Icons.check_circle, color: Colors.white)
                  ],
                ),
              ),
            ),
          )).toList(),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _nextPage, child: const Text("Devam Et"))
        ],
      ),
    );
  }

  // ADIM 2: HEDEF SEÇİMİ
  Widget _buildStep2Goal() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Neden Öğreniyorsun?", style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          Wrap(
            spacing: 15,
            runSpacing: 15,
            children: _goals.map((goal) => GestureDetector(
              onTap: () => setState(() => _selectedGoal = goal["value"]),
              child: Container(
                width: 150,
                height: 120,
                decoration: BoxDecoration(
                  color: _selectedGoal == goal["value"] ? Colors.greenAccent[700] : Colors.grey[800],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(goal["icon"], size: 40, color: Colors.white),
                    const SizedBox(height: 10),
                    Text(goal["label"], style: const TextStyle(color: Colors.white), textAlign: TextAlign.center),
                  ],
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 30),
          ElevatedButton(onPressed: _nextPage, child: const Text("Devam Et"))
        ],
      ),
    );
  }

  // ADIM 3: İLGİ ALANLARI
  Widget _buildStep3Interests() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Nelerden Hoşlanırsın?", style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
          const Text("(AI sana buna göre cümleler kuracak)", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _interestsOptions.map((interest) {
              final isSelected = _selectedInterests.contains(interest);
              return FilterChip(
                label: Text(interest),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedInterests.add(interest);
                    } else {
                      _selectedInterests.remove(interest);
                    }
                  });
                },
                backgroundColor: Colors.grey[800],
                selectedColor: Colors.purpleAccent,
                labelStyle: const TextStyle(color: Colors.white),
              );
            }).toList(),
          ),
          const SizedBox(height: 30),
          ElevatedButton(onPressed: _nextPage, child: const Text("Son Adım: Hesap Oluştur"))
        ],
      ),
    );
  }

  // ADIM 4: KAYIT FORMU
  Widget _buildStep4Form() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("LanguAI'ya Katıl", style: TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildTextField(_usernameController, "Kullanıcı Adı", Icons.person),
          const SizedBox(height: 10),
          _buildTextField(_emailController, "E-Mail", Icons.email),
          const SizedBox(height: 10),
          _buildTextField(_passwordController, "Şifre", Icons.lock, isPassword: true),
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
                    child: const Text("KAYDI TAMAMLA 🚀", style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                )
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.purpleAccent),
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
    );
  }
}