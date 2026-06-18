import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/firestore_service.dart';

class UserProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<User> _users = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<User> get users => _users;
  List<User> get workers =>
      _users.where((user) => user.role == UserRole.worker).toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch all users (admin only)
  Future<void> fetchAllUsers() async {
    try {
      _isLoading = true;
      notifyListeners();

      _users = await _firestoreService.getAllUsers();
      _errorMessage = null;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to fetch users: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add new user
  Future<bool> addUser(User user) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Check for duplicate phone number via Firestore query
      final existingUsers = _users
          .where((u) => u.phoneNumber == user.phoneNumber)
          .toList();

      if (existingUsers.isNotEmpty) {
        _errorMessage = 'User with this phone number already exists';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await _firestoreService.createUserDocument(user);

      // Reload users list
      await fetchAllUsers();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update user
  Future<bool> updateUser(User user) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Check for duplicate phone number (excluding current user)
      final duplicatePhones = _users
          .where((u) =>
              u.phoneNumber == user.phoneNumber &&
              u.id != user.id)
          .toList();

      if (duplicatePhones.isNotEmpty) {
        _errorMessage = 'Phone number already in use by another user';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await _firestoreService.updateUser(user);

      // Update local list
      final index = _users.indexWhere((u) => u.id == user.id);
      if (index >= 0) {
        _users[index] = user;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete user
  Future<bool> deleteUser(String userId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firestoreService.deleteUser(userId);

      _users.removeWhere((u) => u.id == userId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete user: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Toggle user active status
  Future<bool> toggleUserActive(String userId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final user = _users.firstWhere(
        (u) => u.id == userId,
        orElse: () => throw Exception('User not found'),
      );

      final newStatus = !user.isActive;
      await _firestoreService.toggleUserActive(userId, newStatus);

      // Update local list
      final index = _users.indexWhere((u) => u.id == userId);
      if (index >= 0) {
        _users[index] = _users[index].copyWith(isActive: newStatus);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
