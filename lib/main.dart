import 'package:cnpm_ptpm/features/admin/screens/admin_dashboard_screen.dart';
import 'package:cnpm_ptpm/features/auth/screens/login_screen.dart';
import 'package:cnpm_ptpm/features/auth/screens/splash_screen.dart';
import 'package:cnpm_ptpm/features/delivery/screens/delivery_home_screen.dart';
import 'package:cnpm_ptpm/features/seller/screens/seller_dashboard_screen.dart';
import 'package:cnpm_ptpm/providers/shared_preferences_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_router.dart';
import 'package:cnpm_ptpm/providers/auth_provider.dart';

import 'features/user/screens/user_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Sales App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
          ),
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState.isLoading) {
      return const SplashScreen();
    }

    if (authState.currentUser != null) {
      final role = authState.currentUser!.role;
      if (role == 'admin') {
        return const AdminDashboardScreen();
      } else if (role == 'seller') {
        return const SellerDashboardScreen();
      } else if (role == 'delivery') {
        return const DeliveryHomeScreen();
      } else {
        return const UserHomeScreen();
      }
    }

    return const LoginScreen();
  }
}