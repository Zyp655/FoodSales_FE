import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cnpm_ptpm/models/seller.dart';
import 'package:cnpm_ptpm/providers/user_provider.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../widgets/seller_header.dart';
import '../widgets/category_filter_chips.dart';
import '../widgets/product_grid_item.dart';

final selectedCategoryProvider = StateProvider<int?>((ref) => null);

class SellerDetailScreen extends ConsumerWidget {
  static const routeName = '/seller-detail';
  final Seller seller;

  const SellerDetailScreen({super.key, required this.seller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productSearchProvider(
      (sellerId: seller.id!, query: null),
    ));
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCategoryId = ref.watch(selectedCategoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(seller.name ?? 'Seller Details'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SellerHeader(seller: seller),
          categoriesAsync.when(
            data: (allCategories) => productsAsync.when(
              data: (products) => CategoryFilterChips(
                allCategories: allCategories,
                productsInSeller: products,
              ),
              loading: () => const SizedBox.shrink(),
              error: (e,s)=> const SizedBox.shrink(),
            ),
            loading: () => const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('categories error: $err'),
            ),
          ),
          Expanded(
            child: productsAsync.when(
              data: (products) {
                final filteredProducts = selectedCategoryId == null
                    ? products
                    : products.where((p) => p.categoryId == selectedCategoryId).toList();

                if (filteredProducts.isEmpty) {
                  return Center(
                    child: Text(selectedCategoryId == null
                        ? 'Seller dont have any product .'
                        : 'nothing in this category'),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(10.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (ctx, index) {
                    return ProductGridItem(product: filteredProducts[index]);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('product error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}