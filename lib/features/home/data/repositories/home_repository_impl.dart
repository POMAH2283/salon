import '../../../../core/services/api_service.dart';
import '../models/dashboard_stats_model.dart';

class HomeRepositoryImpl {
  final ApiService _apiService;

  HomeRepositoryImpl() : _apiService = ApiService();

  Future<DashboardStats> getDashboardStats() async {
    try {
      final response = await _apiService.get('/api/stats');

      if (response.statusCode == 200) {
        return DashboardStats.fromJson(response.data);
      } else {
        throw Exception('Failed to load stats: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Get stats error: $e');
      throw Exception('Ошибка загрузки статистики: $e');
    }
  }
}