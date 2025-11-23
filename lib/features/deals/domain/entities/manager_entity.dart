class Manager {
  final int id;
  final String name;
  final String email;
  final String role;

  Manager({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
    };
  }

  factory Manager.fromJson(Map<String, dynamic> json) {
    return Manager(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
    );
  }

  @override
  String toString() {
    return 'Manager{id: $id, name: $name, email: $email, role: $role}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Manager && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}