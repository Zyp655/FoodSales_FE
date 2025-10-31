import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cnpm_ptpm/models/delivery_ticket.dart';
import 'package:cnpm_ptpm/providers/admin_provider.dart';
import 'id_card_image_viewer.dart';

class DeliveryTicketItem extends ConsumerWidget {
  final DeliveryTicket ticket;

  const DeliveryTicketItem({super.key, required this.ticket});

  void _updateStatus(BuildContext context, WidgetRef ref, String status) async {
    final success = await ref
        .read(adminProvider.notifier)
        .updateDeliveryTicketStatus(ticket.id, status);

    final snackBarContent = success
        ? 'Successfully $status delivery request for ${ticket.fullName}'
        : 'Failed to update status.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(snackBarContent),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
  }

  void _viewIdCardImage(BuildContext context) {
    if (ticket.idCardImageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No ID card image URL available.')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => IdCardImageViewer(
          imageUrl: ticket.idCardImageUrl,
          cardHolderName: ticket.fullName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isProcessing = ref.watch(adminProvider).isTicketProcessing;

    final userEmail = ticket.user?.email ?? ticket.email;
    final userName = ticket.user?.name ?? ticket.fullName;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Request ID: #${ticket.id}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 5),
            Text(
              userName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(userEmail, style: const TextStyle(color: Colors.blue)),
            Text('Phone: ${ticket.phone}'),
            Text('ID Card: ${ticket.idCardNumber}'),
            Text(
              'Status: ${ticket.status.toUpperCase()}',
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),

            ElevatedButton.icon(
              onPressed: () => _viewIdCardImage(context),
              icon: const Icon(Icons.image, size: 18),
              label: const Text('View ID Card Image'),
            ),

            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: isProcessing
                      ? null
                      : () => _updateStatus(context, ref, 'rejected'),
                  child: const Text(
                    'REJECT',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: isProcessing
                      ? null
                      : () => _updateStatus(context, ref, 'approved'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: isProcessing
                      ? const SizedBox(
                          height: 15,
                          width: 15,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('APPROVE'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
