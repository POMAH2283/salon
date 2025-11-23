import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cars_bloc.dart';

class CarFiltersDialog extends StatefulWidget {
  final Map<String, dynamic>? initialFilters;

  const CarFiltersDialog({
    Key? key,
    this.initialFilters,
  }) : super(key: key);

  @override
  State<CarFiltersDialog> createState() => _CarFiltersDialogState();
}

class _CarFiltersDialogState extends State<CarFiltersDialog> {
  final _formKey = GlobalKey<FormState>();
  
  // Filter values
  String _selectedBrand = 'all';
  String _selectedBodyType = 'all';
  String _selectedFuelType = 'all';
  String _selectedTransmissionType = 'all';
  String _selectedDriveType = 'all';
  
  // Range controllers
  final TextEditingController _yearMinController = TextEditingController();
  final TextEditingController _yearMaxController = TextEditingController();
  final TextEditingController _priceMinController = TextEditingController();
  final TextEditingController _priceMaxController = TextEditingController();
  final TextEditingController _mileageMinController = TextEditingController();
  final TextEditingController _mileageMaxController = TextEditingController();
  final TextEditingController _engineVolumeMinController = TextEditingController();
  final TextEditingController _engineVolumeMaxController = TextEditingController();
  final TextEditingController _powerMinController = TextEditingController();
  final TextEditingController _powerMaxController = TextEditingController();

  // Filter options
  List<Map<String, dynamic>> _brands = [];
  List<Map<String, dynamic>> _bodyTypes = [];
  List<Map<String, dynamic>> _fuelTypes = [];
  List<Map<String, dynamic>> _transmissionTypes = [];
  List<Map<String, dynamic>> _driveTypes = [];

  @override
  void initState() {
    super.initState();
    _loadFilterOptions();
    _loadInitialFilters();
  }

  @override
  void dispose() {
    // Dispose text controllers for range filters
    _yearMinController.dispose();
    _yearMaxController.dispose();
    _priceMinController.dispose();
    _priceMaxController.dispose();
    _mileageMinController.dispose();
    _mileageMaxController.dispose();
    _engineVolumeMinController.dispose();
    _engineVolumeMaxController.dispose();
    _powerMinController.dispose();
    _powerMaxController.dispose();
    super.dispose();
  }

  void _loadFilterOptions() async {
    try {
      final carsBloc = context.read<CarsBloc>();
      
      // Load all filter options from the bloc
      carsBloc.add(LoadAllFilterOptionsEvent());
      
      // Listen for the result
      carsBloc.stream.listen((state) {
        if (state is FilterOptionsLoaded) {
          setState(() {
            _brands = (state.filterOptions['brands'] ?? []).map((option) => {
              'id': option.id,
              'name': option.name,
            }).toList();
            
            _bodyTypes = (state.filterOptions['bodyTypes'] ?? []).map((option) => {
              'id': option.id,
              'name': option.name,
            }).toList();
            
            _fuelTypes = (state.filterOptions['fuelTypes'] ?? []).map((option) => {
              'id': option.id,
              'name': option.name,
            }).toList();
            
            _transmissionTypes = (state.filterOptions['transmissionTypes'] ?? []).map((option) => {
              'id': option.id,
              'name': option.name,
            }).toList();
            
            _driveTypes = (state.filterOptions['driveTypes'] ?? []).map((option) => {
              'id': option.id,
              'name': option.name,
            }).toList();
          });
        } else if (state is FilterOptionsError) {
          // В случае ошибки используем захардкоженные данные
          _useHardcodedData();
        }
      });
      
    } catch (e) {
      // В случае ошибки используем захардкоженные данные
      _useHardcodedData();
    }
  }
  
