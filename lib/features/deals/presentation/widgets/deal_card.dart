import 'package:flutter/material.dart';
import '../../domain/entities/deal_entity.dart';
import 'deal_status_dialog.dart';

class DealCard extends StatelessWidget {
  final Deal deal;
  final VoidCallback? onTap;

  const DealCard({
    super.key,
    required this.deal,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок с автомобилем и типом сделки
              Row(
                children: [
                  Expanded(
                    child: Text(
                      deal.carName ?? 'Автомобиль не найден',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: deal.typeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: deal.typeColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      deal.displayType,
                      style: TextStyle(
                        color: deal.typeColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Информация о клиенте
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      deal.clientName ?? 'Клиент не указан',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 4),
              
              // Информация о менеджере
              Row(
                children: [
                  Icon(
                    Icons.badge,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    deal.managerName ?? 'Менеджер не назначен',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Цена автомобиля
              if (deal.carPrice != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      size: 16,
                      color: Colors.green[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${deal.carPrice!.toStringAsFixed(0)} ₽',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              
              // Статус сделки (кликабельный)
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => DealStatusDialog(deal: deal),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: deal.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: deal.statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(deal.status),
                        color: deal.statusColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        deal.displayStatus,
                        style: TextStyle(
                          color: deal.statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.edit,
                        color: deal.statusColor,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Дата создания
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Создана: ${_formatDate(deal.createdAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              
              // Дата завершения
              if (deal.completedAt != null) ...[
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 14,
                      color: Colors.green[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Завершена: ${_formatDate(deal.completedAt!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[500],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'new':
        return Icons.new_releases;
      case 'in_process':
        return Icons.pending;
      case 'completed':
        return Icons.check_circle;
      case 'canceled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}.${date.month}.${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}