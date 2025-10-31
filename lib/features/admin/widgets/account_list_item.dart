import 'package:cnpm_ptpm/models/account.dart';
import 'package:cnpm_ptpm/providers/admin_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountListItem extends ConsumerWidget {
  final Account account;

  const AccountListItem({super.key, required this.account});

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text(
          'Are you sure you want to delete ${account.name}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              ref.read(adminProvider.notifier).deleteAccount(account);
              Navigator.of(ctx).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showEditRoleDialog(BuildContext context, WidgetRef ref) {
    String selectedRole = account.role;

    final List<String> roleOptions = (account.type == 'user')
        ? ['user', 'delivery', 'admin', 'banned']
        : ['seller', 'banned'];


    if (!roleOptions.contains(selectedRole)) {
      selectedRole = roleOptions.first;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Change Role for ${account.name}'),
              content: DropdownButton<String>(
                value: selectedRole,
                isExpanded: true,
                items: roleOptions
                    .map((role) =>
                    DropdownMenuItem(value: role, child: Text(role)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() {
                      selectedRole = value;
                    });
                  }
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    ref
                        .read(adminProvider.notifier)
                        .adminUpdateAccountRole(account, selectedRole);
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageUrl = (account.type == 'seller' && account.avatar != null)
        ? 'http://10.0.2.2:8000/storage/${account.avatar!}'
        : null;

    String chipText = account.role;
    Color chipColor = Colors.grey;

    switch (account.role) {
      case 'admin':
        chipColor = Colors.blue;
        break;
      case 'delivery':
        chipColor = Colors.teal;
        break;
      case 'seller':
        chipColor = Colors.green;
        break;
      case 'banned':
        chipColor = Colors.red;
        break;
      case 'user':
        chipColor = Colors.grey;
        break;
      default:
        chipColor = Colors.orange;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: (imageUrl != null) ? NetworkImage(imageUrl) : null,
        onBackgroundImageError: (imageUrl != null) ? (e, s) {} : null,
        child: (imageUrl == null)
            ? Text(
          account.name.isNotEmpty ? account.name[0].toUpperCase() : 'A',
        )
            : null,
      ),
      title: Text(account.name),
      subtitle: Text(account.email),
      trailing: Wrap(
        spacing: 0,
        children: [
          Chip(
            label: Text(chipText, style: const TextStyle(fontSize: 10, color: Colors.white)),
            backgroundColor: chipColor,
            side: BorderSide.none,
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: () => _showEditRoleDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            onPressed: () => _showDeleteDialog(context, ref),
          ),
        ],
      ),
    );
  }
}