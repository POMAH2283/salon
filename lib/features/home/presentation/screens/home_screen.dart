import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salon/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:salon/features/auth/data/models/user_model.dart';
import 'package:salon/features/auth/presentation/screens/login_screen.dart';
import 'package:salon/features/cars/presentation/bloc/cars_bloc.dart';
import 'package:salon/features/cars/presentation/widgets/car_card.dart';
import 'package:salon/features/home/data/repositories/home_repository_impl.dart';

import '../../../cars/presentation/screens/car_management_screen.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  final HomeRepositoryImpl _homeRepository = HomeRepositoryImpl();
  late Map<String, int> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
    _checkAuthStatus();
  }

  void _checkAuthStatus() {
    // Проверяем статус авторизации при загрузке экрана
    final authBloc = context.read<AuthBloc>();
    authBloc.add(CheckAuthEvent());
  }

  void _loadStats() async {
    try {
      final stats = await _homeRepository.getDashboardStats();
      setState(() {
        _stats = {
          'cars': stats.carsCount,
          'clients': stats.clientsCount,
          'deals': stats.dealsCount,
          'users': stats.usersCount,
        };
      });
    } catch (e) {
      print('Error loading stats: $e');
    }
  }

  void _simpleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Выход'),
          content: const Text('Вы уверены, что хотите выйти?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                // Закрываем диалог
                Navigator.of(context).pop();
                // Выполняем logout
                context.read<AuthBloc>().add(LogoutEvent());
                // Немедленно переходим на экран входа
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                );
              },
              child: const Text('Выйти', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AutoSalon'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          // Кнопка управления автомобилями
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                final user = state.user;
                if (user.role == 'admin' || user.role == 'manager') {
                  return IconButton(
                    icon: const Icon(Icons.car_repair),
                    tooltip: 'Управление автомобилями',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CarManagementScreen()),
                      );
                    },
                  );
                }
              }
              return const SizedBox.shrink();
            },
          ),
          // Кнопка выхода
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                return IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: 'Выйти',
                  onPressed: () => _simpleLogout(context),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthAuthenticated) {
            return MultiBlocProvider(
              providers: [
                BlocProvider<CarsBloc>(
                  create: (context) => CarsBloc()..add(LoadCarsEvent()),
                ),
              ],
              child: _HomeScreenBody(user: authState.user),
            );
          } else {
            return const Center(child: Text('Ошибка авторизации'));
          }
        },
      ),
    );
  }
}






class _HomeScreenBody extends StatefulWidget {
  final UserModel user;

  const _HomeScreenBody({required this.user});

  @override
  State<_HomeScreenBody> createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends State<_HomeScreenBody> {
  final HomeRepositoryImpl _homeRepository = HomeRepositoryImpl();
  late Map<String, int> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() async {
    try {
      final stats = await _homeRepository.getDashboardStats();
      setState(() {
        _stats = {
          'cars': stats.carsCount,
          'clients': stats.clientsCount,
          'deals': stats.dealsCount,
          'users': stats.usersCount,
        };
      });
    } catch (e) {
      print('Error loading stats: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Карточка пользователя
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: Icon(
                      Icons.person,
                      color: Colors.blue[700],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Добро пожаловать, ${widget.user.name}!',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Chip(
                          label: Text(
                            widget.user.role.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          backgroundColor: _getRoleColor(widget.user.role),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Статистика
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.8,
              children: [
                _buildStatCard('Автомобили', _stats['cars'] ?? 0, Icons.directions_car, Colors.blue),
                _buildStatCard('Клиенты', _stats['clients'] ?? 0, Icons.people, Colors.green),
                _buildStatCard('Сделки', _stats['deals'] ?? 0, Icons.assignment, Colors.orange),
                _buildStatCard('Сотрудники', _stats['users'] ?? 0, Icons.badge, Colors.purple),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Заголовок списка автомобилей
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Последние автомобили',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    context.read<CarsBloc>().add(LoadCarsEvent());
                  },
                ),
              ],
            ),
          ),

          // Список автомобилей
          BlocBuilder<CarsBloc, CarsState>(
            builder: (context, state) {
              if (state is CarsLoading) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (state is CarsError) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(child: Text('Ошибка: ${state.message}')),
                );
              } else if (state is CarsLoaded) {
                return Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.cars.length,
                      itemBuilder: (context, index) {
                        final car = state.cars[index];
                        return CarCard(car: car);
                      },
                    ),
                  ],
                );
              } else {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: Text('Нажмите обновить для загрузки автомобилей')),
                );
              }
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, int count, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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


}


