import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salon/features/cars/domain/entities/car_entity.dart';
import 'package:salon/features/cars/presentation/bloc/car_management_bloc.dart';

class CarFormDialog extends StatefulWidget {
  final Car? car;

  const CarFormDialog({this.car});

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
  final _bodyTypeController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _status = 'available';

  @override
  void initState() {
    super.initState();
    if (widget.car != null) {
      _brandController.text = widget.car!.brand;
      _modelController.text = widget.car!.model;
      _yearController.text = widget.car!.year.toString();
      _priceController.text = widget.car!.price.toString();
      _mileageController.text = widget.car!.mileage.toString();
      _bodyTypeController.text = widget.car!.bodyType;
      _descriptionController.text = widget.car!.description ?? '';
      _status = widget.car!.status;
    }
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _priceController.dispose();
    _mileageController.dispose();
    _bodyTypeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final car = Car(
        id: widget.car?.id,
        brand: _brandController.text,
        model: _modelController.text,
        year: int.parse(_yearController.text),
        price: double.parse(_priceController.text),
        mileage: int.parse(_mileageController.text),
        bodyType: _bodyTypeController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        status: _status,
      );

      if (widget.car == null) {
        // Добавление нового автомобиля
        context.read<CarManagementBloc>().add(AddCarEvent(car));
      } else {
        // Редактирование существующего
        context.read<CarManagementBloc>().add(UpdateCarEvent(car));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CarManagementBloc, CarManagementState>(
      listener: (context, state) {
        if (state is CarOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message))
          );
          Navigator.of(context).pop();
        }
        if (state is CarOperationError) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message))
          );
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
                  decoration: InputDecoration(labelText: 'Марка *'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите марку';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _modelController,
                  decoration: InputDecoration(labelText: 'Модель *'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите модель';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _yearController,
                  decoration: InputDecoration(labelText: 'Год *'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите год';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Введите корректный год';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(labelText: 'Цена *'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите цену';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Введите корректную цену';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _mileageController,
                  decoration: InputDecoration(labelText: 'Пробег *'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите пробег';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Введите корректный пробег';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _bodyTypeController,
                  decoration: InputDecoration(labelText: 'Тип кузова *'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите тип кузова';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Описание'),
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: InputDecoration(labelText: 'Статус'),
                  items: [
                    DropdownMenuItem(value: 'available', child: Text('В наличии')),
                    DropdownMenuItem(value: 'sold', child: Text('Продано')),
                    DropdownMenuItem(value: 'reserved', child: Text('Забронировано')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _status = value!;
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
            child: Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: _submitForm,
            child: Text(widget.car == null ? 'Добавить' : 'Сохранить'),
          ),
        ],
      ),
    );
  }
}