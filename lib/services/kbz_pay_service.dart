import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

/// KBZ Pay 模拟支付服务
class KBZPayService {
  static const String _balanceKey = 'kbz_pay_balance';
  static const double _defaultBalance = 50000.0; // 默认余额 50,000 KS

  /// 获取余额
  static Future<double> getBalance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_balanceKey) ?? _defaultBalance;
  }

  /// 设置余额（仅用于测试）
  static Future<void> setBalance(double amount) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_balanceKey, amount);
  }

  /// 生成模拟二维码数据
  static String generateQRData({
    required String merchantId,
    required double amount,
    required String tripId,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'kbzpay://pay?merchant=$merchantId&amount=$amount&ref=$tripId&ts=$timestamp';
  }

  /// 模拟支付处理
  /// 返回: {'success': bool, 'message': String, 'transactionId': String}
  static Future<Map<String, dynamic>> processPayment({
    required double amount,
    required String tripId,
  }) async {
    // 模拟网络延迟 2-4 秒
    await Future.delayed(Duration(seconds: 2 + Random().nextInt(2)));

    final balance = await getBalance();

    // 模拟 10% 概率支付失败
    final isSuccess = Random().nextDouble() > 0.1;

    if (!isSuccess) {
      return {
        'success': false,
        'message': 'Payment failed. Please try again.',
        'transactionId': '',
      };
    }

    // 检查余额
    if (balance < amount) {
      return {
        'success': false,
        'message': 'Insufficient balance. Please top up.',
        'transactionId': '',
      };
    }

    // 扣款
    await setBalance(balance - amount);

    // 生成交易 ID
    final txId = 'KBZ${DateTime.now().millisecondsSinceEpoch}';

    return {
      'success': true,
      'message': 'Payment successful',
      'transactionId': txId,
      'newBalance': balance - amount,
    };
  }

  /// 模拟查询交易状态
  static Future<Map<String, dynamic>> checkTransactionStatus(String transactionId) async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'transactionId': transactionId,
      'status': 'completed',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// 模拟获取交易历史
  static Future<List<Map<String, dynamic>>> getTransactionHistory() async {
    // 返回模拟数据
    return [
      {
        'id': 'KBZ1700000001',
        'amount': 2500.0,
        'status': 'completed',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'description': 'Taxi fare - Yangon Taxi',
      },
      {
        'id': 'KBZ1700000002',
        'amount': 1800.0,
        'status': 'completed',
        'timestamp': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'description': 'Taxi fare - Yangon Taxi',
      },
    ];
  }
}
