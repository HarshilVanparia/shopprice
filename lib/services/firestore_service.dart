import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import '../models/unit.dart';
import '../models/user.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  final String usersCollection = 'users';
  final String itemsCollection = 'items';
  final String categoriesCollection = 'categories';
  final String unitsCollection = 'units';
  final String activityLogsCollection = 'activity_logs';

  // ===================== ITEMS =====================

  /// Add a new item with duplicate validation
  Future<void> addItem(Item item) async {
    try {
      // Check for duplicate: same name + categoryId
      final query = await _firestore
          .collection(itemsCollection)
          .where('name', isEqualTo: item.name.toLowerCase())
          .where('categoryId', isEqualTo: item.category)
          .get();

      if (query.docs.isNotEmpty) {
        throw Exception('Item with this name already exists in this category');
      }

      await _firestore
          .collection(itemsCollection)
          .doc(item.id)
          .set(item.toMap());
    } catch (e) {
      rethrow;
    }
  }

  /// Get all items as stream
  Stream<List<Item>> getItemsStream() {
    return _firestore
        .collection(itemsCollection)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Item.fromMap(doc.data())).toList();
    });
  }

  /// Get single item
  Future<Item?> getItem(String itemId) async {
    try {
      final doc =
          await _firestore.collection(itemsCollection).doc(itemId).get();
      if (doc.exists) {
        return Item.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Update item with duplicate validation
  Future<void> updateItem(Item item) async {
    try {
      // Check for duplicate (excluding current item)
      final query = await _firestore
          .collection(itemsCollection)
          .where('name', isEqualTo: item.name.toLowerCase())
          .where('categoryId', isEqualTo: item.category)
          .get();

      if (query.docs.isNotEmpty && query.docs.first.id != item.id) {
        throw Exception('Item with this name already exists in this category');
      }

      await _firestore
          .collection(itemsCollection)
          .doc(item.id)
          .update(item.toMap());
    } catch (e) {
      rethrow;
    }
  }

  /// Delete item
  Future<void> deleteItem(String itemId) async {
    try {
      await _firestore.collection(itemsCollection).doc(itemId).delete();
    } catch (e) {
      rethrow;
    }
  }

  /// Search items by name or brand
  Future<List<Item>> searchItems(String query) async {
    try {
      final queryLower = query.toLowerCase();
      final snapshot = await _firestore
          .collection(itemsCollection)
          .get();
      
      return snapshot.docs
          .map((doc) => Item.fromMap(doc.data()))
          .where((item) =>
              item.name.toLowerCase().contains(queryLower) ||
              item.brand.toLowerCase().contains(queryLower))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // ===================== CATEGORIES =====================

  /// Add a new category with duplicate validation
  Future<void> addCategory(Category category) async {
    try {
      final query = await _firestore
          .collection(categoriesCollection)
          .where('name', isEqualTo: category.name.toLowerCase())
          .get();

      if (query.docs.isNotEmpty) {
        throw Exception('Category with this name already exists');
      }

      await _firestore
          .collection(categoriesCollection)
          .doc(category.id)
          .set(category.toMap());
    } catch (e) {
      rethrow;
    }
  }

  /// Get all categories as stream
  Stream<List<Category>> getCategoriesStream() {
    return _firestore
        .collection(categoriesCollection)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Category.fromMap(doc.data()))
          .toList();
    });
  }

  /// Get single category
  Future<Category?> getCategory(String categoryId) async {
    try {
      final doc = await _firestore
          .collection(categoriesCollection)
          .doc(categoryId)
          .get();
      if (doc.exists) {
        return Category.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Update category
  Future<void> updateCategory(Category category) async {
    try {
      final query = await _firestore
          .collection(categoriesCollection)
          .where('name', isEqualTo: category.name.toLowerCase())
          .get();

      if (query.docs.isNotEmpty && query.docs.first.id != category.id) {
        throw Exception('Category with this name already exists');
      }

      await _firestore
          .collection(categoriesCollection)
          .doc(category.id)
          .update(category.toMap());
    } catch (e) {
      rethrow;
    }
  }

  /// Delete category
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _firestore.collection(categoriesCollection).doc(categoryId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // ===================== UNITS =====================

  /// Add a new unit with duplicate validation
  Future<void> addUnit(Unit unit) async {
    try {
      final query = await _firestore
          .collection(unitsCollection)
          .where('name', isEqualTo: unit.name.toLowerCase())
          .get();

      if (query.docs.isNotEmpty) {
        throw Exception('Unit with this name already exists');
      }

      await _firestore.collection(unitsCollection).doc(unit.id).set(unit.toMap());
    } catch (e) {
      rethrow;
    }
  }

  /// Get all units as stream
  Stream<List<Unit>> getUnitsStream() {
    return _firestore
        .collection(unitsCollection)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Unit.fromMap(doc.data())).toList();
    });
  }

  /// Get single unit
  Future<Unit?> getUnit(String unitId) async {
    try {
      final doc =
          await _firestore.collection(unitsCollection).doc(unitId).get();
      if (doc.exists) {
        return Unit.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Update unit
  Future<void> updateUnit(Unit unit) async {
    try {
      final query = await _firestore
          .collection(unitsCollection)
          .where('name', isEqualTo: unit.name.toLowerCase())
          .get();

      if (query.docs.isNotEmpty && query.docs.first.id != unit.id) {
        throw Exception('Unit with this name already exists');
      }

      await _firestore
          .collection(unitsCollection)
          .doc(unit.id)
          .update(unit.toMap());
    } catch (e) {
      rethrow;
    }
  }

  /// Delete unit
  Future<void> deleteUnit(String unitId) async {
    try {
      await _firestore.collection(unitsCollection).doc(unitId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // ===================== USERS =====================

  /// Create user document (called after Firebase Auth registration)
  Future<void> createUserDocument(User user) async {
    try {
      await _firestore.collection(usersCollection).doc(user.id).set(user.toMap());
    } catch (e) {
      rethrow;
    }
  }

  /// Get user by ID
  Future<User?> getUser(String userId) async {
    try {
      final doc =
          await _firestore.collection(usersCollection).doc(userId).get();
      if (doc.exists) {
        return User.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Get user by phone number
  Future<User?> getUserByPhoneNumber(String phoneNumber) async {
    try {
      final query = await _firestore
          .collection(usersCollection)
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        return User.fromMap(query.docs.first.data());
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Get user by phone number and password
  Future<User?> getUserByPhoneAndPassword(
    String phoneNumber,
    String password,
  ) async {
    try {
      final query = await _firestore
          .collection(usersCollection)
          .where('phoneNumber', isEqualTo: phoneNumber)
          .where('password', isEqualTo: password)
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        return User.fromMap(query.docs.first.data());
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Get all users (admin only)
  Future<List<User>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection(usersCollection).get();
      return snapshot.docs.map((doc) => User.fromMap(doc.data())).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get all workers
  Future<List<User>> getWorkers() async {
    try {
      final snapshot = await _firestore
          .collection(usersCollection)
          .where('role', isEqualTo: 'worker')
          .get();
      return snapshot.docs.map((doc) => User.fromMap(doc.data())).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Update user
  Future<void> updateUser(User user) async {
    try {
      await _firestore
          .collection(usersCollection)
          .doc(user.id)
          .update(user.toMap());
    } catch (e) {
      rethrow;
    }
  }

  /// Set user (create or update)
  Future<void> setUser(User user) async {
    try {
      await _firestore.collection(usersCollection).doc(user.id).set(user.toMap());
    } catch (e) {
      rethrow;
    }
  }

  /// Set category (create or update)
  Future<void> setCategory(Category category) async {
    try {
      await _firestore.collection(categoriesCollection).doc(category.id).set(category.toMap());
    } catch (e) {
      rethrow;
    }
  }

  /// Set unit (create or update)
  Future<void> setUnit(Unit unit) async {
    try {
      await _firestore.collection(unitsCollection).doc(unit.id).set(unit.toMap());
    } catch (e) {
      rethrow;
    }
  }

  /// Set item (create or update)
  Future<void> setItem(Item item) async {
    try {
      await _firestore.collection(itemsCollection).doc(item.id).set(item.toMap());
    } catch (e) {
      rethrow;
    }
  }

  /// Delete user
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection(usersCollection).doc(userId).delete();
    } catch (e) {
      rethrow;
    }
  }

  /// Toggle user active status
  Future<void> toggleUserActive(String userId, bool isActive) async {
    try {
      await _firestore
          .collection(usersCollection)
          .doc(userId)
          .update({'isActive': isActive});
    } catch (e) {
      rethrow;
    }
  }

  /// Log user activity
  Future<void> logActivity(String userId, String action) async {
    try {
      await _firestore.collection(activityLogsCollection).add({
        'userId': userId,
        'action': action,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }
}
