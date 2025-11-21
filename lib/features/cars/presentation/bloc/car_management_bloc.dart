import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salon/features/cars/domain/entities/car_entity.dart';
import 'package:salon/core/services/api_service.dart';

// Events
abstract class CarManagementEvent {}

class LoadCarsEvent extends CarManagementEvent {}

class AddCarEvent extends CarManagementEvent {
  final Car car;
  AddCarEvent(this.car);
}

class UpdateCarEvent extends CarManagementEvent {
  final Car car;
  UpdateCarEvent(this.car);
}

class DeleteCarEvent extends CarManagementEvent {
  final int carId;
  DeleteCarEvent(this.carId);
}

// States
abstract class CarManagementState {}

class CarsInitial extends CarManagementState {}

class CarsLoading extends CarManagementState {}

class CarsLoaded extends CarManagementState {
  final List<Car> cars;
  CarsLoaded(this.cars);
}

class CarOperationSuccess extends CarManagementState {
  final String message;
  CarOperationSuccess(this.message);
}

class CarOperationError extends CarManagementState {
  final String message;
  CarOperationError(this.message);
}

// Bloc
class CarManagementBloc extends Bloc<CarManagementEvent, CarManagementState> {
  CarManagementBloc() : super(CarsInitial()) {
    on<LoadCarsEvent>(_onLoadCars);
    on<AddCarEvent>(_onAddCar);
    on<UpdateCarEvent>(_onUpdateCar);
    on<DeleteCarEvent>(_onDeleteCar);
  }

  Future<void> _onLoadCars(LoadCarsEvent event, Emitter<CarManagementState> emit) async {
    emit(CarsLoading());
    try {
      final response = await ApiService.get('/cars');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final cars = data.map((json) => Car.fromJson(json)).toList();
        emit(CarsLoaded(cars));
      } else {
        emit(CarOperationError('Ошибка загрузки автомобилей'));
      }
    } catch (e) {
      emit(CarOperationError('Ошибка: $e'));
    }
  }

  Future<void> _onAddCar(AddCarEvent event, Emitter<CarManagementState> emit) async {
    try {
      final response = await ApiService.post('/cars', data: event.car.toJson());
      if (response.statusCode == 201) {
        emit(CarOperationSuccess('Автомобиль добавлен'));
        add(LoadCarsEvent());
      } else {
        emit(CarOperationError('Ошибка добавления автомобиля'));
      }
    } catch (e) {
      emit(CarOperationError('Ошибка: $e'));
    }
  }

  Future<void> _onUpdateCar(UpdateCarEvent event, Emitter<CarManagementState> emit) async {
    try {
      final response = await ApiService.put('/cars/${event.car.id}', data: event.car.toJson());
      if (response.statusCode == 200) {
        emit(CarOperationSuccess('Автомобиль обновлен'));
        add(LoadCarsEvent());
      } else {
        emit(CarOperationError('Ошибка обновления автомобиля'));
      }
    } catch (e) {
      emit(CarOperationError('Ошибка: $e'));
    }
  }

  Future<void> _onDeleteCar(DeleteCarEvent event, Emitter<CarManagementState> emit) async {
    try {
      final response = await ApiService.delete('/cars/${event.carId}');
      if (response.statusCode == 200) {
        emit(CarOperationSuccess('Автомобиль удален'));
        add(LoadCarsEvent());
      } else {
        emit(CarOperationError('Ошибка удаления автомобиля'));
      }
    } catch (e) {
      emit(CarOperationError('Ошибка: $e'));
    }
  }
}