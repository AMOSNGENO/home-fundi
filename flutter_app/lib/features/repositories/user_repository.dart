import '../../core/network/api_client.dart';
import '../../services/api_contract.dart';
import '../models/homefundi_models.dart';

class UserRepository {
  UserRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<UserDto>> list() async {
    final response = await _apiClient.getJson(ApiContract.users);
    return _parseList(response, 'users').map(UserDto.fromJson).toList();
  }

  Future<UserDto?> findById(String id) async {
    final response = await _apiClient.getJson(ApiContract.userById(id));
    final data = response['user'] ?? response;
    if (data is Map<String, dynamic>) {
      return UserDto.fromJson(data);
    }
    return null;
  }

  Future<UserDto> create(Map<String, dynamic> payload) async {
    final response = await _apiClient.postJson(ApiContract.users, body: payload);
    final data = response['user'] ?? response;
    return UserDto.fromJson(_ensureMap(data));
  }

  Future<UserDto> update(String id, Map<String, dynamic> payload) async {
    final response = await _apiClient.putJson(ApiContract.userById(id), body: payload);
    final data = response['user'] ?? response;
    return UserDto.fromJson(_ensureMap(data));
  }

  Future<void> delete(String id) async {
    await _apiClient.deleteJson(ApiContract.userById(id));
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