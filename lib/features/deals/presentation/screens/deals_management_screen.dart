import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/deal_entity.dart';
import '../bloc/deals_bloc.dart';
import '../bloc/deals_event.dart';
import '../bloc/deals_state.dart';
import '../widgets/deal_form_dialog.dart';
import '../widgets/deal_filters_dialog.dart';
import '../../data/repositories/deals_repository_impl.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/data/models/user_model.dart';

class DealsManagementScreen extends StatelessWidget {
  const DealsManagementScreen({super.key});

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
                  return _DealManagementCard(
                    deal: deal,
                    user: user,
                    canManage: canManage,
                    isAdmin: isAdmin,
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
}

class _DealManagementCard extends StatelessWidget {
  final Deal deal;
  final UserModel user;
  final bool canManage;
  final bool isAdmin;

  const _DealManagementCard({
    required this.deal,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Основная информация о сделке
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deal.carName ?? 'Автомобиль не найден',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Клиент: ${deal.clientName ?? 'Не указан'}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Менеджер: ${deal.managerName ?? 'Не назначен'}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: deal.typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: deal.typeColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    deal.displayType,
                    style: TextStyle(
                      color: deal.typeColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Статус и цена
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: deal.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: deal.statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(deal.status),
                        color: deal.statusColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        deal.displayStatus,
                        style: TextStyle(
                          color: deal.statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (deal.carPrice != null) ...[
                  const Spacer(),
                  Text(
                    '${deal.carPrice!.toStringAsFixed(0)} ₽',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Даты
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  'Создана: ${_formatDate(deal.createdAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                if (deal.completedAt != null) ...[
                  const SizedBox(width: 16),
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Colors.green[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Завершена: ${_formatDate(deal.completedAt!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[600],
                    ),
                  ),
                ],
              ],
            ),
            
            // Кнопки управления для управляющих ролей
            if (canManage) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
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
                  if (deal.status == 'new' || deal.status == 'in_process') ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check),
                        label: const Text('Завершить'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: () => _completeDeal(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (deal.status != 'completed' && deal.status != 'canceled') ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.cancel),
                        label: const Text('Отменить'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        onPressed: () => _cancelDeal(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
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
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'new':
        return Icons.new_releases;
      case 'in_process':
        return Icons.pending;
      case 'completed':
        return Icons.check_circle;
      case 'canceled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  void _showEditDialog(BuildContext context) {
    final dealsBloc = context.read<DealsBloc>();
    showDialog(
      context: context,
      builder: (context) => BlocProvider.value(
        value: dealsBloc,
        child: DealFormDialog(deal: deal),
      ),
    );
  }

  void _completeDeal(BuildContext context) {
    final dealsBloc = context.read<DealsBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Завершение сделки'),
        content: Text('Завершить сделку "${deal.carName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              dealsBloc.add(CompleteDealEvent(dealId: deal.id));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Завершить', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _cancelDeal(BuildContext context) {
    final dealsBloc = context.read<DealsBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Отмена сделки'),
        content: Text('Отменить сделку "${deal.carName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Нет'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              dealsBloc.add(CancelDealEvent(dealId: deal.id));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Отменить', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    final dealsBloc = context.read<DealsBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Удаление сделки'),
        content: Text('Удалить сделку "${deal.carName}"?\nЭто действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              dealsBloc.add(DeleteDealEvent(dealId: deal.id));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Удалить', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}