import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import 'destination_screen.dart';
import 'trip_history_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GoogleMapController _mapController;
  LatLng _currentPosition = const LatLng(16.8661, 96.1951); // 仰光默认位置
  bool _isLoading = true;
  String _currentAddress = '正在获取位置...';
  
  // 模拟附近司机位置
  final List<LatLng> _nearbyDrivers = [
    const LatLng(16.8680, 96.1960),
    const LatLng(16.8650, 96.1940),
    const LatLng(16.8670, 96.1970),
  ];

  // 底部导航栏当前索引
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  // 构建首页内容（地图界面）
  Widget _buildHomeContent() {
    return Stack(
      children: [
        // Google 地图
        _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFFD700),
                ),
              )
            : GoogleMap(
                onMapCreated: (controller) {
                  _mapController = controller;
                  print('✅ Google Map created successfully');
                },
                onCameraMove: (position) {
                  // debug
                },
                initialCameraPosition: CameraPosition(
                  target: _currentPosition,
                  zoom: 15,
                ),
                mapType: MapType.normal,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: false,
                markers: {
                  // 当前位置标记
                  Marker(
                    markerId: const MarkerId('current_location'),
                    position: _currentPosition,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueYellow,
                    ),
                    infoWindow: const InfoWindow(title: '我的位置'),
                  ),
                  // 附近司机标记
                  ..._nearbyDrivers.map((position) {
                    return Marker(
                      markerId: MarkerId('driver_${position.latitude}'),
                      position: position,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueGreen,
                      ),
                      infoWindow: const InfoWindow(title: '附近司机'),
                    );
                  }),
                },
              ),

        // 顶部地址栏
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
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Color(0xFFFFD700),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '当前位置',
                        style: GoogleFonts.poppins(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        _currentAddress,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // 底部叫车按钮
        Positioned(
          bottom: 30,
          left: 16,
          right: 16,
          child: ElevatedButton(
            onPressed: () {
              // 跳转到目的地输入页面
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DestinationScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: const Color(0xFF1A1A2E),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 5,
            ),
            child: Text(
              '去哪里？',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        // 附近司机数量提示
        Positioned(
          bottom: 100,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.directions_car, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  '附近有 ${_nearbyDrivers.length} 位司机',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 请求定位权限
  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      _getCurrentLocation();
    } else {
      setState(() {
        _isLoading = false;
      });
      _showPermissionDeniedDialog();
    }
  }

  // 获取当前位置
  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      // 获取地址
      _getAddressFromLatLng(position.latitude, position.longitude);

      // 移动地图到当前位置
      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _currentPosition,
            zoom: 15,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('获取位置失败: $e');
    }
  }

  // 根据坐标获取地址
  Future<void> _getAddressFromLatLng(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _currentAddress = '${place.street}, ${place.locality}, ${place.country}';
        });
      }
    } catch (e) {
      print('获取地址失败: $e');
    }
  }

  // 显示权限被拒绝的对话框
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          '需要定位权限',
          style: GoogleFonts.poppins(color: const Color(0xFFFFD700)),
        ),
        content: Text(
          '请在设置中允许访问定位权限，以便我们为您提供叫车服务。',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '取消',
              style: GoogleFonts.poppins(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text(
              '去设置',
              style: GoogleFonts.poppins(color: const Color(0xFFFFD700)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 动态构建页面列表（避免在 initState 中调用 MediaQuery）
    final List<Widget> _screens = [
      _buildHomeContent(), // 首页内容
      const TripHistoryScreen(), // 行程历史
      const ProfileScreen(), // 个人中心
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: const Color(0xFF1A1A2E),
        selectedItemColor: const Color(0xFFFFD700),
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: '行程',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}
