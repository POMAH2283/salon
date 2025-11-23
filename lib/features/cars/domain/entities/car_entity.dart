class CarEntity {
  final int id;
  final String brand;
  final String model;
  final int year;
  final double price;
  final int mileage;
  final String bodyType;
  final String description;
  final String status;
  final String createdAt;
  
  // Новые характеристики
  final double? engineVolume;
  final String? fuelType;
  final int? power;
  final String? transmissionType;
  final String? driveType;

  CarEntity({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.price,
    required this.mileage,
    required this.bodyType,
    required this.description,
    required this.status,
    required this.createdAt,
    this.engineVolume,
    this.fuelType,
    this.power,
    this.transmissionType,
    this.driveType,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'year': year,
      'price': price,
      'mileage': mileage,
      'body_type': bodyType,
      'description': description,
      'status': status,
      'created_at': createdAt,
      'engine_volume': engineVolume,
      'fuel_type': fuelType,
      'power': power,
      'transmission_type': transmissionType,
      'drive_type': driveType,
    };
  }

  factory CarEntity.fromJson(Map<String, dynamic> json) {
    return CarEntity(
      id: json['id'] as int,
      brand: json['brand'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      price: _parsePrice(json['price']),
      mileage: json['mileage'] as int,
      bodyType: json['body_type'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
      engineVolume: json['engine_volume'] != null ? _parseEngineVolume(json['engine_volume']) : null,
      fuelType: json['fuel_type'] as String?,
      power: json['power'] as int?,
      transmissionType: json['transmission_type'] as String?,
      driveType: json['drive_type'] as String?,
    );
  }

  static double _parsePrice(dynamic price) {
    if (price is num) {
      return price.toDouble();
    } else if (price is String) {
      return double.tryParse(price) ?? 0.0;
    } else {
      return 0.0;
    }
  }

  static double _parseEngineVolume(dynamic volume) {
    if (volume is num) {
      return volume.toDouble();
    } else if (volume is String) {
      return double.tryParse(volume) ?? 0.0;
    } else {
      return 0.0;
    }
  }
}
