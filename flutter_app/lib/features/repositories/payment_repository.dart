import '../../core/network/api_client.dart';
import '../../services/api_contract.dart';
import '../models/homefundi_models.dart';

class PaymentRepository {
  PaymentRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<PaymentDto>> list({String? bookingId}) async {
    final query = <String, String>{};
    if (bookingId != null && bookingId.isNotEmpty) {
      query['booking_id'] = bookingId;
    }
    final response = await _apiClient.getJson(
      ApiContract.payments,
      queryParameters: query.isEmpty ? null : query,
    );
    return _parseList(response, 'payments').map(PaymentDto.fromJson).toList();
  }

  Future<PaymentDto> create(Map<String, dynamic> payload) async {
    final response = await _apiClient.postJson(ApiContract.payments, body: payload);
    final data = response['payment'] ?? response;
    return PaymentDto.fromJson(_ensureMap(data));
  }

  Future<PaymentDto> verify(String paymentId, {String? code}) async {
    final response = await _apiClient.postJson(
      ApiContract.paymentVerify(paymentId),
      body: <String, dynamic>{if (code != null) 'code': code},
    );
    final data = response['payment'] ?? response;
    return PaymentDto.fromJson(_ensureMap(data));
  }

  Future<PaymentDto> refund(String paymentId, {String? reason}) async {
    final response = await _apiClient.postJson(
      ApiContract.paymentRefund(paymentId),
      body: <String, dynamic>{if (reason != null) 'reason': reason},
    );
    final data = response['payment'] ?? response;
    return PaymentDto.fromJson(_ensureMap(data));
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