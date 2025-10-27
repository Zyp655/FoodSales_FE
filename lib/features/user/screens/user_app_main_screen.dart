import 'package:cnpm_ptpm/features/user/screens/cart_screen.dart';
import 'package:cnpm_ptpm/models/seller.dart';
import 'package:cnpm_ptpm/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/banner_section.dart';
import '../widgets/seller_section.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

class UserAppMainScreen extends ConsumerWidget {
  const UserAppMainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sellersAsync = ref.watch(sellersProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    final filteredSellers = sellersAsync.when(
      data: (sellers) => sellers.where((seller) {
        return seller.name
            ?.toLowerCase()
            .contains(searchQuery.toLowerCase()) ??
            false;
      }).toList(),
      loading: () => <Seller>[],
      error: (e, s) => <Seller>[],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Food Sales App',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            tooltip: 'Cart',
            onPressed: () {
              Navigator.of(context).pushNamed(CartScreen.routeName);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(sellersProvider);
          await ref.read(sellersProvider.future);
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search Sellers...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                ),
                onChanged: (value) {
                  ref.read(searchQueryProvider.notifier).state = value;
                },
              ),
            ),
            sellersAsync.when(
              data: (sellers) => sellers.isNotEmpty
                  ? BannerSection(seller: sellers.first)
                  : const SizedBox.shrink(),
              loading: () => const SizedBox(height: 150),
              error: (e, s) => const SizedBox.shrink(),
            ),
            Expanded(
              child: sellersAsync.when(
                data: (sellers) {
                  if (sellers.isEmpty) {
                    return const Center(child: Text('No sellers available right now.'));
                  }
                  if (filteredSellers.isEmpty && searchQuery.isNotEmpty) {
                    return const Center(child: Text('No sellers found matching your search.'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 10),
                    itemCount: filteredSellers.length,
                    itemBuilder: (context, index) {
                      final seller = filteredSellers[index];
                      return SellerSection(seller: seller);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error loading sellers: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}