import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'waiting_driver_screen.dart';

class RideConfirmationScreen extends StatefulWidget {
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

  const RideConfirmationScreen({
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
  State<RideConfirmationScreen> createState() => _RideConfirmationScreenState();
}

class _RideConfirmationScreenState extends State<RideConfirmationScreen> {
  bool _isAgreed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFD700)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '确认叫车',
          style: GoogleFonts.poppins(
            color: const Color(0xFFFFD700),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // 地图预览
          Expanded(
            flex: 2,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  (widget.pickupLocation.latitude +
                          widget.destinationLocation.latitude) /
                      2,
                  (widget.pickupLocation.longitude +
                          widget.destinationLocation.longitude) /
                      2,
                ),
                zoom: 13,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('pickup'),
                  position: widget.pickupLocation,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueYellow,
                  ),
                  infoWindow: const InfoWindow(title: '上车地点'),
                ),
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
                  points: [widget.pickupLocation, widget.destinationLocation],
                  color: const Color(0xFFFFD700),
                  width: 3,
                ),
              },
            ),
          ),

          // 底部确认区域
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF1A1A2E),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 车型信息
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _getVehicleColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getVehicleIcon(),
                            color: _getVehicleColor(),
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.vehicleName,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '预计等待 ${widget.waitTime} 分钟',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFFFFD700),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${widget.currency} ${widget.price}',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFFFFD700),
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '预估价格',
                              style: GoogleFonts.poppins(
                                color: Colors.white54,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 路线详情
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.my_location,
                                  color: Color(0xFFFFD700), size: 16),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  widget.pickupAddress,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  color: Colors.red, size: 16),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  widget.destinationAddress,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 支付方式
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.payment,
                              color: Color(0xFFFFD700), size: 20),
                          const SizedBox(width: 12),
                          Text(
                            '支付方式',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '现金支付',
                            style: GoogleFonts.poppins(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              color: Colors.white54),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 用户协议
                    Row(
                      children: [
                        Checkbox(
                          value: _isAgreed,
                          onChanged: (value) {
                            setState(() {
                              _isAgreed = value ?? false;
                            });
                          },
                          activeColor: const Color(0xFFFFD700),
                          checkColor: const Color(0xFF1A1A2E),
                        ),
                        Expanded(
                          child: Text(
                            '我已阅读并同意《用车服务协议》',
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 确认叫车按钮
                    ElevatedButton(
                      onPressed: _isAgreed
                          ? () {
                              // 跳转到等待司机页面
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WaitingDriverScreen(
                                    pickupAddress: widget.pickupAddress,
                                    pickupLocation: widget.pickupLocation,
                                    destinationAddress:
                                        widget.destinationAddress,
                                    destinationLocation:
                                        widget.destinationLocation,
                                    vehicleType: widget.vehicleType,
                                    vehicleName: widget.vehicleName,
                                    price: widget.price,
                                    currency: widget.currency,
                                    waitTime: widget.waitTime,
                                    distanceKm: widget.distanceKm,
                                    durationMin: widget.durationMin,
                                  ),
                                ),
                                (route) => false,
                              );
                            }
                          : null,
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
                        '确认叫车',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 获取车型图标
  IconData _getVehicleIcon() {
    switch (widget.vehicleType) {
      case 'cng':
        return Icons.local_gas_station;
      case 'oil':
        return Icons.local_gas_station;
      case 'ev':
        return Icons.electric_car;
      case 'private':
        return Icons.directions_car_filled;
      default:
        return Icons.directions_car;
    }
  }

  // 获取车型颜色
  Color _getVehicleColor() {
    switch (widget.vehicleType) {
      case 'cng':
        return Colors.blue;
      case 'oil':
        return Colors.green;
      case 'ev':
        return Colors.purple;
      case 'private':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}
