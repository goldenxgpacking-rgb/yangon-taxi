import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'vehicle_selection_screen.dart';

class DestinationScreen extends StatefulWidget {
  final LatLng? currentLocation;
  final String? currentAddress;

  const DestinationScreen({super.key, this.currentLocation, this.currentAddress});

  @override
  State<DestinationScreen> createState() => _DestinationScreenState();
}

class _DestinationScreenState extends State<DestinationScreen> {
  String _pickupAddress = '正在获取上车地点...';
  LatLng _pickupLocation = const LatLng(16.8661, 96.1951);

  final _destinationController = TextEditingController();
  List<_PlaceItem> _searchResults = [];
  bool _isSearching = false;
  String _destinationAddress = '';
  LatLng? _destinationLocation;
  bool _isLoading = true;
  bool _showResults = false;

  static const List<_PlaceItem> _yangonPlaces = [
    _PlaceItem('仰光国际机场 (Yangon International Airport)', '机场', 16.9077, 96.1330),
    _PlaceItem('瑞光大金塔 (Shwedagon Pagoda)', '大金塔', 16.7984, 96.1299),
    _PlaceItem('昂山市场 (Bogyoke Aung San Market)', '昂山市场', 16.7738, 96.0962),
    _PlaceItem('苏雷宝塔 (Sule Pagoda)', '苏雷塔', 16.7715, 96.0991),
    _PlaceItem('仰光唐人街 (Chinatown Yangon)', '唐人街', 16.7811, 96.0988),
    _PlaceItem('茵雅湖 (Inya Lake)', '茵雅湖', 16.8372, 96.1375),
    _PlaceItem('甘马育市场 (Hlaing Thayar Market)', '甘马育', 16.8533, 96.1111),
    _PlaceItem('丁茵大桥 (Thanlyin Bridge)', '丁茵', 16.7544, 96.2444),
    _PlaceItem('班杜拉公园 (Maha Bandula Park)', '班杜拉公园', 16.7736, 96.0969),
    _PlaceItem('卡拉威宫 (Karaweik Palace)', '卡拉威宫', 16.8261, 96.1389),
    _PlaceItem('仰光火车站 (Yangon Central Railway Station)', '火车站', 16.7760, 96.0890),
    _PlaceItem('仰光港口 (Yangon Port)', '港口', 16.7694, 96.0933),
    _PlaceItem('仰光大学 (University of Yangon)', '仰光大学', 16.8506, 96.1433),
    _PlaceItem('维巴吉医院 (Yangon General Hospital)', '总医院', 16.7744, 96.1000),
    _PlaceItem('Junction Square', 'Junction广场', 16.8036, 96.1369),
    _PlaceItem('Tarmwe Market', 'Tarmwe', 16.7933, 96.1183),
    _PlaceItem('North Dagon', '北达贡', 16.9083, 96.1700),
    _PlaceItem('South Dagon', '南达贡', 16.8200, 96.1750),
    _PlaceItem('Thaketa', '达基达', 16.7950, 96.1900),
    _PlaceItem('Pabedan', '帕贝丹', 16.7720, 96.1010),
  ];

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
  }

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _pickupLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final parts = [
            place.street, place.locality, place.subLocality, place.country
          ].where((e) => e != null && e!.isNotEmpty).toList();
          setState(() => _pickupAddress = parts.join(', '));
        }
      } catch (_) {}
    } catch (e) {
      setState(() {
        _pickupAddress = '仰光市中心, 缅甸';
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() {
        _searchResults = [];
        _showResults = false;
      });
      return;
    }
    final results = <_PlaceItem>[];
    for (final place in _yangonPlaces) {
      if (place.name.toLowerCase().contains(q) ||
          place.keyword.toLowerCase().contains(q)) {
        results.add(place);
      }
    }
    setState(() {
      _searchResults = results;
      _showResults = results.isNotEmpty;
    });
  }

  void _selectPlace(_PlaceItem place) {
    setState(() {
      _destinationLocation = LatLng(place.lat, place.lng);
      _destinationAddress = place.name;
      _destinationController.text = place.name;
      _showResults = false;
      _searchResults = [];
    });
  }

  Future<void> _onMapTap(LatLng location) async {
    setState(() => _isSearching = true);
    try {
      final placemarks = await placemarkFromCoordinates(
        location.latitude, location.longitude,
      );
      String address =
          '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}';
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final parts = [
          place.street, place.locality, place.subLocality, place.name, place.country
        ].where((e) => e != null && e!.isNotEmpty).toList();
        if (parts.isNotEmpty) address = parts.join(', ');
      }
      setState(() {
        _destinationLocation = location;
        _destinationAddress = address;
        _destinationController.text = address;
        _showResults = false;
        _searchResults = [];
      });
    } catch (_) {
      setState(() {
        _destinationLocation = location;
        _destinationAddress =
            '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}';
        _destinationController.text = _destinationAddress;
        _showResults = false;
        _searchResults = [];
      });
    }
    setState(() => _isSearching = false);
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
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFD700)),
            )
          : Stack(
              children: [
                Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.38,
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
                            compassEnabled: true,
                            markers: {
                              Marker(
                                markerId: const MarkerId('pickup'),
                                position: _pickupLocation,
                                icon: BitmapDescriptor
                                    .defaultMarkerWithHue(
                                        BitmapDescriptor.hueYellow),
                                infoWindow: const InfoWindow(title: '上车地点'),
                              ),
                              if (_destinationLocation != null)
                                Marker(
                                  markerId: const MarkerId('destination'),
                                  position: _destinationLocation!,
                                  icon: BitmapDescriptor
                                      .defaultMarkerWithHue(
                                          BitmapDescriptor.hueRed),
                                  infoWindow: const InfoWindow(title: '目的地'),
                                ),
                            },
                            onTap: _onMapTap,
                          ),
                          if (_isSearching)
                            Container(
                              color: Colors.black26,
                              child: const Center(
                                child: CircularProgressIndicator(
                                    color: Color(0xFFFFD700)),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: Color(0xFF1A1A2E),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildPickupCard(),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  width: 2,
                                  height: 28,
                                  color: const Color(0xFFFFD700)
                                      .withOpacity(0.3),
                                  margin: const EdgeInsets.only(left: 18),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text('目的地',
                                style: GoogleFonts.poppins(
                                    color: Colors.white54, fontSize: 12)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _destinationController,
                              style: const TextStyle(color: Colors.white),
                              onChanged: _onSearchChanged,
                              decoration: InputDecoration(
                                hintText:
                                    '搜索目的地（如：机场、大金塔、唐人街）',
                                hintStyle: const TextStyle(
                                    color: Colors.white54, fontSize: 13),
                                prefixIcon: const Icon(Icons.search,
                                    color: Color(0xFFFFD700)),
                                suffixIcon:
                                    _destinationController.text.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(Icons.clear,
                                                color: Colors.white54,
                                                size: 18),
                                            onPressed: () {
                                              _destinationController.clear();
                                              _onSearchChanged('');
                                              setState(() {
                                                _destinationLocation = null;
                                                _destinationAddress = '';
                                              });
                                            },
                                          )
                                        : null,
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: const Color(0xFFFFD700)
                                        .withOpacity(0.3),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFFFD700)),
                                ),
                              ),
                            ),
                            Expanded(
                              child: _buildSearchResultArea(),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: (_destinationLocation != null &&
                                      _destinationAddress.isNotEmpty)
                                  ? () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              VehicleSelectionScreen(
                                            pickupAddress: _pickupAddress,
                                            pickupLocation: _pickupLocation,
                                            destinationAddress:
                                                _destinationAddress,
                                            destinationLocation:
                                                _destinationLocation!,
                                          ),
                                        ),
                                      )
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFD700),
                                foregroundColor: const Color(0xFF1A1A2E),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                '下一步 → 选择车型',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildSearchResultArea() {
    if (_showResults && _searchResults.isNotEmpty) {
      return Container(
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF16213E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFFFD700).withOpacity(0.2),
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemCount: _searchResults.length,
          itemBuilder: (context, index) {
            final p = _searchResults[index];
            return InkWell(
              onTap: () => _selectPlace(p),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFFFFD700), size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${p.lat.toStringAsFixed(4)}, ${p.lng.toStringAsFixed(4)}',
                            style: const TextStyle(color: Colors.white38, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white38, size: 16),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }

    if (_destinationAddress.isNotEmpty && _destinationLocation != null) {
      return Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFD700).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFFFD700).withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _destinationAddress,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white54, size: 16),
              onPressed: () {
                _destinationController.clear();
                _onSearchChanged('');
                setState(() {
                  _destinationLocation = null;
                  _destinationAddress = '';
                });
              },
            ),
          ],
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.touch_app, color: Colors.white24, size: 36),
            const SizedBox(height: 8),
            Text(
              '输入关键词搜索 或 点击地图选点',
              style: GoogleFonts.poppins(color: Colors.white38, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: ['🛫 机场', '⛩️ 大金塔', '🏪 昂山市场', '🏮 唐人街', '🌊 茵雅湖']
                  .map((tag) => ActionChip(
                        label: Text(tag, style: const TextStyle(fontSize: 12)),
                        backgroundColor: Colors.white.withOpacity(0.08),
                        side: BorderSide.none,
                        onPressed: () {
                          final keyword = tag.replaceAll(
                            RegExp(r'[^\u4e00-\u9fa5a-zA-Z]'),
                            '',
                          );
                          _destinationController.text = keyword;
                          _onSearchChanged(keyword);
                        },
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickupCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFD700).withOpacity(0.25),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.my_location, color: Color(0xFFFFD700), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '上车地点',
                  style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11),
                ),
                const SizedBox(height: 3),
                Text(
                  _pickupAddress,
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
    );
  }
}

class _PlaceItem {
  final String name;
  final String keyword;
  final double lat;
  final double lng;
  const _PlaceItem(this.name, this.keyword, this.lat, this.lng);
}
