// Временный пустой файл для устранения ошибок компиляции
// Этот функционал будет реализован позже

import 'package:image_picker/image_picker.dart';

abstract class CarPhotosState {}

class CarPhotosInitial extends CarPhotosState {}

class CarPhotosLoading extends CarPhotosState {}

class CarPhotosLoaded extends CarPhotosState {
  final List<String> photos;
  CarPhotosLoaded(this.photos);
}

class CarPhotosError extends CarPhotosState {
  final String message;
  CarPhotosError(this.message);
}

class CarPhotosUploading extends CarPhotosState {}

class CarPhotoSelected extends CarPhotosState {
  final XFile image;
  CarPhotoSelected(this.image);
}

class CarPhotoUploaded extends CarPhotosState {
  final String photoUrl;
  CarPhotoUploaded(this.photoUrl);
}

class CarPhotosUploaded extends CarPhotosState {
  final List<String> photoUrls;
  CarPhotosUploaded(this.photoUrls);
}