  void _useHardcodedData() {
    setState(() {
      _brands = [
        {'id': 'all', 'name': 'Все бренды'},
        {'id': 'Toyota', 'name': 'Toyota'},
        {'id': 'BMW', 'name': 'BMW'},
        {'id': 'Mercedes', 'name': 'Mercedes'},
        {'id': 'Audi', 'name': 'Audi'},
      ];
      
      _bodyTypes = [
        {'id': 'all', 'name': 'Все типы кузова'},
        {'id': 'Седан', 'name': 'Седан'},
        {'id': 'Хэтчбек', 'name': 'Хэтчбек'},
        {'id': 'Внедорожник', 'name': 'Внедорожник'},
        {'id': 'Кроссовер', 'name': 'Кроссовер'},
        {'id': 'Купе', 'name': 'Купе'},
      ];
      
      _fuelTypes = [
        {'id': 'all', 'name': 'Все типы топлива'},
        {'id': 'Бензин', 'name': 'Бензин'},
        {'id': 'Дизель', 'name': 'Дизель'},
        {'id': 'Газ', 'name': 'Газ'},
        {'id': 'Гибрид', 'name': 'Гибрид'},
        {'id': 'Электричество', 'name': 'Электричество'},
      ];
      
      _transmissionTypes = [
        {'id': 'all', 'name': 'Все трансмиссии'},
        {'id': 'Механика', 'name': 'Механика'},
        {'id': 'Автомат', 'name': 'Автомат'},
        {'id': 'Вариатор', 'name': 'Вариатор'},
        {'id': 'Робот', 'name': 'Робот'},
      ];
      
      _driveTypes = [
        {'id': 'all', 'name': 'Все приводы'},
        {'id': 'Передний', 'name': 'Передний'},
        {'id': 'Задний', 'name': 'Задний'},
        {'id': 'Полный', 'name': 'Полный'},
        {'id': 'Подключаемый полный', 'name': 'Подключаемый полный'},
      ];
    });
  }

