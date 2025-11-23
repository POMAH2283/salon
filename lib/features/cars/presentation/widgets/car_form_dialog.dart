import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/car.dart';
import '../../domain/entities/car_entity.dart';
import '../../../../core/services/api_service.dart';

class CarFormDialog extends StatefulWidget {
  final CarEntity? car;

  const CarFormDialog({super.key, this.car});

  @override
  State<CarFormDialog> createState() => _CarFormDialogState();
}

class _CarFormDialogState extends State<CarFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _priceController = TextEditingController();
  final _mileageController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // Новые контроллеры для характеристик
  final _engineVolumeController = TextEditingController();
  final _powerController = TextEditingController();

  String? _selectedBrand;
  String _bodyType = 'Седан';
  String _status = 'available';
  
  // Новые характеристики
  String? _selectedFuelType;
  String? _selectedTransmissionType;
  String? _selectedDriveType;
  
  List<String> _brands = [];
  List<String> _fuelTypes = [];
  List<String> _transmissionTypes = [];
  List<String> _driveTypes = [];
  
  bool _isLoadingBrands = true;
  bool _isLoadingCharacteristics = true;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  Future<void> _initializeForm() async {
    // Заполняем базовые поля сразу
    if (widget.car != null) {
      _modelController.text = widget.car!.model;
      _yearController.text = widget.car!.year.toString();
      _priceController.text = widget.car!.price.toString();
      _mileageController.text = widget.car!.mileage.toString();
      _descriptionController.text = widget.car!.description;
      _bodyType = widget.car!.bodyType;
      _status = widget.car!.status;
      
      // Заполняем новые характеристики
      if (widget.car!.engineVolume != null) {
        _engineVolumeController.text = widget.car!.engineVolume.toString();
      }
      if (widget.car!.power != null) {
        _powerController.text = widget.car!.power.toString();
      }
    } else {
      // Для нового автомобиля устанавливаем пробег по умолчанию
      _mileageController.text = '0';
    }

    // Загружаем все данные одновременно
    await Future.wait([
      _loadBrands(),
      _loadCharacteristics(),
    ]);

    // После загрузки всех данных обновляем выбранные значения
    _updateSelectedValues();
  }

  void _updateSelectedValues() {
    if (widget.car != null) {
      setState(() {
        // Обновляем бренд только если он существует в списке
        if (widget.car!.brand.isNotEmpty && _brands.contains(widget.car!.brand)) {
          _selectedBrand = widget.car!.brand;
        }
        
        // Обновляем характеристики только если они существуют в списках
        if (widget.car!.fuelType?.isNotEmpty == true && _fuelTypes.contains(widget.car!.fuelType)) {
          _selectedFuelType = widget.car!.fuelType;
        }
        if (widget.car!.transmissionType?.isNotEmpty == true && _transmissionTypes.contains(widget.car!.transmissionType)) {
          _selectedTransmissionType = widget.car!.transmissionType;
        }
        if (widget.car!.driveType?.isNotEmpty == true && _driveTypes.contains(widget.car!.driveType)) {
          _selectedDriveType = widget.car!.driveType;
        }
      });
    }
  }

  Future<void> _loadBrands() async {
    try {
      setState(() {
        _isLoadingBrands = true;
      });

      final apiService = ApiService.instance;
      final response = await apiService.get('/api/brands');
      
      if (response.statusCode == 200) {
        final List<dynamic> brandsData = response.data;
        setState(() {
          _brands = brandsData.map((b) => b['name'] as String).toList();
          _isLoadingBrands = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading brands: $e');
      setState(() {
        _isLoadingBrands = false;
      });
    }
  }

  Future<void> _loadCharacteristics() async {
    try {
      setState(() {
        _isLoadingCharacteristics = true;
      });

      final apiService = ApiService.instance;

      // Загружаем типы топлива
      try {
        final fuelResponse = await apiService.get('/api/fuel-types');
        if (fuelResponse.statusCode == 200) {
          final List<dynamic> fuelData = fuelResponse.data;
          setState(() {
            _fuelTypes = fuelData.map((f) => f['name'] as String).toSet().toList();
          });
        } else {
          throw Exception('Bad response: ${fuelResponse.statusCode}');
        }
      } catch (e) {
        debugPrint('Error loading fuel types: $e');
        // Используем fallback данные
        setState(() {
          _fuelTypes = ['Бензин', 'Дизель', 'Газ', 'Гибрид', 'Электричество'];
        });
      }

      // Загружаем типы трансмиссии
      try {
        final transmissionResponse = await apiService.get('/api/transmission-types');
        if (transmissionResponse.statusCode == 200) {
          final List<dynamic> transmissionData = transmissionResponse.data;
          setState(() {
            _transmissionTypes = transmissionData.map((t) => t['name'] as String).toSet().toList();
          });
        } else {
          throw Exception('Bad response: ${transmissionResponse.statusCode}');
        }
      } catch (e) {
        debugPrint('Error loading transmission types: $e');
        // Используем fallback данные
        setState(() {
          _transmissionTypes = ['Механика', 'Автомат', 'Вариатор', 'Робот'];
        });
      }

      // Загружаем типы привода
      try {
        final driveResponse = await apiService.get('/api/drive-types');
        if (driveResponse.statusCode == 200) {
          final List<dynamic> driveData = driveResponse.data;
          setState(() {
            _driveTypes = driveData.map((d) => d['name'] as String).toSet().toList();
          });
        } else {
          throw Exception('Bad response: ${driveResponse.statusCode}');
        }
      } catch (e) {
        debugPrint('Error loading drive types: $e');
        // Используем fallback данные
        setState(() {
          _driveTypes = ['Передний', 'Задний', 'Полный', 'Подключаемый полный'];
        });
      }

      setState(() {
        _isLoadingCharacteristics = false;
      });
    } catch (e) {
      debugPrint('Error loading characteristics: $e');
      setState(() {
        _isLoadingCharacteristics = false;
      });
    }
  }

  Future<void> _showAddBrandDialog() async {
    final TextEditingController brandController = TextEditingController();
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить марку'),
        content: TextField(
          controller: brandController,
          decoration: const InputDecoration(
            labelText: 'Название марки',
            hintText: 'Например: BMW',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              if (brandController.text.trim().isNotEmpty) {
                Navigator.of(context).pop(brandController.text.trim());
              }
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        final apiService = ApiService.instance;
        final response = await apiService.post('/api/brands', data: {
          'name': result,
        });

        if (response.statusCode == 201) {
          await _loadBrands();
          setState(() {
            _selectedBrand = result;
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Марка "$result" добавлена'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка добавления марки: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _modelController.dispose();
    _yearController.dispose();
    _priceController.dispose();
    _mileageController.dispose();
    _descriptionController.dispose();
    _engineVolumeController.dispose();
    _powerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CarManagementBloc, CarManagementState>(
      listener: (context, state) {
        if (state is CarManagementSuccess) {
          Navigator.of(context).pop(); // Закрываем диалог при успехе
        }
      },
      child: AlertDialog(
        title: Text(widget.car == null ? 'Добавить автомобиль' : 'Редактировать автомобиль'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Выбор марки из списка
                Row(
                  children: [
                    Expanded(
                      child: _isLoadingBrands
                          ? const Center(child: CircularProgressIndicator())
                          : DropdownButtonFormField<String>(
                              value: _selectedBrand?.isNotEmpty == true ? _selectedBrand : null,
                              decoration: const InputDecoration(
                                labelText: 'Марка *',
                                border: OutlineInputBorder(),
                              ),
                              items: _brands.where((brand) => brand.isNotEmpty).toSet().map((brand) {
                                return DropdownMenuItem<String>(
                                  value: brand,
                                  child: Text(brand),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedBrand = value?.isNotEmpty == true ? value : null;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Выберите марку';
                                }
                                return null;
                              },
                            ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.green),
                      tooltip: 'Добавить новую марку',
                      onPressed: _showAddBrandDialog,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _modelController,
                  decoration: const InputDecoration(
                    labelText: 'Модель *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите модель автомобиля';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _yearController,
                  decoration: const InputDecoration(
                    labelText: 'Год *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите год выпуска';
                    }
                    final year = int.tryParse(value);
                    if (year == null || year < 1900 || year > DateTime.now().year + 1) {
                      return 'Введите корректный год';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Цена *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите цену';
                    }
                    final price = double.tryParse(value);
                    if (price == null || price <= 0) {
                      return 'Введите корректную цену';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _mileageController,
                  decoration: const InputDecoration(
                    labelText: 'Пробег (км)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _bodyType,
                  items: const [
                    DropdownMenuItem(value: 'Седан', child: Text('Седан')),
                    DropdownMenuItem(value: 'Внедорожник', child: Text('Внедорожник')),
                    DropdownMenuItem(value: 'Хэтчбек', child: Text('Хэтчбек')),
                    DropdownMenuItem(value: 'Универсал', child: Text('Универсал')),
                    DropdownMenuItem(value: 'Купе', child: Text('Купе')),
                    DropdownMenuItem(value: 'Кабриолет', child: Text('Кабриолет')),
                    DropdownMenuItem(value: 'SUV', child: Text('SUV')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _bodyType = value!;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Тип кузова',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _status,
                  items: const [
                    DropdownMenuItem(value: 'available', child: Text('В наличии')),
                    DropdownMenuItem(value: 'reserved', child: Text('Забронировано')),
                    DropdownMenuItem(value: 'sold', child: Text('Продано')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _status = value!;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Статус',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Новые характеристики
                TextFormField(
                  controller: _engineVolumeController,
                  decoration: const InputDecoration(
                    labelText: 'Объем двигателя (л)',
                    hintText: 'Например: 1.6, 2.0, 3.2',
                    helperText: 'Введите объем в литрах (можно с десятичными знаками)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final volume = double.tryParse(value);
                      if (volume == null) {
                        return 'Введите корректный объем (например: 1.6, 2.0, 3.2)';
                      }
                      if (volume <= 0 || volume > 10) {
                        return 'Объем должен быть от 0.1 до 10 литров';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                
                // Тип топлива
                if (!_isLoadingBrands && !_isLoadingCharacteristics && _fuelTypes.isNotEmpty)
                  DropdownButtonFormField<String>(
                    value: _selectedFuelType?.isNotEmpty == true ? _selectedFuelType : null,
                    items: _fuelTypes.where((fuel) => fuel.isNotEmpty).toSet().map((fuel) {
                      return DropdownMenuItem<String>(
                        value: fuel,
                        child: Text(fuel),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedFuelType = value?.isNotEmpty == true ? value : null;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Тип топлива',
                      border: OutlineInputBorder(),
                    ),
                  ),
                const SizedBox(height: 12),
                
                TextFormField(
                  controller: _powerController,
                  decoration: const InputDecoration(
                    labelText: 'Мощность (л.с.)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                
                // Тип трансмиссии
                if (!_isLoadingBrands && !_isLoadingCharacteristics && _transmissionTypes.isNotEmpty)
                  DropdownButtonFormField<String>(
                    value: _selectedTransmissionType?.isNotEmpty == true ? _selectedTransmissionType : null,
                    items: _transmissionTypes.where((transmission) => transmission.isNotEmpty).toSet().map((transmission) {
                      return DropdownMenuItem<String>(
                        value: transmission,
                        child: Text(transmission),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTransmissionType = value?.isNotEmpty == true ? value : null;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Трансмиссия',
                      border: OutlineInputBorder(),
                    ),
                  ),
                const SizedBox(height: 12),
                
                // Тип привода
                if (!_isLoadingBrands && !_isLoadingCharacteristics && _driveTypes.isNotEmpty)
                  DropdownButtonFormField<String>(
                    value: _selectedDriveType?.isNotEmpty == true ? _selectedDriveType : null,
                    items: _driveTypes.where((drive) => drive.isNotEmpty).toSet().map((drive) {
                      return DropdownMenuItem<String>(
                        value: drive,
                        child: Text(drive),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDriveType = value?.isNotEmpty == true ? value : null;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Привод',
                      border: OutlineInputBorder(),
                    ),
                  ),
                const SizedBox(height: 12),
                
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Описание',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => _submitForm(context),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final car = CarEntity(
        id: widget.car?.id ?? 0,
        brand: _selectedBrand!,
        model: _modelController.text,
        year: int.parse(_yearController.text),
        price: double.parse(_priceController.text),
        mileage: int.parse(_mileageController.text.isEmpty ? '0' : _mileageController.text),
        bodyType: _bodyType,
        description: _descriptionController.text,
        status: _status,
        createdAt: widget.car?.createdAt ?? DateTime.now().toIso8601String(),
        
        // Новые характеристики
        engineVolume: _engineVolumeController.text.isNotEmpty 
            ? double.parse(_engineVolumeController.text) 
            : null,
        fuelType: _selectedFuelType,
        power: _powerController.text.isNotEmpty 
            ? int.parse(_powerController.text) 
            : null,
        transmissionType: _selectedTransmissionType,
        driveType: _selectedDriveType,
      );

      if (widget.car == null) {
        context.read<CarManagementBloc>().add(CreateCarEvent(car));
      } else {
        context.read<CarManagementBloc>().add(UpdateCarEvent(car));
      }
    }
  }
}
