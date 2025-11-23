import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'api_service.dart';

class ImageUploadService {
  final ApiService _apiService;
  final ImagePicker _picker = ImagePicker();

  ImageUploadService(this._apiService);

  // Запрос разрешений для доступа к камере и галерее
  Future<bool> requestPermissions() async {
    final cameraStatus = await Permission.camera.status;
    final storageStatus = await Permission.storage.status;
    
    if (!cameraStatus.isGranted) {
      await Permission.camera.request();
    }
    if (!storageStatus.isGranted) {
      await Permission.storage.request();
    }
    
    return cameraStatus.isGranted || await Permission.camera.request().isGranted;
  }

  // Выбор изображения из галереи
  Future<XFile?> pickImageFromGallery() async {
    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      throw Exception('Необходимы разрешения для доступа к фотографиям');
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      return image;
    } catch (e) {
      throw Exception('Ошибка при выборе изображения: $e');
    }
  }

  // Съемка фото
  Future<XFile?> takePhoto() async {
    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      throw Exception('Необходимы разрешения для доступа к камере');
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      return image;
    } catch (e) {
      throw Exception('Ошибка при съемке фото: $e');
    }
  }

  // Загрузка изображения на сервер
  Future<String> uploadImage(XFile imageFile, int carId) async {
    try {
      final fileName = imageFile.name;
      final file = File(imageFile.path);
      
      if (!await file.exists()) {
        throw Exception('Файл не найден');
      }

      // Проверяем размер файла (максимум 5 МБ)
      final fileSize = await file.length();
      if (fileSize > 5 * 1024 * 1024) {
        throw Exception('Размер файла не должен превышать 5 МБ');
      }

      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await _apiService.post(
        '/api/cars/$carId/photos',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        return responseData['photoUrl'] ?? '';
      } else {
        throw Exception('Ошибка загрузки: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Неожиданная ошибка: $e');
    }
  }

  // Загрузка нескольких изображений
  Future<List<String>> uploadMultipleImages(List<XFile> imageFiles, int carId) async {
    final uploadResults = <String>[];
    
    for (int i = 0; i < imageFiles.length; i++) {
      try {
        final photoUrl = await uploadImage(imageFiles[i], carId);
        uploadResults.add(photoUrl);
      } catch (e) {
        throw Exception('Ошибка загрузки изображения ${i + 1}: $e');
      }
    }
    
    return uploadResults;
  }

  // Удаление фотографии
  Future<bool> deletePhoto(String photoUrl, int carId) async {
    try {
      final response = await _apiService.delete(
        '/api/cars/$carId/photos',
        data: {'photoUrl': photoUrl},
      );
      
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Ошибка удаления фотографии: $e');
    }
  }

  // Получение списка фотографий автомобиля
  Future<List<String>> getCarPhotos(int carId) async {
    try {
      final response = await _apiService.get('/api/cars/$carId/photos');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return List<String>.from(data);
        } else if (data['photos'] != null) {
          return List<String>.from(data['photos']);
        }
      }
      
      return [];
    } catch (e) {
      throw Exception('Ошибка получения фотографий: $e');
    }
  }



  // Проверка валидности изображения
  Future<bool> validateImage(XFile imageFile) async {
    try {
      final file = File(imageFile.path);
      if (!await file.exists()) return false;

      final fileSize = await file.length();
      final extension = imageFile.path.split('.').last.toLowerCase();

      // Проверяем размер (максимум 5 МБ)
      if (fileSize > 5 * 1024 * 1024) return false;

      // Проверяем формат
      const allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];
      if (!allowedExtensions.contains(extension)) return false;

      return true;
    } catch (e) {
      return false;
    }
  }
}
