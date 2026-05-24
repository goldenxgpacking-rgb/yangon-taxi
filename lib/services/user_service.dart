import 'dart:io';
import '../models/api_response.dart';
import '../models/user.dart';
import '../models/enums.dart';
import 'api_client.dart';

/// 用户服务
class UserService {
  final ApiClient _client;

  UserService(this._client);

  /// 更新用户资料
  Future<ApiResponse<User>> updateProfile({String? name, String? email}) async {
    if (ApiClient.mockMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      return ApiResponse.success(User(
        id: 'user_current',
        phone: '+959000000000',
        name: name ?? '仰光用户',
        email: email,
        points: 120,
        tier: UserTier.silver,
        referralCode: 'YG8888',
      ));
    }

    return _client.put('/users/profile',
      body: {
        if (name != null) 'name': name,
        if (email != null) 'email': email,
      },
      parser: (json) => User.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 上传头像
  Future<ApiResponse<String>> uploadAvatar(File file) async {
    if (ApiClient.mockMode) {
      await Future.delayed(const Duration(seconds: 1));
      return ApiResponse.success(
        'https://api.yangontaxi.com/uploads/avatars/mock_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
    }

    return _client.uploadFile('/users/avatar',
      file: file,
      fieldName: 'avatar',
      parser: (json) => json['url'] as String,
    );
  }

  /// 获取推荐有礼信息
  Future<ApiResponse<Map<String, dynamic>>> getReferralInfo() async {
    if (ApiClient.mockMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      return ApiResponse.success({
        'my_code': 'YG8888',
        'invited_count': 3,
        'total_reward': 15000,
        'reward_per_invite': 5000,
      });
    }

    return _client.get('/users/referral', parser: (json) => json as Map<String, dynamic>);
  }

  /// 使用推荐码
  Future<ApiResponse<Map<String, dynamic>>> applyReferralCode(String code) async {
    if (ApiClient.mockMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (code.toUpperCase() == 'INVALID') {
        return ApiResponse.failure('推荐码无效或已过期');
      }
      final bonus = code.toUpperCase() == 'YG8888' ? 5000 : 3000;
      return ApiResponse.success({'bonus': bonus, 'message': '绑定成功，获得$bonus甲奖励'});
    }

    return _client.post('/users/referral/apply',
      body: {'code': code},
      parser: (json) => json as Map<String, dynamic>,
    );
  }

  /// 获取常用地址
  Future<ApiResponse<List<SavedAddress>>> getSavedAddresses() async {
    if (ApiClient.mockMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      return ApiResponse.success([
        SavedAddress(
          id: 'addr_home',
          label: '家',
          lat: 16.8120,
          lng: 96.1317,
          address: 'Mayangone Township, Yangon',
          isHome: true,
        ),
        SavedAddress(
          id: 'addr_work',
          label: '公司',
          lat: 16.7759,
          lng: 96.1644,
          address: 'Hledan Centre, Kamayut Township, Yangon',
          isWork: true,
        ),
      ]);
    }

    return _client.get('/users/addresses',
      parser: (json) => (json as List).map((e) => SavedAddress.fromJson(e)).toList(),
    );
  }

  /// 添加常用地址
  Future<ApiResponse<SavedAddress>> addSavedAddress(SavedAddress address) async {
    if (ApiClient.mockMode) {
      await Future.delayed(const Duration(milliseconds: 400));
      return ApiResponse.success(address);
    }

    return _client.post('/users/addresses',
      body: address.toJson(),
      parser: (json) => SavedAddress.fromJson(json),
    );
  }

  /// 删除常用地址
  Future<ApiResponse<void>> deleteSavedAddress(String addressId) async {
    if (ApiClient.mockMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      return ApiResponse.success(null);
    }

    return _client.delete('/users/addresses/$addressId', parser: (_) {});
  }
}
