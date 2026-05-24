import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  String _referralCode = '';
  int _invitedCount = 0;
  int _earnedPoints = 0;
  bool _isLoading = true;

  static const int _pointsPerInvite = 500;
  static const int _kyatPerInvite = 1000;

  @override
  void initState() {
    super.initState();
    _loadReferralData();
  }

  Future<void> _loadReferralData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _referralCode = prefs.getString('referral_code') ?? '';
      _invitedCount = prefs.getInt('invited_count') ?? 0;
      _earnedPoints = prefs.getInt('referral_points') ?? 0;
      _isLoading = false;
    });
    if (_referralCode.isEmpty) await _generateReferralCode();
  }

  Future<void> _generateReferralCode() async {
    final rand = Random();
    final chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final code = List.generate(6, (i) => chars[rand.nextInt(chars.length)]).join();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('referral_code', code);
    setState(() => _referralCode = code);
  }

  Future<void> _simulateInvite() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _invitedCount += 1;
      _earnedPoints += _pointsPerInvite;
    });
    await prefs.setInt('invited_count', _invitedCount);
    await prefs.setInt('referral_points', _earnedPoints);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎉 成功邀请1位好友，获得 $_kyatPerInvite K 打车券！', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFF1A1A2E),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _copyReferralCode() async {
    await Clipboard.setData(ClipboardData(text: _referralCode));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('邀请码已复制：$_referralCode', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFF1A1A2E),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _shareViaSystem() async {
    final message = '🚕 加入 Yangon Taxi！\n使用我的邀请码 $_referralCode 注册，你和我各得 $_kyatPerInvite K 打车券！';
    await Clipboard.setData(ClipboardData(text: message));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('分享文案已复制，可粘贴到微信/Facebook等发送给好友', style: GoogleFonts.poppins(fontSize: 12)),
        backgroundColor: const Color(0xFF1A1A2E),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1A1A2E),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFFFD700))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFD700)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('推荐有礼', style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 顶部奖励卡片
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text('每邀请1位好友', style: GoogleFonts.poppins(color: Colors.black87, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text('$_kyatPerInvite K', style: GoogleFonts.poppins(color: Colors.black, fontSize: 36, fontWeight: FontWeight.w800)),
                  Text('打车券奖励', style: GoogleFonts.poppins(color: Colors.black87, fontSize: 13)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 数据统计
            Row(
              children: [
                Expanded(child: _buildStatCard('已邀请', '$_invitedCount', Icons.people, Colors.blue)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('累计奖励', '$_earnedPoints', Icons.stars, const Color(0xFFFFD700))),
              ],
            ),

            const SizedBox(height: 24),

            // 邀请码卡片
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text('我的邀请码', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _referralCode,
                        style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: 4),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _copyReferralCode,
                          icon: const Icon(Icons.copy, size: 16),
                          label: Text('复制邀请码', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD700),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _shareViaSystem,
                          icon: const Icon(Icons.share, size: 16),
                          label: Text('复制分享文案', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.1),
                            foregroundColor: const Color(0xFFFFD700),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            side: const BorderSide(color: Color(0xFFFFD700)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 活动规则
            Align(
              alignment: Alignment.centerLeft,
              child: Text('活动规则', style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontSize: 14, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 8),
            _buildRuleItem('1', '邀请好友注册 Yangon Taxi'),
            _buildRuleItem('2', '好友首次完成打车行程'),
            _buildRuleItem('3', '你和好友各得 $_kyatPerInvite K 打车券'),
            _buildRuleItem('4', '打车券有效期30天'),
            _buildRuleItem('5', '无邀请人数上限，多邀多得'),

            const SizedBox(height: 24),

            // 演示按钮
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _simulateInvite,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFFD700),
                  side: const BorderSide(color: Color(0xFFFFD700)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('📱 模拟：好友通过邀请码注册', style: GoogleFonts.poppins(fontSize: 13)),
              ),
            ),

            const SizedBox(height: 16),
            Text('（演示功能：模拟邀请成功，查看奖励变化）', style: GoogleFonts.poppins(color: Colors.white38, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildRuleItem(String step, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(color: const Color(0xFFFFD700).withOpacity(0.15), borderRadius: BorderRadius.circular(11)),
            child: Center(child: Text(step, style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.w700))),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12))),
        ],
      ),
    );
  }
}
