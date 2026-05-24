import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// KBZ Pay Deep Link 服务
/// 处理调起 KBZ Pay App 和检测是否安装
class KBZPayDeeplinkService {
  static const String _kbzPayPackage = 'com.kbzpay.my';
  static const String _merchantIdKey = 'kbz_merchant_id';

  /// 商户 ID（正式上线前需向 KBZ Bank 申请）
  /// 测试用商户 ID
  static const String _testMerchantId = 'MERCHANT_YANGON_TAXI_001';

  /// 获取保存的商户 ID
  static Future<String> getMerchantId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_merchantIdKey) ?? _testMerchantId;
  }

  /// 设置商户 ID
  static Future<void> setMerchantId(String merchantId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_merchantIdKey, merchantId);
  }

  /// 检测 KBZ Pay 是否安装（Android）
  static Future<bool> isKBZPayInstalled() async {
    try {
      // 尝试通过 PackageManager 检测
      const platform = MethodChannel('com.yangontaxi.yangon_taxi/kbzpay');
      final result = await platform.invokeMethod<bool>('isKBZPayInstalled');
      return result ?? false;
    } catch (e) {
      // 如果 Flutter side 检测失败，尝试直接调起（会失败返回 false）
      try {
        final uri = Uri.parse('kbzpay://');
        final canLaunch = await canLaunchUrl(uri);
        return canLaunch;
      } catch (_) {
        return false;
      }
    }
  }

  /// 构造 KBZ Pay Deep Link URL
  /// 格式参考 KBZ Pay 商户支付协议
  static Uri buildPaymentUri({
    required double amount,
    required String orderId,
    String? callbackUrl,
  }) {
    final merchantId = _testMerchantId;
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    // KBZ Pay Deep Link 参数
    // 注意：正式参数需根据 KBZ Pay 官方文档
    final params = {
      'action': 'pay',
      'merchantId': merchantId,
      'amount': amount.toStringAsFixed(0),
      'orderId': orderId,
      'currency': 'MMK',
      'timestamp': timestamp,
      'callbackUrl': callbackUrl ?? 'yangontaxi://kbzpay/callback',
      'merchantName': 'Yangon Taxi',
      'description': 'Taxi fare payment',
    };

    // 构造 kbzpay:// URL
    final queryString = params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return Uri.parse('kbzpay://$queryString');
  }

  /// 通过 Deep Link 调起 KBZ Pay
  /// 返回：是否成功调起
  static Future<KBZPayLaunchResult> launchKBZPay({
    required double amount,
    required String orderId,
  }) async {
    try {
      final isInstalled = await isKBZPayInstalled();

      if (!isInstalled) {
        return KBZPayLaunchResult(
          success: false,
          errorCode: 'NOT_INSTALLED',
          errorMessage: 'KBZ Pay is not installed on this device',
          canInstall: true,
        );
      }

      final uri = buildPaymentUri(
        amount: amount,
        orderId: orderId,
      );

      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (launched) {
        return KBZPayLaunchResult(
          success: true,
          message: 'KBZ Pay launched successfully',
        );
      } else {
        return KBZPayLaunchResult(
          success: false,
          errorCode: 'LAUNCH_FAILED',
          errorMessage: 'Failed to launch KBZ Pay',
        );
      }
    } catch (e) {
      return KBZPayLaunchResult(
        success: false,
        errorCode: 'EXCEPTION',
        errorMessage: e.toString(),
      );
    }
  }

  /// 打开 KBZ Pay 下载页面
  static Future<void> openKBZPayDownloadPage() async {
    try {
      // KBZ Pay Google Play 地址
      // 正式上线后替换为实际包名
      final playStoreUri = Uri.parse(
        'https://play.google.com/store/apps/details?id=$_kbzPayPackage',
      );
      await launchUrl(playStoreUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      // 如果 Play Store 失败，尝试浏览器打开
      try {
        final webUri = Uri.parse('https://www.kbzbank.com/kbzpay');
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } catch (_) {}
    }
  }

  /// 解析 KBZ Pay 回调 URL
  /// 支付完成后 KBZ Pay 会回调此格式:
  /// yangontaxi://kbzpay/callback?status=SUCCESS&txId=XXX&amount=XXX
  static KBZPayCallbackResult? parseCallback(Uri uri) {
    if (!uri.host.contains('kbzpay') && !uri.path.contains('callback')) {
      return null;
    }

    final params = uri.queryParameters;
    return KBZPayCallbackResult(
      status: params['status'] ?? 'UNKNOWN',
      transactionId: params['txId'] ?? params['transactionId'] ?? '',
      amount: double.tryParse(params['amount'] ?? '0') ?? 0,
      orderId: params['orderId'] ?? '',
      errorCode: params['errorCode'],
      errorMessage: params['errorMessage'],
      rawParams: params,
    );
  }
}

/// KBZ Pay 调起结果
class KBZPayLaunchResult {
  final bool success;
  final String? errorCode;
  final String? errorMessage;
  final String? message;
  final bool canInstall;

  KBZPayLaunchResult({
    required this.success,
    this.errorCode,
    this.errorMessage,
    this.message,
    this.canInstall = false,
  });

  bool get wasInstalledButFailed => !success && errorCode != 'NOT_INSTALLED';
}

/// KBZ Pay 回调结果
class KBZPayCallbackResult {
  final String status; // SUCCESS / FAILED / PENDING
  final String transactionId;
  final double amount;
  final String orderId;
  final String? errorCode;
  final String? errorMessage;
  final Map<String, String> rawParams;

  KBZPayCallbackResult({
    required this.status,
    required this.transactionId,
    required this.amount,
    required this.orderId,
    this.errorCode,
    this.errorMessage,
    required this.rawParams,
  });

  bool get isSuccess => status.toUpperCase() == 'SUCCESS';
  bool get isFailed => status.toUpperCase() == 'FAILED';
  bool get isPending => status.toUpperCase() == 'PENDING';
}
