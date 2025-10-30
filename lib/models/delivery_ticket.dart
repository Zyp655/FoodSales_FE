import 'dart:convert';
import 'user.dart';

class DeliveryTicket {
  final int id;
  final int userId;
  final User? user;
  final String fullName;
  final String email;
  final String phone;
  final String idCardNumber;
  final String idCardImageUrl; // Đây là đường dẫn đầy đủ
  final String status;
  final DateTime createdAt;

  DeliveryTicket({
    required this.id,
    required this.userId,
    this.user,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.idCardNumber,
    required this.idCardImageUrl,
    required this.status,
    required this.createdAt,
  });

  factory DeliveryTicket.fromMap(Map<String, dynamic> map) {
    String _buildImageUrl(String? path) {
      if (path == null || path.isEmpty) {
        return '';
      }
      return 'http://10.0.2.2:8000/storage/$path';
    }

    return DeliveryTicket(
      id: map['id'] as int,
      userId: map['user_id'] as int,
      user: map.containsKey('user') && map['user'] != null && map['user'] is Map
          ? User.fromMap(map['user'] as Map<String, dynamic>)
          : null,
      fullName: map['full_name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      idCardNumber: map['id_card_number'] as String,
      idCardImageUrl: _buildImageUrl(map['id_card_image_path'] as String?),
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  factory DeliveryTicket.fromJson(String source) =>
      DeliveryTicket.fromMap(json.decode(source) as Map<String, dynamic>);
}