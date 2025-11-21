import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/models/car_model.dart';
import '../../data/repositories/car_repository_impl.dart';

part 'cars_event.dart';
part 'cars_state.dart';

class CarsBloc extends Bloc<CarsEvent, CarsState> {
  final CarRepositoryImpl _carRepository;

  CarsBloc()
      : _carRepository = CarRepositoryImpl(),
        super(CarsInitial()) {
    on<LoadCarsEvent>(_onLoadCars);
    on<FilterCarsEvent>(_onFilterCars);
  }

  void _onLoadCars(LoadCarsEvent event, Emitter<CarsState> emit) async {
    emit(CarsLoading());
    try {
      final cars = await _carRepository.getCars();
      emit(CarsLoaded(cars: cars));
    } catch (e) {
      emit(CarsError(e.toString()));
    }
  }

  void _onFilterCars(FilterCarsEvent event, Emitter<CarsState> emit) async {
    emit(CarsLoading());
    try {
      final cars = await _carRepository.getCars(
        brand: event.brand,
        status: event.status,
        minPrice: event.minPrice,
        maxPrice: event.maxPrice,
      );
      emit(CarsLoaded(cars: cars));
    } catch (e) {
      emit(CarsError(e.toString()));
    }
  }
}