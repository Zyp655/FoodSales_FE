import 'package:cnpm_ptpm/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/image_picker_widget.dart';

class StoreInfoScreen extends ConsumerStatefulWidget {
  static const routeName = '/store-info';
  const StoreInfoScreen({super.key});

  @override
  ConsumerState<StoreInfoScreen> createState() => _StoreInfoScreenState();
}

class _StoreInfoScreenState extends ConsumerState<StoreInfoScreen> {
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _descriptionController;
  late TextEditingController _emailController;
  late TextEditingController _nameController;
  XFile? _selectedImageFile;
  final _contactFormKey = GlobalKey<FormState>();
  bool _isSavingContact = false;

  @override
  void initState() {
    super.initState();
    final currentUser = ref.read(authProvider).currentUser;
    _phoneController = TextEditingController(text: currentUser?.phone ?? '');
    _addressController = TextEditingController(text: currentUser?.address ?? '');
    _emailController = TextEditingController(text: currentUser?.email ?? '');
    _nameController = TextEditingController(text: currentUser?.name ?? '');
    _descriptionController = TextEditingController(text: currentUser?.description ?? '');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _handleImagePick(XFile? image) {
    _selectedImageFile = image;
  }

  Future<void> _saveContactInfo() async {
    if (!_contactFormKey.currentState!.validate()) return;

    setState(() => _isSavingContact = true);

    final newPhone = _phoneController.text.trim();
    final newAddress = _addressController.text.trim();
    final newEmail = _emailController.text.trim();
    final newName = _nameController.text.trim();
    final newDescription = _descriptionController.text.trim();

    final success = await ref.read(authProvider.notifier).updateSellerInfo(
      name: newName,
      email: newEmail,
      phone: newPhone.isNotEmpty ? newPhone : null,
      address: newAddress,
      description: newDescription,
      imageFile: _selectedImageFile,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success ? 'Info updated!' : ref.read(authProvider).error ?? 'Failed to update info.'),
        backgroundColor: success ? Colors.green : Colors.red,
      ));
      if (success) {
        _selectedImageFile = null;
      }
      setState(() => _isSavingContact = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).currentUser;
    if (user == null) return Scaffold(appBar: AppBar(), body: const Center(child: Text('User not found')));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isSavingContact) {
        if (_nameController.text != (user.name ?? '')) {
          _nameController.text = user.name ?? '';
        }
        if (_emailController.text != (user.email ?? '')) {
          _emailController.text = user.email ?? '';
        }
        if (_phoneController.text != (user.phone ?? '')) {
          _phoneController.text = user.phone ?? '';
        }
        if (_addressController.text != (user.address ?? '')) {
          _addressController.text = user.address ?? '';
        }
        if (_descriptionController.text != (user.description ?? '')) {
          _descriptionController.text = user.description ?? '';
        }
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Store Information')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _contactFormKey,
            child: Card(
              elevation: 0,
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: Column(
                  children: [
                    ImagePickerWidget(
                      initialImageUrl: user.image,
                      onImagePicked: _handleImagePick,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Store Name'),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'Phone Number', counterText: ""),
                      maxLength: 10,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (val) =>
                      (val != null && val.isNotEmpty && val.length != 10)
                          ? 'Must be 10 digits'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: 'Address'),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isSavingContact ? null : _saveContactInfo,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: _isSavingContact
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Save Store Info'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}