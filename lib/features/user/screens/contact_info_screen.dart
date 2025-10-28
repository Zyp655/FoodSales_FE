import 'package:cnpm_ptpm/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

class ContactInfoScreen extends ConsumerStatefulWidget {
  static const routeName = '/contact-info';
  const ContactInfoScreen({super.key});

  @override
  ConsumerState<ContactInfoScreen> createState() => _ContactInfoScreenState();
}

class _ContactInfoScreenState extends ConsumerState<ContactInfoScreen> {
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  final _contactFormKey = GlobalKey<FormState>();
  bool _isSavingContact = false;
  bool _isEditingContact = false;

  @override
  void initState() {
    super.initState();
    final currentUser = ref.read(authProvider).currentUser;
    _phoneController = TextEditingController(text: currentUser?.phone ?? '');
    _addressController = TextEditingController(text: currentUser?.address ?? '');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveContactInfo() async {
    // Optional validation check
    // if (!_contactFormKey.currentState!.validate()) return;

    setState(() => _isSavingContact = true);
    final newPhone = _phoneController.text.trim();
    final newAddress = _addressController.text.trim();
    final currentUser = ref.read(authProvider).currentUser;
    final currentPhone = currentUser?.phone ?? '';
    final currentAddress = currentUser?.address ?? '';

    bool phoneChanged = newPhone != currentPhone;
    bool addressChanged = newAddress != currentAddress;

    bool success = true;

    if (phoneChanged || addressChanged) {
      success = await ref.read(authProvider.notifier).updateContactInfo(
          phone: phoneChanged ? (newPhone.isNotEmpty ? newPhone : null) : null,
          address: addressChanged ? (newAddress.isNotEmpty ? newAddress : null) : null);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success
            ? 'Contact info updated!'
            : ref.read(authProvider).error ?? 'Failed to update contact info.'),
        backgroundColor: success ? Colors.green : Colors.red,
      ));
      if (success) {
        setState(() => _isEditingContact = false);
      }
      setState(() => _isSavingContact = false);
    }
  }

  void _cancelEditContact() {
    final currentUser = ref.read(authProvider).currentUser;
    setState(() {
      _isEditingContact = false;
      _phoneController.text = currentUser?.phone ?? '';
      _addressController.text = currentUser?.address ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).currentUser;

    if (user == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('User not found')));
    }

    // Update controllers if user data changes externally
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isEditingContact) {
        if (_phoneController.text != (user.phone ?? '')) {
          _phoneController.text = user.phone ?? '';
        }
        if (_addressController.text != (user.address ?? '')) {
          _addressController.text = user.address ?? '';
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Information'),
        actions: [
          // Edit/Save/Cancel buttons moved to the body
          if (_isEditingContact && !_isSavingContact)
            TextButton(onPressed: _cancelEditContact, child: const Text('Cancel')),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _isEditingContact
                ? IconButton(
              icon: _isSavingContact
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.check),
              tooltip: 'Save',
              onPressed: _isSavingContact ? null : _saveContactInfo,
            )
                : IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit',
              onPressed: () => setState(() => _isEditingContact = true),
            ),
          ),
        ],
      ),
      body: Form(
        key: _contactFormKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.person_outline, size: 28),
              title: const Text('Username'),
              subtitle: Text(user.name ?? 'N/A'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.email_outlined, size: 28),
              title: const Text('Email'),
              subtitle: Text(user.email ?? 'N/A'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.location_on_outlined, size: 28),
              title: const Text('Address'),
              subtitle: _isEditingContact
                  ? TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(hintText: 'Enter address', isDense: true),
                maxLines: null,
              )
                  : Text(user.address != null && user.address!.isNotEmpty ? user.address! : 'Not set'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.phone_outlined, size: 28),
              title: const Text('Phone Number'),
              subtitle: _isEditingContact
                  ? TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(hintText: 'Enter 10 digits', isDense: true, counterText: ""),
                maxLength: 10,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length != 10) {
                    return 'Must be 10 digits';
                  }
                  return null;
                },
              )
                  : Text(user.phone != null && user.phone!.isNotEmpty ? user.phone! : 'Not set'),
            ),
          ],
        ),
      ),
    );
  }
}