import 'package:cnpm_ptpm/models/seller.dart';
import 'package:flutter/material.dart';

class SellerHeader extends StatelessWidget {
  final Seller seller;
  const SellerHeader({super.key, required this.seller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundImage: (seller.image != null)
                ? NetworkImage('http://10.0.2.2:8000/storage/${seller.image!}')
                : null,
            onBackgroundImageError: (e, s) {},
            child: (seller.image == null) ? const Icon(Icons.storefront, size: 30) : null,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  seller.name ?? 'Unknown Seller',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  seller.address ?? 'No address',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                ),
                Text(
                  seller.description ?? '',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}