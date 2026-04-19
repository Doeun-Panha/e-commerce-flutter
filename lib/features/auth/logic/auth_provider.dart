import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/auth_api_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthProvider with ChangeNotifier {
  final AuthApiService _apiService = AuthApiService();
  final _storage = const FlutterSecureStorage();

  bool _isLoading = false;
  String? _token;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  String _message = "";
  String get message => _message;

  // 1. Initial Check: See if a token exists when the app starts
  Future<void> checkAuthStatus() async {
    final storedToken = await _storage.read(key: 'jwt_token');

    if (storedToken != null) {
      // Check if the token is still valid before setting it
      if (JwtDecoder.isExpired(storedToken)) {
        await logout(); // Wipe the expired token
      } else {
        _token = storedToken;
      }
    }
    notifyListeners();
  }

  // 2. Login Logic
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _message = "";
    notifyListeners();

    try {
      final data = await _apiService.login(username, password);
      _token = data['token'];

      // Save token securely
      await _storage.write(key: 'jwt_token', value: _token);

      _message = "Welcome back, $username!";
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // Use the error from the backend (e.g., "User not found" or "Invalid credentials")
      _message = e.toString().replaceAll("Exception: ", "");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 3. Register Logic
  Future<bool> register(String username, String password) async {
    _isLoading = true;
    _message = "";
    notifyListeners();

    try {
      final data = await _apiService.register(username, password);
      _token = data['token'];
      await _storage.write(key: 'jwt_token', value: _token);

      _message = "Account created successfully!";
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;

      _message = e.toString().replaceAll("Exception: ", "");
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

  bool get isAdmin{
    if (_token == null) return false;
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(_token!);
      // This matches the 'role' key you set in JwtService.java
      return decodedToken['role'] == 'ADMIN';
    } catch (e) {
      return false;
    }
  }
}