  void _loadInitialFilters() {
    if (widget.initialFilters == null) return;

    _selectedBrand = widget.initialFilters!['brand'] ?? 'all';
    _selectedBodyType = widget.initialFilters!['body_type'] ?? 'all';
    _selectedFuelType = widget.initialFilters!['fuel_type'] ?? 'all';
    _selectedTransmissionType = widget.initialFilters!['transmission_type'] ?? 'all';
    _selectedDriveType = widget.initialFilters!['drive_type'] ?? 'all';
    
    _yearMinController.text = widget.initialFilters!['year_min']?.toString() ?? '';
    _yearMaxController.text = widget.initialFilters!['year_max']?.toString() ?? '';
    _priceMinController.text = widget.initialFilters!['price_min']?.toString() ?? '';
    _priceMaxController.text = widget.initialFilters!['price_max']?.toString() ?? '';
    _mileageMinController.text = widget.initialFilters!['mileage_min']?.toString() ?? '';
    _mileageMaxController.text = widget.initialFilters!['mileage_max']?.toString() ?? '';
    _engineVolumeMinController.text = widget.initialFilters!['engine_volume_min']?.toString() ?? '';
    _engineVolumeMaxController.text = widget.initialFilters!['engine_volume_max']?.toString() ?? '';
    _powerMinController.text = widget.initialFilters!['power_min']?.toString() ?? '';
    _powerMaxController.text = widget.initialFilters!['power_max']?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Фильтры автомобилей',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _buildDropdownFilter('Бренд', _selectedBrand, _brands, (value) {
                        setState(() {
                          _selectedBrand = value ?? 'all';
                        });
                      }),
                      const SizedBox(height: 16),
                      _buildDropdownFilter('Тип кузова', _selectedBodyType, _bodyTypes, (value) {
                        setState(() {
                          _selectedBodyType = value ?? 'all';
                        });
                      }),
                      const SizedBox(height: 16),
                      _buildDropdownFilter('Тип топлива', _selectedFuelType, _fuelTypes, (value) {
                        setState(() {
                          _selectedFuelType = value ?? 'all';
                        });
                      }),
                      const SizedBox(height: 16),
                      _buildDropdownFilter('Трансмиссия', _selectedTransmissionType, _transmissionTypes, (value) {
                        setState(() {
                          _selectedTransmissionType = value ?? 'all';
                        });
                      }),
                      const SizedBox(height: 16),
                      _buildDropdownFilter('Привод', _selectedDriveType, _driveTypes, (value) {
                        setState(() {
                          _selectedDriveType = value ?? 'all';
                        });
                      }),
                      const SizedBox(height: 24),
                      const Text(
                        'Диапазоны значений',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _buildRangeFilter('Год выпуска', _yearMinController, _yearMaxController, 'год'),
                      const SizedBox(height: 16),
                      _buildRangeFilter('Цена (₽)', _priceMinController, _priceMaxController, '₽'),
                      const SizedBox(height: 16),
                      _buildRangeFilter('Пробег (км)', _mileageMinController, _mileageMaxController, 'км'),
                      const SizedBox(height: 16),
                      _buildRangeFilter('Объем двигателя (л)', _engineVolumeMinController, _engineVolumeMaxController, 'л'),
                      const SizedBox(height: 16),
                      _buildRangeFilter('Мощность (л.с.)', _powerMinController, _powerMaxController, 'л.с.'),
                    ],
                  ),
                ),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _clearFilters,
                    child: const Text('Очистить'),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Отмена'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _applyFilters,
                        child: const Text('Применить'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownFilter(String label, String currentValue, List<Map<String, dynamic>> options, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: currentValue,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: options.map((option) => DropdownMenuItem<String>(
            value: option['id'],
            child: Text(option['name']),
          )).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildRangeFilter(String label, TextEditingController minController, TextEditingController maxController, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: minController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'От',
                  suffixText: unit,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: maxController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'До',
                  suffixText: unit,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _clearFilters() {
    _selectedBrand = 'all';
    _selectedBodyType = 'all';
    _selectedFuelType = 'all';
    _selectedTransmissionType = 'all';
    _selectedDriveType = 'all';
    
    _yearMinController.clear();
    _yearMaxController.clear();
    _priceMinController.clear();
    _priceMaxController.clear();
    _mileageMinController.clear();
    _mileageMaxController.clear();
    _engineVolumeMinController.clear();
    _engineVolumeMaxController.clear();
    _powerMinController.clear();
    _powerMaxController.clear();
    
    setState(() {});
  }

  void _applyFilters() {
    final filters = <String, dynamic>{};
    
    // Dropdown filters
    if (_selectedBrand != 'all') filters['brand'] = _selectedBrand;
    if (_selectedBodyType != 'all') filters['body_type'] = _selectedBodyType;
    if (_selectedFuelType != 'all') filters['fuel_type'] = _selectedFuelType;
    if (_selectedTransmissionType != 'all') filters['transmission_type'] = _selectedTransmissionType;
    if (_selectedDriveType != 'all') filters['drive_type'] = _selectedDriveType;
    
    // Range filters with proper error handling
    if (_yearMinController.text.isNotEmpty) {
      try {
        filters['year_min'] = int.parse(_yearMinController.text);
      } catch (e) {
        // Ignore invalid values
      }
    }
    if (_yearMaxController.text.isNotEmpty) {
      try {
        filters['year_max'] = int.parse(_yearMaxController.text);
      } catch (e) {
        // Ignore invalid values
      }
    }
    if (_priceMinController.text.isNotEmpty) {
      try {
        filters['price_min'] = double.parse(_priceMinController.text);
      } catch (e) {
        // Ignore invalid values
      }
    }
    if (_priceMaxController.text.isNotEmpty) {
      try {
        filters['price_max'] = double.parse(_priceMaxController.text);
      } catch (e) {
        // Ignore invalid values
      }
    }
    if (_mileageMinController.text.isNotEmpty) {
      try {
        filters['mileage_min'] = int.parse(_mileageMinController.text);
      } catch (e) {
        // Ignore invalid values
      }
    }
    if (_mileageMaxController.text.isNotEmpty) {
      try {
        filters['mileage_max'] = int.parse(_mileageMaxController.text);
      } catch (e) {
        // Ignore invalid values
      }
    }
    if (_engineVolumeMinController.text.isNotEmpty) {
      try {
        filters['engine_volume_min'] = double.parse(_engineVolumeMinController.text);
      } catch (e) {
        // Ignore invalid values
      }
    }
    if (_engineVolumeMaxController.text.isNotEmpty) {
      try {
        filters['engine_volume_max'] = double.parse(_engineVolumeMaxController.text);
      } catch (e) {
        // Ignore invalid values
      }
    }
    if (_powerMinController.text.isNotEmpty) {
      try {
        filters['power_min'] = int.parse(_powerMinController.text);
      } catch (e) {
        // Ignore invalid values
      }
    }
    if (_powerMaxController.text.isNotEmpty) {
      try {
        filters['power_max'] = int.parse(_powerMaxController.text);
      } catch (e) {
        // Ignore invalid values
      }
    }
    
    Navigator.pop(context, filters);
  }
}