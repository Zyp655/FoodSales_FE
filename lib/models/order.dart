import 'dart:convert';
import 'package:cnpm_ptpm/models/order_item.dart';
import 'package:cnpm_ptpm/models/seller.dart';
import 'package:cnpm_ptpm/models/user.dart';

class Order {
  int? id;
  int? userId;
  int? sellerId;
  int? deliveryPersonId;
  double? totalAmount;
  String? status;
  String? deliveryAddress;
  String? createdAt;
  List<OrderItem>? items;
  User? user;
  Seller? seller;
  User? deliveryPerson;

  Order({
    this.id,
    this.userId,
    this.sellerId,
    this.deliveryPersonId,
    this.totalAmount,
    this.status,
    this.deliveryAddress,
    this.createdAt,
    this.items,
    this.user,
    this.seller,
    this.deliveryPerson,
  });

  factory Order.fromMap(Map<String, dynamic> map) {
    // Logic chuyển đổi an toàn cho totalAmount
    double? safeTotalAmount;
    var totalAmountValue = map['total_amount'];
    if (totalAmountValue != null) {
      if (totalAmountValue is num) {
        safeTotalAmount = totalAmountValue.toDouble();
      } else if (totalAmountValue is String) {
        safeTotalAmount = double.tryParse(totalAmountValue);
      }
    }

    return Order(
      id: (map['id'] as num?)?.toInt(),
      userId: (map['user_id'] as num?)?.toInt(),
      sellerId: (map['seller_id'] as num?)?.toInt(),
      deliveryPersonId: (map['delivery_person_id'] as num?)?.toInt(),
      totalAmount: safeTotalAmount,
      status: map['status'] as String?,
      deliveryAddress: map['delivery_address'] as String?,
      createdAt: map['created_at'] as String?,
      items: map['items'] != null
          ? List<OrderItem>.from(
          (map['items'] as List).map((item) => OrderItem.fromMap(item)))
          : null,
      user: map['user'] != null ? User.fromMap(map['user']) : null,
      seller: map['seller'] != null ? Seller.fromMap(map['seller']) : null,
    );
  }

  Map<String, dynamic> toMapForCreate() {
    return {
      'delivery_address': deliveryAddress,

    };
  }

  String toJsonForCreate() => json.encode(toMapForCreate());
}