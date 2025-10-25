import 'dart:io';
import 'package:cnpm_ptpm/models/product.dart';
import 'package:cnpm_ptpm/models/category.dart';
import 'package:cnpm_ptpm/providers/seller_provider.dart';
import 'package:cnpm_ptpm/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

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
  XFile? _selectedImage;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController = TextEditingController(
        text: widget.product?.pricePerKg?.toString() ?? '');
    _descriptionController =
        TextEditingController(text: widget.product?.description ?? '');
    _selectedCategoryId = widget.product?.categoryId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
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

    if (_isEditing) {
      await sellerNotifier.updateProduct(newProduct, _selectedImage);
    } else {
      await sellerNotifier.addProduct(newProduct, _selectedImage);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
    ref.watch(sellerProvider.select((state) => state.isLoading));

    final categoriesAsync = ref.watch(categoriesProvider);

    ref.listen(sellerProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Product' : 'Add Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: _buildImageProvider(),
                  child: _buildImageOverlay(),
                ),
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
                  if (_selectedCategoryId == null && categories.isNotEmpty) {
                    _selectedCategoryId = categories.first.id;
                  }

                  return DropdownButtonFormField<int>(
                    initialValue: _selectedCategoryId,
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
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      double.tryParse(value) == null) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
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

  ImageProvider? _buildImageProvider() {
    if (_selectedImage != null) {
      return FileImage(File(_selectedImage!.path));
    }
    if (_isEditing && widget.product?.image != null) {
      return NetworkImage(
          'http://10.0.2.2:8000/storage/${widget.product!.image!}');
    }
    return null;
  }

  Widget? _buildImageOverlay() {
    if (_selectedImage == null &&
        (_isEditing == false || widget.product?.image == null)) {
      return const Icon(Icons.camera_alt, color: Colors.grey);
    }
    return null;
  }
}