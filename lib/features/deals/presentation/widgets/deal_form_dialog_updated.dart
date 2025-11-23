import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/deal_entity.dart';
import '../../domain/entities/manager_entity.dart';
import '../../../cars/domain/entities/car_entity.dart';
import '../bloc/deals_bloc.dart';
import '../bloc/deals_event.dart';
import '../../../../core/services/api_service.dart';

class DealFormDialogUpdated extends StatefulWidget {
  final Deal? deal;

  const DealFormDialogUpdated({
    super.key,
    this.deal,
  });

  @override
  State<DealFormDialogUpdated> createState() => _DealFormDialogUpdatedState();
}

class _DealFormDialogUpdatedState extends State<DealFormDialogUpdated> {
  final _formKey = GlobalKey<FormState>();
  final _carController = TextEditingController();
  final _clientNameController = TextEditingController();
  final _managerController = TextEditingController();
  
  int? _selectedCarId;
  int? _selectedManagerId;
  String _selectedType = 'sale';
  String _selectedStatus = 'new';
  String _clientName = '';

  // Реальные данные из API
  final List<CarEntity> _availableCars = [];
  final List<Manager> _availableManagers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.deal != null) {
      _selectedCarId = widget.deal!.carId;
      _selectedManagerId = widget.deal!.managerId;
      _selectedType = widget.deal!.type;
      _selectedStatus = widget.deal!.status;
      _clientName = widget.deal!.clientName ?? '';
      
      _carController.text = widget.deal!.carName ?? '';
      _clientNameController.text = _clientName;
      _managerController.text = widget.deal!.managerName ?? '';
    }
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final apiService = ApiService.instance;
      
      // Загружаем доступные автомобили
      final carsResponse = await apiService.get('/api/cars/available');
      if (carsResponse.statusCode == 200) {
        final List<dynamic> carsData = carsResponse.data;
        _availableCars.clear();
        _availableCars.addAll(
          carsData.map((json) => CarEntity.fromJson(json)).toList()
        );
      }
      
      // Загружаем менеджеров
      final managersResponse = await apiService.get('/api/managers');
      if (managersResponse.statusCode == 200) {
        final List<dynamic> managersData = managersResponse.data;
        _availableManagers.clear();
        _availableManagers.addAll(
          managersData.map((json) => Manager.fromJson(json)).toList()
        );
      }

      setState(() {
        _isLoading = false;
      });
      
    } catch (e) {
      debugPrint('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка загрузки данных: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.deal == null ? 'Создание сделки' : 'Редактирование сделки'),
      content: SingleChildScrollView(
        child: _isLoading 
          ? const Center(
              heightFactor: 2,
              child: CircularProgressIndicator(),
            )
          : Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Выбор автомобиля (только доступные)
                  DropdownButtonFormField<int>(
                    value: _selectedCarId,
                    decoration: const InputDecoration(
                      labelText: 'Автомобиль *',
                      border: OutlineInputBorder(),
                    ),
                    items: _availableCars.map((car) {
                      return DropdownMenuItem<int>(
                        value: car.id,
                        child: Text('${car.brand} ${car.model} (${car.year}) - ${car.price.toStringAsFixed(0)} ₽'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCarId = value;
                        if (value != null) {
                          final selectedCar = _availableCars.firstWhere((car) => car.id == value);
                          _carController.text = '${selectedCar.brand} ${selectedCar.model}';
                        }
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Выберите автомобиль';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Ручной ввод имени клиента (вместо выбора из списка)
                  TextFormField(
                    controller: _clientNameController,
                    decoration: const InputDecoration(
                      labelText: 'Имя клиента *',
                      border: OutlineInputBorder(),
                      hintText: 'Введите имя клиента',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Введите имя клиента';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      _clientName = value;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Выбор менеджера
                  DropdownButtonFormField<int>(
                    value: _selectedManagerId,
                    decoration: const InputDecoration(
                      labelText: 'Менеджер *',
                      border: OutlineInputBorder(),
                    ),
                    items: _availableManagers.map((manager) {
                      return DropdownMenuItem<int>(
                        value: manager.id,
                        child: Text('${manager.name} (${manager.role})'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedManagerId = value;
                        if (value != null) {
                          final selectedManager = _availableManagers.firstWhere((m) => m.id == value);
                          _managerController.text = selectedManager.name;
                        }
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Выберите менеджера';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Тип сделки
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Тип сделки *',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'sale', child: Text('Продажа')),
                      DropdownMenuItem(value: 'reservation', child: Text('Бронирование')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value!;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Статус сделки (только для редактирования)
                  if (widget.deal != null)
                    DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Статус сделки *',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'new', child: Text('Новая')),
                        DropdownMenuItem(value: 'in_process', child: Text('В процессе')),
                        DropdownMenuItem(value: 'completed', child: Text('Завершена')),
                        DropdownMenuItem(value: 'canceled', child: Text('Отменена')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value!;
                        });
                      },
                    ),
                ],
              ),
            ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveDeal,
          child: Text(widget.deal == null ? 'Создать' : 'Сохранить'),
        ),
      ],
    );
  }

  void _saveDeal() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCarId == null || _selectedManagerId == null || _clientName.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Заполните все обязательные поля'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final dealsBloc = context.read<DealsBloc>();
      
      if (widget.deal == null) {
        // Создание новой сделки
        dealsBloc.add(CreateDealEvent(
          carId: _selectedCarId!,
          clientName: _clientName.trim(), // Передаем имя клиента
          managerId: _selectedManagerId!,
          type: _selectedType,
        ));
      } else {
        // Обновление существующей сделки
        dealsBloc.add(UpdateDealEvent(
          dealId: widget.deal!.id,
          carId: _selectedCarId!,
          clientName: _clientName.trim(), // Передаем имя клиента
          managerId: _selectedManagerId!,
          type: _selectedType,
          status: _selectedStatus,
        ));
      }
      
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _carController.dispose();
    _clientNameController.dispose();
    _managerController.dispose();
    super.dispose();
  }
}