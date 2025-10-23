import 'dart:convert';

class Transaction {
  int? id;
  int? orderId;
  int? userId;
  double? amount;
  String? paymentMethod;
  String? status;
  String? qrData;
  String? createdAt;

  Transaction({
    this.id,
    this.orderId,
    this.userId,
    this.amount,
    this.paymentMethod,
    this.status,
    this.qrData,
    this.createdAt,
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: (map['id'] as num?)?.toInt(),
      orderId: (map['order_id'] as num?)?.toInt(),
      userId: (map['user_id'] as num?)?.toInt(),
      amount: (map['amount'] as num?)?.toDouble(),
      paymentMethod: map['payment_method'] as String?,
      status: map['status'] as String?,
      qrData: map['qr_data'] as String?,
      createdAt: map['created_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'user_id': userId,
      'amount': amount,
      'payment_method': paymentMethod,
      'status': status,
      'qr_data': qrData,
      'created_at': createdAt,
    };
  }

  String toJson() => json.encode(toMap());

  factory Transaction.fromJson(String source) =>
      Transaction.fromMap(json.decode(source));
}