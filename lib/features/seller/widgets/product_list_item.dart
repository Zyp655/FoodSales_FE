import 'package:cnpm_ptpm/features/seller/screens/manage_products_screen.dart';
import 'package:cnpm_ptpm/models/product.dart';
import 'package:cnpm_ptpm/providers/seller_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductListItem extends ConsumerWidget {
  final Product product;
  const ProductListItem({super.key, required this.product});

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete "${product.name ?? 'this product'}"?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
          ],
        )
    ).then((confirmed) {
      if (confirmed == true && product.id != null) {
        ref.read(sellerProvider.notifier).deleteProduct(product.id!);
      }
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: (product.image != null)
            ? NetworkImage('http://10.0.2.2:8000/storage/${product.image!}')
            : null,
        onBackgroundImageError: (exception, stackTrace) {},
        child: (product.image == null) ? const Icon(Icons.shopping_bag) : null,
      ),
      title: Text(product.name ?? 'No Name'),
      subtitle: Text('Price: ${product.pricePerKg?.toStringAsFixed(0) ?? '0'}đ / kg'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            tooltip: 'Edit',
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (ctx) => ManageProductsScreen(product: product),
              ));
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: 'Delete',
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
    );
  }
}