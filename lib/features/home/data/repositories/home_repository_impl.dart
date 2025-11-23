import '../../../../core/services/api_service.dart';
import '../models/dashboard_stats_model.dart';

class HomeRepositoryImpl {
  final ApiService _apiService = ApiService();

  Future<DashboardStats> getDashboardStats() async {
    try {
      final response = await _apiService.get('/api/stats');
      if (response.statusCode == 200) {
        return DashboardStats.fromJson(response.data);
      } else {
        throw Exception('Failed to load dashboard stats');
      }
    } catch (e) {
      // Return default stats if API fails
      return DashboardStats(
        carsCount: 0,
        clientsCount: 0,
        dealsCount: 0,
        usersCount: 0,
      );
    }
  }

  Future<List<dynamic>> getRecentCars() async {
    try {
      final response = await _apiService.get('/api/cars');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        // Return only the 5 most recent cars
        return data.take(5).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getRecentDeals() async {
    try {
      final response = await _apiService.get('/api/deals');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        // Return only the 5 most recent deals
        return data.take(5).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}