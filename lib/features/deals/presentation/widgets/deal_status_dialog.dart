import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/deals_bloc.dart';
import '../bloc/deals_event.dart';
import '../../domain/entities/deal_entity.dart';

class DealStatusDialog extends StatefulWidget {
  final Deal deal;

  const DealStatusDialog({
    super.key,
    required this.deal,
  });

  @override
  State<DealStatusDialog> createState() => _DealStatusDialogState();
}

class _DealStatusDialogState extends State<DealStatusDialog> {
  String _selectedStatus = '';

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.deal.status;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Изменить статус сделки'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Сделка: ${widget.deal.carName ?? "Неизвестный автомобиль"}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedStatus,
            decoration: const InputDecoration(
              labelText: 'Статус сделки',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'new', child: Text('Новая')),
              DropdownMenuItem(value: 'in_process', child: Text('В процессе')),
              DropdownMenuItem(value: 'completed', child: Text('Завершена')),
              DropdownMenuItem(value: 'canceled', child: Text('Отменена')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedStatus = value;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          // Показываем информацию о статусе
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getStatusColor(_selectedStatus).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getStatusColor(_selectedStatus).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getStatusIcon(_selectedStatus),
                  color: _getStatusColor(_selectedStatus),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getStatusDescription(_selectedStatus),
                    style: TextStyle(
                      color: _getStatusColor(_selectedStatus),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: _selectedStatus != widget.deal.status
              ? () {
                  context.read<DealsBloc>().add(
                    UpdateDealStatusEvent(
                      dealId: widget.deal.id,
                      status: _selectedStatus,
                    ),
                  );
                  Navigator.of(context).pop();
                }
              : null,
          child: const Text('Сохранить'),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
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

  String _getStatusDescription(String status) {
    switch (status) {
      case 'new':
        return 'Сделка только создана, требует обработки';
      case 'in_process':
        return 'Сделка находится в обработке';
      case 'completed':
        return 'Сделка успешно завершена';
      case 'canceled':
        return 'Сделка отменена';
      default:
        return 'Неизвестный статус';
    }
  }
}