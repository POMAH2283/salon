import '../../domain/entities/deal_entity.dart';
import '../../domain/repositories/deals_repository.dart';
import '../../../../core/services/api_service.dart';

class DealsRepositoryImpl implements DealsRepository {
  final ApiService _apiService = ApiService.instance;

  @override
  Future<List<Deal>> getDeals() async {
    try {
      final response = await _apiService.get('/api/deals');
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data as List<dynamic>;
        return jsonList.map((json) => Deal.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load deals: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка получения сделок: $e');
    }
  }

  @override
  Future<Deal> getDealById(int dealId) async {
    try {
      final response = await _apiService.get('/api/deals/$dealId');
      if (response.statusCode == 200) {
        return Deal.fromJson(response.data);
      } else {
        throw Exception('Failed to load deal: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка получения сделки: $e');
    }
  }

  @override
  Future<Deal> createDeal({
    required int carId,
    required String clientName,
    required int managerId,
    required String type,
  }) async {
    try {
      final response = await _apiService.post(
        '/api/deals/with-client',
        data: {
          'carId': carId,
          'clientName': clientName,
          'managerId': managerId,
          'type': type,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Deal.fromJson(response.data);
      } else {
        throw Exception('Failed to create deal: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка создания сделки: $e');
    }
  }

  @override
  Future<Deal> updateDeal({
    required int dealId,
    required int carId,
    required String clientName,
    required int managerId,
    required String type,
    required String status,
  }) async {
    try {
      // For update, we still use the old endpoint but we won't change client
      // This is a simplified version - in production you might want to handle this differently
      final response = await _apiService.put(
        '/api/deals/$dealId/status',
        data: {
          'status': status,
        },
      );
      if (response.statusCode == 200) {
        return Deal.fromJson(response.data);
      } else {
        throw Exception('Failed to update deal: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка обновления сделки: $e');
    }
  }

  @override
  Future<Deal> updateDealStatus({
    required int dealId,
    required String status,
  }) async {
    try {
      final response = await _apiService.put(
        '/api/deals/$dealId/status',
        data: {
          'status': status,
        },
      );
      if (response.statusCode == 200) {
        return Deal.fromJson(response.data);
      } else {
        throw Exception('Failed to update deal status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка обновления статуса сделки: $e');
    }
  }

  @override
  Future<void> deleteDeal(int dealId) async {
    try {
      final response = await _apiService.delete('/api/deals/$dealId');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete deal: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка удаления сделки: $e');
    }
  }

  @override
  Future<Deal> completeDeal(int dealId) async {
    try {
      final response = await _apiService.put(
        '/api/deals/$dealId/complete',
        data: {},
      );
      if (response.statusCode == 200) {
        return Deal.fromJson(response.data);
      } else {
        throw Exception('Failed to complete deal: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка завершения сделки: $e');
    }
  }

  @override
  Future<Deal> cancelDeal(int dealId) async {
    try {
      final response = await _apiService.put(
        '/api/deals/$dealId/cancel',
        data: {},
      );
      if (response.statusCode == 200) {
        return Deal.fromJson(response.data);
      } else {
        throw Exception('Failed to cancel deal: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка отмены сделки: $e');
    }
  }

  // Методы для получения данных фильтров сделок
  Future<List<Map<String, String>>> getDealStatuses() async {
    try {
      final response = await _apiService.get('/api/deals/statuses');
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data as List<dynamic>;
        return jsonList.map((json) => {
          'id': json['id'] as String,
          'name': json['name'] as String,
        }).toList();
      } else {
        return _getHardcodedStatuses();
      }
    } catch (e) {
      return _getHardcodedStatuses();
    }
  }

  Future<List<Map<String, String>>> getDealTypes() async {
    try {
      final response = await _apiService.get('/api/deals/types');
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data as List<dynamic>;
        return jsonList.map((json) => {
          'id': json['id'] as String,
          'name': json['name'] as String,
        }).toList();
      } else {
        return _getHardcodedTypes();
      }
    } catch (e) {
      return _getHardcodedTypes();
    }
  }

  // Захардкоженные данные на случай недоступности API
  List<Map<String, String>> _getHardcodedStatuses() {
    return [
      {'id': 'all', 'name': 'Все статусы'},
      {'id': 'new', 'name': 'Новая'},
      {'id': 'in_process', 'name': 'В процессе'},
      {'id': 'completed', 'name': 'Завершена'},
      {'id': 'canceled', 'name': 'Отменена'},
    ];
  }

  List<Map<String, String>> _getHardcodedTypes() {
    return [
      {'id': 'all', 'name': 'Все типы'},
      {'id': 'sale', 'name': 'Продажа'},
      {'id': 'reservation', 'name': 'Бронирование'},
    ];
  }
}
