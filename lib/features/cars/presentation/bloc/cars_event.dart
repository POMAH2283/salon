part of 'cars_bloc.dart';

abstract class CarsEvent extends Equatable {
  const CarsEvent();

  @override
  List<Object> get props => [];
}

class LoadCarsEvent extends CarsEvent {}

class FilterCarsEvent extends CarsEvent {
  final String? brand;
  final String? status;
  final double? minPrice;
  final double? maxPrice;

  const FilterCarsEvent({
    this.brand,
    this.status,
    this.minPrice,
    this.maxPrice,
  });

  @override
  List<Object> get props => [
    brand ?? '',
    status ?? '',
    minPrice ?? 0,
    maxPrice ?? 0
  ];
}