import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'vehicle_selection_screen.dart';
import '../utils/price_calculator.dart';

class DestinationScreen extends StatefulWidget {
  final LatLng? currentLocation;
  final String? currentAddress;

  const DestinationScreen({super.key, this.currentLocation, this.currentAddress});

  @override
  State<DestinationScreen> createState() => _DestinationScreenState();
}

class _DestinationScreenState extends State<DestinationScreen> {
  // 上车地点
  String _pickupAddress = '正在获取上车地点...';
  LatLng _pickupLocation = const LatLng(16.8661, 96.1951);

  // 目的地
  final _destinationController = TextEditingController();
  List<Location> _searchResults = [];
  bool _isSearching = false;
  String _destinationAddress = '';
  LatLng? _destinationLocation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.currentLocation != null) {
      _pickupLocation = widget.currentLocation!;
      _pickupAddress = widget.currentAddress ?? '当前位置';
      _isLoading = false;
    } else {
      _getCurrentLocation();
    }
    _destinationController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  // 获取当前位置
  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _pickupLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
      final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _pickupAddress = '${place.street}, ${place.locality}, ${place.country}';
        });
      }
    } catch (e) {
      setState(() {
        _pickupAddress = '仰光市中心, 仰光, 缅甸';
        _isLoading = false;
      });
    }
  }

  // 搜索防抖
  DateTime? _lastSearchTime;
  void _onSearchChanged() {
    final query = _destinationController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }
    // 简单防抖：间隔 > 800ms 才搜索
    final now = DateTime.now();
    if (_lastSearchTime != null && now.difference(_lastSearchTime!).inMilliseconds < 800) {
      return;
    }
    _lastSearchTime = now;
    _searchDestination(query);
  }

  // 搜索目的地（真实地址解析）
  Future<void> _searchDestination(String query) async {
    setState(() { _isSearching = true; });
    try {
      // 搜索缅甸仰光地区
      final results = await locationFromAddress('$query, Yangon, Myanmar');
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      // 如果缅甸范围无结果，尝试全球搜索
      try {
        final results = await locationFromAddress(query);
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      } catch (e2) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    }
  }

  // 选择搜索结果
  Future<void> _selectSearchResult(Location location) async {
    try {
      final placemarks = await placemarkFromCoordinates(location.latitude, location.longitude);
      String address = '${location.latitude}, ${location.longitude}';
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        address = '${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}'.replaceAll(RegExp(r'^,\s*|,\s*$'), '');
      }
      setState(() {
        _destinationLocation = LatLng(location.latitude, location.longitude);
        _destinationAddress = address;
        _destinationController.text = address;
        _searchResults = [];
      });
    } catch (e) {
      setState(() {
        _destinationLocation = LatLng(location.latitude, location.longitude);
        _destinationAddress = '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}';
        _searchResults = [];
      });
    }
  }

  // 地图点击选点
  Future<void> _onMapTap(LatLng location) async {
    try {
      final placemarks = await placemarkFromCoordinates(location.latitude, location.longitude);
      String address = '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}';
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        address = '${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}'.replaceAll(RegExp(r'^,\s*|,\s*$'), '');
      }
      setState(() {
        _destinationLocation = location;
        _destinationAddress = address;
        _destinationController.text = address;
        _searchResults = [];
      });
    } catch (e) {
      setState(() {
        _destinationLocation = location;
        _destinationAddress = '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}';
        _searchResults = [];
      });
    }
  }

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
          '输入目的地',
          style: GoogleFonts.poppins(
            color: const Color(0xFFFFD700),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)))
          : Column(
              children: [
                // 地图预览
                Expanded(
                  flex: 2,
                  child: Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _pickupLocation,
                          zoom: 14,
                        ),
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        markers: {
                          Marker(
                            markerId: const MarkerId('pickup'),
                            position: _pickupLocation,
                            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
                            infoWindow: const InfoWindow(title: '上车地点'),
                          ),
                          if (_destinationLocation != null)
                            Marker(
                              markerId: const MarkerId('destination'),
                              position: _destinationLocation!,
                              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                              infoWindow: const InfoWindow(title: '目的地'),
                            ),
                        },
                        onTap: _onMapTap,
                      ),
                      if (_destinationLocation == null)
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.location_on, color: const Color(0xFFFFD700).withOpacity(0.8), size: 50),
                              const SizedBox(height: 8),
                              Text('点击地图选择目的地', style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // 底部输入区域
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1A1A2E),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 上车地点
                          _buildLocationInput(),
                          const SizedBox(height: 16),
                          // 分隔线
                          Row(children: [Container(width: 2, height: 30, color: const Color(0xFFFFD700).withOpacity(0.3), margin: const EdgeInsets.only(left: 18))]),
                          const SizedBox(height: 16),
                          // 目的地输入
                          _buildDestinationInput(),
                          const SizedBox(height: 30),
                          // 下一步按钮
                          ElevatedButton(
                            onPressed: _destinationLocation != null && _destinationAddress.isNotEmpty
                                ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => VehicleSelectionScreen(
                                          pickupAddress: _pickupAddress,
                                          pickupLocation: _pickupLocation,
                                          destinationAddress: _destinationAddress,
                                          destinationLocation: _destinationLocation!,
                                        ),
                                      ),
                                    );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFD700),
                              foregroundColor: const Color(0xFF1A1A2E),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: Text('下一步', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
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

  Widget _buildLocationInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.my_location, color: Color(0xFFFFD700), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('上车地点', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 4),
                Text(_pickupAddress, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('目的地', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 8),
        TextField(
          controller: _destinationController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: '搜索目的地（如：仰光国际机场、Shwedagon Pagoda）',
            hintStyle: const TextStyle(color: Colors.white54, fontSize: 13),
            prefixIcon: _isSearching
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Color(0xFFFFD700), strokeWidth: 2))
                : const Icon(Icons.search, color: Color(0xFFFFD700)),
            suffixIcon: _destinationController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white54, size: 18),
                    onPressed: () {
                      _destinationController.clear();
                      setState(() { _searchResults = []; _destinationLocation = null; _destinationAddress = ''; });
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: const Color(0xFFFFD700).withOpacity(0.3))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFFD700))),
          ),
        ),
        // 搜索结果列表
        if (_searchResults.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            constraints: const BoxConstraints(maxHeight: 150),
            decoration: BoxDecoration(
              color: const Color(0xFF16213E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.2)),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final location = _searchResults[index];
                return InkWell(
                  onTap: () => _selectSearchResult(location),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Color(0xFFFFD700), size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
                            style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.white38, size: 16),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        // 已选目的地提示
        if (_destinationAddress.isNotEmpty && _destinationLocation != null && _searchResults.isEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_destinationAddress, style: GoogleFonts.poppins(color: Colors.white, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
