class Client {
  final int id;
  final String name;
  final String? phone;
  final String? email;
  final String? notes;
  final String createdAt;

  Client({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.notes,
    required this.createdAt,
  });

  // Преобразование в JSON (для API)
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

  // Создание из JSON (для API)
  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] as String,
    );
  }

  // Копирование с изменением полей
  Client copyWith({
    int? id,
    String? name,
    String? phone,
    String? email,
    String? notes,
    String? createdAt,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Client{id: $id, name: $name, phone: $phone, email: $email}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Client && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}