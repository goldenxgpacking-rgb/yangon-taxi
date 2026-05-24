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

  /// 更新指定 ID 的行程（替换原记录，不新增）
  static Future<void> updateTrip(Trip updatedTrip) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> trips = prefs.getStringList(_tripKey) ?? [];
    final idx = trips.indexWhere(
      (t) => jsonDecode(t)['id'] == updatedTrip.id,
    );
    if (idx != -1) {
      trips[idx] = jsonEncode(updatedTrip.toMap());
      await prefs.setStringList(_tripKey, trips);
    }
  }

  /// 获取所有已保存的行程
  static Future<List<Trip>> getAllTrips() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> trips = prefs.getStringList(_tripKey) ?? [];
    return trips.map((t) => Trip.fromMap(jsonDecode(t))).toList();
  }

  /// 根据 ID 获取单条行程
  static Future<Trip?> getTripById(String id) async {
    final trips = await getAllTrips();
    try {
      return trips.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  /// 删除指定 ID 的行程
  static Future<void> deleteTrip(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> trips = prefs.getStringList(_tripKey) ?? [];
    trips.removeWhere((t) => jsonDecode(t)['id'] == id);
    await prefs.setStringList(_tripKey, trips);
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

  // ===== 统计 =====

  /// 获取总行程数（已完成）
  static Future<int> getCompletedCount() async {
    final trips = await getAllTrips();
    return trips.where((t) => t.status == 'completed').length;
  }

  /// 获取总花费
  static Future<int> getTotalSpent() async {
    final trips = await getAllTrips();
    return trips
        .where((t) => t.status == 'completed')
        .fold<int>(0, (sum, t) => sum + t.price);
  }

  /// 获取总行驶公里数
  static Future<double> getTotalDistance() async {
    final trips = await getAllTrips();
    return trips
        .where((t) => t.status == 'completed' && t.distanceKm != null)
        .fold<double>(0, (sum, t) => sum + t.distanceKm!);
  }

  // ===== 常用地址 =====

  static const String _savedAddressesKey = 'saved_addresses';

  /// 获取所有常用地址
  static Future<List<Map<String, String>>> getSavedAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> data = prefs.getStringList(_savedAddressesKey) ?? [];
    return data.map((e) => Map<String, String>.from(jsonDecode(e))).toList();
  }

  /// 保存常用地址（新增或更新）
  static Future<void> saveAddress(Map<String, String> address) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> data = prefs.getStringList(_savedAddressesKey) ?? [];
    final id = address['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
    address['id'] = id;
    final idx = data.indexWhere((e) => jsonDecode(e)['id'] == id);
    if (idx != -1) {
      data[idx] = jsonEncode(address);
    } else {
      data.add(jsonEncode(address));
    }
    await prefs.setStringList(_savedAddressesKey, data);
  }

  /// 删除常用地址
  static Future<void> deleteAddress(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> data = prefs.getStringList(_savedAddressesKey) ?? [];
    data.removeWhere((e) => jsonDecode(e)['id'] == id);
    await prefs.setStringList(_savedAddressesKey, data);
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
