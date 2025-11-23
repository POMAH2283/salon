import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/services/api_service.dart';
import '../../domain/entities/client_entity.dart';
import '../models/client_model.dart';

abstract class ClientsRepository {
  Future<List<Client>> getClients();
  Future<Client> getClient(int id);
  Future<Client> createClient(Client client);
  Future<Client> updateClient(Client client);
  Future<void> deleteClient(int id);
}

class ClientsRepositoryImpl implements ClientsRepository {
  final ApiService _apiService;
  final FlutterSecureStorage _storage;

  ClientsRepositoryImpl()
      : _apiService = ApiService.instance,
        _storage = const FlutterSecureStorage();

  @override
  Future<List<Client>> getClients() async {
    try {
      print('🔄 Getting clients from server');
      
      final response = await _apiService.get('/api/clients');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final clients = data.map((json) => Client.fromJson(json)).toList();
        
        print('✅ Got ${clients.length} clients from server');
        return clients;
      } else {
        throw Exception('Failed to load clients: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Get clients error: $e');
      throw Exception('Ошибка загрузки клиентов: $e');
    }
  }

  @override
  Future<Client> getClient(int id) async {
    try {
      print('🔄 Getting client $id from server');
      
      final response = await _apiService.get('/api/clients/$id');
      
      if (response.statusCode == 200) {
        final client = Client.fromJson(response.data);
        print('✅ Got client: ${client.name}');
        return client;
      } else {
        throw Exception('Failed to load client: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Get client error: $e');
      throw Exception('Ошибка загрузки клиента: $e');
    }
  }

  @override
  Future<Client> createClient(Client client) async {
    try {
      print('🔄 Creating client: ${client.name}');
      
      final response = await _apiService.post('/api/clients', data: client.toJson());
      
      if (response.statusCode == 201) {
        final newClient = Client.fromJson(response.data);
        print('✅ Created client: ${newClient.name}');
        return newClient;
      } else {
        throw Exception('Failed to create client: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Create client error: $e');
      throw Exception('Ошибка создания клиента: $e');
    }
  }

  @override
  Future<Client> updateClient(Client client) async {
    try {
      print('🔄 Updating client: ${client.name}');
      
      final response = await _apiService.put('/api/clients/${client.id}', data: client.toJson());
      
      if (response.statusCode == 200) {
        final updatedClient = Client.fromJson(response.data);
        print('✅ Updated client: ${updatedClient.name}');
        return updatedClient;
      } else {
        throw Exception('Failed to update client: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Update client error: $e');
      throw Exception('Ошибка обновления клиента: $e');
    }
  }

  @override
  Future<void> deleteClient(int id) async {
    try {
      print('🔄 Deleting client $id');
      
      final response = await _apiService.delete('/api/clients/$id');
      
      if (response.statusCode == 200) {
        print('✅ Deleted client $id');
      } else {
        throw Exception('Failed to delete client: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Delete client error: $e');
      throw Exception('Ошибка удаления клиента: $e');
    }
  }

  // Дополнительный метод для поиска клиентов по имени
  Future<List<Client>> searchClients(String query) async {
    try {
      final allClients = await getClients();
      
      if (query.isEmpty) {
        return allClients;
      }
      
      return allClients.where((client) =>
        client.name.toLowerCase().contains(query.toLowerCase()) ||
        (client.phone != null && client.phone!.contains(query)) ||
        (client.email != null && client.email!.toLowerCase().contains(query.toLowerCase()))
      ).toList();
    } catch (e) {
      print('❌ Search clients error: $e');
      throw Exception('Ошибка поиска клиентов: $e');
    }
  }
}