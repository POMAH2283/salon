import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/car_model.dart';
import '../../data/models/filter_option_model.dart';
import '../../domain/repositories/cars_repository.dart';

part 'cars_event.dart';
part 'cars_state.dart';

class CarsBloc extends Bloc<CarsEvent, CarsState> {
  final CarsRepository _carsRepository;
  
  CarsBloc(this._carsRepository) : super(CarsInitial()) {
    on<LoadCarsEvent>(_onLoadCars);
    on<FilterCarsEvent>(_onFilterCars);
    on<LoadFilterOptionsEvent>(_onLoadFilterOptions);
    on<LoadAllFilterOptionsEvent>(_onLoadAllFilterOptions);
  }

  Future<void> _onLoadCars(LoadCarsEvent event, Emitter<CarsState> emit) async {
    emit(CarsLoading());
    try {
      final cars = await _carsRepository.getCars();
      final carModels = cars.map((entity) => CarModel.fromJson(entity.toJson())).toList();
      emit(CarsLoaded(cars: carModels));
    } catch (e) {
      emit(CarsError('Ошибка загрузки автомобилей: $e'));
    }
  }

  Future<void> _onFilterCars(FilterCarsEvent event, Emitter<CarsState> emit) async {
    emit(CarsLoading());
    try {
      final cars = await _carsRepository.filterCars(event.filters ?? {});
      final carModels = cars.map((entity) => CarModel.fromJson(entity.toJson())).toList();
      emit(CarsLoaded(cars: carModels));
    } catch (e) {
      emit(CarsError('Ошибка фильтрации: $e'));
    }
  }

  Future<void> _onLoadFilterOptions(LoadFilterOptionsEvent event, Emitter<CarsState> emit) async {
    emit(FilterOptionsLoading());
    try {
      final filterOptions = await _carsRepository.getFilterOptions(event.type);
      emit(FilterOptionsLoaded(filterOptions: {event.type: filterOptions}));
    } catch (e) {
      emit(FilterOptionsError('Ошибка загрузки опций фильтра: $e'));
    }
  }

  Future<void> _onLoadAllFilterOptions(LoadAllFilterOptionsEvent event, Emitter<CarsState> emit) async {
    emit(FilterOptionsLoading());
    try {
      final brands = await _carsRepository.getBrands();
      final bodyTypes = await _carsRepository.getBodyTypes();
      final fuelTypes = await _carsRepository.getFuelTypes();
      final transmissionTypes = await _carsRepository.getTransmissionTypes();
      final driveTypes = await _carsRepository.getDriveTypes();
      
      final filterOptions = {
        'brands': brands,
        'bodyTypes': bodyTypes,
        'fuelTypes': fuelTypes,
        'transmissionTypes': transmissionTypes,
        'driveTypes': driveTypes,
      };
      
      emit(FilterOptionsLoaded(filterOptions: filterOptions));
    } catch (e) {
      emit(FilterOptionsError('Ошибка загрузки опций фильтра: $e'));
    }
  }
}
