import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/models.dart';
import '../config/api_config.dart';

class AuthProvider with ChangeNotifier {
  final String _baseUrl = ApiConfig.baseUrl;
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  User? _currentUser;
  String? _token;
  bool _isLoading = false;
  bool _isAuthenticated = false;

  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;

  // Get auth headers for API calls
  Map<String, String> get authHeaders => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  /// Refresh current user profile from server so that latest role,
  /// permissions and stepAccess assigned by Admin are reflected.
  Future<void> refreshCurrentUserFromServer() async {
    if (_currentUser == null) return;

    try {
      final response = await authenticatedRequest(
        method: 'GET',
        endpoint: '/users/${_currentUser!.id}',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _currentUser = User.fromJson(data);

        // Persist updated profile
        await _secureStorage.write(
          key: 'user_data',
          value: jsonEncode(_currentUser!.toJson()),
        );

        debugPrint('✅ Refreshed user from server: ${_currentUser?.name}');
        notifyListeners();
      } else {
        debugPrint('ℹ️ Failed to refresh user: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ refreshCurrentUserFromServer error: $e');
    }
  }

  /// Auto-login on app start
  Future<void> tryAutoLogin() async {
    _isLoading = true;
    Future.microtask(() => notifyListeners());

    try {
      // Read token from secure storage
      final storedToken = await _secureStorage.read(key: 'jwt_token');
      final storedUser = await _secureStorage.read(key: 'user_data');

      if (storedToken != null && storedUser != null) {
        _token = storedToken;
        _currentUser = User.fromJson(jsonDecode(storedUser));
        _isAuthenticated = true;
        
        debugPrint('✅ Auto-login successful: ${_currentUser?.name}');
        // Ensure we have the latest role/permissions/stepAccess from backend
        await refreshCurrentUserFromServer();
      } else {
        debugPrint('ℹ️ No saved session found');
      }
    } catch (e) {
      debugPrint('❌ Auto-login error: $e');
      await logout(); // Clear corrupted data
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Extract token and user data
        _token = data['token'];
        _currentUser = User.fromJson(data['user']);
        _isAuthenticated = true;

        // Save to secure storage
        await _secureStorage.write(key: 'jwt_token', value: _token);
        await _secureStorage.write(
          key: 'user_data',
          value: jsonEncode(_currentUser!.toJson()),
        );

        debugPrint('✅ Login successful: ${_currentUser?.name}');
        _isLoading = false;
        notifyListeners();
        return true;
      } else if (response.statusCode == 401) {
        final data = jsonDecode(response.body);
        final message = data['message'] ?? 'Invalid credentials';
        debugPrint('❌ Login failed: $message');
        throw Exception(message);
      } else if (response.statusCode == 404) {
        throw Exception('EMAIL_NOT_FOUND');
      } else {
        throw Exception('Login failed. Please try again.');
      }
    } catch (e) {
      debugPrint('❌ Login error: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Send OTP to mobile
  Future<void> sendOtp(String phone) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send OTP. Please try again.');
      }
      debugPrint('✅ OTP sent to $phone');
    } catch (e) {
      debugPrint('❌ Send OTP error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Verify OTP and login
  Future<bool> verifyOtp(String phone, String otp) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'otp': otp}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _currentUser = User.fromJson(data['user']);
        _isAuthenticated = true;

        await _secureStorage.write(key: 'jwt_token', value: _token);
        await _secureStorage.write(
          key: 'user_data',
          value: jsonEncode(_currentUser!.toJson()),
        );

        debugPrint('✅ OTP verified, login successful');
        return true;
      } else {
        throw Exception('Invalid OTP. Please try again.');
      }
    } catch (e) {
      debugPrint('❌ Verify OTP error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logout and clear session
  Future<void> logout() async {
    _currentUser = null;
    _token = null;
    _isAuthenticated = false;

    // Clear secure storage
    await _secureStorage.delete(key: 'jwt_token');
    await _secureStorage.delete(key: 'user_data');

    debugPrint('✅ Logout successful');
    notifyListeners();
  }

  /// Handle 401 Unauthorized (token expired)
  void handleUnauthorized() {
    debugPrint('⚠️ Token expired - logging out');
    logout();
  }

  /// Validate token expiry (optional - JWT has built-in expiry)
  bool isTokenExpired() {
    if (_token == null) return true;
    
    try {
      // Decode JWT payload (base64)
      final parts = _token!.split('.');
      if (parts.length != 3) return true;
      
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      
      final exp = payload['exp'] as int?;
      if (exp == null) return false;
      
      final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isAfter(expiryDate);
    } catch (e) {
      debugPrint('❌ Token validation error: $e');
      return true;
    }
  }

  /// Make authenticated API call with auto-logout on 401
  Future<http.Response> authenticatedRequest({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    http.Response response;

    switch (method.toUpperCase()) {
      case 'GET':
        response = await http.get(uri, headers: authHeaders);
        break;
      case 'POST':
        response = await http.post(
          uri,
          headers: authHeaders,
          body: body != null ? jsonEncode(body) : null,
        );
        break;
      case 'PUT':
        response = await http.put(
          uri,
          headers: authHeaders,
          body: body != null ? jsonEncode(body) : null,
        );
        break;
      case 'PATCH':
        response = await http.patch(
          uri,
          headers: authHeaders,
          body: body != null ? jsonEncode(body) : null,
        );
        break;
      case 'DELETE':
        response = await http.delete(uri, headers: authHeaders);
        break;
      default:
        throw Exception('Unsupported HTTP method: $method');
    }

    // Handle 401 Unauthorized
    if (response.statusCode == 401) {
      handleUnauthorized();
      throw Exception('Session expired. Please login again.');
    }

    return response;
  }
}
