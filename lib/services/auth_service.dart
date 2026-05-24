import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/api_response.dart';
import '../models/user.dart';
import '../models/enums.dart';
import 'api_client.dart';

/// 认证服务
class AuthService {
  final ApiClient _client;
  final _storage = const FlutterSecureStorage();

  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyUserId = 'user_id';

  AuthService(this._client);

  /// 发送 OTP
  Future<ApiResponse<String>> sendOtp(String phone) async {
    if (ApiClient.mockMode) {
      await Future.delayed(const Duration(milliseconds: 800));
      return ApiResponse.success('123456', message: '验证码已发送');
    }
    return _client.post('/auth/send-otp',
      body: {'phone': phone},
      parser: (json) => json as String,
    );
  }

  /// 验证 OTP 并登录
  Future<ApiResponse<User>> verifyOtp({
    required String phone,
    required String otp,
    String? email,
    required bool isRegistration,
  }) async {
    if (ApiClient.mockMode) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (otp != '123456') {
        return ApiResponse.failure('验证码错误');
      }
      final user = User(
        id: 'user_${phone.hashCode}',
        phone: phone,
        email: email,
        name: isRegistration ? (email?.split('@').first ?? '用户') : null,
        points: 120,
        tier: UserTier.silver,
        referralCode: _generateReferralCode(),
      );
      await _saveAuth(user.id, 'mock_token_${DateTime.now().millisecondsSinceEpoch}', null);
      return ApiResponse.success(user);
    }

    return _client.post('/auth/verify-otp',
      body: {
        'phone': phone,
        'otp': otp,
        if (email != null) 'email': email,
        'is_registration': isRegistration,
      },
      parser: (json) => User.fromJson(json),
    );
  }

  /// 检查是否已登录
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: _keyAccessToken);
    if (token != null) {
      _client.setTokens(access: token);
      return true;
    }
    return false;
  }

  /// 获取当前用户信息
  Future<ApiResponse<User>> getCurrentUser() async {
    if (ApiClient.mockMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      final userId = await _storage.read(key: _keyUserId);
      if (userId == null) return ApiResponse.failure('未登录');
      return ApiResponse.success(User(
        id: userId,
        phone: '+959000000000',
        name: '仰光用户',
        points: 120,
        tier: UserTier.silver,
        referralCode: 'YG8888',
      ));
    }

    return _client.get('/auth/me',
      parser: (json) => User.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 登出
  Future<void> logout() async {
    if (!ApiClient.mockMode) {
      try {
        await _client.post('/auth/logout', body: {}, parser: (_) {});
      } catch (_) {}
    }
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
    await _storage.delete(key: _keyUserId);
    _client.clearTokens();
  }

  Future<void> _saveAuth(String userId, String accessToken, String? refreshToken) async {
    await _storage.write(key: _keyUserId, value: userId);
    await _storage.write(key: _keyAccessToken, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: _keyRefreshToken, value: refreshToken);
    }
    _client.setTokens(access: accessToken, refresh: refreshToken);
  }

  String _generateReferralCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return 'YG${List.generate(4, (_) => chars[rand.nextInt(chars.length)]).join()}';
  }
}
