import 'package:cnpm_ptpm/features/user/screens/product_detail_screen.dart';
import 'package:cnpm_ptpm/models/product.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductPreviewCard extends StatelessWidget {
  final Product product;
  const ProductPreviewCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          ProductDetailScreen.routeName,
          arguments: product,
        );
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                'http://10.0.2.2:8000/storage/${product.image ?? ''}',
                height: 100,
                width: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container( height: 100, width: 120, color: Colors.grey[200], child: const Icon(Icons.image_not_supported)),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const SizedBox( height: 100, width: 120, child: Center(child: CircularProgressIndicator()));
                },
              ),
            ),
            const SizedBox(height: 5),
            Text(
              product.name ?? 'No Name',
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${product.pricePerKg?.toStringAsFixed(0) ?? '0'}đ / kg',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.teal, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}