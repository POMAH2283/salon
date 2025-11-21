part of 'car_management_bloc.dart';

abstract class CarManagementEvent extends Equatable {
  const CarManagementEvent();

  @override
  List<Object> get props => [];
}

class CreateCarEvent extends CarManagementEvent {
  final CarModel car;
  const CreateCarEvent(this.car);
  @override List<Object> get props => [car];
}

class UpdateCarEvent extends CarManagementEvent {
  final CarModel car;
  const UpdateCarEvent(this.car);
  @override List<Object> get props => [car];
}

class DeleteCarEvent extends CarManagementEvent {
  final int carId;
  const DeleteCarEvent(this.carId);
  @override List<Object> get props => [carId];
}

class UpdateCarStatusEvent extends CarManagementEvent {
  final int carId;
  final String status;
  const UpdateCarStatusEvent(this.carId, this.status);
  @override List<Object> get props => [carId, status];
}