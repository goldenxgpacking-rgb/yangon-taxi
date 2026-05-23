import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/trip.dart';
import '../services/trip_storage.dart';
import 'trip_detail_screen.dart';

class TripHistoryScreen extends StatefulWidget {
  const TripHistoryScreen({super.key});

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> {
  List<Trip> _trips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    final trips = await TripStorage.getAllTrips();
    setState(() {
      _trips = trips;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        title: Text('行程历史', style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontWeight: FontWeight.w600)),
        actions: [
          if (_trips.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
              onPressed: () => _showClearDialog(),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)))
          : _trips.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  color: const Color(0xFFFFD700),
                  backgroundColor: const Color(0xFF1A1A2E),
                  onRefresh: _loadTrips,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _trips.length,
                    itemBuilder: (context, index) {
                      final trip = _trips[index];
                      return _buildTripCard(trip);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, color: Colors.white.withOpacity(0.1), size: 80),
          const SizedBox(height: 16),
          Text('暂无行程记录', style: GoogleFonts.poppins(color: Colors.white38, fontSize: 16)),
          const SizedBox(height: 8),
          Text('完成第一次行程后将显示在这里', style: GoogleFonts.poppins(color: Colors.white24, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTripCard(Trip trip) {
    // 车型图标和颜色
    IconData vehicleIcon = Icons.directions_car;
    Color vehicleColor = Colors.blue;
    switch (trip.vehicleType) {
      case 'oil': vehicleColor = Colors.green; break;
      case 'ev': vehicleColor = Colors.purple; vehicleIcon = Icons.electric_car; break;
      case 'private': vehicleColor = Colors.orange; vehicleIcon = Icons.directions_car_filled; break;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => TripDetailScreen(trip: trip)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部：时间 + 状态
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(trip.pickupTime, style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: trip.status == 'completed' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    trip.status == 'completed' ? '已完成' : '进行中',
                    style: GoogleFonts.poppins(color: trip.status == 'completed' ? Colors.green : Colors.orange, fontSize: 10, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 路线
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    const Icon(Icons.circle, color: Color(0xFFFFD700), size: 8),
                    Container(width: 1, height: 24, color: Colors.white24),
                    const Icon(Icons.location_on, color: Colors.red, size: 12),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(trip.pickupAddress, style: GoogleFonts.poppins(color: Colors.white, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 16),
                      Text(trip.destinationAddress, style: GoogleFonts.poppins(color: Colors.white, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.white12),
            const SizedBox(height: 8),
            // 底部信息
            Row(
              children: [
                Icon(vehicleIcon, color: vehicleColor, size: 16),
                const SizedBox(width: 4),
                Text(trip.vehicleName, style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                if (trip.distanceKm != null) ...[
                  const SizedBox(width: 12),
                  Text('${trip.distanceKm!.toStringAsFixed(1)} km', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
                ],
                const Spacer(),
                Text('${trip.currency} ${trip.price}', style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
            if (trip.rating > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Text('你的评分：', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11)),
                    ...List.generate(5, (i) => Icon(Icons.star, color: i < trip.rating ? const Color(0xFFFFD700) : Colors.white24, size: 14)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text('清除所有记录', style: GoogleFonts.poppins(color: const Color(0xFFFFD700))),
        content: Text('确定要清除所有行程记录吗？此操作不可恢复。', style: GoogleFonts.poppins(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('取消', style: GoogleFonts.poppins(color: Colors.white54))),
          TextButton(
            onPressed: () async {
              await TripStorage.clearTrips();
              Navigator.pop(context);
              _loadTrips();
            },
            child: Text('清除', style: GoogleFonts.poppins(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
