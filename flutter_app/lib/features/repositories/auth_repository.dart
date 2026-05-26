import '../../core/network/api_client.dart';
import '../../core/storage/token_storage.dart';
import '../../services/api_contract.dart';
import '../models/homefundi_models.dart';

class AuthRepository {
  AuthRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  Future<AuthSessionDto> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.postJson(
      ApiContract.authLogin,
      authenticated: false,
      body: <String, dynamic>{
        'email': email,
        'password': password,
      },
    );
    final session = AuthSessionDto.fromJson(response);
    if (session.accessToken.isNotEmpty) {
      await _tokenStorage.saveSession(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
        tokenType: session.tokenType,
        profile: session.profile?.toJson(),
        expiresAt: session.expiresAt,
      );
    }
    return session;
  }

  Future<AuthSessionDto> register(Map<String, dynamic> payload) async {
    final response = await _apiClient.postJson(
      ApiContract.authRegister,
      authenticated: false,
      body: payload,
    );
    final session = AuthSessionDto.fromJson(response);
    if (session.accessToken.isNotEmpty) {
      await _tokenStorage.saveSession(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
        tokenType: session.tokenType,
        profile: session.profile?.toJson(),
        expiresAt: session.expiresAt,
      );
    }
    return session;
  }

  Future<UserDto?> profile({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await _tokenStorage.readProfile();
      if (cached != null && cached.isNotEmpty) {
        return UserDto.fromJson(cached);
      }
    }

    final response = await _apiClient.getJson(ApiContract.authProfile);
    final data = response['user'] ?? response['profile'] ?? response;
    if (data is Map<String, dynamic>) {
      final user = UserDto.fromJson(data);
      await _tokenStorage.saveProfile(user.toJson());
      return user;
    }
    return null;
  }

  Future<void> logout() async {
    try {
      await _apiClient.postJson(ApiContract.authLogout);
    } finally {
      await _tokenStorage.clear();
    }
  }

  Future<String?> refresh() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }

    final response = await _apiClient.postJson(
      ApiContract.authRefresh,
      authenticated: false,
      body: <String, dynamic>{'refresh_token': refreshToken},
    );

    final token = response['access_token']?.toString() ?? response['token']?.toString();
    if (token != null && token.isNotEmpty) {
      await _tokenStorage.saveTokens(
        accessToken: token,
        refreshToken: response['refresh_token']?.toString(),
        tokenType: response['token_type']?.toString(),
      );
    }
    return token;
  }

  Future<UserDto?> meCached() async {
    final cached = await _tokenStorage.readProfile();
    if (cached == null) return null;
    return UserDto.fromJson(cached);
  }
}