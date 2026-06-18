import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';

class CategoryProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Category> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Initialize categories from Firestore stream
  void initializeCategoriesStream() {
    try {
      _firestoreService.getCategoriesStream().listen(
        (categories) {
          _categories = categories;
          _errorMessage = null;
          notifyListeners();
        },
        onError: (error) {
          _errorMessage = 'Failed to load categories: $error';
          print('CategoryProvider Error: $_errorMessage');
          notifyListeners();
        },
      );
    } catch (e) {
      _errorMessage = 'Error initializing categories: $e';
      print('CategoryProvider Exception: $_errorMessage');
      notifyListeners();
    }
  }

  /// Fetch all categories once
  Future<void> fetchCategories() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Using stream - this will auto-update
      initializeCategoriesStream();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to fetch categories: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add new category
  Future<bool> addCategory(Category category) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firestoreService.addCategory(category);

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

  /// Update category
  Future<bool> updateCategory(Category category) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firestoreService.updateCategory(category);

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

  /// Delete category
  Future<bool> deleteCategory(String categoryId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firestoreService.deleteCategory(categoryId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete category: $e';
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
