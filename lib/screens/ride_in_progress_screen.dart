import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'payment_screen.dart';

class RideInProgressScreen extends StatefulWidget {
  final String pickupAddress;
  final LatLng pickupLocation;
  final String destinationAddress;
  final LatLng destinationLocation;
  final String vehicleType;
  final String vehicleName;
  final int price;
  final String currency;
  final double? distanceKm;
  final int? durationMin;

  const RideInProgressScreen({
    super.key,
    required this.pickupAddress,
    required this.pickupLocation,
    required this.destinationAddress,
    required this.destinationLocation,
    required this.vehicleType,
    required this.vehicleName,
    required this.price,
    this.currency = 'K',
    this.distanceKm,
    this.durationMin,
  });

  @override
  State<RideInProgressScreen> createState() => _RideInProgressScreenState();
}

class _RideInProgressScreenState extends State<RideInProgressScreen> {
  late Timer _timer;
  int _remainingMinutes = 15; // 预计15分钟到达
  bool _isTripStarted = false;
  LatLng _driverCurrentLocation = const LatLng(16.8680, 96.1960); // 模拟司机当前位置

  @override
  void initState() {
    super.initState();
    _startTripTimer();
  }

  // 开始行程计时器
  void _startTripTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingMinutes > 0) {
          _remainingMinutes--;
          // 模拟司机移动（向目的地靠近）
          _updateDriverLocation();
        } else {
          // 行程结束
          _timer.cancel();
          _showTripCompletedDialog();
        }
      });
    });
  }

  // 更新司机位置（模拟）
  void _updateDriverLocation() {
    // 模拟司机向目的地移动
    setState(() {
      _driverCurrentLocation = LatLng(
        _driverCurrentLocation.latitude +
            (widget.destinationLocation.latitude - _driverCurrentLocation.latitude) *
                0.01,
        _driverCurrentLocation.longitude +
            (widget.destinationLocation.longitude -
                    _driverCurrentLocation.longitude) *
                0.01,
      );
    });
  }

  // 显示行程完成，跳转到支付页面
  void _showTripCompletedDialog() {
    // 取消定时器
    _timer.cancel();
    
    // 跳转到支付页面
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          pickupAddress: widget.pickupAddress,
          destinationAddress: widget.destinationAddress,
          vehicleName: widget.vehicleName,
          price: widget.price,
          currency: widget.currency,
          distanceKm: widget.distanceKm,
          durationMin: widget.durationMin,
        ),
      ),
    );
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
              target: _driverCurrentLocation,
              zoom: 15,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            markers: {
              // 司机当前位置
              Marker(
                markerId: const MarkerId('driver'),
                position: _driverCurrentLocation,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen,
                ),
                infoWindow: const InfoWindow(title: '司机位置'),
              ),
              // 目的地
              Marker(
                markerId: const MarkerId('destination'),
                position: widget.destinationLocation,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed,
                ),
                infoWindow: const InfoWindow(title: '目的地'),
              ),
            },
            polylines: {
              Polyline(
                polylineId: const PolylineId('route'),
                points: [_driverCurrentLocation, widget.destinationLocation],
                color: const Color(0xFFFFD700),
                width: 3,
              ),
            },
          ),

          // 顶部行程信息栏
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
                  // 司机信息
                  Row(
                    children: [
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
                              'U Mya Win',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: const Color(0xFFFFD700),
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '4.8',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'YUE 123',
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
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 行程进度
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '预计到达',
                            style: GoogleFonts.poppins(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '$_remainingMinutes 分钟',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFFFD700),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '费用',
                            style: GoogleFonts.poppins(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
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
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 底部操作栏
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
                  // 目的地
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.destinationAddress,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 操作按钮
                  Row(
                    children: [
                      // 分享行程（暂时禁用）
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '分享功能开发中...',
                                  style: GoogleFonts.poppins(),
                                ),
                                backgroundColor: const Color(0xFFFFD700),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: const Icon(Icons.share, size: 18),
                          label: Text(
                            '分享行程',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFFFD700),
                            side: const BorderSide(color: Color(0xFFFFD700)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // SOS 按钮
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: SOS 紧急按钮
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
                          icon: const Icon(Icons.emergency, size: 18),
                          label: Text(
                            'SOS',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
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
