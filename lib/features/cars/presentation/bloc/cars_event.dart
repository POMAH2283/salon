part of 'cars_bloc.dart';

abstract class CarsEvent extends Equatable {
  const CarsEvent();

  @override
  List<Object> get props => [];
}

class LoadCarsEvent extends CarsEvent {}

class FilterCarsEvent extends CarsEvent {
  final Map<String, dynamic>? filters;

  const FilterCarsEvent({
    this.filters,
  });

  @override
  List<Object> get props => [filters ?? {}];
}

class LoadFilterOptionsEvent extends CarsEvent {
  final String type;

  const LoadFilterOptionsEvent(this.type);

  @override
  List<Object> get props => [type];
}

class LoadAllFilterOptionsEvent extends CarsEvent {}