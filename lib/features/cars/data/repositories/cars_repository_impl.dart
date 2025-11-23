import '../../domain/entities/car_entity.dart';
import '../../domain/repositories/cars_repository.dart';
import '../../data/models/filter_option_model.dart';
import '../../../../core/services/api_service.dart';

class CarsRepositoryImpl implements CarsRepository {
  final ApiService _apiService = ApiService.instance;

  @override
  Future<List<CarEntity>> getCars() async {
    try {
      final response = await _apiService.get('/api/cars');
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data as List<dynamic>;
        return jsonList.map((json) => CarEntity.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load cars: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка получения автомобилей: $e');
    }
  }

  @override
  Future<CarEntity> getCarById(int carId) async {
    try {
      final response = await _apiService.get('/api/cars/$carId');
      if (response.statusCode == 200) {
        return CarEntity.fromJson(response.data);
      } else {
        throw Exception('Failed to load car: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка получения автомобиля: $e');
    }
  }

  @override
  Future<List<CarEntity>> filterCars(Map<String, dynamic> filters) async {
    try {
      final response = await _apiService.get('/api/cars');
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data as List<dynamic>;
        List<CarEntity> cars = jsonList.map((json) => CarEntity.fromJson(json)).toList();
        
        // Применяем фильтры на стороне клиента
        if (filters['brand'] != null) {
          cars = cars.where((car) => car.brand == filters['brand']).toList();
        }
        if (filters['body_type'] != null) {
          cars = cars.where((car) => car.bodyType == filters['body_type']).toList();
        }
        if (filters['fuel_type'] != null) {
          cars = cars.where((car) => car.fuelType == filters['fuel_type']).toList();
        }
        if (filters['transmission_type'] != null) {
          cars = cars.where((car) => car.transmissionType == filters['transmission_type']).toList();
        }
        if (filters['drive_type'] != null) {
          cars = cars.where((car) => car.driveType == filters['drive_type']).toList();
        }
        if (filters['year_min'] != null) {
          cars = cars.where((car) => car.year >= filters['year_min']).toList();
        }
        if (filters['year_max'] != null) {
          cars = cars.where((car) => car.year <= filters['year_max']).toList();
        }
        if (filters['price_min'] != null) {
          cars = cars.where((car) => car.price >= filters['price_min']).toList();
        }
        if (filters['price_max'] != null) {
          cars = cars.where((car) => car.price <= filters['price_max']).toList();
        }
        if (filters['mileage_min'] != null) {
          cars = cars.where((car) => car.mileage >= filters['mileage_min']).toList();
        }
        if (filters['mileage_max'] != null) {
          cars = cars.where((car) => car.mileage <= filters['mileage_max']).toList();
        }
        if (filters['engine_volume_min'] != null) {
          cars = cars.where((car) => (car.engineVolume ?? 0) >= filters['engine_volume_min']).toList();
        }
        if (filters['engine_volume_max'] != null) {
          cars = cars.where((car) => (car.engineVolume ?? 0) <= filters['engine_volume_max']).toList();
        }
        if (filters['power_min'] != null) {
          cars = cars.where((car) => (car.power ?? 0) >= filters['power_min']).toList();
        }
        if (filters['power_max'] != null) {
          cars = cars.where((car) => (car.power ?? 0) <= filters['power_max']).toList();
        }
        
        return cars;
      } else {
        throw Exception('Failed to load cars: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка фильтрации автомобилей: $e');
    }
  }

  // Методы для получения данных для фильтров
  @override
  Future<List<FilterOptionModel>> getFilterOptions(String type) async {
    try {
      final response = await _apiService.get('/api/cars/filter-options?type=$type');
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data as List<dynamic>;
        return jsonList.map((json) => FilterOptionModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load filter options: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка получения опций фильтра: $e');
    }
  }

  @override
  Future<List<FilterOptionModel>> getBrands() async {
    try {
      final response = await _apiService.get('/api/cars/brands');
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data as List<dynamic>;
        return jsonList.map((json) => FilterOptionModel.fromJson(json)).toList();
      } else {
        // Если API не возвращает данные, возвращаем захардкоженные
        return _getHardcodedBrands();
      }
    } catch (e) {
      // В случае ошибки возвращаем захардкоженные данные
      return _getHardcodedBrands();
    }
  }

  @override
  Future<List<FilterOptionModel>> getBodyTypes() async {
    try {
      final response = await _apiService.get('/api/cars/body-types');
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data as List<dynamic>;
        return jsonList.map((json) => FilterOptionModel.fromJson(json)).toList();
      } else {
        return _getHardcodedBodyTypes();
      }
    } catch (e) {
      return _getHardcodedBodyTypes();
    }
  }

  @override
  Future<List<FilterOptionModel>> getFuelTypes() async {
    try {
      final response = await _apiService.get('/api/cars/fuel-types');
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data as List<dynamic>;
        return jsonList.map((json) => FilterOptionModel.fromJson(json)).toList();
      } else {
        return _getHardcodedFuelTypes();
      }
    } catch (e) {
      return _getHardcodedFuelTypes();
    }
  }

