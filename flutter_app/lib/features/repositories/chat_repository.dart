import '../../core/network/api_client.dart';
import '../../services/api_contract.dart';
import '../models/homefundi_models.dart';

class ChatRepository {
  ChatRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ChatThreadDto>> threads() async {
    final response = await _apiClient.getJson(ApiContract.chatThreads());
    return _parseList(response, 'threads').map(ChatThreadDto.fromJson).toList();
  }

  Future<List<MessageDto>> messages(String threadId) async {
    final response = await _apiClient.getJson(ApiContract.chatMessages(threadId));
    return _parseList(response, 'messages').map(MessageDto.fromJson).toList();
  }

  Future<MessageDto> sendMessage({
    required String threadId,
    required String message,
  }) async {
    final response = await _apiClient.postJson(
      ApiContract.chatMessages(threadId),
      body: <String, dynamic>{'message': message},
    );
    final data = response['message'] ?? response['data'] ?? response;
    return MessageDto.fromJson(_ensureMap(data));
  }

  Future<ChatThreadDto?> findThread(String id) async {
    final response = await _apiClient.getJson('${ApiContract.chats}/$id');
    final data = response['thread'] ?? response['chat'] ?? response;
    if (data is Map<String, dynamic>) {
      return ChatThreadDto.fromJson(data);
    }
    return null;
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