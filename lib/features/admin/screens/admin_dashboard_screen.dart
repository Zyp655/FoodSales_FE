import 'package:cnpm_ptpm/providers/admin_provider.dart';
import 'package:cnpm_ptpm/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cnpm_ptpm/features/auth/screens/login_screen.dart';
import '../widgets/user_list_item.dart';
import '../widgets/seller_list_item.dart';
import 'package:cnpm_ptpm/models/order.dart';
import 'package:cnpm_ptpm/models/user.dart';
import 'admin_manage_tickets_screen.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  static const routeName = '/admin-dashboard';

  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(adminProvider.notifier).fetchAllData();
      }
    });
  }

  void _logout() {
    ref.read(authProvider.notifier).logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (ctx) => const LoginScreen()),
          (route) => false,
    );
  }

  void _showAssignDriverDialog(Order order) {
    final drivers = ref.read(deliveryDriversProvider);
    if (drivers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No delivery drivers available. Add drivers first.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    int? selectedDriverId = drivers.first.id;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Assign Driver for Order #${order.id}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Status: ${order.status}'),
                  Text('Seller: ${order.seller?.name ?? 'N/A'}'),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<int>(
                    value: selectedDriverId,
                    items: drivers.map((User driver) {
                      return DropdownMenuItem<int>(
                        value: driver.id,
                        child: Text(driver.name ?? 'Unnamed Driver'),
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        setDialogState(() {
                          selectedDriverId = newValue;
                        });
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Select Driver',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: (selectedDriverId == null ||
                      ref.watch(adminProvider).isLoading)
                      ? null
                      : () {
                    ref
                        .read(adminProvider.notifier)
                        .assignDriver(order.id!, selectedDriverId!);
                    Navigator.of(ctx).pop();
                  },
                  child: ref.watch(adminProvider).isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text('Assign'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);
    final users = adminState.allUsers;
    final sellers = adminState.allSellers;
    final orders = adminState.allOrders;
    final pendingTicketsCount = adminState.deliveryTickets.length;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          actions: [
            IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              const Tab(text: 'Orders', icon: Icon(Icons.receipt)),
              const Tab(text: 'Users', icon: Icon(Icons.person)),
              const Tab(text: 'Sellers', icon: Icon(Icons.store)),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.drive_eta),
                    const SizedBox(width: 5),
                    const Text('Tickets'),
                    if (pendingTicketsCount > 0)
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Chip(
                          label: Text(
                            '$pendingTicketsCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                          backgroundColor: Colors.red,
                          materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: adminState.isLoading &&
            (users.isEmpty && sellers.isEmpty && orders.isEmpty)
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
          children: [
            RefreshIndicator(
              onRefresh: () =>
                  ref.read(adminProvider.notifier).fetchAllOrders(),
              child: orders.isEmpty
                  ? const Center(child: Text('No orders found.'))
                  : ListView.builder(
                itemCount: orders.length,
                itemBuilder: (ctx, index) {
                  final order = orders[index];
                  return ListTile(
                    title: Text(
                      'Order #${order.id} - ${order.status ?? 'N/A'}',
                    ),
                    subtitle: Text(
                      'Seller: ${order.seller?.name ?? 'N/A'}\nDriver: ${order.deliveryPerson?.name ?? 'Not Assigned'}',
                    ),
                    isThreeLine: true,
                    trailing:
                    (order.status?.toLowerCase() ==
                        'ready_for_pickup')
                        ? ElevatedButton(
                      child: const Text('Assign'),
                      onPressed: () =>
                          _showAssignDriverDialog(order),
                    )
                        : (order.deliveryPersonId != null
                        ? const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    )
                        : null),
                    onTap: () => _showAssignDriverDialog(order),
                  );
                },
              ),
            ),
            RefreshIndicator(
              onRefresh: () =>
                  ref.read(adminProvider.notifier).fetchAllData(),
              child: users.isEmpty
                  ? const Center(child: Text('No users found.'))
                  : ListView.builder(
                itemCount: users.length,
                itemBuilder: (ctx, index) =>
                    UserListItem(user: users[index]),
              ),
            ),
            RefreshIndicator(
              onRefresh: () =>
                  ref.read(adminProvider.notifier).fetchAllData(),
              child: sellers.isEmpty
                  ? const Center(child: Text('No sellers found.'))
                  : ListView.builder(
                itemCount: sellers.length,
                itemBuilder: (ctx, index) =>
                    SellerListItem(seller: sellers[index]),
              ),
            ),
            const AdminManageTicketsScreen(),
          ],
        ),
      ),
    );
  }
}