import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cnpm_ptpm/providers/admin_provider.dart';
import '../widgets/delivery_ticket_item.dart';

class AdminManageTicketsScreen extends ConsumerWidget {
  const AdminManageTicketsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingTickets = ref.watch(pendingDeliveryTicketsProvider);
    final isProcessing = ref.watch(adminProvider).isTicketProcessing;
    final errorMessage = ref.watch(adminProvider).error;

    Future<void> _refreshTickets() async {
      await ref.read(adminProvider.notifier).fetchDeliveryTickets(status: 'pending');
    }

    if (errorMessage != null) {
      return Center(child: Text('Error loading tickets: $errorMessage'));
    }

    if (isProcessing && pendingTickets.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _refreshTickets,
      child: pendingTickets.isEmpty
          ? const Center(child: Text('No pending delivery requests.'))
          : ListView.builder(
        itemCount: pendingTickets.length,
        itemBuilder: (context, index) {
          final ticket = pendingTickets[index];
          return DeliveryTicketItem(ticket: ticket);
        },
      ),
    );
  }
}