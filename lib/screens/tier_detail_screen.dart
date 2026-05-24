import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/user_tier_service.dart';
import '../services/trip_storage.dart';

class TierDetailScreen extends StatefulWidget {
  const TierDetailScreen({super.key});

  @override
  State<TierDetailScreen> createState() => _TierDetailScreenState();
}

class _TierDetailScreenState extends State<TierDetailScreen> {
  Map<String, dynamic> _tierInfo = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTierInfo();
  }

  Future<void> _loadTierInfo() async {
    final completed = await TripStorage.getCompletedCount();
    final info = await UserTierService.getTierInfo(completed);
    setState(() {
      _tierInfo = info;
      _isLoading = false;
    });
  }

  Color get _tierColor {
    final c = _tierInfo['color'] ?? 0xFFCD7F32;
    return Color(c);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1A1A2E),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFFFD700))),
      );
    }

    final allTiers = UserTierService.getAllTiers();
    final completed = _tierInfo['completedTrips'] ?? 0;
    final tripsToNext = _tierInfo['tripsToNext'] ?? 0;
    final points = _tierInfo['points'] ?? 0;
    final tier = _tierInfo['tier'] ?? 'Bronze';
    final nextTier = _tierInfo['nextTier'] ?? '';
    final minTripsForNext = _tierInfo['minTripsForNext'] ?? 1;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFD700)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('会员等级', style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 当前等级大卡片
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_tierColor.withOpacity(0.2), _tierColor.withOpacity(0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _tierColor.withOpacity(0.4)),
              ),
              child: Column(
                children: [
                  Text(_tierInfo['icon'] ?? '🏅', style: const TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text(tier, style: GoogleFonts.poppins(color: _tierColor, fontSize: 24, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text('$points 积分', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('已完成 $completed 单', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 进度条
            if (tripsToNext > 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('距下一等级（$nextTier）', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11)),
                  Text('还需 $tripsToNext 单', style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (completed / minTripsForNext).clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(_tierColor),
                ),
              ),
              const SizedBox(height: 20),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.emoji_events, color: Colors.green, size: 16),
                    const SizedBox(width: 8),
                    Text('已达到最高等级！', style: GoogleFonts.poppins(color: Colors.green, fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 等级权益说明
            Align(
              alignment: Alignment.centerLeft,
              child: Text('等级权益', style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontSize: 14, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 12),

            // 各等级卡片
            ...allTiers.asMap().entries.map((entry) {
              final i = entry.key;
              final t = entry.value;
              final isCurrent = t['tier'] == tier;
              final color = Color(t['color']);

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isCurrent ? color.withOpacity(0.1) : Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(12),
                  border: isCurrent ? Border.all(color: color.withOpacity(0.4)) : null,
                ),
                child: Row(
                  children: [
                    Text(t['icon'], style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(t['tier'], style: GoogleFonts.poppins(color: color, fontSize: 14, fontWeight: FontWeight.w600)),
                              if (isCurrent) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                                  child: Text('当前', style: GoogleFonts.poppins(color: color, fontSize: 9, fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('满 ${t['minTrips']} 单 · 每单 ${t['pointsPerTrip']} 积分', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 24),

            // 积分说明
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('积分规则', style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  _buildRuleRow('每完成1单', '获得对应等级积分'),
                  _buildRuleRow('等级越高', '每单积分越多'),
                  _buildRuleRow('积分可兑换', '打车券（即将上线）'),
                  _buildRuleRow('邀请好友', '额外获得积分奖励'),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleRow(String left, String right) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontSize: 11)),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(text: '$left ', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11)),
                  TextSpan(text: right, style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontSize: 11)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
