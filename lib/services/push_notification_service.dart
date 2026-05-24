import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 推送通知服务
/// 使用 flutter_local_notifications 处理本地通知
/// TODO: 集成 Firebase Cloud Messaging (FCM) 实现真实推送
class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._();
  factory PushNotificationService() => _instance;
  PushNotificationService._();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final _storage = const FlutterSecureStorage();

  static const _keyNotifEnabled = 'notif_enabled';

  bool _initialized = false;

  /// 初始化通知服务
  Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    try {
      await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } catch (_) {}

    _initialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    try {
      final payload = jsonDecode(response.payload ?? '{}');
      final type = payload['type'] as String?;
      if (type == 'trip_update') {
        debugPrint('通知点击: 行程ID=${payload['trip_id']}');
      }
    } catch (_) {}
  }

  /// 显示行程状态更新通知
  Future<void> showTripNotification({
    required String tripId,
    required String title,
    required String body,
    String? driverName,
    String? licensePlate,
  }) async {
    final enabled = await _storage.read(key: _keyNotifEnabled);
    if (enabled == 'false') return;

    final androidDetails = AndroidNotificationDetails(
      'trip_channel',
      '行程通知',
      channelDescription: '行程状态更新通知',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(body),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _notifications.show(
      tripId.hashCode,
      title,
      body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: jsonEncode({
        'type': 'trip_update',
        'trip_id': tripId,
        if (driverName != null) 'driver_name': driverName,
        if (licensePlate != null) 'license_plate': licensePlate,
      }),
    );
  }

  /// 显示司机到达通知
  Future<void> showDriverArriving({
    required String tripId,
    required String driverName,
    required String licensePlate,
    required int etaMinutes,
  }) async {
    await showTripNotification(
      tripId: tripId,
      title: '🚗 司机即将到达',
      body: '$driverName 正在赶来，预计 $etaMinutes 分钟到达。车牌：$licensePlate',
      driverName: driverName,
      licensePlate: licensePlate,
    );
  }

  /// 显示支付成功通知
  Future<void> showPaymentSuccess({
    required String tripId,
    required double amount,
  }) async {
    await showTripNotification(
      tripId: tripId,
      title: '✅ 支付成功',
      body: '您已支付 ${amount.toStringAsFixed(0)} 甲，行程结束，感谢乘坐！',
    );
  }

  /// 显示系统通知
  Future<void> showSystemNotification({
    required String title,
    required String body,
  }) async {
    final enabled = await _storage.read(key: _keyNotifEnabled);
    if (enabled == 'false') return;

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'system_channel',
          '系统通知',
          channelDescription: '系统公告和更新通知',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  /// 取消通知
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// 取消所有通知
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  /// 设置通知开关
  Future<void> setEnabled(bool enabled) async {
    await _storage.write(key: _keyNotifEnabled, value: enabled.toString());
  }

  Future<bool> isEnabled() async {
    final val = await _storage.read(key: _keyNotifEnabled);
    return val != 'false';
  }

  // ========== FCM 集成预留（TODO）==========
  //
  // 集成步骤：
  // 1. 在 Firebase Console 创建项目
  // 2. 下载 google-services.json 放到 android/app/
  // 3. 添加依赖: firebase_core, firebase_messaging
  // 4. 在 pubspec.yaml 添加后运行 flutter pub get
  //
  // Future<String?> getFcmToken() async {
  //   final token = await FirebaseMessaging.instance.getToken();
  //   if (token != null) {
  //     await _storage.write(key: 'fcm_token', value: token);
  //   }
  //   return token;
  // }
  //
  // // 监听 FCM 消息
  // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //   // App 在前台时收到推送
  //   _handleFcmMessage(message);
  // });
  //
  // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  //   // 点击通知打开 App
  //   _handleFcmMessage(message);
  // });
}
