import 'package:cnpm_ptpm/models/seller.dart';
import 'package:cnpm_ptpm/providers/admin_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SellerListItem extends ConsumerWidget {
  final Seller seller;
  const SellerListItem({super.key, required this.seller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isApproved = seller.description == 'approved';

    return SwitchListTile(
      secondary: CircleAvatar(
        backgroundImage: (seller.image != null)
            ? NetworkImage('http://10.0.2.2:8000/storage/${seller.image!}')
            : null,
        onBackgroundImageError: (e, s) {},
        child: (seller.image == null) ? const Icon(Icons.storefront) : null,
      ),
      title: Text(seller.name ?? 'No Name'),
      subtitle: Text(seller.email ?? 'No Email'),
      value: isApproved,
      onChanged: (bool value) {
        String newStatus = value ? 'approved' : 'pending';

        showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('Confirm Status Change'),
              content: Text('Set status for ${seller.name} to "$newStatus"?'),
              actions: [
                TextButton(onPressed: ()=> Navigator.of(ctx).pop(), child: Text('Cancel')),
                TextButton(onPressed: (){
                  ref.read(adminProvider.notifier).updateSellerStatus(seller.id!, newStatus);
                  Navigator.of(ctx).pop();
                }, child: Text('Confirm')),
              ],
            )
        );
      },
      activeColor: Colors.green,
    );
  }
}