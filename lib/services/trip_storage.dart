import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/trip.dart';

class TripStorage {
  static const String _tripKey = 'saved_trips';
  static const String _userProfileKey = 'user_profile';

  // ===== 行程历史 =====

  /// 保存行程到本地
  static Future<void> saveTrip(Trip trip) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> trips = prefs.getStringList(_tripKey) ?? [];
    trips.insert(0, jsonEncode(trip.toMap()));
    // 最多保留 50 条
    if (trips.length > 50) trips.removeRange(50, trips.length);
    await prefs.setStringList(_tripKey, trips);
  }

  /// 获取所有已保存的行程
  static Future<List<Trip>> getAllTrips() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> trips = prefs.getStringList(_tripKey) ?? [];
    return trips.map((t) => Trip.fromMap(jsonDecode(t))).toList();
  }

  /// 获取行程数量
  static Future<int> getTripCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_tripKey)?.length ?? 0;
  }

  /// 清除所有行程
  static Future<void> clearTrips() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tripKey);
  }

  // ===== 用户资料 =====

  /// 保存用户资料
  static Future<void> saveUserProfile(Map<String, String> profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userProfileKey, jsonEncode(profile));
  }

  /// 获取用户资料
  static Future<Map<String, String>> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_userProfileKey);
    if (data == null) return {};
    return Map<String, String>.from(jsonDecode(data));
  }
}
