import 'dart:convert';

class User {
  int? id;
  String? name;
  String? email;
  String? role;
  String? address;
  double? lat;
  double? lng;
  String? phone;
  String? token;
  String? image;
  String? description;

  User({
    this.id,
    this.name,
    this.email,
    this.role,
    this.address,
    this.lat,
    this.lng,
    this.phone,
    this.token,
    this.image,
    this.description,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic> userData = map['user'] ?? map;

    return User(
      id: (userData['id'] as num?)?.toInt(),
      name: userData['name'] as String?,
      email: userData['email'] as String?,
      role: userData['role'] as String? ?? userData['user_type'] as String?,
      address: userData['address'] as String?,
      lat: (userData['lat'] as num?)?.toDouble(),
      lng: (userData['lng'] as num?)?.toDouble(),
      phone: userData['phone'] as String?,
      token: map['token'] as String?,
      image: userData['image'] as String?,
      description: userData['description'] as String?,
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
      'phone': phone,
      'token': token,
      'image': image,
      'description': description,
    };
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));
}

extension UserCopyWith on User {
  User copyWith({
    int? id,
    String? name,
    String? email,
    String? role,
    String? address,
    double? lat,
    double? lng,
    String? phone,
    String? token,
    String? image,
    String? description,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      address: address ?? this.address,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      phone: phone ?? this.phone,
      token: token ?? this.token,
      image: image ?? this.image,
      description: description ?? this.description,
    );
  }
}