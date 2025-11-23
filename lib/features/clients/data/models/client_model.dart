class ClientModel {
  final int id;
  final String name;
  final String? phone;
  final String? email;
  final String? notes;
  final String createdAt;

  ClientModel({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.notes,
    required this.createdAt,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'notes': notes,
      'created_at': createdAt,
    };
  }

  ClientModel copyWith({
    int? id,
    String? name,
    String? phone,
    String? email,
    String? notes,
    String? createdAt,
  }) {
    return ClientModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}