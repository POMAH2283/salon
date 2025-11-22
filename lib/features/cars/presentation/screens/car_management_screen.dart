import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:salon/features/cars/domain/entities/car_entity.dart';
import 'package:salon/features/cars/presentation/bloc/car_management_bloc.dart';
import 'package:salon/features/cars/presentation/widgets/car_form_dialog.dart';
import 'package:salon/features/cars/presentation/widgets/delete_confirmation_dialog.dart';

class CarManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider<CarManagementBloc>(
      create: (context) => CarManagementBloc(),
      dispose: (context, bloc) => bloc.close(),
      child: _CarManagementScreenContent(),
    );
  }
}

class _CarManagementScreenContent extends StatefulWidget {
  @override
  State<_CarManagementScreenContent> createState() => _CarManagementScreenContentState();
}

class _CarManagementScreenContentState extends State<_CarManagementScreenContent> {
  @override
  void initState() {
    super.initState();
    // Загружаем автомобили при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CarManagementBloc>().add(LoadCarsEvent());
    });
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => CarFormDialog(),
    );
  }

  void _showEditDialog(Car car) {
    showDialog(
      context: context,
      builder: (context) => CarFormDialog(car: car),
    );
  }

  void _showDeleteDialog(Car car) {
    showDialog(
      context: context,
      builder: (context) => DeleteConfirmationDialog(car: car),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Управление автомобилями'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddDialog,
          ),
        ],
      ),
      body: BlocConsumer<CarManagementBloc, CarManagementState>(
        listener: (context, state) {
          if (state is CarOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message))
            );
            // Перезагружаем список автомобилей
            context.read<CarManagementBloc>().add(LoadCarsEvent());
          }
          if (state is CarOperationError) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message))
            );
          }
        },
        builder: (context, state) {
          if (state is CarsLoading) {
            return Center(child: CircularProgressIndicator());
          }
          if (state is CarsLoaded) {
            return _buildCarsList(state.cars);
          }
          if (state is CarOperationError) {
            return Center(child: Text('Ошибка: ${state.message}'));
          }
          return Center(child: Text('Нажмите + чтобы добавить автомобиль'));
        },
      ),
    );
  }

  Widget _buildCarsList(List<Car> cars) {
    if (cars.isEmpty) {
      return Center(child: Text('Нет автомобилей'));
    }

    return ListView.builder(
      itemCount: cars.length,
      itemBuilder: (context, index) {
        final car = cars[index];
        return _CarManagementCard(
          car: car,
          onEdit: () => _showEditDialog(car),
          onDelete: () => _showDeleteDialog(car),
        );
      },
    );
  }
}

class _CarManagementCard extends StatelessWidget {
  final Car car;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CarManagementCard({
    required this.car,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${car.brand} ${car.model}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: onEdit,
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            Text('Год: ${car.year}'),
            Text('Пробег: ${car.mileage} км'),
            Text('Цена: ${car.price} ₽'),
            Text('Тип кузова: ${car.bodyType}'),
            Text('Статус: ${_getStatusText(car.status)}'),
            if (car.description != null && car.description!.isNotEmpty)
              Text('Описание: ${car.description}'),
          ],
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'available':
        return 'В наличии';
      case 'sold':
        return 'Продано';
      case 'reserved':
        return 'Забронировано';
      default:
        return status;
    }
  }
}