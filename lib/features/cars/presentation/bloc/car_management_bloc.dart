import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/car_model.dart';
import '../../data/repositories/car_repository_impl.dart';

part 'car_management_event.dart';
part 'car_management_state.dart';

class CarManagementBloc extends Bloc<CarManagementEvent, CarManagementState> {
  final CarRepositoryImpl _carRepository;

  CarManagementBloc()
      : _carRepository = CarRepositoryImpl(),
        super(CarManagementInitial()) {
    on<CreateCarEvent>(_onCreateCar);
    on<UpdateCarEvent>(_onUpdateCar);
    on<DeleteCarEvent>(_onDeleteCar);
    on<UpdateCarStatusEvent>(_onUpdateCarStatus);
  }

  void _onCreateCar(CreateCarEvent event, Emitter<CarManagementState> emit) async {
    emit(CarManagementLoading());
    try {
      await _carRepository.createCar(event.car);
      emit(CarManagementSuccess('Автомобиль создан успешно'));
    } catch (e) {
      emit(CarManagementError(e.toString()));
    }
  }

  void _onUpdateCar(UpdateCarEvent event, Emitter<CarManagementState> emit) async {
    emit(CarManagementLoading());
    try {
      await _carRepository.updateCar(event.car);
      emit(CarManagementSuccess('Автомобиль обновлен успешно'));
    } catch (e) {
      emit(CarManagementError(e.toString()));
    }
  }

  void _onDeleteCar(DeleteCarEvent event, Emitter<CarManagementState> emit) async {
    emit(CarManagementLoading());
    try {
      await _carRepository.deleteCar(event.carId);
      emit(CarManagementSuccess('Автомобиль удален успешно'));
    } catch (e) {
      emit(CarManagementError(e.toString()));
    }
  }

  void _onUpdateCarStatus(UpdateCarStatusEvent event, Emitter<CarManagementState> emit) async {
    emit(CarManagementLoading());
    try {
      await _carRepository.updateCarStatus(event.carId, event.status);
      emit(CarManagementSuccess('Статус обновлен успешно'));
    } catch (e) {
      emit(CarManagementError(e.toString()));
    }
  }
}