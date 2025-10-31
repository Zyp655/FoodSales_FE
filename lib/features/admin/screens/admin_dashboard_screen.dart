import 'package:cnpm_ptpm/providers/admin_provider.dart';
import 'package:cnpm_ptpm/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cnpm_ptpm/features/auth/screens/login_screen.dart';
import 'package:cnpm_ptpm/models/order.dart';
import 'package:cnpm_ptpm/models/account.dart';
import '../widgets/admin_manage_categories_screen.dart';
import 'admin_manage_tickets_screen.dart';
import '../widgets/account_list_item.dart';

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
                    items: drivers.map((Account driver) {
                      return DropdownMenuItem<int>(
                        value: driver.id,
                        child: Text(driver.name),
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
    final accounts = adminState.allAccounts;
    final orders = adminState.allOrders;
    final pendingTicketsCount = adminState.deliveryTickets.length;
    final currentFilter = adminState.accountFilter;

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
              const Tab(text: 'Accounts', icon: Icon(Icons.people)),
              const Tab(text: 'Categories', icon: Icon(Icons.category)),
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
            (accounts.isEmpty &&
                orders.isEmpty &&
                adminState.allCategories.isEmpty)
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
                    trailing: (order.status?.toLowerCase() ==
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
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 4.0,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FilterChip(
                          label: const Text('All'),
                          selected: currentFilter == 'all',
                          onSelected: (_) => ref
                              .read(adminProvider.notifier)
                              .setAccountFilter('all'),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Users'),
                          selected: currentFilter == 'user',
                          onSelected: (_) => ref
                              .read(adminProvider.notifier)
                              .setAccountFilter('user'),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Sellers'),
                          selected: currentFilter == 'seller',
                          onSelected: (_) => ref
                              .read(adminProvider.notifier)
                              .setAccountFilter('seller'),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Delivery'),
                          selected: currentFilter == 'delivery',
                          onSelected: (_) => ref
                              .read(adminProvider.notifier)
                              .setAccountFilter('delivery'),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Admins'),
                          selected: currentFilter == 'admin',
                          onSelected: (_) => ref
                              .read(adminProvider.notifier)
                              .setAccountFilter('admin'),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () =>
                        ref.read(adminProvider.notifier).fetchAllData(),
                    child: accounts.isEmpty
                        ? const Center(child: Text('No accounts found.'))
                        : ListView.builder(
                      itemCount: accounts.length,
                      itemBuilder: (ctx, index) =>
                          AccountListItem(account: accounts[index]),
                    ),
                  ),
                ),
              ],
            ),
            const AdminManageCategoriesScreen(),
            const AdminManageTicketsScreen(),
          ],
        ),
      ),
    );
  }
}