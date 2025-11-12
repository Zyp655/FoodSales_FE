class User {
  final int? id;
  final String? name;
  final String? email;
  final String? role;
  final String? address;
  final double? lat;
  final double? lng;
  final String? phone;
  final String? token;
  final String? image;
  final String? description;

  const User({
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

  factory User.fromMap(Map<String, dynamic> json) {
    Map<String, dynamic> userData = json['user'] ?? json;

    if (json.containsKey('token')) {
      userData['token'] = json['token'];
    }

    if (userData.containsKey('user_type') && userData['role'] == null) {
      userData['role'] = userData['user_type'];
    }

    return User(
      id: userData['id'],
      name: userData['name'],
      email: userData['email'],
      role: userData['role'],
      address: userData['address'],
      lat: (userData['lat'] as num?)?.toDouble(),
      lng: (userData['lng'] as num?)?.toDouble(),
      phone: userData['phone'],
      token: userData['token'],
      image: userData['image'],
      description: userData['description'],
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