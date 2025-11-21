part of 'car_management_bloc.dart';

abstract class CarManagementState extends Equatable {
  const CarManagementState();

  @override
  List<Object> get props => [];
}

class CarManagementInitial extends CarManagementState {}
class CarManagementLoading extends CarManagementState {}
class CarManagementSuccess extends CarManagementState {
  final String message;
  const CarManagementSuccess(this.message);
  @override List<Object> get props => [message];
}
class CarManagementError extends CarManagementState {
  final String message;
  const CarManagementError(this.message);
  @override List<Object> get props => [message];
}