import 'enums.dart';

/// 司机模型
class Driver {
  final String id;
  final String name;
  final String phone;
  final String? avatarUrl;
  final String licensePlate;
  final VehicleType vehicleType;
  final String vehicleBrand;
  final String vehicleColor;
  final double rating;
  final int tripCount;
  final bool isAvailable;

  Driver({
    required this.id,
    required this.name,
    required this.phone,
    this.avatarUrl,
    required this.licensePlate,
    required this.vehicleType,
    required this.vehicleBrand,
    required this.vehicleColor,
    this.rating = 5.0,
    this.tripCount = 0,
    this.isAvailable = true,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      avatarUrl: json['avatar_url'] as String?,
      licensePlate: json['license_plate'] as String,
      vehicleType: VehicleType.values.firstWhere(
        (v) => v.code == json['vehicle_type'],
        orElse: () => VehicleType.cngCar,
      ),
      vehicleBrand: json['vehicle_brand'] as String? ?? '',
      vehicleColor: json['vehicle_color'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      tripCount: json['trip_count'] as int? ?? 0,
      isAvailable: json['is_available'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'avatar_url': avatarUrl,
      'license_plate': licensePlate,
      'vehicle_type': vehicleType.code,
      'vehicle_brand': vehicleBrand,
      'vehicle_color': vehicleColor,
      'rating': rating,
      'trip_count': tripCount,
      'is_available': isAvailable,
    };
  }
}

/// 附近司机位置
class NearbyDriver {
  final Driver driver;
  final double lat;
  final double lng;
  final double distanceKm;

  NearbyDriver({
    required this.driver,
    required this.lat,
    required this.lng,
    required this.distanceKm,
  });

  factory NearbyDriver.fromJson(Map<String, dynamic> json) {
    return NearbyDriver(
      driver: Driver.fromJson(json['driver'] as Map<String, dynamic>),
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      distanceKm: (json['distance_km'] as num).toDouble(),
    );
  }

  /// 预计到达分钟数（按直线距离估算）
  int get etaMinutes => (distanceKm * 3).ceil(); // 约 20km/h
}
