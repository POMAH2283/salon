import '../../domain/entities/deal_entity.dart';

class DealModel {
  final int id;
  final int carId;
  final int clientId;
  final int managerId;
  final String type;
  final String status;
  final String createdAt;
  final String? completedAt;

  DealModel({
    required this.id,
    required this.carId,
    required this.clientId,
    required this.managerId,
    required this.type,
    required this.status,
    required this.createdAt,
    this.completedAt,
  });

  factory DealModel.fromJson(Map<String, dynamic> json) {
    return DealModel(
      id: json['id'] as int,
      carId: json['car_id'] as int,
      clientId: json['client_id'] as int,
      managerId: json['manager_id'] as int,
      type: json['type'] as String,
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
      completedAt: json['completed_at'] as String?,
    );
  }

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

  DealModel copyWith({
    int? id,
    int? carId,
    int? clientId,
    int? managerId,
    String? type,
    String? status,
    String? createdAt,
    String? completedAt,
  }) {
    return DealModel(
      id: id ?? this.id,
      carId: carId ?? this.carId,
      clientId: clientId ?? this.clientId,
      managerId: managerId ?? this.managerId,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  // Конвертация в Entity для бизнес-логики
  Deal toEntity() {
    return Deal(
      id: id,
      carId: carId,
      clientId: clientId,
      managerId: managerId,
      type: type,
      status: status,
      createdAt: createdAt,
      completedAt: completedAt,
    );
  }

  // Создание из Entity для API
  factory DealModel.fromEntity(Deal deal) {
    return DealModel(
      id: deal.id,
      carId: deal.carId,
      clientId: deal.clientId,
      managerId: deal.managerId,
      type: deal.type,
      status: deal.status,
      createdAt: deal.createdAt,
      completedAt: deal.completedAt,
    );
  }
}