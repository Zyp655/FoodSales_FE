import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'info_card.dart';
import 'info_row.dart';

class CommissionCard extends StatelessWidget {
  final double commissionAmount;
  final double totalAmount;
  final NumberFormat formatter;

  const CommissionCard({
    super.key,
    required this.commissionAmount,
    required this.totalAmount,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        children: [
          InfoRow(
            title: 'Your Commission',
            value: formatter.format(commissionAmount),
            valueColor: Colors.green,
            isBold: true,
          ),
          const Divider(height: 15),
          InfoRow(
            title: 'Order Total',
            value: formatter.format(totalAmount),
          ),
        ],
      ),
    );
  }
}