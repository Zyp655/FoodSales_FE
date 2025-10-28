import 'package:cnpm_ptpm/features/user/screens/product_detail_screen.dart';
import 'package:cnpm_ptpm/models/product.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class GroupedProductList extends StatelessWidget {
  final List<Product> products;
  final Map<int, String> categoryMap;

  const GroupedProductList({super.key, required this.products, required this.categoryMap});

  @override
  Widget build(BuildContext context) {
    final groupedProducts = groupBy<Product, int?>(
      products,
          (product) => product.categoryId,
    );

    return ListView.builder(
      itemCount: groupedProducts.keys.length,
      itemBuilder: (ctx, categoryIndex) {
        final categoryId = groupedProducts.keys.elementAt(categoryIndex);
        final productsInCategory = groupedProducts[categoryId]!;
        final categoryName = categoryMap[categoryId] ?? 'Other';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                child: Text(
                  categoryName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: productsInCategory.length,
                itemBuilder: (listCtx, productIndex) {
                  final product = productsInCategory[productIndex];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: (product.image != null)
                            ? NetworkImage('http://10.0.2.2:8000/storage/${product.image!}')
                            : null,
                        onBackgroundImageError: (exception, stackTrace) {},
                        child: (product.image == null)
                            ? const Icon(Icons.shopping_bag)
                            : null,
                      ),
                      title: Text(product.name ?? 'N/A'),
                      subtitle: Text(product.description ?? ''),
                      trailing: Text('${product.pricePerKg?.toStringAsFixed(0) ?? '0'}đ / kg'),
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          ProductDetailScreen.routeName,
                          arguments: product,
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}