import 'package:cnpm_ptpm/features/auth/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cnpm_ptpm/features/user/screens/sellers_screen.dart';
import 'features/user/screens/product_screen.dart';

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
      home: const SplashScreen(),
      routes: {
        SellersScreen.routeName: (context) => const SellersScreen(),
        ProductScreen.routeName: (context) => const ProductScreen(),
      },
    );
  }
}