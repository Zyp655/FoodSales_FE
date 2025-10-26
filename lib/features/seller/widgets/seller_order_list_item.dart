import 'package:cnpm_ptpm/models/order.dart';
import 'package:flutter/material.dart';
import '../screens/seller_order_detail_screen.dart';

class SellerOrderListItem extends StatelessWidget {
  final Order order;
  const SellerOrderListItem({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        leading: CircleAvatar(child: Text('#${order.id}')),
        title: Text('Customer: ${order.user?.name ?? 'Unknown'}'),
        subtitle: Text('Total: ${order.totalAmount?.toStringAsFixed(0) ?? '0'}đ'),
        trailing: Chip(
          label: Text(order.status ?? 'N/A', style: const TextStyle(fontSize: 12)),
          backgroundColor: _getStatusColor(order.status),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
          visualDensity: VisualDensity.compact,
        ),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => SellerOrderDetailScreen(order: order),
          ));
        },
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch(status?.toLowerCase()) {
      case 'preparing': return Colors.yellow.shade100;
      case 'ready_for_pickup': return Colors.lightBlue.shade50;
      case 'delivered': return Colors.green.shade100;
      case 'cancelled':
      case 'failed': return Colors.red.shade100;
      default: return Colors.grey.shade200;
    }
  }
}