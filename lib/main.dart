import 'package:cnpm_ptpm/Screens/splash_screen.dart';
import 'package:flutter/material.dart';
import './Screens/sellers_screen.dart';
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
      routes: {
        SellersScreen.routeName: (context) => const SellersScreen(),
      },
    );
  }
}
