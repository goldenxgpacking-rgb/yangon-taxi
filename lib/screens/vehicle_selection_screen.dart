import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../utils/price_calculator.dart';
import 'ride_confirmation_screen.dart';

class VehicleSelectionScreen extends StatefulWidget {
  final String pickupAddress;
  final LatLng pickupLocation;
  final String destinationAddress;
  final LatLng destinationLocation;

  const VehicleSelectionScreen({
    super.key,
    required this.pickupAddress,
    required this.pickupLocation,
    required this.destinationAddress,
    required this.destinationLocation,
  });

  @override
  State<VehicleSelectionScreen> createState() => _VehicleSelectionScreenState();
}

class _VehicleSelectionScreenState extends State<VehicleSelectionScreen> {
  String _selectedVehicle = 'cng';

  // 距离和时长（全局计算一次）
  late final double _distanceKm;
  late final int _durationMin;

  // 车型列表（价格运行时计算）
  final List<Map<String, dynamic>> _vehicleTemplates = [
    {'id': 'cng', 'name': 'CNG CAR', 'icon': Icons.local_gas_station, 'description': '压缩天然气，环保节能', 'capacity': '4人', 'color': Colors.blue},
    {'id': 'oil', 'name': 'OIL CAR', 'icon': Icons.local_gas_station, 'description': '传统燃油，动力强劲', 'capacity': '4人', 'color': Colors.green},
    {'id': 'ev', 'name': 'EV CAR', 'icon': Icons.electric_car, 'description': '新能源电动车，零排放', 'capacity': '4人', 'color': Colors.purple},
    {'id': 'private', 'name': '私家车', 'icon': Icons.directions_car_filled, 'description': '私人车辆，舒适出行', 'capacity': '4人', 'color': Colors.orange},
  ];

  late List<Map<String, dynamic>> _vehicles;

  @override
  void initState() {
    super.initState();
    _distanceKm = PriceCalculator.calculateDistanceLatLng(widget.pickupLocation, widget.destinationLocation);
    _durationMin = PriceCalculator.calculateDuration(_distanceKm);

    // 为每个车型计算实际价格
    _vehicles = _vehicleTemplates.map((v) {
      final price = PriceCalculator.calculatePriceLatLng(widget.pickupLocation, widget.destinationLocation, v['id']);
      return {...v, 'price': price, 'currency': 'K', 'waitTime': '${_durationMin + 2}-${_durationMin + 5}'};
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final selected = _vehicles.firstWhere((v) => v['id'] == _selectedVehicle);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFD700)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('选择车型', style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          // 路线摘要
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.my_location, color: Color(0xFFFFD700), size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(widget.pickupAddress, style: GoogleFonts.poppins(color: Colors.white, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(children: [
                    const SizedBox(width: 8),
                    Text('${_distanceKm.toStringAsFixed(1)} 公里  |  约 $_durationMin 分钟', style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontSize: 11)),
                  ]),
                ),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(widget.destinationAddress, style: GoogleFonts.poppins(color: Colors.white, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ],
            ),
          ),

          // 车型列表
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _vehicles.length,
              itemBuilder: (context, index) {
                final vehicle = _vehicles[index];
                final isSelected = vehicle['id'] == _selectedVehicle;

                return GestureDetector(
                  onTap: () => setState(() { _selectedVehicle = vehicle['id']; }),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFFD700).withOpacity(0.1) : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? const Color(0xFFFFD700) : Colors.white.withOpacity(0.1), width: isSelected ? 2 : 1),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60, height: 60,
                          decoration: BoxDecoration(color: vehicle['color'].withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                          child: Icon(vehicle['icon'], color: vehicle['color'], size: 30),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(vehicle['name'], style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(vehicle['description'], style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.people, color: Colors.white54, size: 14),
                                  const SizedBox(width: 4),
                                  Text(vehicle['capacity'], style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
                                  const SizedBox(width: 16),
                                  Icon(Icons.access_time, color: const Color(0xFFFFD700), size: 14),
                                  const SizedBox(width: 4),
                                  Text('${vehicle['waitTime']} 分钟', style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontSize: 12, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${vehicle['currency']} ${vehicle['price']}', style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontSize: 18, fontWeight: FontWeight.w700)),
                            Text('预估', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 10)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 底部确认按钮
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF1A1A2E), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, -5))]),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RideConfirmationScreen(
                      pickupAddress: widget.pickupAddress,
                      pickupLocation: widget.pickupLocation,
                      destinationAddress: widget.destinationAddress,
                      destinationLocation: widget.destinationLocation,
                      vehicleType: selected['id'],
                      vehicleName: selected['name'],
                      price: selected['price'],
                      currency: selected['currency'],
                      waitTime: selected['waitTime'],
                      distanceKm: _distanceKm,
                      durationMin: _durationMin,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: const Color(0xFF1A1A2E),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text('确认车型', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
