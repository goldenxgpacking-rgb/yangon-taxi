import 'dart:math';
import '../models/api_response.dart';
import '../models/driver.dart';
import '../models/trip.dart';
import 'api_client.dart';
import '../models/enums.dart';

/// 行程服务
/// 负责叫车、查询行程、取消订单
class TripService {
  final ApiClient _client;

  TripService(this._client);

  /// 获取附近司机
  Future<ApiResponse<List<NearbyDriver>>> getNearbyDrivers({
    required double lat,
    required double lng,
    String? vehicleType,
  }) async {
    if (ApiClient.mockMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      return ApiResponse.success(_mockNearbyDrivers(lat, lng));
    }

    return _client.get('/trips/nearby-drivers',
      queryParams: {
        'lat': lat.toString(),
        'lng': lng.toString(),
        if (vehicleType != null) 'vehicle_type': vehicleType,
      },
      parser: (json) => (json as List).map((e) => NearbyDriver.fromJson(e)).toList(),
    );
  }

  /// 创建行程
  Future<ApiResponse<Trip>> createTrip({
    required String pickupAddress,
    required String? pickupLat,
    required String? pickupLng,
    required String destAddress,
    required String? destLat,
    required String? destLng,
    required String vehicleType,
    required String paymentMethod,
  }) async {
    if (ApiClient.mockMode) {
      await Future.delayed(const Duration(milliseconds: 800));
      final trip = _mockCreateTrip(pickupAddress, pickupLat, pickupLng,
          destAddress, destLat, destLng, vehicleType, paymentMethod);
      return ApiResponse.success(trip);
    }

    return _client.post('/trips',
      body: {
        'pickup_address': pickupAddress,
        'pickup_lat': pickupLat,
        'pickup_lng': pickupLng,
        'dest_address': destAddress,
        'dest_lat': destLat,
        'dest_lng': destLng,
        'vehicle_type': vehicleType,
        'payment_method': paymentMethod,
      },
      parser: (json) => Trip.fromApiJson(json),
    );
  }

  /// 获取行程详情
  Future<ApiResponse<Trip>> getTrip(String tripId) async {
    if (ApiClient.mockMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      return ApiResponse.success(_mockTrip(tripId));
    }

    return _client.get('/trips/$tripId', parser: (json) => Trip.fromApiJson(json));
  }

  /// 获取行程历史
  Future<ApiResponse<List<Trip>>> getTripHistory({
    int page = 1,
    int pageSize = 20,
    String? status,
  }) async {
    if (ApiClient.mockMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      return ApiResponse.success(_mockTripHistory(status));
    }

    return _client.get('/trips/history',
      queryParams: {
        'page': page.toString(),
        'page_size': pageSize.toString(),
        if (status != null) 'status': status,
      },
      parser: (json) => (json as List).map((e) => Trip.fromApiJson(e)).toList(),
    );
  }

  /// 取消行程
  Future<ApiResponse<Trip>> cancelTrip(String tripId, {String? reason}) async {
    if (ApiClient.mockMode) {
      await Future.delayed(const Duration(milliseconds: 400));
      return ApiResponse.success(_mockTrip(tripId).copyWith(status: 'cancelled'));
    }

    return _client.post('/trips/$tripId/cancel',
      body: {if (reason != null) 'reason': reason},
      parser: (json) => Trip.fromApiJson(json),
    );
  }

  // ========== 模拟数据 ==========

