import 'dart:math';
import '../models/api_response.dart';
import 'api_client.dart';

/// 推荐有礼服务
/// 负责推荐码生成、分享、绑定验证
class ReferralService {
  final ApiClient _client;

  ReferralService(this._client);

  /// 获取推荐信息
  Future<ApiResponse<ReferralInfo>> getReferralInfo() async {
    if (ApiClient.mockMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      return ApiResponse.success(ReferralInfo(
        myCode: 'YG8888',
        invitedCount: 3,
        totalReward: 15000,
        rewardPerInvite: 5000,
        minWithdraw: 10000,
      ));
    }

    return _client.get('/referral/info', parser: (json) => ReferralInfo.fromJson(json));
  }

  /// 验证推荐码是否有效
  Future<ApiResponse<bool>> validateCode(String code) async {
    if (ApiClient.mockMode) {
      await Future.delayed(const Duration(milliseconds: 400));
      // 4-8位字母数字
      final valid = RegExp(r'^[A-Z0-9]{4,8}$').hasMatch(code.toUpperCase());
      return ApiResponse.success(valid && code.toUpperCase() != 'YG8888');
    }

    return _client.get('/referral/validate',
      queryParams: {'code': code},
      parser: (json) => json['valid'] as bool,
    );
  }

  /// 使用推荐码（注册时绑定 / 我的页面输入）
  Future<ApiResponse<int>> applyCode(String code) async {
    if (ApiClient.mockMode) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (code.toUpperCase() == 'INVALID') {
        return ApiResponse.failure('推荐码无效或已过期');
      }
      final reward = code.toUpperCase() == 'YG8888' ? 5000 : 3000;
      return ApiResponse.success(reward, message: '绑定成功，获得 $reward 甲奖励！');
    }

    return _client.post('/referral/apply',
      body: {'code': code.toUpperCase()},
      parser: (json) => json['reward'] as int,
    );
  }

  /// 获取推荐记录
  Future<ApiResponse<List<ReferralRecord>>> getReferralHistory() async {
    if (ApiClient.mockMode) {
      await Future.delayed(const Duration(milliseconds: 400));
      final rand = Random();
      return ApiResponse.success(List.generate(3, (i) => ReferralRecord(
        phone: '+959${rand.nextInt(90000000) + 10000000}',
        reward: 5000,
        joinedAt: DateTime.now().subtract(Duration(days: i * 7 + 3)),
      )));
    }

    return _client.get('/referral/history', parser: (json) {
      return (json as List).map((e) => ReferralRecord.fromJson(e)).toList();
    });
  }
}

/// 推荐信息
class ReferralInfo {
  final String myCode;
  final int invitedCount;
  final int totalReward;
  final int rewardPerInvite;
  final int minWithdraw;

  ReferralInfo({
    required this.myCode,
    required this.invitedCount,
    required this.totalReward,
    required this.rewardPerInvite,
    required this.minWithdraw,
  });

  int get withdrawable => totalReward >= minWithdraw ? totalReward : 0;

  factory ReferralInfo.fromJson(Map<String, dynamic> json) {
    return ReferralInfo(
      myCode: json['my_code'] as String,
      invitedCount: json['invited_count'] as int? ?? 0,
      totalReward: json['total_reward'] as int? ?? 0,
      rewardPerInvite: json['reward_per_invite'] as int? ?? 5000,
      minWithdraw: json['min_withdraw'] as int? ?? 10000,
    );
  }
}

/// 推荐记录
class ReferralRecord {
  final String phone;
  final int reward;
  final DateTime joinedAt;

  ReferralRecord({
    required this.phone,
    required this.reward,
    required this.joinedAt,
  });

  /// 脱敏手机号
  String get maskedPhone => phone.replaceFirstMapped(
    RegExp(r'\d(?=.{4})'),
    (m) => '*',
  );

  factory ReferralRecord.fromJson(Map<String, dynamic> json) {
    return ReferralRecord(
      phone: json['phone'] as String,
      reward: json['reward'] as int,
      joinedAt: DateTime.parse(json['joined_at'] as String),
    );
  }
}
