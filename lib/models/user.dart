import 'dart:convert';

class User {
  int? id;
  String? name;
  String? email;
  String? role;
  String? address;
  double? lat;
  double? lng;
  String? token;

  User({
    this.id,
    this.name,
    this.email,
    this.role,
    this.address,
    this.lat,
    this.lng,
    this.token,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic> userData = map['user'] ?? map;

    return User(
      id: (userData['id'] as num?)?.toInt(),
      name: userData['name'] as String?,
      email: userData['email'] as String?,
      role: userData['role'] as String?,
      address: userData['address'] as String?,
      lat: (userData['lat'] as num?)?.toDouble(),
      lng: (userData['lng'] as num?)?.toDouble(),
      token: map['token'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'address': address,
      'lat': lat,
      'lng': lng,
      'token': token,
    };
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));
}