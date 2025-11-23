import '../../data/models/filter_option_model.dart';
import '../entities/car_entity.dart';

abstract class CarsRepository {
  Future<List<CarEntity>> getCars();
  Future<CarEntity> getCarById(int carId);
  Future<List<CarEntity>> filterCars(Map<String, dynamic> filters);
  
  // Методы для получения данных для фильтров
  Future<List<FilterOptionModel>> getFilterOptions(String type);
  Future<List<FilterOptionModel>> getBrands();
  Future<List<FilterOptionModel>> getBodyTypes();
  Future<List<FilterOptionModel>> getFuelTypes();
  Future<List<FilterOptionModel>> getTransmissionTypes();
  Future<List<FilterOptionModel>> getDriveTypes();
}