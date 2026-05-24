import 'dart:convert';
import 'package:http/http.dart' as http;

/// KBZ Pay 商户 API 服务
/// 需要向 KBZ Bank 申请商户账号和 API Key
/// API 文档联系 KBZ Bank 商户服务获取
class KBZPayApiService {
  // ============== 配置项（需替换为正式信息）==============
  /// 商户 ID - 向 KBZ Bank 申请
  static const String merchantId = 'MERCHANT_YANGON_TAXI_001';

  /// API Key - 向 KBZ Bank 申请（不要硬编码在客户端！）
  /// 正式项目中应存储在安全服务器端
  static const String apiKey = 'KBZ_API_KEY_PLACEHOLDER';

  /// API Base URL - KBZ Pay 商户 API 地址
  /// 沙箱环境用于测试
  static const String baseUrl = 'https://api-sandbox.kbzpay.com/merchant';
  // static const String baseUrl = 'https://api.kbzpay.com/merchant'; // 正式环境

  /// 回调地址 - 你的服务器地址
  /// KBZ Pay 支付完成后会 POST 到此地址
  static const String callbackUrl = 'https://your-server.com/api/kbzpay/callback';

  // ============== API 端点 ==============

  /// 生成支付二维码（商户扫码）
  /// 用户打开 KBZ Pay 扫描此二维码完成支付
  static Future<KBZQRCodeResult> generateQRCode({
    required double amount,
    required String orderId,
    required String description,
  }) async {
    try {
      // 构建请求体
      final body = {
        'merchantId': merchantId,
        'orderId': orderId,
        'amount': amount.toStringAsFixed(0),
        'currency': 'MMK',
        'description': description,
        'callbackUrl': callbackUrl,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
      };

      // TODO: 正式项目中，签名应在服务器端生成
      // body['signature'] = _generateSignature(body);

      final response = await http.post(
        Uri.parse('$baseUrl/v1/qrcode'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': apiKey,
          'X-Merchant-Id': merchantId,
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return KBZQRCodeResult(
          success: true,
          qrData: data['qrData'] ?? data['qr_code'],
          qrId: data['qrId'] ?? data['qr_id'],
          expiryTime: data['expiryTime'] ?? data['expire_at'],
          amount: amount,
        );
      } else {
        final error = jsonDecode(response.body);
        return KBZQRCodeResult(
          success: false,
          errorCode: error['code']?.toString() ?? 'UNKNOWN',
          errorMessage: error['message'] ?? 'Failed to generate QR code',
        );
      }
    } catch (e) {
      // 网络错误时返回模拟 QR 数据（演示用）
      return KBZQRCodeResult(
        success: false,
        errorCode: 'NETWORK_ERROR',
        errorMessage: 'Network error: $e',
        // 演示用模拟 QR 数据
        qrData: _generateMockQRData(amount: amount, orderId: orderId),
        qrId: 'MOCK_QR_${DateTime.now().millisecondsSinceEpoch}',
        expiryTime: DateTime.now().add(const Duration(minutes: 5)).toIso8601String(),
        amount: amount,
        isMockData: true,
      );
    }
  }

  /// 查询支付状态
  static Future<KBZPaymentStatus> checkPaymentStatus(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/v1/order/$orderId/status'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': apiKey,
          'X-Merchant-Id': merchantId,
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return KBZPaymentStatus(
          success: true,
          orderId: orderId,
          status: _parseStatus(data['status']),
          transactionId: data['transactionId'] ?? '',
          paidAmount: double.tryParse(data['paidAmount']?.toString() ?? '0') ?? 0,
          paidAt: data['paidAt'],
        );
      } else {
        return KBZPaymentStatus(
          success: false,
          orderId: orderId,
          status: KBZPaymentState.unknown,
          errorCode: response.statusCode.toString(),
        );
      }
    } catch (e) {
      return KBZPaymentStatus(
        success: false,
        orderId: orderId,
        status: KBZPaymentState.unknown,
        errorCode: 'NETWORK_ERROR',
        errorMessage: e.toString(),
      );
    }
  }

  /// 查询交易详情
  static Future<KBZTransaction?> getTransaction(String transactionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/v1/transaction/$transactionId'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': apiKey,
          'X-Merchant-Id': merchantId,
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return KBZTransaction.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取交易历史
  static Future<List<KBZTransaction>> getTransactionHistory({
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final params = {
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (startDate != null) params['startDate'] = startDate.toIso8601String();
      if (endDate != null) params['endDate'] = endDate.toIso8601String();

      final uri = Uri.parse('$baseUrl/v1/transactions').replace(queryParameters: params);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': apiKey,
          'X-Merchant-Id': merchantId,
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data['transactions'] as List? ?? [];
        return list.map((e) => KBZTransaction.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// 申请退款
  static Future<KBZRefundResult> refund({
    required String transactionId,
    required double amount,
    String? reason,
  }) async {
    try {
      final body = {
        'transactionId': transactionId,
        'amount': amount.toStringAsFixed(0),
        'reason': reason ?? 'Customer refund',
        'timestamp': DateTime.now().toUtc().toIso8601String(),
      };

      final response = await http.post(
        Uri.parse('$baseUrl/v1/refund'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': apiKey,
          'X-Merchant-Id': merchantId,
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return KBZRefundResult(
          success: true,
          refundId: data['refundId'] ?? '',
          status: data['status'] ?? 'PENDING',
        );
      } else {
        final error = jsonDecode(response.body);
        return KBZRefundResult(
          success: false,
          errorCode: error['code']?.toString() ?? 'UNKNOWN',
          errorMessage: error['message'] ?? 'Refund failed',
        );
      }
    } catch (e) {
      return KBZRefundResult(
        success: false,
        errorCode: 'NETWORK_ERROR',
        errorMessage: e.toString(),
      );
    }
  }

  // ============== 内部工具方法 ==============

  /// 生成模拟 QR 数据（演示用）
  /// 正式项目不应使用此方法
  static String _generateMockQRData({
    required double amount,
    required String orderId,
  }) {
    // KBZ Pay QR 格式（基于 Myanmar QR Payment Standard）
    return '00020101021230310066A0112233445566770703QRI12345678031234567890123456000163040009';
  }

  /// 解析状态字符串
  static KBZPaymentState _parseStatus(String? status) {
    switch ((status ?? '').toUpperCase()) {
      case 'SUCCESS':
      case 'COMPLETED':
      case 'PAID':
        return KBZPaymentState.paid;
      case 'PENDING':
        return KBZPaymentState.pending;
      case 'FAILED':
      case 'EXPIRED':
        return KBZPaymentState.failed;
      default:
        return KBZPaymentState.unknown;
    }
  }

  // ============== 签名生成（需在服务器端执行）==============
  // 正式项目中，签名应在服务器端生成以保护 API Key
  // 以下为签名算法示例（供参考）:
  /*
  static String generateSignature(Map<String, dynamic> params, String apiSecret) {
    final sortedKeys = params.keys.toList()..sort();
    final data = sortedKeys.map((k) => '$k=${params[k]}').join('&');
    final signature = Hmac(sha256, utf8.encode(apiSecret))
        .convert(utf8.encode(data))
        .toString();
    return signature;
  }
  */
}

// ============== 数据模型 ==============

/// QR 码生成结果
class KBZQRCodeResult {
  final bool success;
  final String? qrData;
  final String? qrId;
  final String? expiryTime;
  final double? amount;
  final String? errorCode;
  final String? errorMessage;
  final bool isMockData; // 是否为模拟数据

  KBZQRCodeResult({
    required this.success,
    this.qrData,
    this.qrId,
    this.expiryTime,
    this.amount,
    this.errorCode,
    this.errorMessage,
    this.isMockData = false,
  });

  bool get isExpired {
    if (expiryTime == null) return false;
    try {
      return DateTime.parse(expiryTime!).isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }
}

/// 支付状态
enum KBZPaymentState { pending, paid, failed, unknown }

/// 支付状态查询结果
class KBZPaymentStatus {
  final bool success;
  final String orderId;
  final KBZPaymentState status;
  final String transactionId;
  final double paidAmount;
  final String? paidAt;
  final String? errorCode;
  final String? errorMessage;

  KBZPaymentStatus({
    required this.success,
    required this.orderId,
    required this.status,
    this.transactionId = '',
    this.paidAmount = 0,
    this.paidAt,
    this.errorCode,
    this.errorMessage,
  });

  bool get isPaid => status == KBZPaymentState.paid;
  bool get isPending => status == KBZPaymentState.pending;
  bool get isFailed => status == KBZPaymentState.failed;
}

/// 交易记录
class KBZTransaction {
  final String transactionId;
  final String orderId;
  final double amount;
  final String currency;
  final KBZPaymentState status;
  final DateTime createdAt;
  final DateTime? paidAt;
  final String? description;
  final String? customerPhone;

  KBZTransaction({
    required this.transactionId,
    required this.orderId,
    required this.amount,
    this.currency = 'MMK',
    required this.status,
    required this.createdAt,
    this.paidAt,
    this.description,
    this.customerPhone,
  });

  factory KBZTransaction.fromJson(Map<String, dynamic> json) {
    return KBZTransaction(
      transactionId: json['transactionId'] ?? json['txId'] ?? '',
      orderId: json['orderId'] ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      currency: json['currency'] ?? 'MMK',
      status: _parseKBZState(json['status']),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      paidAt: json['paidAt'] != null ? DateTime.tryParse(json['paidAt']) : null,
      description: json['description'],
      customerPhone: json['customerPhone'],
    );
  }

  static KBZPaymentState _parseKBZState(String? s) {
    switch ((s ?? '').toUpperCase()) {
      case 'SUCCESS':
      case 'COMPLETED':
      case 'PAID':
        return KBZPaymentState.paid;
      case 'PENDING':
        return KBZPaymentState.pending;
      case 'FAILED':
      case 'EXPIRED':
        return KBZPaymentState.failed;
      default:
        return KBZPaymentState.unknown;
    }
  }
}

/// 退款结果
class KBZRefundResult {
  final bool success;
  final String? refundId;
  final String? status;
  final String? errorCode;
  final String? errorMessage;

  KBZRefundResult({
    required this.success,
    this.refundId,
    this.status,
    this.errorCode,
    this.errorMessage,
  });
}
