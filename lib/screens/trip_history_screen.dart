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
  String _filterStatus = 'all'; // all, completed, cancelled, ongoing
  bool _showStats = true;

  // 统计数据
  int _totalCount = 0;
  int _totalSpent = 0;
  double _totalDistance = 0;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    final trips = await TripStorage.getAllTrips();
    final completedCount = trips.where((t) => t.status == 'completed').length;
    final spent = trips
        .where((t) => t.status == 'completed')
        .fold<int>(0, (sum, t) => sum + t.price);
    final dist = trips
        .where((t) => t.status == 'completed' && t.distanceKm != null)
        .fold<double>(0, (sum, t) => sum + t.distanceKm!);

    setState(() {
      _trips = trips;
      _totalCount = completedCount;
      _totalSpent = spent;
      _totalDistance = dist;
      _isLoading = false;
    });
  }

  List<Trip> get _filteredTrips {
    if (_filterStatus == 'all') return _trips;
    return _trips.where((t) => t.status == _filterStatus).toList();
  }

  /// 按日期分组
  Map<String, List<Trip>> get _groupedTrips {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo = today.subtract(const Duration(days: 7));

    final map = <String, List<Trip>>{};

    for (final trip in _filteredTrips) {
      String group;
      final parts = trip.pickupTime.split(' ');
      final dateStr = parts[0];
      try {
        final date = DateTime.parse(dateStr);
        if (date.isAfter(today) || date.isAtSameMomentAs(today)) {
          group = '今天';
        } else if (date.isAfter(yesterday) || date.isAtSameMomentAs(yesterday)) {
          group = '昨天';
        } else if (date.isAfter(weekAgo)) {
          group = '最近7天';
        } else {
          group = dateStr;
        }
      } catch (_) {
        group = dateStr;
      }
      map.putIfAbsent(group, () => []).add(trip);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        title: Text(
          '行程历史',
          style: GoogleFonts.poppins(
            color: const Color(0xFFFFD700),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_trips.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
              onPressed: () => _showClearDialog(),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFD700)),
            )
          : _trips.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    // 统计卡片
                    _buildStatsCard(),
                    // 筛选标签
                    _buildFilterTabs(),
                    // 行程列表
                    Expanded(
                      child: RefreshIndicator(
                        color: const Color(0xFFFFD700),
                        backgroundColor: const Color(0xFF1A1A2E),
                        onRefresh: _loadTrips,
                        child: _filteredTrips.isEmpty
                            ? Center(
                                child: Text(
                                  '暂无${_filterStatus == 'all' ? '' : '此类型的'}行程记录',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white38,
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            : _buildGroupedList(),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildStatsCard() {
    if (!_showStats || _totalCount == 0) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFD700).withOpacity(0.12),
            Colors.white.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFD700).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem('总行程', '$_totalCount', Icons.directions_car),
          ),
          Container(
            width: 1,
            height: 36,
            color: Colors.white12,
          ),
          Expanded(
            child: _buildStatItem(
              '总花费',
              '${_totalSpent >= 1000 ? '${(_totalSpent / 1000).toStringAsFixed(1)}K' : _totalSpent} Ks',
              Icons.payments,
            ),
          ),
          Container(
            width: 1,
            height: 36,
            color: Colors.white12,
          ),
          Expanded(
            child: _buildStatItem(
              '总里程',
              '${_totalDistance.toStringAsFixed(1)} km',
              Icons.straighten,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFFFD700), size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.white54, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildFilterTabs() {
    final tabs = [
      ('all', '全部'),
      ('completed', '已完成'),
      ('ongoing', '进行中'),
      ('cancelled', '已取消'),
    ];
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (value, label) = tabs[index];
          final isSelected = _filterStatus == value;
          return GestureDetector(
            onTap: () => setState(() => _filterStatus = value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFFD700)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFFFD700)
                      : Colors.white.withOpacity(0.1),
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: isSelected
                        ? const Color(0xFF1A1A2E)
                        : Colors.white70,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGroupedList() {
    final groups = _groupedTrips;
    final groupKeys = groups.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: groupKeys.length,
      itemBuilder: (context, sectionIndex) {
        final group = groupKeys[sectionIndex];
        final trips = groups[group]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 日期分组标题
            Padding(
              padding: EdgeInsets.only(bottom: 8, top: sectionIndex > 0 ? 16 : 0),
              child: Row(
                children: [
                  Text(
                    group,
                    style: GoogleFonts.poppins(
                      color: Colors.white54,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${trips.length} 趟',
                    style: GoogleFonts.poppins(
                      color: Colors.white24,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            // 该日期下的行程卡片
            ...trips.map((trip) => _buildTripCard(trip)),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, color: Colors.white.withOpacity(0.1), size: 80),
          const SizedBox(height: 16),
          Text(
            '暂无行程记录',
            style: GoogleFonts.poppins(color: Colors.white38, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '完成第一次行程后将显示在这里',
            style: GoogleFonts.poppins(color: Colors.white24, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard(Trip trip) {
    IconData vehicleIcon = Icons.local_gas_station;
    Color vehicleColor = Colors.blue;
    switch (trip.vehicleType) {
      case 'oil':
        vehicleColor = Colors.green;
        break;
      case 'ev':
        vehicleColor = Colors.purple;
        vehicleIcon = Icons.electric_car;
        break;
      case 'private':
        vehicleColor = Colors.orange;
        vehicleIcon = Icons.directions_car_filled;
        break;
    }

    return Dismissible(
      key: Key(trip.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.red, size: 22),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A2E),
            title: Text(
              '删除行程',
              style: GoogleFonts.poppins(color: const Color(0xFFFFD700)),
            ),
            content: Text(
              '确定要删除这条行程记录吗？',
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('取消', style: GoogleFonts.poppins(color: Colors.white54)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('删除', style: GoogleFonts.poppins(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) async {
        await TripStorage.deleteTrip(trip.id);
        _loadTrips();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已删除行程记录', style: GoogleFonts.poppins()),
            backgroundColor: Colors.grey[800],
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TripDetailScreen(trip: trip),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部：时间 + 状态
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    trip.pickupTime,
                    style: GoogleFonts.poppins(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getStatusColor(trip.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _getStatusText(trip.status),
                      style: GoogleFonts.poppins(
                        color: _getStatusColor(trip.status),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
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
                        Text(
                          trip.pickupAddress,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          trip.destinationAddress,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
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
                  Text(
                    trip.vehicleName ?? "",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (trip.distanceKm != null) ...[
                    const SizedBox(width: 12),
                    Icon(Icons.straighten, color: Colors.white38, size: 14),
                    const SizedBox(width: 2),
                    Text(
                      '${trip.distanceKm!.toStringAsFixed(1)} km',
                      style: GoogleFonts.poppins(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    '${trip.currency} ${trip.price}',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFFFD700),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              if (trip.rating > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Text(
                        '你的评分：',
                        style: GoogleFonts.poppins(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                      ...List.generate(
                        5,
                        (i) => Icon(
                          Icons.star,
                          color: i < trip.rating
                              ? const Color(0xFFFFD700)
                              : Colors.white24,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'ongoing':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return '已完成';
      case 'cancelled':
        return '已取消';
      case 'ongoing':
        return '进行中';
      default:
        return status;
    }
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          '清除所有记录',
          style: GoogleFonts.poppins(color: const Color(0xFFFFD700)),
        ),
        content: Text(
          '确定要清除所有行程记录吗？此操作不可恢复。',
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
            onPressed: () async {
              await TripStorage.clearTrips();
              Navigator.pop(context);
              _loadTrips();
            },
            child: Text(
              '清除',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
