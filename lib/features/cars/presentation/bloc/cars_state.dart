part of 'cars_bloc.dart';

abstract class CarsState extends Equatable {
  const CarsState();

  @override
  List<Object> get props => [];
}

class CarsInitial extends CarsState {}

class CarsLoading extends CarsState {}

class CarsLoaded extends CarsState {
  final List<CarModel> cars;

  const CarsLoaded({required this.cars});

  @override
  List<Object> get props => [cars];
}

class CarsError extends CarsState {
  final String message;

  const CarsError(this.message);

  @override
  List<Object> get props => [message];
}

class FilterOptionsLoading extends CarsState {}

class FilterOptionsLoaded extends CarsState {
  final Map<String, dynamic> filterOptions;

  const FilterOptionsLoaded({
    required this.filterOptions,
  });

  @override
  List<Object> get props => [filterOptions];
}

class FilterOptionsError extends CarsState {
  final String message;

  const FilterOptionsError(this.message);

  @override
  List<Object> get props => [message];
}