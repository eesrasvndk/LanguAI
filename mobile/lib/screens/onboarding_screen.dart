import 'package:flutter/material.dart';
import 'package:langu_ai/screens/register_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // ---------------- CONTROLLERS ----------------
  final PageController _pageController = PageController();

  // ---------------- STATE ----------------
  int _currentPage = 0;

// --- TOPLANACAK VERİLER ---
  String? _selectedLevel;
  String? _selectedGoal;
  List<String> _selectedInterests = [];
  int _dailyTime = 15;

  final int _totalSteps = 4;

  // ---------------- STATIC DATA ----------------
  final List<Map<String, String>> _levels = [
    {"label": "Başlangıç (A1)", "value": "A1"},
    {"label": "Orta (B1)", "value": "B1"},
    {"label": "İleri (C1)", "value": "C1"},
  ];

  final List<Map<String, dynamic>> _goals = [
    {"label": "Seyahat", "value": "travel", "icon": Icons.flight},
    {"label": "Kariyer", "value": "career", "icon": Icons.work},
    {"label": "Eğitim", "value": "education", "icon": Icons.school},
  ];

  final List<String> _interestOptions = [
    "Teknoloji",
    "Müzik",
    "Spor",
    "Film",
    "Oyun",
    "Seyahat",
  ];

  final List<Map<String, dynamic>> _timeOptions = [
    {"time": 15, "label": "Basit (15 Dk)"},
    {"time": 30, "label": "Normal (30 Dk)"},
    {"time": 45, "label": "Ciddi (45 Dk)"},
    {"time": 60, "label": "Çılgın (60 Dk)"},
  ];

  // ---------------- NAVIGATION ----------------
void _nextPage() {
  if (_currentPage < _totalSteps - 1) {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
    setState(() => _currentPage++);
  } else {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterPage(
          englishLevel: _selectedLevel ?? "A1",
          learningGoal: _selectedGoal ?? "general",
          interests: _selectedInterests,
          dailyTimeGoal: _dailyTime,
        ),
      ),
    );
  }
}

void _prevPage() {
    if (_currentPage > 0) {
      // Ara sayfalardaysak bir geri git
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
      setState(() => _currentPage--);
    } else {
      // EĞER İLK SAYFADAYSAK (Index 0):
      // Geldiğimiz sayfaya (Login) geri dön
      Navigator.pop(context);
    }
  }


  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_currentPage + 1) / _totalSteps,
              backgroundColor: Colors.grey[800],
              color: Colors.purpleAccent,
              minHeight: 6,
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _stepLevel(),
                  _stepGoal(),
                  _stepInterests(),
                  _stepTime(),
                ],
              ),
            ),
            _bottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _bottomNav() { //navigation bar (ekranın en altında yer alan gezinti çubugu)
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ESKİ KOD: _currentPage > 0 ? TextButton(...) : SizedBox(...) idi.
          // YENİ KOD: Buton her zaman görünsün.
          TextButton(
            onPressed: _prevPage, // Yukarıda güncellediğimiz metodu çağırır
            child: Text(
              _currentPage == 0 ? "İptal" : "Geri", // İlk sayfada "İptal", diğerlerinde "Geri" yazsın
              style: const TextStyle(color: Colors.white54),
            ),
          ),
          
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purpleAccent,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _nextPage,
            child: Text(
              _currentPage == _totalSteps - 1 ? "KAYIT OL 🚀" : "İLERİ",
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- STEPS ----------------
  Widget _stepLevel() {
    return _centered(
      "İngilizce Seviyen?",
      _levels.map((level) {
        final selected = _selectedLevel == level["value"];
        return _selectCard(
          text: level["label"]!,
          selected: selected,
          onTap: () => setState(() => _selectedLevel = level["value"]),
        );
      }).toList(),
    );
  }

  Widget _stepInterests() {
    return _centered(
      "İlgi Alanların",
      _interestOptions.map((interest) {
        final selected = _selectedInterests.contains(interest);
        return FilterChip(
          label: Text(interest),
          selected: selected,
          selectedColor: Colors.purpleAccent,
          backgroundColor: Colors.grey[800],
          labelStyle: const TextStyle(color: Colors.white),
          onSelected: (v) {
            setState(() {
              v
                  ? _selectedInterests.add(interest)
                  : _selectedInterests.remove(interest);
            });
          },
        );
      }).toList(),
      wrap: true,
    );
  }

  Widget _stepTime() {
    return _centered(
      "Günde Ne Kadar Zaman?",
      _timeOptions.map((option) {
        return _timeBtn(
          option["time"],
          option["label"],
        );
      }).toList(),
    );
  }

  Widget _selectCard({  //selectCard tek bir sayfa designı için yazıldı (DRY)
    required String text,
    IconData? icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected ? Colors.purpleAccent : Colors.grey[800],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              if (icon != null) Icon(icon, color: Colors.white),
              if (icon != null) const SizedBox(width: 10),
              Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _timeBtn(int time, String label) {
    final bool selected = _dailyTime == time;
    return _selectCard(
      text: label,
      selected: selected,
      onTap: () => setState(() => _dailyTime = time),
    );
  }

  Widget _stepGoal() {
    return _centered(
      "Neden Öğreniyorsun?",
      _goals.map((goal) {
        final selected = _selectedGoal == goal["value"];
        return _selectCard(
          text: goal["label"],
          icon: goal["icon"],
          selected: selected,
          onTap: () => setState(() => _selectedGoal = goal["value"]),
        );
      }).toList(),
    );
  }

  // ---------------- COMPONENTS ----------------
  Widget _centered(String title, List<Widget> children, {bool wrap = false}) {  //centered tek bir layout için yazıldı
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          wrap
              ? Wrap(spacing: 10, runSpacing: 10, children: children)
              : Column(children: children),
        ],
      ),
    );
  }
}