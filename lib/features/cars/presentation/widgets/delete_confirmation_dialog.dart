import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salon/features/cars/data/models/car_model.dart';
import 'package:salon/features/cars/presentation/bloc/car_management_bloc.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final CarModel car;

  const DeleteConfirmationDialog({required this.car});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Удалить автомобиль?'),
      content: Text('Вы уверены, что хотите удалить ${car.brand} ${car.model}?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            // Use the context from the builder
            context.read<CarManagementBloc>().add(DeleteCarEvent(car.id));
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Удалить'),
        ),
      ],
    );
  }
}