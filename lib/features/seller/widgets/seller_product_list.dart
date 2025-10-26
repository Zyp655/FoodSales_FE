import 'package:cnpm_ptpm/providers/seller_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'product_list_item.dart';

class SellerProductList extends ConsumerStatefulWidget {
  const SellerProductList({super.key});

  @override
  ConsumerState<SellerProductList> createState() => _SellerProductListState();
}

class _SellerProductListState extends ConsumerState<SellerProductList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && ref.read(sellerProvider).myProducts.isEmpty && !ref.read(sellerProvider).isLoading) {
        ref.read(sellerProvider.notifier).fetchMyProducts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sellerState = ref.watch(sellerProvider);
    final products = sellerState.myProducts;

    if (sellerState.isLoading && products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (sellerState.error != null) {
      return Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error loading products: ${sellerState.error}'),
                ElevatedButton(onPressed: ()=> ref.read(sellerProvider.notifier).fetchMyProducts(), child: Text('Retry'))
              ]
          )
      );
    }
    if (products.isEmpty) {
      return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('You have no products yet. Add one!'),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                onPressed: () => ref.read(sellerProvider.notifier).fetchMyProducts(),
              )
            ],
          )
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(sellerProvider.notifier).fetchMyProducts(),
      child: ListView.builder(
        itemCount: products.length,
        itemBuilder: (ctx, index) => ProductListItem(product: products[index]),
      ),
    );
  }
}