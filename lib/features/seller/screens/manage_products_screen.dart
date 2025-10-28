import 'package:cnpm_ptpm/models/product.dart';
import 'package:cnpm_ptpm/models/category.dart';
import 'package:cnpm_ptpm/providers/seller_provider.dart';
import 'package:cnpm_ptpm/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

// Import the new image picker widget
import '../widgets/image_picker_widget.dart';

class ManageProductsScreen extends ConsumerStatefulWidget {
  static const routeName = '/manage-product';
  final Product? product;

  const ManageProductsScreen({super.key, this.product});

  @override
  ConsumerState<ManageProductsScreen> createState() =>
      _ManageProductsScreenState();
}

class _ManageProductsScreenState extends ConsumerState<ManageProductsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;

  int? _selectedCategoryId;
  XFile? _selectedImageFile;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController = TextEditingController(
      text: widget.product?.pricePerKg?.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.product?.description ?? '',
    );
    _selectedCategoryId = widget.product?.categoryId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleImagePick(XFile? image) {
    _selectedImageFile = image;
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final newProduct = Product(
      id: widget.product?.id,
      name: _nameController.text.trim(),
      pricePerKg: double.tryParse(_priceController.text.trim()) ?? 0.0,
      description: _descriptionController.text.trim(),
      categoryId: _selectedCategoryId,
      image: widget.product?.image,
    );

    final sellerNotifier = ref.read(sellerProvider.notifier);
    bool success = false;
    if (_isEditing) {
      success = await sellerNotifier.updateProduct(
        newProduct,
        _selectedImageFile,
      );
    } else {
      success = await sellerNotifier.addProduct(newProduct, _selectedImageFile);
    }

    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      sellerProvider.select((state) => state.isLoading),
    );
    final categoriesAsync = ref.watch(categoriesProvider);

    ref.listen(sellerProvider, (previous, next) {
      if (previous != null && !next.isLoading && next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Product' : 'Add Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ImagePickerWidget(
                initialImageUrl: widget.product?.image,
                onImagePicked: _handleImagePick,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              categoriesAsync.when(
                data: (categories) {
                  if (_selectedCategoryId == null &&
                      categories.isNotEmpty &&
                      !_isEditing) {
                    _selectedCategoryId = categories.first.id;
                  }
                  return DropdownButtonFormField<int>(
                    value: _selectedCategoryId,
                    items: categories.map((Category category) {
                      return DropdownMenuItem<int>(
                        value: category.id,
                        child: Text(category.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Category'),
                    validator: (value) =>
                        value == null ? 'Please select a category' : null,
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Text('Error loading categories: $err'),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price per Kg'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    // Check if > 0
                    return 'Please enter a valid positive price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: isLoading ? null : _saveProduct,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(_isEditing ? 'Update Product' : 'Add Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