  @override
  Future<List<FilterOptionModel>> getTransmissionTypes() async {
    try {
      final response = await _apiService.get('/api/cars/transmission-types');
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data as List<dynamic>;
        return jsonList.map((json) => FilterOptionModel.fromJson(json)).toList();
      } else {
        return _getHardcodedTransmissionTypes();
      }
    } catch (e) {
      return _getHardcodedTransmissionTypes();
    }
  }

  @override
  Future<List<FilterOptionModel>> getDriveTypes() async {
    try {
      final response = await _apiService.get('/api/cars/drive-types');
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data as List<dynamic>;
        return jsonList.map((json) => FilterOptionModel.fromJson(json)).toList();
      } else {
        return _getHardcodedDriveTypes();
      }
    } catch (e) {
      return _getHardcodedDriveTypes();
    }
  }

  // Захардкоженные данные на случай недоступности API
  List<FilterOptionModel> _getHardcodedBrands() {
    return [
      FilterOptionModel(id: 'all', name: 'Все бренды'),
      FilterOptionModel(id: 'Toyota', name: 'Toyota'),
      FilterOptionModel(id: 'BMW', name: 'BMW'),
      FilterOptionModel(id: 'Mercedes', name: 'Mercedes'),
      FilterOptionModel(id: 'Audi', name: 'Audi'),
    ];
  }

  List<FilterOptionModel> _getHardcodedBodyTypes() {
    return [
      FilterOptionModel(id: 'all', name: 'Все типы кузова'),
      FilterOptionModel(id: 'Седан', name: 'Седан'),
      FilterOptionModel(id: 'Хэтчбек', name: 'Хэтчбек'),
      FilterOptionModel(id: 'Внедорожник', name: 'Внедорожник'),
      FilterOptionModel(id: 'Кроссовер', name: 'Кроссовер'),
      FilterOptionModel(id: 'Купе', name: 'Купе'),
    ];
  }

  List<FilterOptionModel> _getHardcodedFuelTypes() {
    return [
      FilterOptionModel(id: 'all', name: 'Все типы топлива'),
      FilterOptionModel(id: 'Бензин', name: 'Бензин'),
      FilterOptionModel(id: 'Дизель', name: 'Дизель'),
      FilterOptionModel(id: 'Газ', name: 'Газ'),
      FilterOptionModel(id: 'Гибрид', name: 'Гибрид'),
      FilterOptionModel(id: 'Электричество', name: 'Электричество'),
    ];
  }

  List<FilterOptionModel> _getHardcodedTransmissionTypes() {
    return [
      FilterOptionModel(id: 'all', name: 'Все трансмиссии'),
      FilterOptionModel(id: 'Механика', name: 'Механика'),
      FilterOptionModel(id: 'Автомат', name: 'Автомат'),
      FilterOptionModel(id: 'Вариатор', name: 'Вариатор'),
      FilterOptionModel(id: 'Робот', name: 'Робот'),
    ];
  }

  List<FilterOptionModel> _getHardcodedDriveTypes() {
    return [
      FilterOptionModel(id: 'all', name: 'Все приводы'),
      FilterOptionModel(id: 'Передний', name: 'Передний'),
      FilterOptionModel(id: 'Задний', name: 'Задний'),
      FilterOptionModel(id: 'Полный', name: 'Полный'),
      FilterOptionModel(id: 'Подключаемый полный', name: 'Подключаемый полный'),
    ];
  }
}