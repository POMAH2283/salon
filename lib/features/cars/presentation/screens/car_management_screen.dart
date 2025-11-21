import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salon/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:salon/features/auth/data/models/user_model.dart';
import '../bloc/cars_bloc.dart';
import '../bloc/car_management_bloc.dart';
import '../widgets/car_card.dart';
import '../widgets/car_form_dialog.dart';
import '../../data/models/car_model.dart';

class CarManagementScreen extends StatelessWidget {
  const CarManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Управление автомобилями'),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthAuthenticated) {
            return _CarManagementContent(user: authState.user);
          } else {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Ошибка авторизации',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Пожалуйста, войдите в систему'),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

class _CarManagementContent extends StatelessWidget {
  final UserModel user;

  const _CarManagementContent({required this.user});

  @override
  Widget build(BuildContext context) {
    final canManage = user.role == 'admin' || user.role == 'manager';
    final isAdmin = user.role == 'admin';

    return MultiBlocProvider(
      providers: [
        BlocProvider<CarsBloc>(
          create: (context) => CarsBloc()..add(LoadCarsEvent()),
        ),
        BlocProvider<CarManagementBloc>(
          create: (context) => CarManagementBloc(),
        ),
      ],
      child: _CarManagementScreenBody(
        user: user,
        canManage: canManage,
        isAdmin: isAdmin,
      ),
    );
  }
}

class _CarManagementScreenBody extends StatelessWidget {
  final UserModel user;
  final bool canManage;
  final bool isAdmin;

  const _CarManagementScreenBody({
    required this.user,
    required this.canManage,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Заголовок с информацией о пользователе
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getRoleColor(user.role),
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Управление автомобилями',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _getRoleColor(user.role),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Пользователь: ${user.name} (${user.role})',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                if (canManage)
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.green),
                    onPressed: () => _showAddCarDialog(context),
                  ),
              ],
            ),
          ),
        ),

        // Тело с списком автомобилей
        Expanded(
          child: _CarListBody(
            user: user,
            canManage: canManage,
            isAdmin: isAdmin,
          ),
        ),
      ],
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'manager':
        return Colors.blue;
      case 'viewer':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showAddCarDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CarFormDialog(),
    );
  }
}

class _CarListBody extends StatelessWidget {
  final UserModel user;
  final bool canManage;
  final bool isAdmin;

  const _CarListBody({
    required this.user,
    required this.canManage,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<CarManagementBloc, CarManagementState>(
      listener: (context, state) {
        if (state is CarManagementSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          context.read<CarsBloc>().add(LoadCarsEvent());
        }
        if (state is CarManagementError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<CarsBloc, CarsState>(
        builder: (context, state) {
          if (state is CarsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CarsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Ошибка загрузки: ${state.message}'),
                ],
              ),
            );
          } else if (state is CarsLoaded) {
            if (state.cars.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.directions_car, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Автомобили не найдены'),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.cars.length,
              itemBuilder: (context, index) {
                final car = state.cars[index];
                return _CarManagementCard(
                  car: car,
                  user: user,
                  canManage: canManage,
                  isAdmin: isAdmin,
                );
              },
            );
          } else {
            return const Center(child: Text('Загрузка автомобилей...'));
          }
        },
      ),
    );
  }
}

class _CarManagementCard extends StatelessWidget {
  final CarModel car;
  final UserModel user;
  final bool canManage;
  final bool isAdmin;

  const _CarManagementCard({
    required this.car,
    required this.user,
    required this.canManage,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CarCard(car: car),
            const SizedBox(height: 12),

            // Для viewer показываем только статус
            if (!canManage)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStatusColor(car.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getStatusIcon(car.status),
                      color: _getStatusColor(car.status),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Статус: ${_getStatusText(car.status)}',
                      style: TextStyle(
                        color: _getStatusColor(car.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

            // Для admin и manager показываем кнопки управления
            if (canManage)
              Column(
                children: [
                  // Селектор статуса
                  DropdownButtonFormField<String>(
                    value: car.status,
                    items: const [
                      DropdownMenuItem(value: 'available', child: Text('В наличии')),
                      DropdownMenuItem(value: 'reserved', child: Text('Забронировано')),
                      DropdownMenuItem(value: 'sold', child: Text('Продано')),
                    ],
                    onChanged: (newStatus) {
                      if (newStatus != null) {
                        context.read<CarManagementBloc>().add(
                          UpdateCarStatusEvent(car.id, newStatus),
                        );
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Статус автомобиля',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Кнопки управления
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.edit),
                          label: const Text('Редактировать'),
                          onPressed: () => _showEditDialog(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isAdmin)
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.delete, color: Colors.white),
                            label: const Text('Удалить', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () => _showDeleteDialog(context),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'available':
        return Colors.green;
      case 'sold':
        return Colors.red;
      case 'reserved':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'available':
        return Icons.check_circle;
      case 'sold':
        return Icons.sell;
      case 'reserved':
        return Icons.lock_clock;
      default:
        return Icons.help;
    }
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

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CarFormDialog(car: car),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удаление автомобиля'),
        content: Text('Вы уверены, что хотите удалить автомобиль ${car.brand} ${car.model}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<CarManagementBloc>().add(DeleteCarEvent(car.id));
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}