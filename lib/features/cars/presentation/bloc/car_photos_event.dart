// Временный пустой файл для устранения ошибок компиляции
// Этот функционал будет реализован позже

import 'package:image_picker/image_picker.dart';

abstract class CarPhotosEvent {}

// События для загрузки фотографий
class LoadCarPhotos extends CarPhotosEvent {
  final int carId;
  LoadCarPhotos({required this.carId});
}

class PickImageFromGallery extends CarPhotosEvent {}

class TakePhoto extends CarPhotosEvent {}

class UploadPhoto extends CarPhotosEvent {
  final XFile imageFile;
  final int carId;
  UploadPhoto({required this.imageFile, required this.carId});
}

class UploadMultiplePhotos extends CarPhotosEvent {
  final List<XFile> imageFiles;
  final int carId;
  UploadMultiplePhotos({required this.imageFiles, required this.carId});
}

class DeletePhoto extends CarPhotosEvent {
  final String photoUrl;
  final int carId;
  DeletePhoto({required this.photoUrl, required this.carId});
}

class ClearPhotos extends CarPhotosEvent {}
