// Временный пустой файл для устранения ошибок компиляции
// Этот функционал будет реализован позже

import 'package:flutter_bloc/flutter_bloc.dart';

abstract class CarPhotosEvent {}

abstract class CarPhotosState {}

class CarPhotosBloc extends Bloc<CarPhotosEvent, CarPhotosState> {
  CarPhotosBloc() : super(CarPhotosInitial());
}

class CarPhotosInitial extends CarPhotosState {}
