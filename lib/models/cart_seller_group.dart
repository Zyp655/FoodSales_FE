import 'cart_item.dart';

class CartSellerGroup {
  final int sellerId;
  final String sellerName;
  final double totalAmountBySeller;
  final List<CartItem> items;


  CartSellerGroup({
    required this.sellerId,
    required this.sellerName,
    required this.totalAmountBySeller,
    required this.items,
  });

  factory CartSellerGroup.fromMap(Map<String, dynamic> map) {
    List<CartItem> parsedItems = [];
    if (map['items'] is List) {
      parsedItems = (map['items'] as List)
          .map((itemData) => CartItem.fromMap(itemData as Map<String, dynamic>))
          .toList();
    }

    return CartSellerGroup(
      sellerId: (map['seller_id'] as num).toInt(),
      sellerName: map['seller_name'] as String,
      totalAmountBySeller: (map['total_amount_by_seller'] as num).toDouble(),
      items: parsedItems,
    );
  }
}