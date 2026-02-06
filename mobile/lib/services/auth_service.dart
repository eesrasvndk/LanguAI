import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = "http://192.168.1.121:5173/api/Auth";

  Future<String?> register({
    required String username,
    required String email,
    required String password,
    required String englishLevel,
    required String learningGoal,
    required List<String> interests,
    required int dailyTimeGoal,
  }) async {
    final url = Uri.parse("$baseUrl/register");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "email": email,
          "password": password, // Backend'e şifreyi yolluyoruz
          "englishLevel": englishLevel,
          "learningGoal": learningGoal,
          "interests": interests,
          "dailyTimeGoal": dailyTimeGoal,
        }),
      );

      if (response.statusCode == 200) {
        // --- YENİ EKLENEN KISIM ---
        // Kayıt başarılıysa gelen Token'ı hemen kaydedelim
        final data = jsonDecode(response.body);
        String token = data['token'];
        int userId = data['userId'];
        String username = data['username'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        await prefs.setString('username', username);
        await prefs.setInt('userId', userId);
        
        return null; // Hata yok, direkt içeri alabilirsin!
      } else {
        return response.body;
      }
    } catch (e) {
      return "Bağlantı hatası.";
    }
  }
  Future<String?> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/login");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        // 1. Gelen cevabı (JSON) parçala
        final data = jsonDecode(response.body);
        String token = data['token'];
        int userId = data['userId'];
        String username = data['username'];

        // 2. Token'ı telefonun hafızasına kaydet 💾
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        await prefs.setString('username', username);
        await prefs.setInt('userId', userId);

        return null; // Hata yok, giriş başarılı!
      } else {
        return response.body; // Hata mesajını döndür (Örn: "Şifre yanlış")
      }
    } catch (e) {
      return "Sunucuya bağlanılamadı. İnternetini kontrol et.";
    }
  }

  // --- ÇIKIŞ YAP (LOGOUT) ---
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token'); // Token'ı sil, oturum düşsün.
  }
}




