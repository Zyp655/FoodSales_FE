import 'dart:convert';
import 'order_item.dart';
import 'package:cnpm_ptpm/models/seller.dart';
import 'package:cnpm_ptpm/models/user.dart';

class Order {
  static const String STATUS_PENDING = 'Pending';
  static const String STATUS_PROCESSING = 'Processing';
  static const String STATUS_READY_FOR_PICKUP = 'ReadyForPickup';
  static const String STATUS_PICKING_UP = 'Picking Up';
  static const String STATUS_IN_TRANSIT = 'In Transit';
  static const String STATUS_DELIVERED = 'Delivered';
  static const String STATUS_CANCELLED = 'Cancelled';
  static const String API_STATUS_PROCESSING = 'processing';
  static const String API_STATUS_READY_FOR_PICKUP = 'ready_for_pickup';

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
  double? commissionAmount;
  double? distanceKm;

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
    this.commissionAmount,
    this.distanceKm,
  });

  factory Order.fromMap(Map<String, dynamic> map) {
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
      deliveryPerson: map['delivery_person'] != null
          ? User.fromMap(map['delivery_person'])
          : null,
      commissionAmount: (map['commission_amount'] as num?)?.toDouble(),
      distanceKm: (map['distance_km'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMapForCreate() {
    return {
      'delivery_address': deliveryAddress,
    };
  }

  String toJsonForCreate() => json.encode(toMapForCreate());
}