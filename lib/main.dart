import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_screen.dart';
import 'features/worker_home/home_wrapper.dart';
import 'features/admin/admin_dashboard.dart';
import 'features/admin/item_management_screen.dart';
import 'features/admin/category_management_screen.dart';
import 'features/admin/unit_management_screen.dart';
import 'features/admin/worker_management_screen.dart';
import 'features/item_detail/item_detail_screen.dart';
import 'models/models.dart';
import 'providers/auth_provider_firebase.dart';
import 'providers/item_provider_firestore.dart';
import 'providers/category_provider_firestore.dart';
import 'providers/unit_provider_firestore.dart';
import 'providers/user_provider_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..initializeAuthState()),
        ChangeNotifierProvider(create: (_) => ItemProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => UnitProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShopPrice',
      theme: AppTheme.darkTheme,
      home: const _RoleBasedRouter(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeWrapper(),
        '/admin': (context) => const AdminDashboard(),
        '/admin/items': (context) => const ItemManagementScreen(),
        '/admin/categories': (context) => const CategoryManagementScreen(),
        '/admin/units': (context) => const UnitManagementScreen(),
        '/admin/workers': (context) => const WorkerManagementScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/item_detail') {
          final item = settings.arguments as Item;
          return MaterialPageRoute(
            builder: (context) => ItemDetailScreen(item: item),
          );
        }
        return null;
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class _RoleBasedRouter extends StatelessWidget {
  const _RoleBasedRouter();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If no user logged in, show login screen
        if (!authProvider.isLoggedIn) {
          return const LoginScreen();
        }

        // User logged in - initialize data streams
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          context.read<ItemProvider>().initializeItemsStream();
          context.read<CategoryProvider>().initializeCategoriesStream();
          context.read<UnitProvider>().initializeUnitsStream();
          context.read<UserProvider>().fetchAllUsers();
        });

        // Route based on role
        if (authProvider.isAdmin) {
          return const AdminDashboard();
        } else {
          return const HomeWrapper();
        }
      },
    );
  }
}
