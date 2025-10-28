import 'package:cnpm_ptpm/features/user/screens/cart_screen.dart';
import 'package:cnpm_ptpm/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/banner_section.dart';
import '../widgets/seller_section.dart';
import 'search_screen.dart';

class UserAppMainScreen extends ConsumerWidget {
  const UserAppMainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sellersAsync = ref.watch(sellersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Food Sales App',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Consumer(
              builder: (context, ref, child) {
                final cartState = ref.watch(cartProvider);
                final cartItemCount = cartState.totalItemCount;
                return Badge(
                  label: Text(cartItemCount.toString()),
                  isLabelVisible: cartItemCount > 0,
                  child: IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    tooltip: 'Cart',
                    onPressed: () {
                      Navigator.of(context).pushNamed(CartScreen.routeName);
                    },
                  ),
                );
              },
            ),
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
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(SearchScreen.routeName);
              },
              child: Container(
                margin: const EdgeInsets.all(15.0),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 10),
                    Text('Search Sellers or Products...',
                        style: TextStyle(color: Colors.grey[700])),
                  ],
                ),
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
                    return const Center(
                        child: Text('No sellers available right now.'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 10),
                    itemCount: sellers.length,
                    itemBuilder: (context, index) {
                      final seller = sellers[index];
                      return SellerSection(seller: seller);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) =>
                    Center(child: Text('Error loading sellers: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}