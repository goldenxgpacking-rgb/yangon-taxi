import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// 路线生成工具 - 模拟真实道路的曲线路线
class RouteGenerator {
  /// 生成两点之间的模拟曲线路线
  /// 模拟真实道路弯曲，不是简单直线
  static List<LatLng> generateCurvedRoute(LatLng start, LatLng end, {int numPoints = 30}) {
    final points = <LatLng>[];
    final random = Random(42); // 固定种子保证一致性

    // 计算路线总距离决定偏移量
    final distance = _haversineKm(start, end);
    final offsetScale = min(0.005, distance * 0.0004); // 距离越远偏移越大

    for (int i = 0; i <= numPoints; i++) {
      final t = i / numPoints;

      // 直线插值
      final lat = start.latitude + (end.latitude - start.latitude) * t;
      final lng = start.longitude + (end.longitude - start.longitude) * t;

      // 中间点添加偏移（两端不偏移）
      double offsetLat = 0;
      double offsetLng = 0;
      if (i > 0 && i < numPoints) {
        // 正弦波偏移模拟道路弯曲
        final wave = sin(t * pi * 2) * offsetScale;
        offsetLat = wave + (random.nextDouble() - 0.5) * offsetScale * 0.5;
        offsetLng = wave * 0.7 + (random.nextDouble() - 0.5) * offsetScale * 0.5;
      }

      points.add(LatLng(lat + offsetLat, lng + offsetLng));
    }

    return points;
  }

  /// 生成模拟转向指令
  static List<Map<String, dynamic>> generateTurnByTurn(LatLng start, LatLng end, List<LatLng> routePoints) {
    final distance = _haversineKm(start, end);

    final instructions = <Map<String, dynamic>>[];
    final numTurns = min(5, (routePoints.length / 6).floor());

    for (int i = 0; i < numTurns; i++) {
      final idx = ((i + 1) * routePoints.length / (numTurns + 1)).round();
      if (idx >= routePoints.length) continue;

      final dist = (distance / (numTurns + 1) * 1000).round(); // 米
      instructions.add({
        'icon': i == 0 ? 'straight' : (i % 3 == 0 ? 'right' : 'left'),
        'instruction': i == 0
            ? '沿当前道路行驶'
            : i % 3 == 0
                ? '右转进入下一道路'
                : '左转进入下一道路',
        'distance': '$dist m',
        'point': routePoints[idx],
      });
    }

    // 终点
    instructions.add({
      'icon': 'destination',
      'instruction': '到达目的地',
      'distance': '',
      'point': end,
    });

    return instructions;
  }

  /// Haversine 距离（公里）
  static double _haversineKm(LatLng a, LatLng b) {
    const r = 6371.0;
    final dLat = _rad(b.latitude - a.latitude);
    final dLng = _rad(b.longitude - a.longitude);
    final x = sin(dLat / 2) * sin(dLat / 2) +
        cos(_rad(a.latitude)) * cos(_rad(b.latitude)) * sin(dLng / 2) * sin(dLng / 2);
    return r * 2 * atan2(sqrt(x), sqrt(1 - x));
  }

  static double _rad(double deg) => deg * pi / 180;
}
