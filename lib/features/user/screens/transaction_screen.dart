import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../providers/order_provider.dart';

class TransactionScreen extends ConsumerWidget {
  static const routeName = '/transactions';
  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(userOrdersProvider);

    final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions '),
      ),
      body: ordersAsync.when(
        data: (orders) {
          final transactions = orders
              .where((order) => order.id != null)
              .map((order) {
            DateTime? parsedDate;
            if (order.createdAt != null) {
              try {
                parsedDate = DateTime.parse(order.createdAt!);
              } catch (_) {
                parsedDate = null;
              }
            }
            return {
              'orderId': order.id,
              'amount': order.totalAmount,
              'status': order.status,
              'date': parsedDate,
            };
          })
              .toList();

          if (transactions.isEmpty) {
            return const Center(child: Text('No transactions found.'));
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(userOrdersProvider.future),
            child: ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (ctx, index) {
                final tx = transactions[index];
                final amount = tx['amount'] as num?;
                final date = tx['date'] as DateTime?;

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: const Icon(Icons.payment),
                    title: Text('Order #${tx['orderId']} Transaction'),
                    subtitle: Text(
                        'Amount: ${amount?.toStringAsFixed(2) ?? 'N/A'}đ\nStatus: ${tx['status'] ?? 'Unknown'}'),
                    trailing: Text(date != null ? dateFormatter.format(date) : ''),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading data: $err')),
      ),
    );
  }
}