  List<NearbyDriver> _mockNearbyDrivers(double lat, double lng) {
    final rand = Random();
    final names = ['吴丹', '貌昂', '丁吞', '梭温', '敏佐'];
    final plates = ['YGN-1234', 'YGN-5678', 'YGN-9012', 'YGN-3456', 'YGN-7890'];
    final brands = ['Toyota Corolla', 'Honda Civic', 'Nissan Note', 'Suzuki Swift', 'Hyundai Elantra'];
    final types = ['cng', 'oil', 'ev', 'private', 'cng'];

    return List.generate(5, (i) {
      final dlat = lat + (rand.nextDouble() - 0.5) * 0.02;
      final dlng = lng + (rand.nextDouble() - 0.5) * 0.02;
      return NearbyDriver(
        driver: Driver(
          id: 'driver_$i',
          name: names[i],
          phone: '+959${rand.nextInt(90000000) + 10000000}',
          licensePlate: plates[i],
          vehicleType: _strToVehicleType(types[i]),
          vehicleBrand: brands[i],
          vehicleColor: ['白色', '银色', '黑色', '蓝色', '红色'][i],
          rating: 4.0 + rand.nextDouble(),
          tripCount: rand.nextInt(500) + 50,
        ),
        lat: dlat,
        lng: dlng,
        distanceKm: 0.5 + rand.nextDouble() * 3.0,
      );
    });
  }

  Trip _mockCreateTrip(
    String pickupAddress, String? pickupLat, String? pickupLng,
    String destAddress, String? destLat, String? destLng,
    String vehicleType, String paymentMethod,
  ) {
    final id = Trip.generateId();
    return Trip(
      id: id,
      pickupAddress: pickupAddress,
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      destinationAddress: destAddress,
      destLat: destLat,
      destLng: destLng,
      pickupTime: Trip.currentTime(),
      price: 8500,
      vehicleType: vehicleType,
      paymentMethod: paymentMethod,
      status: 'pending',
      createdAt: DateTime.now(),
    );
  }

  Trip _mockTrip(String tripId) {
    return Trip(
      id: tripId,
      pickupAddress: '仰光国际机场',
      destinationAddress: '苏雷塔',
      pickupTime: Trip.currentTime(),
      dropoffTime: null,
      price: 8500,
      vehicleType: 'oil',
      vehicleName: 'Toyota Corolla',
      vehicleColor: '白色',
      vehiclePlate: 'YGN-1234',
      driverName: '吴丹',
      driverPhone: '+95990000001',
      driverRating: '4.8',
      status: 'in_progress',
      paymentMethod: 'cash',
      paymentStatus: 'pending',
      distanceKm: 12.5,
      durationMin: 35,
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    );
  }

  List<Trip> _mockTripHistory(String? status) {
    final now = DateTime.now();
    final rand = Random();
    final addresses = ['仰光国际机场', '苏雷塔', '昂山市场', '茵雅湖', '唐人街'];
    final types = ['cng', 'oil', 'ev', 'private'];
    final statuses = ['completed', 'completed', 'completed', 'cancelled'];

    return List.generate(8, (i) {
      final tripStatus = status ?? statuses[rand.nextInt(statuses.length)];
      return Trip(
        id: 'trip_history_$i',
        pickupAddress: addresses[rand.nextInt(addresses.length)],
        destinationAddress: addresses[rand.nextInt(addresses.length)],
        vehicleType: types[rand.nextInt(types.length)],
        paymentMethod: 'cash',
        status: tripStatus,
        price: (rand.nextInt(8) + 3) * 1000,
        vehicleName: 'Toyota Corolla',
        driverName: '吴丹',
        driverRating: '4.${rand.nextInt(9)}',
        vehiclePlate: 'YGN-${rand.nextInt(9000) + 1000}',
        rating: tripStatus == 'completed' ? 4 + rand.nextInt(2) : 0,
        distanceKm: (rand.nextInt(15) + 3).toDouble(),
        durationMin: rand.nextInt(40) + 15,
        pickupTime: '${now.year}-05-${(now.day - i * 2).toString().padLeft(2, '0')} 10:00',
        createdAt: now.subtract(Duration(days: i * 2 + 1)),
      );
    });
  }

  // 兼容 VehicleType 枚举转字符串
  VehicleType _strToVehicleType(String code) {
    return VehicleType.values.firstWhere(
      (v) => v.code == code,
      orElse: () => VehicleType.cngCar,
    );
  }
}
