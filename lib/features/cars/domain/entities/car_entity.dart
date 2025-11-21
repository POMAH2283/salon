class Car {
  final int? id;
  final String brand;
  final String model;
  final int year;
  final double price;
  final int mileage;
  final String bodyType;
  final String? description;
  final String status;

  Car({
    this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.price,
    required this.mileage,
    required this.bodyType,
    this.description,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'year': year,
      'price': price,
      'mileage': mileage,
      'bodyType': bodyType,
      'description': description,
      'status': status,
    };
  }

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'],
      brand: json['brand'],
      model: json['model'],
      year: json['year'],
      price: json['price'] is int ? json['price'].toDouble() : json['price'],
      mileage: json['mileage'],
      bodyType: json['bodyType'],
      description: json['description'],
      status: json['status'] ?? 'available',
    );
  }
}