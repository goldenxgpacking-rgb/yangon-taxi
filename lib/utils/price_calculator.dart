import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PriceCalculator {
  // 起步价（MMK）
  static const int baseFare = 500;

  // 各车型每公里单价（MMK）
  static const Map<String, int> _perKmRates = {
    'cng': 300,
    'oil': 400,
    'ev': 350,
    'private': 500,
  };

  // 最低消费（MMK）
  static const int minFare = 800;

  // 仰光市区平均车速 km/h
  static const double avgSpeedKmh = 25.0;

  // 高峰时段（小时，24小时制）
  static const List<int> _morningPeak = [8, 9];
  static const List<int> _eveningPeak = [17, 18];

  /// Haversine 公式计算两点间距离（公里）
  static double calculateDistance(
    double pickupLat, double pickupLng,
    double destLat, double destLng,
  ) {
    const double earthRadius = 6371; // 地球半径（公里）
    final double dLat = _toRadians(destLat - pickupLat);
    final double dLng = _toRadians(destLng - pickupLng);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(pickupLat)) *
            cos(_toRadians(destLat)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  /// 计算预估价格（MMK）
  static int calculatePrice(
    double pickupLat, double pickupLng,
    double destLat, double destLng,
    String vehicleType,
  ) {
    final double distance = calculateDistance(pickupLat, pickupLng, destLat, destLng);
    final int rate = _perKmRates[vehicleType] ?? 400;
    int price = baseFare + (distance * rate).round();

    // 高峰期加价 10%
    final now = DateTime.now();
    if (_morningPeak.contains(now.hour) || _eveningPeak.contains(now.hour)) {
      price = (price * 1.1).round();
    }

    // 最低消费
    return price < minFare ? minFare : price;
  }

  /// 计算预估时长（分钟）
  static int calculateDuration(double distanceKm) {
    return max(2, (distanceKm / avgSpeedKmh * 60).round());
  }

  /// 获取完整价格估算信息
  static Map<String, dynamic> getPriceEstimate(
    double pickupLat, double pickupLng,
    double destLat, double destLng,
    String vehicleType,
  ) {
    final double distance = calculateDistance(pickupLat, pickupLng, destLat, destLng);
    final int price = calculatePrice(pickupLat, pickupLng, destLat, destLng, vehicleType);
    final int duration = calculateDuration(distance);

    return {
      'price': price,
      'distance': distance,
      'duration': duration,
      'currency': 'K',
    };
  }

  /// 使用 LatLng 重载
  static double calculateDistanceLatLng(LatLng pickup, LatLng destination) {
    return calculateDistance(
      pickup.latitude, pickup.longitude,
      destination.latitude, destination.longitude,
    );
  }

  static int calculatePriceLatLng(LatLng pickup, LatLng destination, String vehicleType) {
    return calculatePrice(
      pickup.latitude, pickup.longitude,
      destination.latitude, destination.longitude,
      vehicleType,
    );
  }

  static Map<String, dynamic> getPriceEstimateLatLng(LatLng pickup, LatLng destination, String vehicleType) {
    return getPriceEstimate(
      pickup.latitude, pickup.longitude,
      destination.latitude, destination.longitude,
      vehicleType,
    );
  }

  static double _toRadians(double degree) {
    return degree * pi / 180;
  }
}
