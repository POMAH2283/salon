import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/deals_bloc.dart';
import '../bloc/deals_event.dart';
import '../bloc/deals_state.dart';

class DealFiltersDialog extends StatefulWidget {
  const DealFiltersDialog({super.key});

  @override
  State<DealFiltersDialog> createState() => _DealFiltersDialogState();
}

class _DealFiltersDialogState extends State<DealFiltersDialog> {
  String? _selectedStatus;
  String? _selectedType;
  String? _selectedManagerName;
  String? _selectedClientName;

  List<Map<String, String>> _statuses = [];
  List<Map<String, String>> _types = [];

  @override
  void initState() {
    super.initState();
    _loadFilterOptions();
  }

  void _loadFilterOptions() {
    context.read<DealsBloc>().add(LoadDealFilterOptionsEvent());
    
    // Listen for filter options
    context.read<DealsBloc>().stream.listen((state) {
      if (state is DealFilterOptionsLoaded) {
        setState(() {
          _statuses = state.statuses;
          _types = state.types;
        });
      } else if (state is DealFilterOptionsError) {
        // В случае ошибки используем захардкоженные данные
        _useHardcodedData();
      }
    });
  }

  void _useHardcodedData() {
    setState(() {
      _statuses = [
        {'id': 'all', 'name': 'Все статусы'},
        {'id': 'new', 'name': 'Новая'},
        {'id': 'in_process', 'name': 'В процессе'},
        {'id': 'completed', 'name': 'Завершена'},
        {'id': 'canceled', 'name': 'Отменена'},
      ];
      
      _types = [
        {'id': 'all', 'name': 'Все типы'},
        {'id': 'sale', 'name': 'Продажа'},
        {'id': 'reservation', 'name': 'Бронирование'},
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Фильтры сделок'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Фильтр по статусу
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Статус',
                border: OutlineInputBorder(),
              ),
              items: _statuses.map((status) => DropdownMenuItem<String>(
                value: status['id'] == 'all' ? null : status['id'],
                child: Text(status['name'] ?? ''),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Фильтр по типу
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Тип сделки',
                border: OutlineInputBorder(),
              ),
              items: _types.map((type) => DropdownMenuItem<String>(
                value: type['id'] == 'all' ? null : type['id'],
                child: Text(type['name'] ?? ''),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Фильтр по менеджеру
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Менеджер',
                border: OutlineInputBorder(),
                hintText: 'Введите имя менеджера',
              ),
              onChanged: (value) {
                setState(() {
                  _selectedManagerName = value.isEmpty ? null : value;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Фильтр по клиенту
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Клиент',
                border: OutlineInputBorder(),
                hintText: 'Введите имя клиента',
              ),
              onChanged: (value) {
                setState(() {
                  _selectedClientName = value.isEmpty ? null : value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              _selectedStatus = null;
              _selectedType = null;
              _selectedManagerName = null;
              _selectedClientName = null;
            });
          },
          child: const Text('Сбросить'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () {
            _applyFilters();
            Navigator.of(context).pop();
          },
          child: const Text('Применить'),
        ),
      ],
    );
  }

  void _applyFilters() {
    context.read<DealsBloc>().add(FilterDealsEvent(
      status: _selectedStatus,
      type: _selectedType,
      managerId: _selectedManagerName, // Временно используем managerId как managerName
      clientName: _selectedClientName,
    ));
  }
}