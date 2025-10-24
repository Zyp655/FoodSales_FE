import 'package:cnpm_ptpm/features/auth/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/user/screens/product_screen.dart';
import 'features/user/screens/user_home_screen.dart';

void main() => runApp(
  const ProviderScope(
    child: MyApp(),
  ),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CNPTM_PTPM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginScreen(),
      routes: {
        UserHomeScreen.routeName: (context) => const UserHomeScreen(),
        ProductScreen.routeName: (context) => const ProductScreen(),
      },
    );
  }
}