import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService apiService;

  AuthProvider({required this.apiService});

  bool _isLoggedIn = false;
  String _actorType = ''; // ADMIN or FACILITY_USER
  int? _actorId;
  String _fullName = '';
  String _role = '';
  int? _facilityId;
  bool _mustChangePassword = false;

  bool get isLoggedIn => _isLoggedIn;
  String get actorType => _actorType;
  String get fullName => _fullName;
  String get role => _role;
  int? get actorId => _actorId;
  int? get facilityId => _facilityId;
  bool get mustChangePassword => _mustChangePassword;
  bool get isAdmin => _actorType == 'ADMIN';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    final refreshToken = prefs.getString('refreshToken');
    if (accessToken != null && refreshToken != null) {
      apiService.setTokens(accessToken, refreshToken);
      _isLoggedIn = true;
      _actorType = prefs.getString('actorType') ?? '';
      _actorId = prefs.getInt('actorId');
      _fullName = prefs.getString('fullName') ?? '';
      _role = prefs.getString('role') ?? '';
      _facilityId = prefs.getInt('facilityId');
      _mustChangePassword = prefs.getBool('mustChangePassword') ?? false;
      notifyListeners();
    }
  }

  Future<bool> loginAdmin(String username, String password) async {
    try {
      final response = await apiService.post('/auth/admin/login', body: {
        'username': username,
        'password': password,
        'actorType': 'ADMIN',
      });
      await _handleAuthResponse(response);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> loginUser(String phone, String password) async {
    try {
      final response = await apiService.post('/auth/user/login', body: {
        'phoneNumber': phone,
        'password': password,
        'actorType': 'FACILITY_USER',
      });
      await _handleAuthResponse(response);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> registerOwner({
    required String firstName,
    required String middleName,
    required String lastName,
    required String nationalId,
    required String phoneNumber,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      await apiService.post('/auth/user/register-owner', body: {
        'firstName': firstName,
        'middleName': middleName,
        'lastName': lastName,
        'nationalId': nationalId,
        'phoneNumber': phoneNumber,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
      });
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _handleAuthResponse(Map<String, dynamic> response) async {
    _isLoggedIn = true;
    _actorType = response['actorType'] ?? '';
    _actorId = response['actorId'];
    _fullName = response['fullName'] ?? '';
    _role = response['role'] ?? '';
    _facilityId = response['facilityId'];
    _mustChangePassword = response['mustChangePassword'] ?? false;

    apiService.setTokens(response['accessToken'], response['refreshToken']);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', response['accessToken']);
    await prefs.setString('refreshToken', response['refreshToken']);
    await prefs.setString('actorType', _actorType);
    if (_actorId != null) await prefs.setInt('actorId', _actorId!);
    await prefs.setString('fullName', _fullName);
    await prefs.setString('role', _role);
    if (_facilityId != null) await prefs.setInt('facilityId', _facilityId!);
    await prefs.setBool('mustChangePassword', _mustChangePassword);

    notifyListeners();
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _actorType = '';
    _actorId = null;
    _fullName = '';
    _role = '';
    _facilityId = null;
    apiService.clearTokens();

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}

