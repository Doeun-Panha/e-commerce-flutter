import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/auth_api_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthApiService _apiService = AuthApiService();
  final _storage = const FlutterSecureStorage();

  bool _isLoading = false;
  String? _token;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  // 1. Initial Check: See if a token exists when the app starts
  Future<void> checkAuthStatus() async {
    _token = await _storage.read(key: 'jwt_token');
    notifyListeners();
  }

  // 2. Login Logic
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _apiService.login(username, password);
      _token = data['token'];

      // Save token securely
      await _storage.write(key: 'jwt_token', value: _token);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint("Login Error: $e");
      return false;
    }
  }

  // 3. Register Logic
  Future<bool> register(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _apiService.register(username, password);
      _token = data['token'];
      await _storage.write(key: 'jwt_token', value: _token);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 4. Logout Logic
  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
    _token = null;
    notifyListeners();
  }
}