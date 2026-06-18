import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/item_provider_firestore.dart';
import '../../providers/category_provider_firestore.dart';
import '../../providers/unit_provider_firestore.dart';
import '../../providers/user_provider_firestore.dart';
import '../../providers/auth_provider_firebase.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  static const List<String> _backupCollections = <String>[
    'items',
    'categories',
    'units',
    'users',
    'activity_logs',
  ];

  static const List<String> _weekdayNames = <String>[
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.import_export),
            onSelected: (value) {
              if (value == 'export') {
                _exportBackup(context);
              } else if (value == 'import') {
                _pickImportBackupFile(context);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'export', child: Text('Export Backup')),
              PopupMenuItem(value: 'import', child: Text('Import Backup')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome header
              Text(
                'Welcome, Admin!',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              // Stats cards
              _buildStatsGrid(context),
              const SizedBox(height: AppSizes.paddingLarge),
              // Quick actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              _buildQuickActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return Consumer4<ItemProvider, CategoryProvider, UnitProvider, UserProvider>(
      builder: (context, itemProvider, categoryProvider, unitProvider, userProvider, _) {
        return GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: AppSizes.paddingMedium,
          mainAxisSpacing: AppSizes.paddingMedium,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildStatCard(
              context,
              'Items',
              itemProvider.items.length.toString(),
              Icons.shopping_bag,
            ),
            _buildStatCard(
              context,
              'Categories',
              categoryProvider.categories.length.toString(),
              Icons.category,
            ),
            _buildStatCard(
              context,
              'Units',
              unitProvider.units.length.toString(),
              Icons.scale,
            ),
            _buildStatCard(
              context,
              'Users',
              userProvider.users.length.toString(),
              Icons.people,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(icon, size: 32, color: AppColors.primary),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      children: [
        _buildActionButton(
          context,
          'Manage Item',
          Icons.add_shopping_cart,
          () => Navigator.pushNamed(context, '/admin/items'),
        ),
        const SizedBox(height: AppSizes.paddingSmall),
        _buildActionButton(
          context,
          'Manage Categories',
          Icons.category,
          () => Navigator.pushNamed(context, '/admin/categories'),
        ),
        const SizedBox(height: AppSizes.paddingSmall),
        _buildActionButton(
          context,
          'Manage Units',
          Icons.scale,
          () => Navigator.pushNamed(context, '/admin/units'),
        ),
        const SizedBox(height: AppSizes.paddingSmall),
        _buildActionButton(
          context,
          'Manage Users',
          Icons.people,
          () => Navigator.pushNamed(context, '/admin/workers'),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(width: AppSizes.paddingMedium),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.neutral),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportBackup(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      final backup = await _buildBackupData();
      final jsonText = const JsonEncoder.withIndent('  ').convert(backup);
      final fileName = _buildBackupFileName(DateTime.now());

      // Write to temporary file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsString(jsonText);

      if (!messenger.mounted) {
        return;
      }

      // Show native share dialog
      await Share.shareXFiles(
        [XFile(tempFile.path, mimeType: 'application/json')],
        subject: 'ShopPrice Backup - $fileName',
      );

      if (!messenger.mounted) {
        return;
      }

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Backup ready to share. Choose location or app.'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (error) {
      if (!messenger.mounted) {
        return;
      }

      messenger.showSnackBar(
        SnackBar(
          content: Text('Export failed: $error'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _pickImportBackupFile(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: <String>['json'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        if (!messenger.mounted) {
          return;
        }

        messenger.showSnackBar(
          const SnackBar(content: Text('Import cancelled.')),
        );
        return;
      }

      final file = result.files.single;
      final bytes = file.bytes;

      if (bytes == null || bytes.isEmpty) {
        if (!messenger.mounted) {
          return;
        }

        messenger.showSnackBar(
          const SnackBar(content: Text('The selected file could not be read.')),
        );
        return;
      }

      final backupData = _parseBackupJson(utf8.decode(bytes));
      if (backupData == null) {
        if (!messenger.mounted) {
          return;
        }

        messenger.showSnackBar(
          const SnackBar(content: Text('Invalid or corrupted backup file.')),
        );
        return;
      }

      // ignore: use_build_context_synchronously
      final shouldImport = await _showOverwriteConfirmation(context, file.name);
      if (!shouldImport || !messenger.mounted) {
        return;
      }

      // ignore: use_build_context_synchronously
      await _restoreBackup(context, backupData);
    } catch (error) {
      if (!messenger.mounted) {
        return;
      }

      messenger.showSnackBar(
        SnackBar(
          content: Text('Import failed: $error'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<bool> _showOverwriteConfirmation(BuildContext context, String fileName) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Overwrite Existing Data?'),
          content: Text(
            'Importing $fileName will replace the current Firestore data in all backup collections. This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Overwrite'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<void> _restoreBackup(BuildContext context, Map<String, dynamic> backupData) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      final categoryProvider = context.read<CategoryProvider>();
      final unitProvider = context.read<UnitProvider>();
      final itemProvider = context.read<ItemProvider>();
      final userProvider = context.read<UserProvider>();

      final rawCollections = backupData['collections'];
      if (rawCollections is! Map) {
        throw const FormatException('Backup file is missing collections data.');
      }

      final collections = <String, List<Map<String, dynamic>>>{};
      for (final entry in rawCollections.entries) {
        if (entry.value is! List) {
          throw FormatException('Collection ${entry.key} is not a valid list.');
        }
        collections[entry.key.toString()] = _normalizeDocuments(entry.value as List<dynamic>);
      }

      final firestore = FirebaseFirestore.instance;
      for (final collectionName in collections.keys) {
        await _replaceCollectionDocuments(
          firestore,
          collectionName,
          collections[collectionName] ?? <Map<String, dynamic>>[],
        );
      }

      categoryProvider.initializeCategoriesStream();
      unitProvider.initializeUnitsStream();
      itemProvider.initializeItemsStream();
      await userProvider.fetchAllUsers();

      if (!messenger.mounted) {
        return;
      }

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Backup imported successfully from ${(backupData['exportedAt'] ?? 'the selected file').toString()}.',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (error) {
      if (!messenger.mounted) {
        return;
      }

      messenger.showSnackBar(
        SnackBar(
          content: Text('Import failed: $error'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _replaceCollectionDocuments(
    FirebaseFirestore firestore,
    String collectionName,
    List<Map<String, dynamic>> documents,
  ) async {
    await _clearCollection(firestore, collectionName);

    const batchSize = 400;
    for (var index = 0; index < documents.length; index += batchSize) {
      final batch = firestore.batch();
      final chunk = documents.skip(index).take(batchSize);

      for (final document in chunk) {
        final documentId = document['id']?.toString().trim() ?? '';
        if (documentId.isEmpty) {
          throw FormatException('Backup document in $collectionName is missing an id.');
        }

        final data = Map<String, dynamic>.from(document)..remove('id');
        batch.set(
          firestore.collection(collectionName).doc(documentId),
          data,
          SetOptions(merge: false),
        );
      }

      await batch.commit();
    }
  }

  Future<void> _clearCollection(FirebaseFirestore firestore, String collectionName) async {
    final collectionRef = firestore.collection(collectionName);

    while (true) {
      final snapshot = await collectionRef.limit(400).get();
      if (snapshot.docs.isEmpty) {
        break;
      }

      final batch = firestore.batch();
      for (final document in snapshot.docs) {
        batch.delete(document.reference);
      }
      await batch.commit();
    }
  }

  Future<Map<String, dynamic>> _buildBackupData() async {
    final firestore = FirebaseFirestore.instance;
    final collections = <String, List<Map<String, dynamic>>>{};

    for (final collectionName in _backupCollections) {
      final snapshot = await firestore.collection(collectionName).get();
      collections[collectionName] = snapshot.docs.map(_serializeDocument).toList();
    }

    return <String, dynamic>{
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'source': 'manual',
      'collections': collections,
    };
  }

  Map<String, dynamic> _serializeDocument(QueryDocumentSnapshot<Map<String, dynamic>> document) {
    return <String, dynamic>{
      'id': document.id,
      ..._serializeMap(document.data()),
    };
  }

  Map<String, dynamic> _serializeMap(Map<String, dynamic> map) {
    return map.map((key, value) => MapEntry(key, _serializeValue(value)));
  }

  dynamic _serializeValue(dynamic value) {
    if (value is Timestamp) {
      return value.toDate().toIso8601String();
    }
    if (value is DateTime) {
      return value.toIso8601String();
    }
    if (value is GeoPoint) {
      return <String, double>{
        'latitude': value.latitude,
        'longitude': value.longitude,
      };
    }
    if (value is DocumentReference) {
      return value.path;
    }
    if (value is Map<String, dynamic>) {
      return _serializeMap(value);
    }
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), _serializeValue(item)));
    }
    if (value is List) {
      return value.map(_serializeValue).toList();
    }
    return value;
  }

  Map<String, dynamic>? _parseBackupJson(String backupText) {
    try {
      final decoded = jsonDecode(backupText);
      if (decoded is! Map) {
        return null;
      }

      final backupMap = Map<String, dynamic>.from(decoded);
      final normalizedCollections = <String, List<Map<String, dynamic>>>{};
      final collections = backupMap['collections'];

      if (collections is Map) {
        for (final collectionName in _backupCollections) {
          final documents = collections[collectionName];
          if (documents == null) {
            normalizedCollections[collectionName] = <Map<String, dynamic>>[];
            continue;
          }
          if (documents is! List) {
            return null;
          }

          normalizedCollections[collectionName] = _normalizeDocuments(documents);
        }
      } else {
        var foundKnownCollection = false;
        for (final collectionName in _backupCollections) {
          final documents = backupMap[collectionName];
          if (documents == null) {
            normalizedCollections[collectionName] = <Map<String, dynamic>>[];
            continue;
          }
          if (documents is! List) {
            return null;
          }

          normalizedCollections[collectionName] = _normalizeDocuments(documents);
          foundKnownCollection = true;
        }

        if (!foundKnownCollection) {
          return null;
        }
      }

      return <String, dynamic>{
        'version': backupMap['version'] ?? 1,
        'exportedAt': backupMap['exportedAt']?.toString() ?? DateTime.now().toIso8601String(),
        'source': backupMap['source']?.toString() ?? 'manual',
        'collections': normalizedCollections,
      };
    } catch (_) {
      return null;
    }
  }

  List<Map<String, dynamic>> _normalizeDocuments(List<dynamic> documents) {
    return documents.map((document) {
      if (document is! Map) {
        throw const FormatException('Backup documents must be JSON objects.');
      }

      final normalized = Map<String, dynamic>.from(document);
      final documentId = normalized['id']?.toString().trim() ?? '';
      if (documentId.isEmpty) {
        throw const FormatException('Backup documents must contain an id field.');
      }

      normalized['id'] = documentId;
      return normalized;
    }).toList();
  }

  String _buildBackupFileName(DateTime dateTime) {
    final localDate = dateTime.toLocal();
    final weekdayName = _weekdayNames[localDate.weekday - 1];
    final day = localDate.day.toString().padLeft(2, '0');
    final month = localDate.month.toString().padLeft(2, '0');
    return 'backup-$weekdayName-${localDate.year}-$month-$day.json';
  }
}
