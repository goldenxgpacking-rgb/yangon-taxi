import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = '';
  String _phone = '';
  String _email = '';
  int _tierLevel = 0;
  int _points = 0;
  String _avatarPath = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('user_name') ?? '未设置昵称';
      _phone = prefs.getString('user_phone') ?? '';
      _email = prefs.getString('user_email') ?? '';
      _tierLevel = prefs.getInt('user_tier_level') ?? 0;
      _points = prefs.getInt('user_points') ?? 0;
      _avatarPath = prefs.getString('user_avatar') ?? '';
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_avatar', image.path);
      setState(() {
        _avatarPath = image.path;
      });
    }
  }

  String _getTierName() {
    switch (_tierLevel) {
      case 0:
        return '普通用户';
      case 1:
        return '银卡会员';
      case 2:
        return '金卡会员';
      case 3:
        return '铂金会员';
      default:
        return '普通用户';
    }
  }

  Color _getTierColor() {
    switch (_tierLevel) {
      case 0:
        return Colors.grey;
      case 1:
        return Colors.blueGrey;
      case 2:
        return const Color(0xFFFFD700);
      case 3:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Future<void> _editProfile() async {
    final nameController = TextEditingController(text: _name == '未设置昵称' ? '' : _name);
    final emailController = TextEditingController(text: _email);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        title: Text('编辑资料', style: GoogleFonts.poppins(color: const Color(0xFFFFD700))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: GoogleFonts.poppins(color: Colors.white),
              decoration: InputDecoration(
                labelText: '昵称',
                labelStyle: GoogleFonts.poppins(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: const Color(0xFFFFD700))),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              style: GoogleFonts.poppins(color: Colors.white),
              decoration: InputDecoration(
                labelText: '邮箱（选填）',
                labelStyle: GoogleFonts.poppins(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: const Color(0xFFFFD700))),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消', style: GoogleFonts.poppins(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('user_name', nameController.text.trim());
              await prefs.setString('user_email', emailController.text.trim());
              if (!mounted) return;
              Navigator.pop(context);
              _loadUserData();
            },
            child: Text('保存', style: GoogleFonts.poppins(color: const Color(0xFFFFD700))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        title: Text('个人中心', style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFFFFD700)),
            onPressed: _editProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 头像
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFFFFD700),
                backgroundImage: _avatarPath.isNotEmpty ? FileImage(File(_avatarPath)) : null,
                child: _avatarPath.isEmpty
                    ? const Icon(Icons.person, size: 50, color: Color(0xFF1A1A2E))
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            Text(_name, style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(_phone, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
            if (_email.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(_email, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
            ],
            const SizedBox(height: 16),
            // 用户等级卡片
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A3E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getTierColor(), width: 1.5),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('用户等级', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getTierColor().withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(_getTierName(), style: GoogleFonts.poppins(color: _getTierColor(), fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('积分', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
                      Text('$_points 分', style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontSize: 14, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // 菜单项
            _buildMenuItem(Icons.location_on, '常用地址', '/saved_addresses'),
            _buildMenuItem(Icons.card_giftcard, '推荐有礼', '/referral'),
            _buildMenuItem(Icons.star, '会员权益', '/tier_detail'),
            _buildMenuItem(Icons.settings, '设置', '/settings'),
            const SizedBox(height: 20),
            // 退出登录
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // TODO: 退出登录逻辑
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text('退出登录', style: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String routeName) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFFFD700)),
        title: Text(title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 15)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white70),
        onTap: () {
          Navigator.pushNamed(context, routeName);
        },
      ),
    );
  }
}
