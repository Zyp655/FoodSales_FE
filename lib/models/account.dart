class Account {
  final int id;
  final String name;
  final String email;
  final String? avatar;
  final String type;
  final String role;
  final String? status;

  Account({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    required this.type,
    required this.role,
    this.status,
  });

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'] as int,
      name: map['name'] ?? 'No Name',
      email: map['email'] ?? 'No Email',
      avatar: map['avatar'],
      type: map['type'] as String,
      role: map['role'] as String,
      status: map['status'],
    );
  }
}