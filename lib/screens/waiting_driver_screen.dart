import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../utils/route_generator.dart';
import 'ride_in_progress_screen.dart';

class WaitingDriverScreen extends StatefulWidget {
  final String pickupAddress;
  final LatLng pickupLocation;
  final String destinationAddress;
  final LatLng destinationLocation;
  final String vehicleType;
  final String vehicleName;
  final int price;
  final String currency;
  final String waitTime;
  final double? distanceKm;
  final int? durationMin;

  const WaitingDriverScreen({
    super.key,
    required this.pickupAddress,
    required this.pickupLocation,
    required this.destinationAddress,
    required this.destinationLocation,
    required this.vehicleType,
    required this.vehicleName,
    required this.price,
    required this.currency,
    required this.waitTime,
    this.distanceKm,
    this.durationMin,
  });

  @override
  State<WaitingDriverScreen> createState() => _WaitingDriverScreenState();
}

class _WaitingDriverScreenState extends State<WaitingDriverScreen> {
  late Timer _timer;
  int _remainingSeconds = 180;
  bool _driverFound = false;
  
  // 司机位置和路线
  late LatLng _driverStartLocation;
  late List<LatLng> _routePoints;
  int _currentRouteIndex = 0;
  
  // 模拟司机信息
  final String _driverName = 'U Mya Win';
  final String _driverRating = '4.8';
  final String _driverPlate = 'YUE 123';
  final String _driverPhone = '09-123-456-789';

  @override
  void initState() {
    super.initState();
    _generateMockRoute();
    _startSearching();
  }

  // 生成模拟路线（曲线）
  void _generateMockRoute() {
    // 司机起始位置（模拟在附近 2-3km）
    final random = Random();
    final latOffset = (random.nextDouble() - 0.5) * 0.02;
    final lngOffset = (random.nextDouble() - 0.5) * 0.02;
    
    _driverStartLocation = LatLng(
      widget.pickupLocation.latitude + latOffset,
      widget.pickupLocation.longitude + lngOffset,
    );

    // 使用共享路线生成器
    _routePoints = RouteGenerator.generateCurvedRoute(
      _driverStartLocation,
      widget.pickupLocation,
      numPoints: 20,
    );
  }

