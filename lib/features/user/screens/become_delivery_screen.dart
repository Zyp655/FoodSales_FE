import 'package:cnpm_ptpm/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../providers/account_provider.dart';
import '../../seller/widgets/image_picker_widget.dart';

class BecomeDeliveryScreen extends ConsumerStatefulWidget {
  static const routeName = '/become-delivery';

  const BecomeDeliveryScreen({super.key});

  @override
  ConsumerState<BecomeDeliveryScreen> createState() =>
      _BecomeDeliveryScreenState();
}

class _BecomeDeliveryScreenState extends ConsumerState<BecomeDeliveryScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _idCardNumberController;
  XFile? _selectedImageFile;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final currentUser = ref.read(authProvider).currentUser;
    _nameController = TextEditingController(text: currentUser?.name ?? '');
    _phoneController = TextEditingController(text: currentUser?.phone ?? '');
    _emailController = TextEditingController(text: currentUser?.email ?? '');
    _idCardNumberController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(accountProvider.notifier).fetchDeliveryTicketStatus();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _idCardNumberController.dispose();
    super.dispose();
  }

  void _handleImagePick(XFile? image) {
    _selectedImageFile = image;
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload an image of your ID card.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await ref
        .read(accountProvider.notifier)
        .submitDeliveryRequest(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      idCardNumber: _idCardNumberController.text.trim(),
      idCardImage: _selectedImageFile!,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Application submitted! Awaiting admin review.' // Thay đổi thông báo
                : ref.read(accountProvider).error ?? 'Submission failed.',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      if (success) {
        ref.read(accountProvider.notifier).fetchDeliveryTicketStatus();
      }
      setState(() => _isSubmitting = false);
    }
  }

  Widget _buildStatusMessage(String status) {
    String message = '';
    Color color = Colors.grey;
    IconData icon = Icons.help_outline;

    switch (status.toLowerCase()) {
      case 'pending':
        message = 'Your application is pending review by the admin.';
        color = Colors.orange;
        icon = Icons.hourglass_full;
        break;
      case 'approved':
        message = 'Congratulations! Your delivery driver application has been approved.';
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'rejected':
        message = 'Your application was rejected. Please contact support for details.';
        color = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        message = 'Application status unknown.';
        color = Colors.grey;
        icon = Icons.help_outline;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: color),
            const SizedBox(height: 20),
            Text(
              'Application Status: ${status}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            if (status.toLowerCase() == 'rejected')
              const Padding(
                padding: EdgeInsets.only(top: 15.0),
                child: Text(
                  'You may re-apply if the issue is resolved.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).currentUser;
    final accountState = ref.watch(accountProvider);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('User not found')),
      );
    }

    if (user.role == 'delivery') {
      return Scaffold(
        appBar: AppBar(title: const Text('Delivery Driver Application')),
        body: _buildStatusMessage('Approved'),
      );
    }

    if (accountState.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Delivery Driver Application')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currentTicketStatus = accountState.deliveryTicketStatus;

    if (currentTicketStatus != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Delivery Driver Application')),
        body: _buildStatusMessage(currentTicketStatus),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Delivery Driver Application')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Submit your application',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Text(
                'Admin will review your application and approve your account.',
              ),
              const SizedBox(height: 20),
              // Các TextFormField
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (val) =>
                val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (val) =>
                val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  counterText: "",
                ),
                maxLength: 10,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (val) =>
                (val == null || val.isEmpty || val.length != 10)
                    ? 'Must be 10 digits'
                    : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _idCardNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'ID Card Number (CCCD/CMND)',
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  if (val.length != 9 && val.length != 12) {
                    return 'Must be 9 or 12 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'ID Card Image',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Center(
                child: ImagePickerWidget(
                  initialImageUrl: null,
                  onImagePicked: _handleImagePick,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: accountState.isLoading ? null : _submitApplication,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: accountState.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit Application'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}