import '../entities/deal_entity.dart';

abstract class DealsRepository {
  Future<List<Deal>> getDeals();
  Future<Deal> getDealById(int dealId);
  Future<Deal> createDeal({
    required int carId,
    required String clientName,
    required int managerId,
    required String type,
  });
  Future<Deal> updateDeal({
    required int dealId,
    required int carId,
    required String clientName,
    required int managerId,
    required String type,
    required String status,
  });
  Future<Deal> updateDealStatus({
    required int dealId,
    required String status,
  });
  Future<void> deleteDeal(int dealId);
  Future<Deal> completeDeal(int dealId);
  Future<Deal> cancelDeal(int dealId);
  
  // Методы для получения данных фильтров
  Future<List<Map<String, String>>> getDealStatuses();
  Future<List<Map<String, String>>> getDealTypes();
}