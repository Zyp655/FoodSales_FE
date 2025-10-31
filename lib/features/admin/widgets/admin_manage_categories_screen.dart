import 'package:cnpm_ptpm/models/category.dart';
import 'package:cnpm_ptpm/providers/admin_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminManageCategoriesScreen extends ConsumerWidget {
  const AdminManageCategoriesScreen({super.key});

  void _showDeleteDialog(BuildContext context,
      WidgetRef ref,
      Category category,) {
    showDialog(
      context: context,
      builder: (ctx) =>
          AlertDialog(
            title: const Text('Confirm Deletion'),
            content: Text(
              'Are you sure you want to delete ${category
                  .name}? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () {
                  ref.read(adminProvider.notifier).adminDeleteCategory(
                      category.id);
                  Navigator.of(ctx).pop();
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _showAddOrEditDialog(BuildContext context,
      WidgetRef ref, [
        Category? category,
      ]) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: category?.name);
    final descriptionController = TextEditingController(
      text: category?.description,
    );
    final bool isEditing = category != null;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Category' : 'Add New Category'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Category Name'),
                  validator: (value) {
                    if (value == null || value
                        .trim()
                        .isEmpty) {
                      return 'Please enter a name.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final name = nameController.text.trim();
                  final description = descriptionController.text.trim();

                  if (isEditing) {
                    ref
                        .read(adminProvider.notifier)
                        .adminUpdateCategory(
                      category.id,
                      name,
                      description.isEmpty ? null : description,
                    );
                  } else {
                    ref
                        .read(adminProvider.notifier)
                        .adminCreateCategory(
                      name,
                      description.isEmpty ? null : description,
                    );
                  }
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminState = ref.watch(adminProvider);
    final categories = adminState.allCategories;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(adminProvider.notifier).fetchAllData(),
        child: categories.isEmpty
            ? const Center(child: Text('No categories found. Pull to refresh.'))
            : ListView.builder(
          itemCount: categories.length,
          itemBuilder: (ctx, index) {
            final category = categories[index];
            return ListTile(
              title: Text(category.name),
              subtitle: Text(category.description ?? 'No description'),
              trailing: Wrap(
                spacing: 0,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () =>
                        _showAddOrEditDialog(context, ref, category),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                    onPressed: () =>
                        _showDeleteDialog(context, ref, category),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrEditDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}
