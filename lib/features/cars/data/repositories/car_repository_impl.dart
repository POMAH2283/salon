import '../../../../core/services/api_service.dart';
import '../models/car_model.dart';

class CarRepositoryImpl {
  final ApiService _apiService;

  CarRepositoryImpl() : _apiService = ApiService();

  Future<List<CarModel>> getCars({
    String? brand,
    String? status,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (brand != null && brand.isNotEmpty) params['brand'] = brand;
      if (status != null && status.isNotEmpty) params['status'] = status;
      if (minPrice != null) params['min_price'] = minPrice;
      if (maxPrice != null) params['max_price'] = maxPrice;

      final response = await _apiService.get('/api/cars', params: params);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => CarModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load cars: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Get cars error: $e');
      throw Exception('Ошибка загрузки автомобилей: $e');
    }
  }

  // ДОБАВЛЯЕМ К СУЩЕСТВУЮЩИМ МЕТОДАМ:

  Future<CarModel> createCar(CarModel car) async {
    try {
      final response = await _apiService.post('/api/cars', data: car.toJson());

      if (response.statusCode == 201) {
        return CarModel.fromJson(response.data);
      } else {
        throw Exception('Failed to create car: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Create car error: $e');
      throw Exception('Ошибка создания автомобиля: $e');
    }
  }

  Future<CarModel> updateCar(CarModel car) async {
    try {
      final response = await _apiService.put('/api/cars/${car.id}', data: car.toJson());

      if (response.statusCode == 200) {
        return CarModel.fromJson(response.data);
      } else {
        throw Exception('Failed to update car: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Update car error: $e');
      throw Exception('Ошибка обновления автомобиля: $e');
    }
  }

  Future<void> deleteCar(int carId) async {
    try {
      final response = await _apiService.delete('/api/cars/$carId');

      if (response.statusCode != 200) {
        throw Exception('Failed to delete car: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Delete car error: $e');
      throw Exception('Ошибка удаления автомобиля: $e');
    }
  }

  Future<void> updateCarStatus(int carId, String status) async {
    try {
      final response = await _apiService.put('/api/cars/$carId/status', data: {'status': status});

      if (response.statusCode != 200) {
        throw Exception('Failed to update status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Update status error: $e');
      throw Exception('Ошибка обновления статуса: $e');
    }
  }
}