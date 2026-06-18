enum UserRole { admin, worker }

class User {
  final String id;
  final String phoneNumber;
  final String password; // For demo only - hash in production
  final String name;
  final UserRole role;
  final bool isActive;

  User({
    required this.id,
    required this.phoneNumber,
    required this.password,
    required this.name,
    required this.role,
    this.isActive = true,
  });

  User copyWith({
    String? id,
    String? phoneNumber,
    String? password,
    String? name,
    UserRole? role,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
      name: name ?? this.name,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'password': password,
      'name': name,
      'role': role == UserRole.admin ? 'admin' : 'worker',
      'isActive': isActive,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      password: map['password'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] == 'admin' ? UserRole.admin : UserRole.worker,
      isActive: map['isActive'] ?? true,
    );
  }
}
