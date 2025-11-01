import 'package:cnpm_ptpm/models/order.dart';
import 'package:flutter/material.dart';
import 'info_card.dart';

class ProductListCard extends StatelessWidget {
  final Order order;
  const ProductListCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Products',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          if (order.items == null || order.items!.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text('No product information available.'),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.items!.length,
              itemBuilder: (ctx, index) {
                final item = order.items![index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(item.product?.name ?? 'Unknown product'),
                  trailing: Text('x ${item.quantity}'),
                );
              },
            ),
        ],
      ),
    );
  }
}