  // 开始搜索司机
  void _startSearching() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        }
      });
    });

    // 模拟 3 秒后找到司机
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _driverFound = true;
        });
        _timer.cancel();
        _startDriverMovement();
      }
    });
  }

  // 开始司机移动模拟
  void _startDriverMovement() {
    _currentRouteIndex = 0;
    
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        if (_currentRouteIndex < _routePoints.length - 1) {
          _currentRouteIndex++;
        } else {
          _timer.cancel();
        }
      });
    });
  }

  // 计算当前司机位置
  LatLng get _currentDriverLocation {
    if (!_driverFound || _routePoints.isEmpty) {
      return _driverStartLocation;
    }
    return _routePoints[_currentRouteIndex];
  }

  // 计算司机到上车点的距离（km）
  double get _distanceToPickup {
    if (!_driverFound) return 0.0;
    
    final driver = _currentDriverLocation;
    const earthRadius = 6371.0; // km
    
    final dLat = _degreesToRadians(widget.pickupLocation.latitude - driver.latitude);
    final dLng = _degreesToRadians(widget.pickupLocation.longitude - driver.longitude);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(driver.latitude)) *
            cos(_degreesToRadians(widget.pickupLocation.latitude)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }

  // 计算预计到达时间（分钟）
  int get _etaMinutes {
    final distance = _distanceToPickup;
    const avgSpeed = 30.0; // km/h，仰光市区平均速度
    return (distance / avgSpeed * 60).round();
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Stack(
        children: [
          // 地图
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.pickupLocation,
              zoom: 14,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            markers: {
              // 上车地点
              Marker(
                markerId: const MarkerId('pickup'),
                position: widget.pickupLocation,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueYellow,
                ),
                infoWindow: const InfoWindow(title: '上车地点'),
              ),
              // 司机位置（找到司机后显示）
              if (_driverFound)
                Marker(
                  markerId: const MarkerId('driver'),
                  position: _currentDriverLocation,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen,
                  ),
                  infoWindow: InfoWindow(title: '司机: $_driverName'),
                ),
            },
            polylines: {
              // 路线（找到司机后显示）
              if (_driverFound && _routePoints.isNotEmpty)
                Polyline(
                  polylineId: const PolylineId('driver_route'),
                  points: _routePoints.sublist(0, _currentRouteIndex + 1),
                  color: const Color(0xFFFFD700),
                  width: 4,
                  patterns: [
                    PatternItem.dash(20),
                    PatternItem.gap(10),
                  ],
                ),
            },
          ),

          // 顶部状态栏
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (!_driverFound) ...[
                    // 正在寻找司机
                    Row(
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Color(0xFFFFD700),
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '正在为您寻找司机...',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '预计等待 ${_remainingSeconds ~/ 60}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFFFFD700),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    // 司机已接单
                    Row(
                      children: [
                        // 司机头像
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.green,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _driverName,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: const Color(0xFFFFD700),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _driverRating,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _driverPlate,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // 联系司机
                        IconButton(
                          icon: const Icon(Icons.phone, color: Color(0xFFFFD700)),
                          onPressed: () {
                            // TODO: 拨打司机电话
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('拨打 $_driverPhone'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // 司机到达时间（实时更新）
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.access_time, color: Colors.green, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            _etaMinutes > 0
                                ? '司机正在赶来，约 $_etaMinutes 分钟到达（距离 ${_distanceToPickup.toStringAsFixed(1)} km）'
                                : '司机已到达！',
                            style: GoogleFonts.poppins(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // 底部取消按钮（未找到司机前）
          if (!_driverFound)
            Positioned(
              bottom: 30,
              left: 16,
              right: 16,
              child: OutlinedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: const Color(0xFF1A1A2E),
                      title: Text(
                        '取消叫车',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFFFD700),
                        ),
                      ),
                      content: Text(
                        '确定要取消此次叫车吗？',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            '不取消',
                            style: GoogleFonts.poppins(
                              color: Colors.white54,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: Text(
                            '取消叫车',
                            style: GoogleFonts.poppins(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  '取消叫车',
                  style: GoogleFonts.poppins(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

          // 底部行程控制栏（司机已接单后显示）
          if (_driverFound)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 行程信息
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '前往目的地',
                                style: GoogleFonts.poppins(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                widget.destinationAddress,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${widget.currency} ${widget.price}',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFFFD700),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // 开始行程按钮
                    ElevatedButton(
                      onPressed: _etaMinutes <= 0
                          ? () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RideInProgressScreen(
                                    pickupAddress: widget.pickupAddress,
                                    pickupLocation: widget.pickupLocation,
                                    destinationAddress: widget.destinationAddress,
                                    destinationLocation: widget.destinationLocation,
                                    vehicleType: widget.vehicleType,
                                    vehicleName: widget.vehicleName,
                                    price: widget.price,
                                    currency: widget.currency,
                                    distanceKm: widget.distanceKm,
                                    durationMin: widget.durationMin,
                                  ),
                                ),
                              );
                            }
                          : null, // 司机未到达前禁用
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: const Color(0xFF1A1A2E),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _etaMinutes <= 0 ? Icons.play_arrow : Icons.hourglass_empty,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _etaMinutes <= 0 ? '开始行程' : '等待司机到达...',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // SOS 按钮
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: const Color(0xFF1A1A2E),
                            title: Text(
                              '🚨 紧急求助',
                              style: GoogleFonts.poppins(
                                color: Colors.red,
                              ),
                            ),
                            content: Text(
                              '将向紧急联系人发送您的位置信息，并通知平台客服。',
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  '取消',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white54,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '已发送紧急求助信息！',
                                        style: GoogleFonts.poppins(),
                                      ),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: Text(
                                  '确认发送',
                                  style: GoogleFonts.poppins(),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.emergency, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'SOS 紧急按钮',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
