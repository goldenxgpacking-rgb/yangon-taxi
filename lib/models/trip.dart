import 'dart:convert';

// 行程数据模型（统一版本，支持API和本地存储）
class Trip {
  final String id;
  // 地址
  final String pickupAddress;
  final String? pickupLat;
  final String? pickupLng;
  final String destinationAddress;
  final String? destLat;
  final String? destLng;
  // 时间
  final String pickupTime;
  final String? dropoffTime;
  // 费用
  final int price;
  final String currency;
  // 车辆
  final String vehicleType;
  final String? vehicleName;
  final String? vehicleColor;
  final String? vehiclePlate;
  // 司机
  final String? driverName;
  final String? driverPhone;
  final String? driverRating;
  final String? driverAvatar;
  // 状态
  final String status; // pending/confirmed/arriving/in_progress/completed/cancelled/no_show
  // 评分
  final int rating;
  final String? comment;
  // 距离
  final double? distanceKm;
  final int? durationMin;
  // 支付
  final String paymentMethod;
  final String paymentStatus;
  final String? paymentTransactionId;
  final DateTime? createdAt;

  Trip({
    required this.id,
    required this.pickupAddress,
    this.pickupLat,
    this.pickupLng,
    required this.destinationAddress,
    this.destLat,
    this.destLng,
    required this.pickupTime,
    this.dropoffTime,
    required this.price,
    this.currency = 'K',
    required this.vehicleType,
    this.vehicleName,
    this.vehicleColor,
    this.vehiclePlate,
    this.driverName,
    this.driverPhone,
    this.driverRating,
    this.driverAvatar,
    required this.status,
    this.rating = 0,
    this.comment,
    this.distanceKm,
    this.durationMin,
    this.paymentMethod = 'cash',
    this.paymentStatus = 'pending',
    this.paymentTransactionId,
    this.createdAt,
  });

  // ===== 序列化 =====

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pickupAddress': pickupAddress,
      'pickupLat': pickupLat,
      'pickupLng': pickupLng,
      'destinationAddress': destinationAddress,
      'destLat': destLat,
      'destLng': destLng,
      'pickupTime': pickupTime,
      'dropoffTime': dropoffTime,
      'price': price,
      'currency': currency,
      'vehicleType': vehicleType,
      'vehicleName': vehicleName,
      'vehicleColor': vehicleColor,
      'vehiclePlate': vehiclePlate,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'driverRating': driverRating,
      'driverAvatar': driverAvatar,
      'status': status,
      'rating': rating,
      'comment': comment,
      'distanceKm': distanceKm,
      'durationMin': durationMin,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'paymentTransactionId': paymentTransactionId,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory Trip.fromMap(Map<String, dynamic> map) {
    return Trip(
      id: map['id'] ?? '',
      pickupAddress: map['pickupAddress'] ?? '',
      pickupLat: map['pickupLat']?.toString(),
      pickupLng: map['pickupLng']?.toString(),
      destinationAddress: map['destinationAddress'] ?? '',
      destLat: map['destLat']?.toString(),
      destLng: map['destLng']?.toString(),
      pickupTime: map['pickupTime'] ?? '',
      dropoffTime: map['dropoffTime'],
      price: map['price'] ?? 0,
      currency: map['currency'] ?? 'K',
      vehicleType: map['vehicleType'] ?? 'cng',
      vehicleName: map['vehicleName'],
      vehicleColor: map['vehicleColor'],
      vehiclePlate: map['vehiclePlate'],
      driverName: map['driverName'],
      driverPhone: map['driverPhone'],
      driverRating: map['driverRating'],
      driverAvatar: map['driverAvatar'],
      status: map['status'] ?? 'completed',
      rating: map['rating'] ?? 0,
      comment: map['comment'],
      distanceKm: map['distanceKm']?.toDouble(),
      durationMin: map['durationMin'],
      paymentMethod: map['paymentMethod'] ?? 'cash',
      paymentStatus: map['paymentStatus'] ?? 'pending',
      paymentTransactionId: map['paymentTransactionId'],
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt']) : null,
    );
  }

  /// API JSON 反序列化（与后端对接时使用）
  factory Trip.fromApiJson(Map<String, dynamic> json) {
    // 映射后端字段到前端字段
    final driver = json['driver'] as Map<String, dynamic>?;
    return Trip(
      id: json['id'] as String,
      pickupAddress: json['pickup_address'] as String? ?? '',
      pickupLat: json['pickup_lat']?.toString(),
      pickupLng: json['pickup_lng']?.toString(),
      destinationAddress: json['dest_address'] as String? ?? json['destination_address'] as String? ?? '',
      destLat: json['dest_lat']?.toString(),
      destLng: json['dest_lng']?.toString(),
      pickupTime: json['pickup_time'] as String? ?? json['pickupTime'] as String? ?? DateTime.now().toString(),
      dropoffTime: json['dropoff_time'] as String?,
      price: json['price'] as int? ?? 0,
      currency: json['currency'] as String? ?? 'K',
      vehicleType: json['vehicle_type'] as String? ?? 'cng',
      vehicleName: driver?['vehicle_brand'] as String? ?? json['vehicle_name'] as String?,
      vehicleColor: driver?['vehicle_color'] as String?,
      vehiclePlate: driver?['license_plate'] as String? ?? json['vehicle_plate'] as String?,
      driverName: driver?['name'] as String? ?? json['driver_name'] as String?,
      driverPhone: driver?['phone'] as String?,
      driverRating: driver?['rating']?.toString() ?? json['driver_rating']?.toString(),
      driverAvatar: driver?['avatar_url'] as String?,
      status: json['status'] as String? ?? 'completed',
      rating: json['rating'] as int? ?? 0,
      comment: json['comment'] as String?,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      durationMin: json['duration_min'] as int?,
      paymentMethod: json['payment_method'] as String? ?? 'cash',
      paymentStatus: json['payment_status'] as String? ?? 'pending',
      paymentTransactionId: json['payment_transaction_id'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
    );
  }

  // ===== 便捷构造方法 =====

  static String currentTime() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  static String generateId() {
    return 'TRIP${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
  }

  // ===== copyWith =====

  Trip copyWith({
    String? id,
    String? pickupAddress,
    String? pickupLat,
    String? pickupLng,
    String? destinationAddress,
    String? destLat,
    String? destLng,
    String? pickupTime,
    String? dropoffTime,
    int? price,
    String? currency,
    String? vehicleType,
    String? vehicleName,
    String? vehicleColor,
    String? vehiclePlate,
    String? driverName,
    String? driverPhone,
    String? driverRating,
    String? driverAvatar,
    String? status,
    int? rating,
    String? comment,
    double? distanceKm,
    int? durationMin,
    String? paymentMethod,
    String? paymentStatus,
    String? paymentTransactionId,
    DateTime? createdAt,
  }) {
    return Trip(
      id: id ?? this.id,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      pickupLat: pickupLat ?? this.pickupLat,
      pickupLng: pickupLng ?? this.pickupLng,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      destLat: destLat ?? this.destLat,
      destLng: destLng ?? this.destLng,
      pickupTime: pickupTime ?? this.pickupTime,
      dropoffTime: dropoffTime ?? this.dropoffTime,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleName: vehicleName ?? this.vehicleName,
      vehicleColor: vehicleColor ?? this.vehicleColor,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      driverRating: driverRating ?? this.driverRating,
      driverAvatar: driverAvatar ?? this.driverAvatar,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      distanceKm: distanceKm ?? this.distanceKm,
      durationMin: durationMin ?? this.durationMin,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentTransactionId: paymentTransactionId ?? this.paymentTransactionId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
