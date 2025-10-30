import 'package:cnpm_ptpm/models/user.dart';
import 'package:cnpm_ptpm/providers/admin_provider.dart';
import 'package:cnpm_ptpm/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ManageUsersScreen extends ConsumerStatefulWidget {
  static const routeName = '/manage-users';

  final User user;
  const ManageUsersScreen({super.key, required this.user});

  @override
  ConsumerState<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends ConsumerState<ManageUsersScreen> {
  late String _selectedRole;
  final List<String> _roles = ['user', 'admin', 'seller', 'delivery'];

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.user.role ?? 'user';
  }

  void _updateRole() {
    final token = ref.read(authProvider).currentUser?.token;
    if (token != null && _selectedRole != widget.user.role) {
      ref.read(adminProvider.notifier)
          .adminUpdateUserRole(widget.user.id!, _selectedRole);

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage ${widget.user.name}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text('User Email: ${widget.user.email}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              initialValue: _selectedRole,
              items: _roles.map((String role) {
                return DropdownMenuItem<String>(
                  value: role,
                  child: Text(role.toUpperCase()),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedRole = newValue;
                  });
                }
              },
              decoration: const InputDecoration(labelText: 'Role'),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: adminState.isLoading ? null : _updateRole,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: adminState.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Update Role'),
            )
          ],
        ),
      ),
    );
  }
}