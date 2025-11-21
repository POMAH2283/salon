class CarModel {
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

  CarModel({
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
  });

  factory CarModel.fromJson(Map<String, dynamic> json) {
    return CarModel(
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
    };
  }
}