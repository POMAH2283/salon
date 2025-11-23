import 'package:flutter/material.dart';
import '../../domain/entities/car_entity.dart';
import '../screens/car_photo_upload_screen.dart';

class CarDetailModal extends StatelessWidget {
  final CarEntity car;

  const CarDetailModal({
    Key? key,
    required this.car,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${car.brand} ${car.model}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${car.year} • ${car.mileage} км',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Price and Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${car.price.toStringAsFixed(0)} ₽',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(car.status),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _getStatusText(car.status),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Car Image Placeholder
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          const Center(
                            child: Icon(
                              Icons.directions_car,
                              size: 80,
                              color: Colors.grey,
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context); // Закрываем модальное окно
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CarPhotoUploadScreen(
                                      carId: car.id,
                                      carName: '${car.brand} ${car.model}',
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.camera_alt, size: 16),
                              label: const Text('Фото', style: TextStyle(fontSize: 12)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Theme.of(context).primaryColor,
                                elevation: 2,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Car Characteristics
                    const Text(
                      'Характеристики',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCharacteristicsGrid(),
                    const SizedBox(height: 24),
                    
                    // Description
                    if (car.description?.isNotEmpty == true) ...[
                      const Text(
                        'Описание',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          car.description!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    // Additional Info
                    const Text(
                      'Дополнительная информация',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildAdditionalInfo(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacteristicsGrid() {
    final characteristics = [
      {'label': 'Тип кузова', 'value': car.bodyType ?? 'Не указан', 'icon': Icons.directions_car},
      {'label': 'Двигатель', 'value': car.engineVolume != null ? '${car.engineVolume} л' : 'Не указан', 'icon': Icons.engineering},
      {'label': 'Мощность', 'value': car.power != null ? '${car.power} л.с.' : 'Не указана', 'icon': Icons.speed},
      {'label': 'Топливо', 'value': car.fuelType ?? 'Не указано', 'icon': Icons.local_gas_station},
      {'label': 'Трансмиссия', 'value': car.transmissionType ?? 'Не указана', 'icon': Icons.settings},
      {'label': 'Привод', 'value': car.driveType ?? 'Не указан', 'icon': Icons.all_inclusive},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: characteristics.length,
      itemBuilder: (context, index) {
        final char = characteristics[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Icon(
                char['icon'] as IconData,
                size: 20,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      char['label'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      char['value'] as String,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAdditionalInfo() {
    return Column(
      children: [
        _buildInfoRow('ID автомобиля', car.id.toString()),
        _buildInfoRow('Дата добавления', _formatDate(car.createdAt)),
        _buildInfoRow('Статус', _getStatusText(car.status)),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'available':
        return Colors.green;
      case 'sold':
        return Colors.blue;
      case 'reserved':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'available':
        return 'Доступен';
      case 'sold':
        return 'Продан';
      case 'reserved':
        return 'Зарезервирован';
      default:
        return 'Неизвестно';
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'Не указана';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}.${date.month}.${date.year}';
    } catch (e) {
      return dateStr; // Return as-is if parsing fails
    }
  }
}