import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cnpm_ptpm/models/order.dart';
import '../widgets/seller_order_list_item.dart';


final sellerOrdersProvider = FutureProvider<List<Order>>((ref) async {
  await Future.delayed(const Duration(seconds: 1));
  return [];
});

class SellerOrdersScreen extends ConsumerWidget {
  static const routeName = '/seller-orders';
  const SellerOrdersScreen({super.key});



  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(sellerOrdersProvider);

    return Scaffold(

      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('No incoming orders.'),
                      ElevatedButton(
                          onPressed: ()=> ref.invalidate(sellerOrdersProvider),
                          child: Text('Refresh')
                      )
                    ]
                )
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(sellerOrdersProvider),
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (ctx, index) => SellerOrderListItem(order: orders[index]),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading orders: $err')),
      ),
    );
  }
}