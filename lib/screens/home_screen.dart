import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
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
  LatLng _currentPosition = const LatLng(16.8661, 96.1951); // ä»°å…‰é»˜è®¤ä½ç½®
  bool _isLoading = true;
  String _currentAddress = 'æ­£åœ¨èŽ·å–ä½ç½®...';
  
  // æ¨¡æ‹Ÿé™„è¿‘å¸æœºä½ç½®
  final List<LatLng> _nearbyDrivers = [
    const LatLng(16.8680, 96.1960),
    const LatLng(16.8650, 96.1940),
    const LatLng(16.8670, 96.1970),
  ];

  // åº•éƒ¨å¯¼èˆªæ å½“å‰ç´¢å¼•
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  // æž„å»ºé¦–é¡µå†…å®¹ï¼ˆåœ°å›¾ç•Œé¢ï¼‰
  Widget _buildHomeContent() {
    return Stack(
      children: [
        // Google åœ°å›¾
        _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFFD700),
                ),
              )
            : GoogleMap(
                onMapCreated: (controller) {
                  _mapController = controller;
                  print('âœ… Google Map created successfully');
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
                  // å½“å‰ä½ç½®æ ‡è®°
                  Marker(
                    markerId: const MarkerId('current_location'),
                    position: _currentPosition,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueYellow,
                    ),
                    infoWindow: const InfoWindow(title: 'æˆ‘çš„ä½ç½®'),
                  ),
                  // é™„è¿‘å¸æœºæ ‡è®°
                  ..._nearbyDrivers.map((position) {
                    return Marker(
                      markerId: MarkerId('driver_${position.latitude}'),
                      position: position,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueGreen,
                      ),
                      infoWindow: const InfoWindow(title: 'é™„è¿‘å¸æœº'),
                    );
                  }),
                },
              ),

        // é¡¶éƒ¨åœ°å€æ 
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
                  color: Colors.black.withValues(alpha: 0.),
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
                        'å½“å‰ä½ç½®',
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

        // åº•éƒ¨å«è½¦æŒ‰é’®
        Positioned(
          bottom: 30,
          left: 16,
          right: 16,
          child: ElevatedButton(
            onPressed: () {
              // è·³è½¬åˆ°ç›®çš„åœ°è¾“å…¥é¡µé¢
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
              'åŽ»å“ªé‡Œï¼Ÿ',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        // SOS ç´§æ€¥æŒ‰é’®
        Positioned(
          right: 16,
          bottom: 100,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _showSOSPanel,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sos, color: Colors.white, size: 22),
                      Text('SOS', style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // é™„è¿‘å¸æœºæ•°é‡æç¤º
        Positioned(
          bottom: 100,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.directions_car, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  'é™„è¿‘æœ‰ ${_nearbyDrivers.length} ä½å¸æœº',
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

  // è¯·æ±‚å®šä½æƒé™
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

  // èŽ·å–å½“å‰ä½ç½®
  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      // èŽ·å–åœ°å€
      _getAddressFromLatLng(position.latitude, position.longitude);

      // ç§»åŠ¨åœ°å›¾åˆ°å½“å‰ä½ç½®
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
      print('èŽ·å–ä½ç½®å¤±è´¥: $e');
    }
  }

  // æ˜¾ç¤ºåæ ‡ï¼Œä¸è°ƒæ…¢é€Ÿ geocoding API
  void _getAddressFromLatLng(double lat, double lng) {
    setState(() {
      _currentAddress = 'Yangon (${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)})';
    });
  }

  // æ˜¾ç¤ºæƒé™è¢«æ‹’ç»çš„å¯¹è¯æ¡†
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          'éœ€è¦å®šä½æƒé™',
          style: GoogleFonts.poppins(color: const Color(0xFFFFD700)),
        ),
        content: Text(
          'è¯·åœ¨è®¾ç½®ä¸­å…è®¸è®¿é—®å®šä½æƒé™ï¼Œä»¥ä¾¿æˆ‘ä»¬ä¸ºæ‚¨æä¾›å«è½¦æœåŠ¡ã€‚',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'å–æ¶ˆ',
              style: GoogleFonts.poppins(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text(
              'åŽ»è®¾ç½®',
              style: GoogleFonts.poppins(color: const Color(0xFFFFD700)),
            ),
          ),
        ],
      ),
    );
  }

  // SOS æ¨¡æ‹Ÿé™„è¿‘å¸æœºæ•°æ®
  final List<Map<String, dynamic>> _sosDrivers = [
    {'name': 'Aung Kyaw', 'phone': '+959123456789', 'distance': '0.3 km', 'vehicle': 'Toyota Vios', 'plate': '1/12345', 'rating': 4.8},
    {'name': 'Min Thant', 'phone': '+959987654321', 'distance': '0.5 km', 'vehicle': 'Honda Fit', 'plate': '6/54321', 'rating': 4.5},
    {'name': 'Thu Zar', 'phone': '+959555123456', 'distance': '0.8 km', 'vehicle': 'Suzuki Alto', 'plate': '2/67890', 'rating': 4.9},
    {'name': 'Zaw Win', 'phone': '+959777888999', 'distance': '1.2 km', 'vehicle': 'Nissan Sunny', 'plate': '3/11223', 'rating': 4.2},
  ];

  // æ˜¾ç¤º SOS é¢æ¿
  void _showSOSPanel() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
                  const SizedBox(width: 8),
                  Text('ç´§æ€¥æ±‚åŠ© SOS', style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 6),
              Text('ä»¥ä¸‹å¸æœºåœ¨æ‚¨é™„è¿‘ï¼Œå¯ç›´æŽ¥è”ç³»', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 13)),
              const SizedBox(height: 16),
              // æŠ¥è­¦æŒ‰é’®
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton.icon(
                  onPressed: () => _callPhone('999'),
                  icon: const Icon(Icons.local_police, color: Colors.white),
                  label: Text('æ‹¨æ‰“æŠ¥è­¦ç”µè¯ 999', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const Divider(color: Colors.white12),
              const SizedBox(height: 8),
              Text('é™„è¿‘å¸æœº', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: _sosDrivers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final driver = _sosDrivers[index];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.red.withValues(alpha: 0.),
                            child: Text('${driver['name']}'.substring(0, 1), style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.w700, fontSize: 18)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(driver['name'], style: GoogleFonts.poppins(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                                    const SizedBox(width: 6),
                                    Icon(Icons.star, color: const Color(0xFFFFD700), size: 14),
                                    Text('${driver['rating']}', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text('${driver['vehicle']} Â· ${driver['plate']}', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
                                Text('${driver['distance']} è¿œ', style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontSize: 12, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => _callPhone(driver['phone']),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.phone, size: 16),
                                const SizedBox(width: 4),
                                Text('å‘¼å«', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // æ‹¨æ‰“ç”µè¯
  Future<void> _callPhone(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    // åŠ¨æ€æž„å»ºé¡µé¢åˆ—è¡¨ï¼ˆé¿å…åœ¨ initState ä¸­è°ƒç”¨ MediaQueryï¼‰
    final List<Widget> _screens = [
      _buildHomeContent(), // é¦–é¡µå†…å®¹
      const TripHistoryScreen(), // è¡Œç¨‹åŽ†å²
      const ProfileScreen(), // ä¸ªäººä¸­å¿ƒ
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
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: AppLocalizations.of(context).home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.history),
            label: AppLocalizations.of(context).trips,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: AppLocalizations.of(context).myProfile,
          ),
        ],
      ),
    );
  }
}
