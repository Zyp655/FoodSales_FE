import 'package:cnpm_ptpm/models/category.dart';
import 'package:cnpm_ptpm/models/product.dart';
import 'package:cnpm_ptpm/features/user/screens/seller_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoryFilterChips extends ConsumerWidget {
  final List<Category> allCategories;
  final List<Product> productsInSeller;

  const CategoryFilterChips({super.key, required this.allCategories, required this.productsInSeller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategoryId = ref.watch(selectedCategoryProvider);
    final notifier = ref.read(selectedCategoryProvider.notifier);

    final availableCategoryIds = productsInSeller.map((p) => p.categoryId).toSet();
    final availableCategories = allCategories.where((cat) => availableCategoryIds.contains(cat.id)).toList();

    List<Widget> chips = [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ChoiceChip(
          label: const Text('ALL'),
          selected: selectedCategoryId == null,
          onSelected: (selected) {
            if (selected) notifier.state = null;
          },
          selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
          checkmarkColor: Theme.of(context).primaryColor,
        ),
      )
    ];

    chips.addAll(availableCategories.map((category) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ChoiceChip(
          label: Text(category.name),
          selected: selectedCategoryId == category.id,
          onSelected: (selected) {
            if (selected) notifier.state = category.id;
          },
          selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
          checkmarkColor: Theme.of(context).primaryColor,
        ),
      );
    }).toList());

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Wrap(
        spacing: 8.0,
        children: chips,
      ),
    );
  }
}