import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'payment_screen.dart';

// Google Maps API Key
const String _googleApiKey = 'AIzaSyByqGvjK-RffjPefoQQSAN6Tcnpxs6VrWs';

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
  GoogleMapController? _mapController;
  Timer? _timer;
  int _remainingMinutes = 15;
  bool _isTripStarted = false;

  // 路线相关
  List<LatLng> _polylinePoints = [];
  Set<Polyline> _polylines = {};
  bool _isLoadingRoute = false;

  // 司机模拟位置（沿路线移动）
  int _routeIndex = 0;
  List<LatLng> _routePath = [];

  @override
  void initState() {
    super.initState();
    _loadRoute(); // 先加载路线
    _startTripTimer();
  }

  // 加载 Google Directions 路线
  Future<void> _loadRoute() async {
    setState(() => _isLoadingRoute = true);
    try {
      final url =
          'https://maps.googleapis.com/maps/api/directions/json?origin=${widget.pickupLocation.latitude},${widget.pickupLocation.longitude}&destination=${widget.destinationLocation.latitude},${widget.destinationLocation.longitude}&key=$_googleApiKey';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['routes'].isNotEmpty) {
          final points = data['routes'][0]['overview_polyline']['points'];
          final decoded = PolylinePoints().decodePolyline(points);
          final coords = decoded
              .map((p) => LatLng(p.latitude, p.longitude))
              .toList();
          setState(() {
            _polylinePoints = coords;
            _routePath = coords;
            _polylines = {
              Polyline(
                polylineId: const PolylineId('route'),
                points: coords,
                color: const Color(0xFFFFD700),
                width: 4,
                startCap: Cap.roundCap,
                endCap: Cap.roundCap,
              ),
            };
            _isLoadingRoute = false;
          });
          // 缩放到路线范围
          if (_mapController != null && coords.isNotEmpty) {
            _fitMapToRoute(coords);
          }
        }
      }
    } catch (e) {
      // API 失败时用直线替代
      setState(() {
        _polylinePoints = [widget.pickupLocation, widget.destinationLocation];
        _routePath = _polylinePoints;
        _polylines = {
          Polyline(
            polylineId: const PolylineId('route_fallback'),
            points: _polylinePoints,
            color: const Color(0xFFFFD700).withOpacity(0.5),
            width: 3,
          ),
        };
        _isLoadingRoute = false;
      });
    }
  }

  void _fitMapToRoute(List<LatLng> coords) {
    if (_mapController == null || coords.isEmpty) return;
    double minLat = coords.first.latitude, maxLat = coords.first.latitude;
    double minLng = coords.first.longitude, maxLng = coords.first.longitude;
    for (final c in coords) {
      if (c.latitude < minLat) minLat = c.latitude;
      if (c.latitude > maxLat) maxLat = c.latitude;
      if (c.longitude < minLng) minLng = c.longitude;
      if (c.longitude > maxLng) maxLng = c.longitude;
    }
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat - 0.005, minLng - 0.005),
          northeast: LatLng(maxLat + 0.005, maxLng + 0.005),
        ),
        50,
      ),
    );
  }

  // 司机沿路线移动的模拟位置
  LatLng get _driverCurrentLocation {
    if (_routePath.isEmpty) return widget.pickupLocation;
    if (_routeIndex >= _routePath.length) return _routePath.last;
    return _routePath[_routeIndex];
  }

  void _startTripTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingMinutes > 0) {
          _remainingMinutes--;
          // 司机沿路线前进（每2秒移动一个路径点）
          if (_routePath.isNotEmpty && _routeIndex < _routePath.length - 1) {
            _routeIndex += 1;
          }
        } else {
          _timer?.cancel();
          _showTripCompletedDialog();
        }
      });
    });
  }

  void _showTripCompletedDialog() {
    _timer?.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          pickupAddress: widget.pickupAddress,
          destinationAddress: widget.destinationAddress,
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

  @override
  void dispose() {
    _timer?.cancel();
    _mapController?.dispose();
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
            onMapCreated: (controller) {
              _mapController = controller;
              if (_polylinePoints.isNotEmpty) {
                _fitMapToRoute(_polylinePoints);
              }
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            markers: {
              Marker(
                markerId: const MarkerId('driver'),
                position: _driverCurrentLocation,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                infoWindow: const InfoWindow(title: '司机位置'),
              ),
              Marker(
                markerId: const MarkerId('pickup'),
                position: widget.pickupLocation,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                infoWindow: const InfoWindow(title: '上车点'),
              ),
              Marker(
                markerId: const MarkerId('destination'),
                position: widget.destinationLocation,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                infoWindow: const InfoWindow(title: '目的地'),
              ),
            },
            polylines: _polylines,
          ),

          // 加载路线提示
          if (_isLoadingRoute)
            const Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFFFFD700)),
              ),
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
                        child: const Icon(Icons.person, color: Colors.green, size: 30),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('U Mya Win',
                                style: GoogleFonts.poppins(
                                    color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Color(0xFFFFD700), size: 14),
                                const SizedBox(width: 4),
                                Text('4.8',
                                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                                const SizedBox(width: 12),
                                Text('YUE 123',
                                    style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.phone, color: Color(0xFFFFD700)),
                        onPressed: () {},
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
                          Text('预计到达',
                              style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
                          Text('$_remainingMinutes 分钟',
                              style: GoogleFonts.poppins(
                                  color: const Color(0xFFFFD700),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('费用', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
                          Text('${widget.currency} ${widget.price}',
                              style: GoogleFonts.poppins(
                                  color: const Color(0xFFFFD700),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700)),
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
                        child: Text(widget.destinationAddress,
                            style: GoogleFonts.poppins(
                                color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 操作按钮
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('分享功能开发中...', style: GoogleFonts.poppins()),
                                backgroundColor: const Color(0xFFFFD700),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: const Icon(Icons.share, size: 18),
                          label: Text('分享行程', style: GoogleFonts.poppins(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFFFD700),
                            side: const BorderSide(color: Color(0xFFFFD700)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: const Color(0xFF1A1A2E),
                                title: Text('🚨 紧急求助',
                                    style: GoogleFonts.poppins(color: Colors.red)),
                                content: Text('将向紧急联系人发送您的位置信息，并通知平台客服。',
                                    style: GoogleFonts.poppins(color: Colors.white70)),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('取消',
                                          style: GoogleFonts.poppins(color: Colors.white54))),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text('已发送紧急求助信息！',
                                                style: GoogleFonts.poppins()),
                                            backgroundColor: Colors.red,
                                            behavior: SnackBarBehavior.floating),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red, foregroundColor: Colors.white),
                                    child: Text('确认发送', style: GoogleFonts.poppins()),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(Icons.emergency, size: 18),
                          label: Text('SOS', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
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
