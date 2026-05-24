import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'trip_history_screen.dart';
import 'saved_addresses_screen.dart';
import 'login_screen.dart';
import '../services/trip_storage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = '游客用户';
  String _userPhone = '+95 900000000';
  String _userEmail = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profile = await TripStorage.getUserProfile();
    final name = prefs.getString('user_name') ?? profile['name'] ?? '';
    final phone = prefs.getString('user_phone') ?? profile['phone'] ?? '';
    final email = prefs.getString('user_email') ?? profile['email'] ?? '';
    setState(() {
      _userName = name.isNotEmpty ? name : '游客用户';
      _userPhone = phone.isNotEmpty ? phone : '+95 900000000';
      _userEmail = email;
      _isLoading = false;
    });
  }

  Future<void> _showEditProfile() async {
    final nameController = TextEditingController(text: _userName == '游客用户' ? '' : _userName);
    final emailController = TextEditingController(text: _userEmail);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text('编辑资料', style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: '姓名',
                labelStyle: GoogleFonts.poppins(color: Colors.white54),
                hintText: '输入你的姓名',
                hintStyle: GoogleFonts.poppins(color: Colors.white38),
                prefixIcon: const Icon(Icons.person, color: Color(0xFFFFD700), size: 20),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: const Color(0xFFFFD700).withOpacity(0.3))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFFD700))),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: '邮箱（可选）',
                labelStyle: GoogleFonts.poppins(color: Colors.white54),
                hintText: '输入你的邮箱',
                hintStyle: GoogleFonts.poppins(color: Colors.white38),
                prefixIcon: const Icon(Icons.email, color: Color(0xFFFFD700), size: 20),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: const Color(0xFFFFD700).withOpacity(0.3))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFFD700))),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('取消', style: GoogleFonts.poppins(color: Colors.white54))),
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final email = emailController.text.trim();
              await TripStorage.saveUserProfile({'name': name, 'phone': _userPhone, 'email': email});
              final prefs = await SharedPreferences.getInstance();
              if (name.isNotEmpty) await prefs.setString('user_name', name);
              if (email.isNotEmpty) await prefs.setString('user_email', email);
              Navigator.pop(context);
              _loadProfile();
            },
            child: Text('保存', style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    nameController.dispose();
    emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(backgroundColor: const Color(0xFF1A1A2E), body: const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700))));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        title: Text('个人中心', style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 用户信息卡片
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [const Color(0xFFFFD700).withOpacity(0.15), Colors.white.withOpacity(0.05)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(color: const Color(0xFFFFD700).withOpacity(0.1), borderRadius: BorderRadius.circular(30), border: Border.all(color: const Color(0xFFFFD700), width: 2)),
                    child: Text(_userName.isNotEmpty && _userName != '游客用户' ? _userName[0].toUpperCase() : '?', style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontSize: 24, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_userName, style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(_userPhone, style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
                        if (_userEmail.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(_userEmail, style: GoogleFonts.poppins(color: Colors.white38, fontSize: 11)),
                        ],
                      ],
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.edit, color: Color(0xFFFFD700)), onPressed: _showEditProfile),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildMenuItem(context, icon: Icons.history, title: '行程历史', subtitle: '查看过去的行程记录', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TripHistoryScreen()))),
            _buildMenuItem(context, icon: Icons.location_on, title: '常用地址', subtitle: '设置家和公司地址', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SavedAddressesScreen()))),
            _buildMenuItem(context, icon: Icons.payment, title: '支付管理', subtitle: '管理支付方式和账单', onTap: () => _showComingSoon('支付管理')),
            _buildMenuItem(context, icon: Icons.local_offer, title: '优惠券', subtitle: '查看可用优惠券', onTap: () => _showComingSoon('优惠券')),
            _buildMenuItem(context, icon: Icons.notifications, title: '消息通知', subtitle: '行程通知、优惠信息', onTap: () => _showComingSoon('消息通知')),
            _buildMenuItem(context, icon: Icons.shield, title: '安全中心', subtitle: '紧急联系人、行程分享', onTap: () => _showComingSoon('安全中心')),
            _buildMenuItem(context, icon: Icons.settings, title: '设置', subtitle: '隐私设置、通知设置', onTap: () => _showComingSoon('设置')),
            _buildMenuItem(context, icon: Icons.help, title: '帮助中心', subtitle: '常见问题、联系客服', onTap: () => _showComingSoon('帮助中心')),
            _buildMenuItem(context, icon: Icons.info, title: '关于我们', subtitle: '版本 1.0.0 · Yangon Taxi', onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Yangon Taxi',
                applicationVersion: '1.0.0',
                applicationIcon: Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFFFFD700).withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.local_taxi, color: Color(0xFFFFD700), size: 32)),
                children: [Text('Yangon Taxi — 仰光最便捷的打车应用', style: GoogleFonts.poppins(color: Colors.white54))],
              );
            }),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text('退出登录', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFFFFD700).withOpacity(0.1), borderRadius: BorderRadius.circular(18)), child: Icon(icon, color: const Color(0xFFFFD700), size: 18)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)), const SizedBox(height: 2), Text(subtitle, style: GoogleFonts.poppins(color: Colors.white38, fontSize: 10))])),
            const Icon(Icons.chevron_right, color: Colors.white38, size: 16),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$feature 即将上线，敬请期待！', style: GoogleFonts.poppins()), backgroundColor: const Color(0xFF1A1A2E), behavior: SnackBarBehavior.floating));
  }
}
