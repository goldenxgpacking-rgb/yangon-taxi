import 'dart:convert';

// 行程数据模型
class Trip {
  final String id;
  final String pickupAddress;
  final String destinationAddress;
  final String pickupTime;
  final String dropoffTime;
  final int price;
  final String currency;
  final String vehicleType;
  final String vehicleName;
  final String driverName;
  final String driverRating;
  final String vehiclePlate;
  final String status; // completed, cancelled, ongoing
  final int rating; // 用户评分（0-5，0表示未评价）
  final String? comment; // 用户评价内容
  final double? distanceKm; // 行程距离（公里）

  Trip({
    required this.id,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.pickupTime,
    required this.dropoffTime,
    required this.price,
    this.currency = 'K',
    required this.vehicleType,
    required this.vehicleName,
    required this.driverName,
    required this.driverRating,
    required this.vehiclePlate,
    required this.status,
    this.rating = 0,
    this.comment,
    this.distanceKm,
  });

  // 序列化为 Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pickupAddress': pickupAddress,
      'destinationAddress': destinationAddress,
      'pickupTime': pickupTime,
      'dropoffTime': dropoffTime,
      'price': price,
      'currency': currency,
      'vehicleType': vehicleType,
      'vehicleName': vehicleName,
      'driverName': driverName,
      'driverRating': driverRating,
      'vehiclePlate': vehiclePlate,
      'status': status,
      'rating': rating,
      'comment': comment,
      'distanceKm': distanceKm,
    };
  }

  // 从 Map 反序列化
  factory Trip.fromMap(Map<String, dynamic> map) {
    return Trip(
      id: map['id'] ?? '',
      pickupAddress: map['pickupAddress'] ?? '',
      destinationAddress: map['destinationAddress'] ?? '',
      pickupTime: map['pickupTime'] ?? '',
      dropoffTime: map['dropoffTime'] ?? '',
      price: map['price'] ?? 0,
      currency: map['currency'] ?? 'K',
      vehicleType: map['vehicleType'] ?? 'cng',
      vehicleName: map['vehicleName'] ?? '',
      driverName: map['driverName'] ?? '',
      driverRating: map['driverRating'] ?? '',
      vehiclePlate: map['vehiclePlate'] ?? '',
      status: map['status'] ?? 'completed',
      rating: map['rating'] ?? 0,
      comment: map['comment'],
      distanceKm: map['distanceKm']?.toDouble(),
    );
  }

  /// 生成唯一行程 ID
  static String generateId() {
    final now = DateTime.now();
    final ts = now.millisecondsSinceEpoch.toString();
    return 'TRIP${ts.substring(ts.length - 6)}';
  }

  /// 获取当前时间字符串
  static String currentTime() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}
