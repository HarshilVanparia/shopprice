import 'package:flutter/material.dart';
import '../models/unit.dart';
import '../services/firestore_service.dart';

class UnitProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Unit> _units = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Unit> get units => _units;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Initialize units from Firestore stream
  void initializeUnitsStream() {
    try {
      _firestoreService.getUnitsStream().listen(
        (units) {
          _units = units;
          _errorMessage = null;
          notifyListeners();
        },
        onError: (error) {
          _errorMessage = 'Failed to load units: $error';
          print('UnitProvider Error: $_errorMessage');
          notifyListeners();
        },
      );
    } catch (e) {
      _errorMessage = 'Error initializing units: $e';
      print('UnitProvider Exception: $_errorMessage');
      notifyListeners();
    }
  }

  /// Fetch all units once
  Future<void> fetchUnits() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Using stream - this will auto-update
      initializeUnitsStream();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to fetch units: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add new unit
  Future<bool> addUnit(Unit unit) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firestoreService.addUnit(unit);

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

  /// Update unit
  Future<bool> updateUnit(Unit unit) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firestoreService.updateUnit(unit);

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

  /// Delete unit
  Future<bool> deleteUnit(String unitId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firestoreService.deleteUnit(unitId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete unit: $e';
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
