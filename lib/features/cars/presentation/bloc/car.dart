import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salon/features/cars/domain/entities/car_entity.dart';
import 'package:salon/core/services/api_service.dart';

// Events
abstract class CarManagementEvent {}

class LoadCarsEvent extends CarManagementEvent {}

class AddCarEvent extends CarManagementEvent {
  final CarEntity car;
  AddCarEvent(this.car);
}

class UpdateCarEvent extends CarManagementEvent {
  final CarEntity car;
  UpdateCarEvent(this.car);
}

class DeleteCarEvent extends CarManagementEvent {
  final int carId;
  DeleteCarEvent(this.carId);
}

class CreateCarEvent extends CarManagementEvent {
  final CarEntity car;
  CreateCarEvent(this.car);
}

class UpdateCarStatusEvent extends CarManagementEvent {
  final int carId;
  final String status;
  UpdateCarStatusEvent(this.carId, this.status);
}

// States
abstract class CarManagementState {}

class CarsInitial extends CarManagementState {}

class CarsLoading extends CarManagementState {}

class CarsLoaded extends CarManagementState {
  final List<CarEntity> cars;
  CarsLoaded(this.cars);
}

class CarManagementSuccess extends CarManagementState {
  final String message;
  CarManagementSuccess(this.message);
}

class CarManagementError extends CarManagementState {
  final String message;
  CarManagementError(this.message);
}

// Bloc
class CarManagementBloc extends Bloc<CarManagementEvent, CarManagementState> {
  CarManagementBloc() : super(CarsInitial()) {
    on<LoadCarsEvent>(_onLoadCars);
    on<AddCarEvent>(_onAddCar);
    on<CreateCarEvent>(_onCreateCar);
    on<UpdateCarEvent>(_onUpdateCar);
    on<DeleteCarEvent>(_onDeleteCar);
    on<UpdateCarStatusEvent>(_onUpdateCarStatus);
  }

  Future<void> _onLoadCars(LoadCarsEvent event, Emitter<CarManagementState> emit) async {
    emit(CarsLoading());
    try {
      final response = await ApiService.instance.get('/api/cars');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final cars = data.map((json) => CarEntity.fromJson(json)).toList();
        emit(CarsLoaded(cars));
      } else {
        emit(CarManagementError('Ошибка загрузки автомобилей'));
      }
    } catch (e) {
      emit(CarManagementError('Ошибка: $e'));
    }
  }

  Future<void> _onAddCar(AddCarEvent event, Emitter<CarManagementState> emit) async {
    try {
      final response = await ApiService.instance.post('/api/cars', data: event.car.toJson());
      if (response.statusCode == 201) {
        emit(CarManagementSuccess('Автомобиль добавлен'));
        add(LoadCarsEvent());
      } else {
        emit(CarManagementError('Ошибка добавления автомобиля'));
      }
    } catch (e) {
      emit(CarManagementError('Ошибка: $e'));
    }
  }

  Future<void> _onCreateCar(CreateCarEvent event, Emitter<CarManagementState> emit) async {
    try {
      final response = await ApiService.instance.post('/api/cars', data: event.car.toJson());
      if (response.statusCode == 201) {
        emit(CarManagementSuccess('Автомобиль создан'));
        add(LoadCarsEvent());
      } else {
        emit(CarManagementError('Ошибка создания автомобиля'));
      }
    } catch (e) {
      emit(CarManagementError('Ошибка: $e'));
    }
  }

  Future<void> _onUpdateCar(UpdateCarEvent event, Emitter<CarManagementState> emit) async {
    try {
      final response = await ApiService.instance.put('/api/cars/${event.car.id}', data: event.car.toJson());
      if (response.statusCode == 200) {
        emit(CarManagementSuccess('Автомобиль обновлен'));
        add(LoadCarsEvent());
      } else {
        emit(CarManagementError('Ошибка обновления автомобиля'));
      }
    } catch (e) {
      emit(CarManagementError('Ошибка: $e'));
    }
  }

  Future<void> _onUpdateCarStatus(UpdateCarStatusEvent event, Emitter<CarManagementState> emit) async {
    try {
      final response = await ApiService.instance.put('/api/cars/${event.carId}/status', data: {'status': event.status});
      if (response.statusCode == 200) {
        emit(CarManagementSuccess('Статус автомобиля обновлен'));
        add(LoadCarsEvent());
      } else {
        emit(CarManagementError('Ошибка обновления статуса'));
      }
    } catch (e) {
      emit(CarManagementError('Ошибка: $e'));
    }
  }

  Future<void> _onDeleteCar(DeleteCarEvent event, Emitter<CarManagementState> emit) async {
    try {
      final response = await ApiService.instance.delete('/api/cars/${event.carId}');
      if (response.statusCode == 200) {
        emit(CarManagementSuccess('Автомобиль удален'));
        add(LoadCarsEvent());
      } else {
        emit(CarManagementError('Ошибка удаления автомобиля'));
      }
    } catch (e) {
      emit(CarManagementError('Ошибка: $e'));
    }
  }
}
