import '../../core/network/api_client.dart';
import '../../services/api_contract.dart';
import '../models/homefundi_models.dart';

class BookingRepository {
  BookingRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<BookingDto>> list({String? status}) async {
    final query = <String, String>{};
    if (status != null && status.isNotEmpty) {
      query['status'] = status;
    }
    final response = await _apiClient.getJson(
      ApiContract.bookings,
      queryParameters: query.isEmpty ? null : query,
    );
    return _parseList(response, 'bookings').map(BookingDto.fromJson).toList();
  }

  Future<BookingDto?> findById(String id) async {
    final response = await _apiClient.getJson('${ApiContract.bookings}/$id');
    final data = response['booking'] ?? response;
    if (data is Map<String, dynamic>) {
      return BookingDto.fromJson(data);
    }
    return null;
  }

  Future<BookingDto> create(Map<String, dynamic> payload) async {
    final response = await _apiClient.postJson(ApiContract.bookings, body: payload);
    final data = response['booking'] ?? response;
    return BookingDto.fromJson(_ensureMap(data));
  }

  Future<BookingDto> confirm(String id) async {
    final response = await _apiClient.postJson(ApiContract.bookingConfirm(id));
    final data = response['booking'] ?? response;
    return BookingDto.fromJson(_ensureMap(data));
  }

  Future<BookingDto> updateStatus(String id, String status) async {
    final response = await _apiClient.patchJson(
      ApiContract.bookingStatus(id),
      body: <String, dynamic>{'status': status},
    );
    final data = response['booking'] ?? response;
    return BookingDto.fromJson(_ensureMap(data));
  }

  Future<BookingDto> cancel(String id, {String? reason}) async {
    final response = await _apiClient.postJson(
      ApiContract.bookingCancel(id),
      body: <String, dynamic>{if (reason != null) 'reason': reason},
    );
    final data = response['booking'] ?? response;
    return BookingDto.fromJson(_ensureMap(data));
  }

  Future<BookingDto> rate(
    String id, {
    required double rating,
    String? comment,
  }) async {
    final response = await _apiClient.postJson(
      ApiContract.bookingRate(id),
      body: <String, dynamic>{
        'rating': rating,
        if (comment != null) 'comment': comment,
      },
    );
    final data = response['booking'] ?? response;
    return BookingDto.fromJson(_ensureMap(data));
  }

  Future<BookingDto> submitOtp({
    required String bookingId,
    required String otp,
  }) async {
    final response = await _apiClient.postJson(
      '${ApiContract.bookings}/$bookingId/otp',
      body: <String, dynamic>{'otp': otp},
    );
    final data = response['booking'] ?? response;
    return BookingDto.fromJson(_ensureMap(data));
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