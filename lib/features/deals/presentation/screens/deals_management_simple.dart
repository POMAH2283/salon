import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/deal_entity.dart';
import '../bloc/deals_bloc.dart';
import '../bloc/deals_event.dart';
import '../bloc/deals_state.dart';
import '../widgets/deal_card.dart';
import '../widgets/deal_form_dialog.dart';
import '../widgets/deal_filters_dialog.dart';
import '../../data/repositories/deals_repository_impl.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/data/models/user_model.dart';

class DealsManagementScreenSimple extends StatelessWidget {
  const DealsManagementScreenSimple({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Управление сделками'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFiltersDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthAuthenticated) {
            return _DealsManagementContent(user: authState.user);
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

  void _showFiltersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => DealFiltersDialog(),
    );
  }
}

class _DealsManagementContent extends StatelessWidget {
  final UserModel user;

  const _DealsManagementContent({required this.user});

  @override
  Widget build(BuildContext context) {
    final canManage = user.role == 'admin' || user.role == 'manager';
    final isAdmin = user.role == 'admin';

    return BlocProvider<DealsBloc>(
      create: (context) => DealsBloc(
        DealsRepositoryImpl(),
      )..add(LoadDealsEvent()),
      child: _DealsManagementScreenBody(
        user: user,
        canManage: canManage,
        isAdmin: isAdmin,
      ),
    );
  }
}

class _DealsManagementScreenBody extends StatelessWidget {
  final UserModel user;
  final bool canManage;
  final bool isAdmin;

  const _DealsManagementScreenBody({
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
                        'Управление сделками',
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
                    onPressed: () => _showAddDealDialog(context),
                    tooltip: 'Создать новую сделку',
                  ),
              ],
            ),
          ),
        ),

        // Тело с списком сделок
        Expanded(
          child: _DealsListBody(
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

  void _showAddDealDialog(BuildContext context) {
    final dealsBloc = context.read<DealsBloc>();
    showDialog(
      context: context,
      builder: (context) => BlocProvider.value(
        value: dealsBloc,
        child: DealFormDialog(),
      ),
    );
  }
}

class _DealsListBody extends StatelessWidget {
  final UserModel user;
  final bool canManage;
  final bool isAdmin;

  const _DealsListBody({
    required this.user,
    required this.canManage,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<DealsBloc, DealsState>(
      listener: (context, state) {
        if (state is DealCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          context.read<DealsBloc>().add(LoadDealsEvent());
        }
        if (state is DealUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          context.read<DealsBloc>().add(LoadDealsEvent());
        }
        if (state is DealDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          context.read<DealsBloc>().add(LoadDealsEvent());
        }
        if (state is DealCompleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          context.read<DealsBloc>().add(LoadDealsEvent());
        }
        if (state is DealCancelled) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.orange,
            ),
          );
          context.read<DealsBloc>().add(LoadDealsEvent());
        }
        if (state is DealsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<DealsBloc, DealsState>(
        builder: (context, state) {
          if (state is DealsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DealsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Ошибка загрузки: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<DealsBloc>().add(LoadDealsEvent()),
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          } else if (state is DealsLoaded) {
            final dealsToShow = state.filteredDeals;
            
            if (dealsToShow.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assignment, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Сделки не найдены'),
                    SizedBox(height: 8),
                    Text(
                      'Попробуйте изменить фильтры',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<DealsBloc>().add(LoadDealsEvent());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: dealsToShow.length,
                itemBuilder: (context, index) {
                  final deal = dealsToShow[index];
                  return DealCard(
                    deal: deal,
                    onTap: canManage ? () => _showDealDetails(context, deal) : null,
                  );
                },
              ),
            );
          } else {
            return const Center(child: Text('Загрузка сделок...'));
          }
        },
      ),
    );
  }

  void _showDealDetails(BuildContext context, Deal deal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Детали сделки'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Автомобиль: ${deal.carName ?? "Не указан"}'),
            Text('Клиент: ${deal.clientName ?? "Не указан"}'),
            Text('Менеджер: ${deal.managerName ?? "Не назначен"}'),
            Text('Тип: ${deal.displayType}'),
            Text('Статус: ${deal.displayStatus}'),
            if (deal.carPrice != null) Text('Цена: ${deal.carPrice!.toStringAsFixed(0)} ₽'),
            Text('Создана: ${_formatDate(deal.createdAt)}'),
            if (deal.completedAt != null) Text('Завершена: ${_formatDate(deal.completedAt!)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}