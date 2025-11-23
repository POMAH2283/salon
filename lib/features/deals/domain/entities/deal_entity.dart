import 'package:flutter/material.dart';

class Deal {
  final int id;
  final int carId;
  final int clientId;
  final int managerId;
  final String type; // 'sale' или 'reservation'
  final String status; // 'new', 'in_process', 'completed', 'canceled'
  final String createdAt;
  final String? completedAt;
  
  // Дополнительные поля для UI
  final String? carName;
  final String? clientName;
  final String? managerName;
  final double? carPrice;

  Deal({
    required this.id,
    required this.carId,
    required this.clientId,
    required this.managerId,
    required this.type,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.carName,
    this.clientName,
    this.managerName,
    this.carPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'car_id': carId,
      'client_id': clientId,
      'manager_id': managerId,
      'type': type,
      'status': status,
      'created_at': createdAt,
      'completed_at': completedAt,
    };
  }

  factory Deal.fromJson(Map<String, dynamic> json) {
    return Deal(
      id: json['id'] as int,
      carId: json['car_id'] as int,
      clientId: json['client_id'] as int,
      managerId: json['manager_id'] as int,
      type: json['type'] as String,
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
      completedAt: json['completed_at'] as String?,
      carName: json['car_name'] as String?,
      clientName: json['client_name'] as String?,
      managerName: json['manager_name'] as String?,
      carPrice: json['price'] != null ? double.tryParse(json['price'].toString()) : null,
    );
  }

  Deal copyWith({
    int? id,
    int? carId,
    int? clientId,
    int? managerId,
    String? type,
    String? status,
    String? createdAt,
    String? completedAt,
    String? carName,
    String? clientName,
    String? managerName,
    double? carPrice,
  }) {
    return Deal(
      id: id ?? this.id,
      carId: carId ?? this.carId,
      clientId: clientId ?? this.clientId,
      managerId: managerId ?? this.managerId,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      carName: carName ?? this.carName,
      clientName: clientName ?? this.clientName,
      managerName: managerName ?? this.managerName,
      carPrice: carPrice ?? this.carPrice,
    );
  }

  String get displayStatus {
    switch (status) {
      case 'new':
        return 'Новая';
      case 'in_process':
        return 'В процессе';
      case 'completed':
        return 'Завершена';
      case 'canceled':
        return 'Отменена';
      default:
        return status;
    }
  }

  String get displayType {
    switch (type) {
      case 'sale':
        return 'Продажа';
      case 'reservation':
        return 'Бронирование';
      default:
        return type;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'new':
        return Colors.blue;
      case 'in_process':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'canceled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color get typeColor {
    switch (type) {
      case 'sale':
        return Colors.purple;
      case 'reservation':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}