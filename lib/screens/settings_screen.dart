import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  String _language = '简体中文';
  bool _isLoading = true;

  final List<String> _languages = ['简体中文', 'English', 'မြန်မာ (Burmese)'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notif_enabled') ?? true;
      _soundEnabled = prefs.getBool('notif_sound') ?? true;
      _vibrationEnabled = prefs.getBool('notif_vibrate') ?? true;
      _language = prefs.getString('app_language') ?? '简体中文';
      _isLoading = false;
    });
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _saveLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', lang);
    setState(() => _language = lang);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('语言已切换为 $lang，重启应用后生效', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFF1A1A2E),
        behavior: SnackBarBehavior.floating,
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
        title: Text('设置', style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontWeight: FontWeight.w600)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 通知设置
          _sectionTitle('通知设置'),
          _buildSwitchTile(
            icon: Icons.notifications_active,
            title: '推送通知',
            subtitle: '行程状态、优惠活动通知',
            value: _notificationsEnabled,
            onChanged: (v) {
              setState(() => _notificationsEnabled = v);
              _saveBool('notif_enabled', v);
            },
          ),
          _buildSwitchTile(
            icon: Icons.volume_up,
            title: '提示音',
            subtitle: '新消息提示音',
            value: _soundEnabled,
            onChanged: _notificationsEnabled
                ? (v) {
                    setState(() => _soundEnabled = v);
                    _saveBool('notif_sound', v);
                  }
                : null,
          ),
          _buildSwitchTile(
            icon: Icons.vibration,
            title: '震动提醒',
            subtitle: '新消息震动提醒',
            value: _vibrationEnabled,
            onChanged: _notificationsEnabled
                ? (v) {
                    setState(() => _vibrationEnabled = v);
                    _saveBool('notif_vibrate', v);
                  }
                : null,
          ),

          const SizedBox(height: 24),

          // 语言设置
          _sectionTitle('语言设置'),
          ListTile(
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: const Color(0xFFFFD700).withOpacity(0.1), borderRadius: BorderRadius.circular(18)),
              child: const Icon(Icons.language, color: Color(0xFFFFD700), size: 18),
            ),
            title: Text('应用语言', style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
            subtitle: Text(_language, style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white38, size: 16),
            onTap: () async {
              final result = await showDialog<String>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF2A2A3E),
                  title: Text('选择语言', style: GoogleFonts.poppins(color: const Color(0xFFFFD700))),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _languages
                        .map((lang) => RadioListTile<String>(
                              title: Text(lang, style: GoogleFonts.poppins(color: Colors.white, fontSize: 13)),
                              value: lang,
                              groupValue: _language,
                              activeColor: const Color(0xFFFFD700),
                              onChanged: (v) => Navigator.pop(context, v),
                            ))
                        .toList(),
                  ),
                ),
              );
              if (result != null) await _saveLanguage(result);
            },
          ),

          const SizedBox(height: 24),

          // 隐私设置
          _sectionTitle('隐私设置'),
          ListTile(
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: const Color(0xFFFFD700).withOpacity(0.1), borderRadius: BorderRadius.circular(18)),
              child: const Icon(Icons.lock, color: Color(0xFFFFD700), size: 18),
            ),
            title: Text('隐私政策', style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white38, size: 16),
            onTap: () => _showPrivacyDialog(),
          ),
          ListTile(
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: const Color(0xFFFFD700).withOpacity(0.1), borderRadius: BorderRadius.circular(18)),
              child: const Icon(Icons.description, color: Color(0xFFFFD700), size: 18),
            ),
            title: Text('用户协议', style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white38, size: 16),
            onTap: () => _showTermsDialog(),
          ),
          SwitchListTile(
            secondary: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: const Color(0xFFFFD700).withOpacity(0.1), borderRadius: BorderRadius.circular(18)),
              child: const Icon(Icons.location_on, color: Color(0xFFFFD700), size: 18),
            ),
            title: Text('行程分享默认开启', style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
            subtitle: Text('叫车时默认分享行程给紧急联系人', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11)),
            value: true,
            activeColor: const Color(0xFFFFD700),
            onChanged: (v) {},
          ),

          const SizedBox(height: 24),

          // 其他
          _sectionTitle('其他'),
          ListTile(
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: const Color(0xFFFFD700).withOpacity(0.1), borderRadius: BorderRadius.circular(18)),
              child: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
            ),
            title: Text('清除缓存', style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
            subtitle: Text('清除本地缓存数据', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white38, size: 16),
            onTap: () => _clearCache(),
          ),
          ListTile(
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: const Color(0xFFFFD700).withOpacity(0.1), borderRadius: BorderRadius.circular(18)),
              child: const Icon(Icons.info, color: Color(0xFFFFD700), size: 18),
            ),
            title: Text('关于 Yangon Taxi', style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
            subtitle: Text('版本 1.0.0', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white38, size: 16),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'Yangon Taxi',
              applicationVersion: '1.0.0',
              applicationIcon: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: const Color(0xFFFFD700).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.local_taxi, color: Color(0xFFFFD700), size: 32),
              ),
              children: [Text('仰光最便捷的打车应用', style: GoogleFonts.poppins(color: Colors.white54))],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(title, style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontSize: 13, fontWeight: FontWeight.w600)),
      );

  Widget _buildSwitchTile({required IconData icon, required String title, required String subtitle, required bool value, required void Function(bool)? onChanged}) {
    return SwitchListTile(
      secondary: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: const Color(0xFFFFD700).withOpacity(0.1), borderRadius: BorderRadius.circular(18)),
        child: Icon(icon, color: const Color(0xFFFFD700), size: 18),
      ),
      title: Text(title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
      subtitle: Text(subtitle, style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11)),
      value: value,
      activeColor: const Color(0xFFFFD700),
      onChanged: onChanged,
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        title: Text('隐私政策', style: GoogleFonts.poppins(color: const Color(0xFFFFD700))),
        content: Text(
          'Yangon Taxi 重视您的隐私保护。\n\n我们收集的信息仅用于提供打车服务，包括：\n• 位置信息（用于叫车和路线规划）\n• 联系人信息（用于注册和紧急联系）\n• 行程记录（用于历史查询和费用计算）\n\n我们不会将您的信息出售给第三方。',
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('关闭', style: GoogleFonts.poppins(color: const Color(0xFFFFD700))))],
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        title: Text('用户协议', style: GoogleFonts.poppins(color: const Color(0xFFFFD700))),
        content: Text(
          '使用 Yangon Taxi 服务即表示您同意以下条款：\n\n1. 您须提供真实有效的个人信息\n2. 禁止利用本平台从事违法活动\n3. 行程费用以平台显示为准\n4. 如遇纠纷，双方应友好协商解决\n5. 平台有权对违规行为进行处罚',
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('关闭', style: GoogleFonts.poppins(color: const Color(0xFFFFD700))))],
      ),
    );
  }

  Future<void> _clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cached_data');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('缓存已清除', style: GoogleFonts.poppins()), backgroundColor: const Color(0xFF1A1A2E), behavior: SnackBarBehavior.floating),
    );
  }
}
