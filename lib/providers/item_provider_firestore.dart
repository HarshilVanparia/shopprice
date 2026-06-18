import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';

class ItemProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Item> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Item> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Initialize items from Firestore stream
  void initializeItemsStream() {
    try {
      _firestoreService.getItemsStream().listen(
        (items) {
          _items = items;
          _errorMessage = null;
          notifyListeners();
        },
        onError: (error) {
          _errorMessage = 'Failed to load items: $error';
          print('ItemProvider Error: $_errorMessage');
          notifyListeners();
        },
      );
    } catch (e) {
      _errorMessage = 'Error initializing items: $e';
      print('ItemProvider Exception: $_errorMessage');
      notifyListeners();
    }
  }

  /// Fetch all items once
  Future<void> fetchItems() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Using stream - this will auto-update
      initializeItemsStream();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to fetch items: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add new item
  Future<bool> addItem(Item item) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firestoreService.addItem(item);

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

  /// Update item
  Future<bool> updateItem(Item item) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firestoreService.updateItem(item);

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

  /// Delete item
  Future<bool> deleteItem(String itemId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firestoreService.deleteItem(itemId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete item: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Search items
  Future<List<Item>> searchItems(String query) async {
    try {
      return await _firestoreService.searchItems(query);
    } catch (e) {
      _errorMessage = 'Search failed: $e';
      notifyListeners();
      return [];
    }
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
