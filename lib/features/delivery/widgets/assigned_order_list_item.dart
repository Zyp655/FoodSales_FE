import 'package:cnpm_ptpm/models/order.dart';
import 'package:flutter/material.dart';
import '../screens/delivery_order_detail_screen.dart';

class AssignedOrderListItem extends StatelessWidget {
  final Order order;
  const AssignedOrderListItem({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        leading: CircleAvatar(child: Text('#${order.id}')),
        title: Text('To: ${order.deliveryAddress ?? 'N/A'}'),
        subtitle: Text('From: ${order.seller?.name ?? 'Unknown'}'),
        trailing: Chip(
          label: Text(order.status ?? 'N/A', style: const TextStyle(fontSize: 12)),
          backgroundColor: _getStatusColor(order.status),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
          visualDensity: VisualDensity.compact,
        ),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => DeliveryOrderDetailScreen(order: order),
          ));
        },
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch(status?.toLowerCase()) {
      case 'Picking Up': return Colors.orange.shade100;
      case 'Delivered': return Colors.green.shade100;
      case 'failed': return Colors.red.shade100;
      default: return Colors.blue.shade50;
    }
  }
}