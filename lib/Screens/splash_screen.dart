import 'dart:async';

import 'package:cnpm_ptpm/Screens/sellers_screen.dart';
import 'package:cnpm_ptpm/server_handle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool showLoadingSellers = false;
  dynamic _timer;

  void getSellers() {
    ServerHandler()
        .getSellers()
        .then((value) => Navigator.of(context).popAndPushNamed(SellersScreen.routeName))
        .catchError((e)=> print(e));
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer(
        const Duration(seconds: 3),
            () {
          showLoadingSellers = true;
          setState(() {});
          getSellers();
        });
  }

  @override
  void dispose() {
    _timer.cancel;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        color: const Color(0xffE6F3EC),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'CNPM-PTPM',
              style: GoogleFonts.pacifico(
                color: Colors.blueAccent,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (showLoadingSellers)
              const SizedBox(
                height: 20.0,
                width: 20.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xff4E8489)),
                  strokeWidth: 1.6,
                ),
              ),
            if (showLoadingSellers)
              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text('Loading Sellers', style: GoogleFonts.poppins()),
              ),
          ],
        ),
      ),
    );
  }


}
