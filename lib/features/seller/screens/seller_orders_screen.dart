import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cnpm_ptpm/providers/seller_provider.dart';
import 'package:cnpm_ptpm/models/order.dart';
import '../widgets/seller_order_list_item.dart';

class SellerOrdersScreen extends ConsumerWidget {
  static const routeName = '/seller-orders';
  final String? filterStatus;
  final bool showAppBar;

  const SellerOrdersScreen({
    super.key,
    this.filterStatus,
    required this.showAppBar,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(sellerOrdersProvider);

    String title = 'All Orders';
    if (filterStatus == 'Completed') title = 'Completed Orders';
    if (filterStatus == 'Pending') title = 'Pending Orders';
    if (filterStatus == 'InTransit') title = 'In Transit Orders';
    if (filterStatus == 'Cancelled') title = 'Cancelled Orders';

    Widget content = ordersAsync.when(
      data: (orders) {
        List<Order> filteredOrders;

        if (filterStatus == 'Completed') {
          filteredOrders =
              orders.where((o) => o.status == Order.STATUS_DELIVERED).toList();
        } else if (filterStatus == 'Pending') {
          filteredOrders = orders
              .where((o) =>
          o.status == Order.STATUS_PENDING ||
              o.status == Order.STATUS_PROCESSING ||
              o.status == Order.STATUS_READY_FOR_PICKUP)
              .toList();
        } else if (filterStatus == 'InTransit') {
          filteredOrders = orders
              .where((o) =>
          o.status == Order.STATUS_PICKING_UP ||
              o.status == Order.STATUS_IN_TRANSIT)
              .toList();
        } else if (filterStatus == 'Cancelled') {
          filteredOrders =
              orders.where((o) => o.status == Order.STATUS_CANCELLED).toList();
        } else {
          filteredOrders = orders;
        }

        if (filteredOrders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(filterStatus != null
                    ? 'No orders found with status: "$filterStatus".'
                    : 'No orders found yet.'),
                ElevatedButton(
                  onPressed: () => ref.invalidate(sellerOrdersProvider),
                  child: const Text('Reload'),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(sellerOrdersProvider),
          child: ListView.builder(
            itemCount: filteredOrders.length,
            itemBuilder: (ctx, index) =>
                SellerOrderListItem(order: filteredOrders[index]),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) =>
          Center(child: Text('Oops, have an error for orders: $err')),
    );

    if (showAppBar) {
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: content,
      );
    }

    return content;
  }
}