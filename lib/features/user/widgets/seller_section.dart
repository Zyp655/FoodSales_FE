import 'package:cnpm_ptpm/features/user/screens/seller_detail_screen.dart';
import 'package:cnpm_ptpm/models/seller.dart';
import 'package:cnpm_ptpm/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'product_preview_card.dart';

class SellerSection extends ConsumerWidget {
  final Seller seller;
  const SellerSection({super.key, required this.seller});

  void _navigateToSellerDetailScreen(BuildContext context) {
    Navigator.of(context).pushNamed(
      SellerDetailScreen.routeName,
      arguments: seller,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productPreviewAsync = ref.watch(productSearchProvider(
      (sellerId: seller.id!, query: null),
    ));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _navigateToSellerDetailScreen(context),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: (seller.image != null)
                      ? NetworkImage('http://10.0.2.2:8000/storage/${seller.image!}')
                      : null,
                  onBackgroundImageError: (seller.image != null)
                      ? (e, s) { print('Image load error: $e'); }
                      : null,
                  child: (seller.image == null)
                      ? const Icon(Icons.storefront, size: 25)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          seller.name ?? 'Unknown Seller',
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          seller.address ?? 'No address',
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    )
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
          const Divider(height: 20),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text("Featured Products", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
          productPreviewAsync.when(
            data: (allProducts) {
              final previewProducts = allProducts.take(4).toList();
              if (previewProducts.isEmpty) {
                return const Text('No products available from this seller yet.');
              }
              return SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: previewProducts.length,
                  itemBuilder: (ctx, index) {
                    final product = previewProducts[index];
                    return ProductPreviewCard(product: product);
                  },
                ),
              );
            },
            loading: () => const SizedBox(height: 160, child: Center(child: CircularProgressIndicator())),
            error: (err, stack) => SizedBox(height: 160, child: Center(child: Text('Error: $err'))),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _navigateToSellerDetailScreen(context),
              child: const Text('See More >>'),
            ),
          ),
        ],
      ),
    );
  }
}