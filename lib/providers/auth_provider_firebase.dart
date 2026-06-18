import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  static const String _prefsPhoneNumber = 'saved_phone_number';
  static const String _prefsPassword = 'saved_password';

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  UserRole? get currentRole => _currentUser?.role;
  bool get isAdmin => _currentUser?.role == UserRole.admin;
  bool get isWorker => _currentUser?.role == UserRole.worker;
  bool get isLoggedIn => _currentUser != null;

  /// Initialize auth state from saved credentials
  Future<void> initializeAuthState() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPhone = prefs.getString(_prefsPhoneNumber);
      final savedPassword = prefs.getString(_prefsPassword);

      if (savedPhone != null && savedPassword != null) {
        final user = await _firestoreService.getUserByPhoneAndPassword(
          savedPhone,
          savedPassword,
        );

        if (user != null && user.isActive) {
          _currentUser = user;
        } else {
          await _clearSavedCredentials();
        }
      }
    } catch (_) {
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveCredentials(String phoneNumber, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsPhoneNumber, phoneNumber);
    await prefs.setString(_prefsPassword, password);
  }

  Future<void> _clearSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsPhoneNumber);
    await prefs.remove(_prefsPassword);
  }

  /// Register with phone number and password
  Future<bool> register(String phoneNumber, String password, String name) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final existingUser = await _firestoreService.getUserByPhoneNumber(phoneNumber);
      if (existingUser != null) {
        _errorMessage = 'Phone number already registered';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _currentUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        phoneNumber: phoneNumber,
        password: password,
        name: name,
        role: UserRole.worker,
        isActive: true,
      );

      await _firestoreService.createUserDocument(_currentUser!);
      await _saveCredentials(phoneNumber, password);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Registration failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Login with phone number and password
  Future<bool> login(String phoneNumber, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final user = await _firestoreService.getUserByPhoneAndPassword(
        phoneNumber,
        password,
      );

      if (user == null) {
        _errorMessage = 'Invalid phone number or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _currentUser = user;
      await _saveCredentials(phoneNumber, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Login failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    _currentUser = null;
    _errorMessage = null;
    await _clearSavedCredentials();
    notifyListeners();
  }

  /// Update user profile
  Future<bool> updateProfile(String name, String? phoneNumber) async {
    try {
      if (_currentUser == null) return false;

      _isLoading = true;
      notifyListeners();

      _currentUser = _currentUser!.copyWith(name: name);
      if (phoneNumber != null) {
        _currentUser = _currentUser!.copyWith(phoneNumber: phoneNumber);
        if (_currentUser != null) {
          await _saveCredentials(_currentUser!.phoneNumber, _currentUser!.password);
        }
      }

      await _firestoreService.updateUser(_currentUser!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Profile update failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Change password
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      if (_currentUser == null) return false;

      if (_currentUser!.password != oldPassword) {
        _errorMessage = 'Incorrect current password';
        return false;
      }

      _isLoading = true;
      notifyListeners();

      _currentUser = _currentUser!.copyWith(password: newPassword);
      await _firestoreService.updateUser(_currentUser!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Password change failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
