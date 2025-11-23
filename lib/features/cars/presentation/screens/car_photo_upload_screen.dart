import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/image_upload_service.dart';
import '../../../../core/services/api_service.dart';

class CarPhotoUploadScreen extends StatefulWidget {
  final int carId;
  final String carName;

  const CarPhotoUploadScreen({
    super.key,
    required this.carId,
    required this.carName,
  });

  @override
  State<CarPhotoUploadScreen> createState() => _CarPhotoUploadScreenState();
}

class _CarPhotoUploadScreenState extends State<CarPhotoUploadScreen> {
  final ImageUploadService _imageUploadService = ImageUploadService(ApiService());
  final List<XFile> _selectedImages = [];
  final List<String> _uploadedPhotoUrls = [];
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadExistingPhotos();
  }

  Future<void> _loadExistingPhotos() async {
    try {
      final photos = await _imageUploadService.getCarPhotos(widget.carId);
      setState(() {
        _uploadedPhotoUrls.clear();
        _uploadedPhotoUrls.addAll(photos);
      });
    } catch (e) {
      // Игнорируем ошибку загрузки существующих фото
    }
  }

  Future<void> _pickImagesFromGallery() async {
    try {
      final images = await _imageUploadService.pickImageFromGallery();
      if (images != null) {
        setState(() {
          _selectedImages.add(images);
        });
      }
    } catch (e) {
      _showErrorDialog('Ошибка выбора изображения: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final image = await _imageUploadService.takePhoto();
      if (image != null) {
        setState(() {
          _selectedImages.add(image);
        });
      }
    } catch (e) {
      _showErrorDialog('Ошибка съемки фото: $e');
    }
  }

  Future<void> _pickFilesFromDesktop() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {
      _showErrorDialog('Ошибка выбора файлов: $e');
    }
  }

  bool get _isDesktop {
    return defaultTargetPlatform == TargetPlatform.windows ||
           defaultTargetPlatform == TargetPlatform.macOS ||
           defaultTargetPlatform == TargetPlatform.linux;
  }

  Future<void> _uploadImages() async {
    if (_selectedImages.isEmpty) {
      _showErrorDialog('Выберите изображения для загрузки');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final urls = await _imageUploadService.uploadMultipleImages(_selectedImages, widget.carId);
      setState(() {
        _uploadedPhotoUrls.addAll(urls);
        _selectedImages.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Фотографии успешно загружены!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showErrorDialog('Ошибка загрузки: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _deletePhoto(String photoUrl) async {
    try {
      final success = await _imageUploadService.deletePhoto(photoUrl, widget.carId);
      if (success && mounted) {
        setState(() {
          _uploadedPhotoUrls.remove(photoUrl);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Фотография удалена'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      _showErrorDialog('Ошибка удаления: $e');
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ошибка'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Фотографии: ${widget.carName}'),
        actions: [
          if (_selectedImages.isNotEmpty)
            IconButton(
              onPressed: _isUploading ? null : _uploadImages,
              icon: _isUploading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cloud_upload),
              tooltip: _isUploading ? 'Загрузка...' : 'Загрузить фото',
            ),
        ],
      ),
      body: Column(
        children: [
          // Кнопки выбора фото (адаптивные под платформу)
          Container(
            padding: const EdgeInsets.all(16),
            child: _isDesktop
                ? Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isUploading ? null : _pickFilesFromDesktop,
                              icon: const Icon(Icons.folder_open),
                              label: const Text('Выбрать файлы'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Zone для перетаскивания
                      Container(
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).primaryColor,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: Theme.of(context).primaryColor.withAlpha(26), // ~0.1 opacity
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 32,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Перетащите файлы сюда',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isUploading ? null : _pickImagesFromGallery,
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Из галереи'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isUploading ? null : _takePhoto,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Сфотографировать'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),

          // Счетчик выбранных фото
          if (_selectedImages.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.image, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Выбрано: ${_selectedImages.length} фото',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // Выбранные фото (предпросмотр)
          if (_selectedImages.isNotEmpty)
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _selectedImages.length,
                itemBuilder: (context, index) {
                  final image = _selectedImages[index];
                  return Container(
                    width: 120,
                    height: 120,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(image.path),
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedImages.removeAt(index);
                              });
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 16),

          // Заголовок загруженных фото
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.photo_album, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Загруженные фотографии',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Загруженные фото
          Expanded(
            child: _uploadedPhotoUrls.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_library,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Нет загруженных фотографий',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Добавьте первую фотографию',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _uploadedPhotoUrls.length,
                    itemBuilder: (context, index) {
                      final photoUrl = _uploadedPhotoUrls[index];
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                photoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 48,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _showDeleteConfirmation(photoUrl),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(String photoUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить фото'),
        content: const Text('Вы уверены, что хотите удалить эту фотографию?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePhoto(photoUrl);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}
