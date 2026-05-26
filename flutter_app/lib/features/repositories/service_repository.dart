import '../../core/network/api_client.dart';
import '../../services/api_contract.dart';
import '../models/homefundi_models.dart';

class ServiceRepository {
  ServiceRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ServiceDto>> list({String? category, bool activeOnly = true}) async {
    final query = <String, String>{};
    if (category != null && category.isNotEmpty) {
      query['category'] = category;
    }
    if (activeOnly) {
      query['active'] = '1';
    }

    final response = await _apiClient.getJson(
      ApiContract.services,
      queryParameters: query.isEmpty ? null : query,
    );
    return _parseList(response, 'services').map(ServiceDto.fromJson).toList();
  }

  Future<ServiceDto?> findById(String id) async {
    final response = await _apiClient.getJson(ApiContract.serviceById(id));
    final data = response['service'] ?? response;
    if (data is Map<String, dynamic>) {
      return ServiceDto.fromJson(data);
    }
    return null;
  }

  Future<ServiceDto> create(Map<String, dynamic> payload) async {
    final response = await _apiClient.postJson(ApiContract.services, body: payload);
    final data = response['service'] ?? response;
    return ServiceDto.fromJson(_ensureMap(data));
  }

  Future<ServiceDto> update(String id, Map<String, dynamic> payload) async {
    final response = await _apiClient.putJson(ApiContract.serviceById(id), body: payload);
    final data = response['service'] ?? response;
    return ServiceDto.fromJson(_ensureMap(data));
  }

  Future<void> delete(String id) async {
    await _apiClient.deleteJson(ApiContract.serviceById(id));
  }

  List<Map<String, dynamic>> _parseList(Map<String, dynamic> response, String key) {
    final data = response[key] ?? response['data'] ?? response['items'] ?? response;
    if (data is List) {
      return data.whereType<Map>().map(_ensureMap).toList();
    }
    if (data is Map<String, dynamic>) {
      final inner = data[key];
      if (inner is List) {
        return inner.whereType<Map>().map(_ensureMap).toList();
      }
    }
    return <Map<String, dynamic>>[];
  }

  Map<String, dynamic> _ensureMap(Map value) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
}