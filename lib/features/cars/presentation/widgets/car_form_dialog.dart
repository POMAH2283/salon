import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/car_management_bloc.dart';
import '../../data/models/car_model.dart';

class CarFormDialog extends StatefulWidget {
  final CarModel? car;

  const CarFormDialog({super.key, this.car});

  @override
  State<CarFormDialog> createState() => _CarFormDialogState();
}

class _CarFormDialogState extends State<CarFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _priceController = TextEditingController();
  final _mileageController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _bodyType = 'Седан';
  String _status = 'available';

  @override
  void initState() {
    super.initState();
    // Если передан автомобиль для редактирования - заполняем поля
    if (widget.car != null) {
      _brandController.text = widget.car!.brand;
      _modelController.text = widget.car!.model;
      _yearController.text = widget.car!.year.toString();
      _priceController.text = widget.car!.price.toString();
      _mileageController.text = widget.car!.mileage.toString();
      _descriptionController.text = widget.car!.description;
      _bodyType = widget.car!.bodyType;
      _status = widget.car!.status;
    } else {
      // Для нового автомобиля устанавливаем пробег по умолчанию
      _mileageController.text = '0';
    }
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _priceController.dispose();
    _mileageController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CarManagementBloc, CarManagementState>(
      listener: (context, state) {
        if (state is CarManagementSuccess) {
          Navigator.of(context).pop(); // Закрываем диалог при успехе
        }
      },
      child: AlertDialog(
        title: Text(widget.car == null ? 'Добавить автомобиль' : 'Редактировать автомобиль'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _brandController,
                  decoration: const InputDecoration(labelText: 'Марка *'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите марку автомобиля';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _modelController,
                  decoration: const InputDecoration(labelText: 'Модель *'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите модель автомобиля';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _yearController,
                  decoration: const InputDecoration(labelText: 'Год *'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите год выпуска';
                    }
                    final year = int.tryParse(value);
                    if (year == null || year < 1900 || year > DateTime.now().year + 1) {
                      return 'Введите корректный год';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Цена *'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите цену';
                    }
                    final price = double.tryParse(value);
                    if (price == null || price <= 0) {
                      return 'Введите корректную цену';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _mileageController,
                  decoration: const InputDecoration(labelText: 'Пробег (км)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _bodyType,
                  items: const [
                    DropdownMenuItem(value: 'Седан', child: Text('Седан')),
                    DropdownMenuItem(value: 'Внедорожник', child: Text('Внедорожник')),
                    DropdownMenuItem(value: 'Хэтчбек', child: Text('Хэтчбек')),
                    DropdownMenuItem(value: 'Универсал', child: Text('Универсал')),
                    DropdownMenuItem(value: 'Купе', child: Text('Купе')),
                    DropdownMenuItem(value: 'Кабриолет', child: Text('Кабриолет')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _bodyType = value!;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Тип кузова'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _status,
                  items: const [
                    DropdownMenuItem(value: 'available', child: Text('В наличии')),
                    DropdownMenuItem(value: 'reserved', child: Text('Забронировано')),
                    DropdownMenuItem(value: 'sold', child: Text('Продано')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _status = value!;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Статус'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Описание'),
                  maxLines: 3,
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
            onPressed: () => _submitForm(context),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final car = CarModel(
        id: widget.car?.id ?? 0,
        brand: _brandController.text,
        model: _modelController.text,
        year: int.parse(_yearController.text),
        price: double.parse(_priceController.text),
        mileage: int.parse(_mileageController.text.isEmpty ? '0' : _mileageController.text),
        bodyType: _bodyType,
        description: _descriptionController.text,
        status: _status,
        createdAt: widget.car?.createdAt ?? DateTime.now().toIso8601String(),
      );

      if (widget.car == null) {
        context.read<CarManagementBloc>().add(CreateCarEvent(car));
      } else {
        context.read<CarManagementBloc>().add(UpdateCarEvent(car));
      }
    }
  }
}