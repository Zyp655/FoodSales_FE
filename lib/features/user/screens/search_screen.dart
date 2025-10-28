import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cnpm_ptpm/providers/user_provider.dart';
import 'package:cnpm_ptpm/models/product.dart';
import 'package:cnpm_ptpm/models/seller.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'product_detail_screen.dart';
import 'seller_detail_screen.dart';

final debouncedSearchQueryProvider = StateProvider<String>((ref) => '');

class SearchScreen extends ConsumerStatefulWidget {
  static const routeName = '/search';

  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        ref.read(debouncedSearchQueryProvider.notifier).state =
            _searchController.text;
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(debouncedSearchQueryProvider);
    final searchResultsAsync = ref.watch(combinedSearchProvider(query));

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search products or sellers...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white),
          ),
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: searchResultsAsync.when(
              data: (results) {
                if (query.trim().isEmpty) {
                  return const Center(
                    child: Text('Enter a search term above.'),
                  );
                }
                if (results.products.isEmpty && results.sellers.isEmpty) {
                  return const Center(
                      child: Text("Don't have product or seller like that"));
                }

                return ListView(
                  children: [
                    if (results.products.isNotEmpty)
                      _buildSectionHeader(
                        context,
                        'Matching Products (${results.products.length})',
                      ),
                    ...results.products
                        .map(
                          (product) =>
                          _buildProductResultItem(context, product),
                    )
                        .toList(),
                    if (results.sellers.isNotEmpty)
                      _buildSectionHeader(
                        context,
                        'Matching Sellers (${results.sellers.length})',
                      ),
                    ...results.sellers
                        .map(
                          (seller) => _buildSellerResultItem(context, seller),
                    )
                        .toList(),
                  ],
                );
              },
              loading: () {
                return query.trim().isEmpty
                    ? const Center(child: Text('Enter a search term above.'))
                    : const Center(child: CircularProgressIndicator());
              },
              error: (err, stack) =>
                  Center(child: Text('Error searching: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildProductResultItem(BuildContext context, Product product) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: (product.image != null)
            ? NetworkImage('http://10.0.2.2:8000/storage/${product.image!}')
            : null,
        onBackgroundImageError: (product.image != null)
            ? (e, s) { print('Image load error: $e'); }
            : null,
        child: (product.image == null) ? const Icon(Icons.shopping_bag) : null,
      ),
      title: Text(product.name ?? 'No Name'),
      subtitle: Text(
        'by ${product.seller?.name ?? 'Unknown Seller'} - ${product.pricePerKg?.toStringAsFixed(0) ?? '0'}đ/kg',
      ),
      onTap: () {
        Navigator.of(
          context,
        ).pushNamed(ProductDetailScreen.routeName, arguments: product);
      },
    );
  }

  Widget _buildSellerResultItem(BuildContext context, Seller seller) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: (seller.image != null)
            ? NetworkImage('http://10.0.2.2:8000/storage/${seller.image!}')
            : null,
        onBackgroundImageError: (seller.image != null)
            ? (e, s) { print('Image load error: $e'); }
            : null,
        child: (seller.image == null) ? const Icon(Icons.storefront) : null,
      ),
      title: Text(seller.name ?? 'No Name'),
      subtitle: Text(seller.address ?? 'No Address'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.of(
          context,
        ).pushNamed(SellerDetailScreen.routeName, arguments: seller);
      },
    );
  }
}