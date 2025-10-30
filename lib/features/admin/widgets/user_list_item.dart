import 'package:cnpm_ptpm/models/user.dart';
import 'package:flutter/material.dart';
import '../screens/manage_users_screen.dart'; 

class UserListItem extends StatelessWidget {
  final User user;
  const UserListItem({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(user.name?.substring(0, 1).toUpperCase() ?? '?'),
      ),
      title: Text(user.name ?? 'No Name'),
      subtitle: Text(user.email ?? 'No Email'),
      trailing: Chip(
        label: Text(user.role ?? 'N/A', style: const TextStyle(fontSize: 12)),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        labelPadding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      ),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (ctx) => ManageUsersScreen(user: user),
        ));
      },
    );
  }
}