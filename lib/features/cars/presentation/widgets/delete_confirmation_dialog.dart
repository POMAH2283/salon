import 'package:flutter/material.dart';
import 'package:salon/features/cars/domain/entities/car_entity.dart';
import 'package:salon/features/cars/presentation/bloc/car_management_bloc.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final Car car;

  const DeleteConfirmationDialog({required this.car});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Удалить автомобиль?'),
      content: Text('Вы уверены, что хотите удалить ${car.brand} ${car.model}?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () {
            context.read<CarManagementBloc>().add(DeleteCarEvent(car.id!));
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: Text('Удалить'),
        ),
      ],
    );
  }
}