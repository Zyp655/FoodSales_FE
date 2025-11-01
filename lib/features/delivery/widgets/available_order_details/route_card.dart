import 'package:cnpm_ptpm/models/order.dart';
import 'package:flutter/material.dart';
import 'info_card.dart';

class RouteCard extends StatelessWidget {
  final Order order;

  const RouteCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final distance = order.distanceKm ?? 0;

    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Route (${distance.toStringAsFixed(1)} km)',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const Divider(height: 15),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.storefront, color: Colors.orange),
            title: Text(
              order.seller?.name ?? 'Unknown Seller',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(order.seller?.address ?? 'No address provided'),
          ),
          const Divider(height: 10),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.person_pin_circle, color: Colors.blue),
            title: Text(
              order.user?.name ?? 'Unknown Customer',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(order.deliveryAddress ?? 'No address provided'),
          ),
        ],
      ),
    );
  }
}