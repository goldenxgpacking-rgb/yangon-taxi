import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import '../../utils/route_generator.dart';
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
  bool _useRealRoute = false;
  double _totalRouteDistanceKm = 0;

  // 司机模拟位置（沿路线移动）
  int _routeIndex = 0;
  List<LatLng> _routePath = [];

  // 行程进度
  double _tripProgress = 0.0; // 0.0 ~ 1.0
  bool _showNavPanel = false;

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
          // 提取距离和时长
          final leg = data['routes'][0]['legs'][0];
          _totalRouteDistanceKm = (leg['distance']['value'] as int) / 1000.0;
          final durationSec = leg['duration']['value'] as int;
          setState(() {
            _remainingMinutes = (durationSec / 60).round().clamp(2, 60);
          });
          final points = data['routes'][0]['overview_polyline']['points'];
          final decoded = PolylinePoints().decodePolyline(points);
          final coords = decoded.map((p) => LatLng(p.latitude, p.longitude)).toList();
          setState(() {
            _polylinePoints = coords;
            _routePath = coords;
            _useRealRoute = true;
            _polylines = {
              Polyline(
                polylineId: const PolylineId('route'),
                points: coords,
                color: const Color(0xFFFFD700),
                width: 5,
                startCap: Cap.roundCap,
                endCap: Cap.roundCap,
              ),
            };
            _isLoadingRoute = false;
          });
          if (_mapController != null && coords.isNotEmpty) {
            _fitMapToRoute(coords);
          }
          return;
        }
      }
    } catch (e) {
      // Directions API 失败，使用模拟曲线路线
    }
    // Fallback: 模拟曲线路线
    _useSimulatedRoute();
  }

  void _useSimulatedRoute() {
    final coords = RouteGenerator.generateCurvedRoute(
      widget.pickupLocation,
      widget.destinationLocation,
    );
    final dist = widget.distanceKm ?? 5.0;
    _totalRouteDistanceKm = dist;
    final durationMin = widget.durationMin ?? (dist / 25 * 60).round().clamp(2, 60);
    setState(() {
      _polylinePoints = coords;
      _routePath = coords;
      _remainingMinutes = durationMin;
      _polylines = {
        Polyline(
          polylineId: const PolylineId('route_simulated'),
          points: coords,
          color: const Color(0xFFFFD700),
          width: 5,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ),
      };
      _isLoadingRoute = false;
    });
    if (_mapController != null && coords.isNotEmpty) {
      _fitMapToRoute(coords);
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
    final totalSeconds = _remainingMinutes * 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingMinutes > 0) {
          _remainingMinutes--;
          // 计算行程进度
          final elapsed = totalSeconds - _remainingMinutes * 60;
          _tripProgress = (elapsed / totalSeconds).clamp(0.0, 1.0);
          // 司机沿路线前进
          if (_routePath.isNotEmpty && _routeIndex < _routePath.length - 1) {
            final stepsPerSecond = max(1, (_routePath.length / totalSeconds).ceil());
            _routeIndex = min(_routeIndex + stepsPerSecond, _routePath.length - 1);
            // 相机跟随司机位置
            _mapController?.animateCamera(
              CameraUpdate.newLatLng(_routePath[_routeIndex]),
            );
          }
        } else {
          _tripProgress = 1.0;
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

  // 计算剩余距离
  double get _remainingDistanceKm {
    if (_routePath.isEmpty || _routeIndex >= _routePath.length - 1) return 0;
    double dist = 0;
    for (int i = _routeIndex; i < _routePath.length - 1; i++) {
      dist += _haversine(_routePath[i], _routePath[i + 1]);
    }
    return dist;
  }

  double _haversine(LatLng a, LatLng b) {
    const r = 6371.0;
    final dLat = (b.latitude - a.latitude) * pi / 180;
    final dLng = (b.longitude - a.longitude) * pi / 180;
    final x = sin(dLat / 2) * sin(dLat / 2) +
        cos(a.latitude * pi / 180) * cos(b.latitude * pi / 180) * sin(dLng / 2) * sin(dLng / 2);
    return r * 2 * atan2(sqrt(x), sqrt(1 - x));
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
            onCameraMove: (_) {},
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

          // 顶部导航信息栏
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Column(
              children: [
                // 导航方向卡片
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
                    ],
                  ),
                  child: Column(
                    children: [
                      // 剩余距离和方向
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD700).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.navigation, color: Color(0xFFFFD700), size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _remainingDistanceKm < 1
                                      ? '${(_remainingDistanceKm * 1000).round()} m'
                                      : '${_remainingDistanceKm.toStringAsFixed(1)} km',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFFFFD700),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '预计 $_remainingMinutes 分钟到达',
                                  style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          // 展开导航详情按钮
                          IconButton(
                            icon: Icon(
                              _showNavPanel ? Icons.expand_less : Icons.expand_more,
                              color: Colors.white54,
                            ),
                            onPressed: () => setState(() => _showNavPanel = !_showNavPanel),
                          ),
                        ],
                      ),
                      // 行程进度条
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _tripProgress,
                          backgroundColor: Colors.white10,
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                          minHeight: 4,
                        ),
                      ),
                    ],
                  ),
                ),
                // 展开导航详情面板
                if (_showNavPanel) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A2E),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 3)),
                      ],
                    ),
                    child: Column(
                      children: [
                        // 司机信息
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(Icons.person, color: Colors.green, size: 24),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('U Mya Win', style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                                  Row(
                                    children: [
                                      const Icon(Icons.star, color: Color(0xFFFFD700), size: 12),
                                      const SizedBox(width: 3),
                                      Text('4.8', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11)),
                                      const SizedBox(width: 8),
                                      Text('YUE 123', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(icon: const Icon(Icons.phone, color: Color(0xFFFFD700), size: 20), onPressed: () {}),
                          ],
                        ),
                        const Divider(color: Colors.white10, height: 16),
                        // 路线信息
                        _buildRouteInfoRow(Icons.my_location, '上车点', widget.pickupAddress, const Color(0xFFFFD700)),
                        const SizedBox(height: 6),
                        _buildRouteInfoRow(Icons.location_on, '目的地', widget.destinationAddress, Colors.red),
                        const Divider(color: Colors.white10, height: 16),
                        // 费用和车型
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('车型: ${widget.vehicleName}', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
                            Text('${widget.currency} ${widget.price}', style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontSize: 14, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        if (!_useRealRoute) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline, color: Colors.orange, size: 14),
                                const SizedBox(width: 6),
                                Expanded(child: Text('路线为模拟数据，正式版将接入实时导航', style: GoogleFonts.poppins(color: Colors.orange, fontSize: 10))),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 底部操作栏
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 16, right: 16, top: 16,
                bottom: MediaQuery.of(context).padding.bottom + 16,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, -5)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 目的地 + 剩余距离
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.flag, color: Colors.red, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(widget.destinationAddress,
                              style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _remainingDistanceKm < 1
                              ? '${(_remainingDistanceKm * 1000).round()}m'
                              : '${_remainingDistanceKm.toStringAsFixed(1)}km',
                          style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 操作按钮
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: '我在Yangon Taxi上打车从${widget.pickupAddress}到${widget.destinationAddress}，费用${widget.currency} ${widget.price}'));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('行程信息已复制', style: GoogleFonts.poppins()), backgroundColor: const Color(0xFFFFD700), behavior: SnackBarBehavior.floating),
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
                                title: Text('🚨 紧急求助', style: GoogleFonts.poppins(color: Colors.red)),
                                content: Text('将向紧急联系人发送您的位置信息，并通知平台客服。', style: GoogleFonts.poppins(color: Colors.white70)),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('取消', style: GoogleFonts.poppins(color: Colors.white54)),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('已发送紧急求助信息！', style: GoogleFonts.poppins()), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                    child: Text('确认发送', style: GoogleFonts.poppins()),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(Icons.emergency, size: 18),
                          label: Text('SOS', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red, foregroundColor: Colors.white,
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

  Widget _buildRouteInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 10),
        Expanded(child: Text(value, style: GoogleFonts.poppins(color: Colors.white, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
