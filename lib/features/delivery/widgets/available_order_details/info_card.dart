import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final Widget child;
  const InfoCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: child,
      ),
    );
  }
}