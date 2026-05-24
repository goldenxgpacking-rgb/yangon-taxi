import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _isLoading = true;
  bool _isCheckingUpdate = false;
  String _appVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() => _appVersion = info.version);
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notif_enabled') ?? true;
      _soundEnabled = prefs.getBool('notif_sound') ?? true;
      _vibrationEnabled = prefs.getBool('notif_vibrate') ?? true;
      _isLoading = false;
    });
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _checkForUpdate() async {
    if (_isCheckingUpdate) return;
    setState(() => _isCheckingUpdate = true);

    final l = AppLocalizations.of(context);

    // 模拟版本检查延迟
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _isCheckingUpdate = false);

    // 演示：始终显示"已是最新版本"（真实场景可对接 API）
    _showSnackBar(l.latestVersion, Icons.check_circle, const Color(0xFF4CAF50));
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showSnackBar(String message, IconData icon, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(message, style: GoogleFonts.poppins())),
          ],
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
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
        title: Text(
          l.settings,
          style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ========== 通知设置 ==========
          _sectionTitle(l.notifSettings),
          _buildSwitchTile(
            icon: Icons.notifications_active,
            title: l.pushNotif,
            subtitle: l.pushNotifDesc,
            value: _notificationsEnabled,
            onChanged: (v) {
              setState(() => _notificationsEnabled = v);
              _saveBool('notif_enabled', v);
            },
          ),
          _buildSwitchTile(
            icon: Icons.volume_up,
            title: l.soundNotif,
            subtitle: l.soundNotifDesc,
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
            title: l.vibrateNotif,
            subtitle: l.vibrateNotifDesc,
            value: _vibrationEnabled,
            onChanged: _notificationsEnabled
                ? (v) {
                    setState(() => _vibrationEnabled = v);
                    _saveBool('notif_vibrate', v);
                  }
                : null,
          ),

          const SizedBox(height: 24),

          // ========== 语言设置 ==========
          _sectionTitle(l.langSettings),
          Consumer<LocaleProvider>(
            builder: (context, provider, _) {
              return ListTile(
                leading: _iconBox(Icons.language, Icons.language),
                title: Text(l.appLanguage, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
                subtitle: Text(
                  provider.displayName,
                  style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.w500),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.white38, size: 16),
                onTap: () async {
                  final result = await showDialog<int>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: const Color(0xFF2A2A3E),
                      title: Text(l.selectLanguage, style: GoogleFonts.poppins(color: const Color(0xFFFFD700))),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _langOption(ctx, '简体中文', '🇨🇳', 0, provider),
                          _langOption(ctx, 'English', '🇬🇧', 1, provider),
                          _langOption(ctx, 'မြန်မာ (Burmese)', '🇲🇲', 2, provider),
                        ],
                      ),
                    ),
                  );
                  if (result != null) {
                    await provider.setLocale(provider.getLocaleByIndex(result));
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l.langChanged, style: GoogleFonts.poppins()),
                        backgroundColor: const Color(0xFF1A1A2E),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              );
            },
          ),

          const SizedBox(height: 24),

          // ========== 版本与更新 ==========
          _sectionTitle(l.checkUpdate),
          ListTile(
            leading: _iconBox(Icons.system_update, Icons.system_update),
            title: Text(l.checkUpdate, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
            subtitle: Text('v$_appVersion', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11)),
            trailing: _isCheckingUpdate
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFFD700)),
                  )
                : const Icon(Icons.chevron_right, color: Colors.white38, size: 16),
            onTap: _isCheckingUpdate ? null : _checkForUpdate,
          ),

          const SizedBox(height: 24),

          // ========== 帮助与支持 ==========
          _sectionTitle(l.helpSupport),
          ListTile(
            leading: _iconBox(Icons.help_outline, Icons.help_outline),
            title: Text(l.helpSupport, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
            subtitle: Text(l.helpSupportDesc, style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white38, size: 16),
            onTap: () => _showHelpDialog(context),
          ),
          ListTile(
            leading: _iconBox(Icons.email_outlined, Icons.email_outlined),
            title: Text(l.contactUs, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
            subtitle: Text('support@yangontaxi.com', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white38, size: 16),
            onTap: () => _showContactDialog(context),
          ),

          const SizedBox(height: 24),

          // ========== 隐私与条款 ==========
          _sectionTitle(l.privacyPolicy),
          ListTile(
            leading: _iconBox(Icons.lock, Icons.lock),
            title: Text(l.privacyPolicy, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white38, size: 16),
            onTap: () => _showDialog(
              context,
              l.privacyPolicy,
              '${l.privacyPolicy}\n\n'
              '• ${l.phoneNumber} info for ride matching\n'
              '• Location data for routing\n'
              '• Trip records for history\n'
              '• Secure data encryption\n'
              '• No third-party data sharing',
            ),
          ),
          ListTile(
            leading: _iconBox(Icons.description, Icons.description),
            title: Text(l.termsOfService, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white38, size: 16),
            onTap: () => _showDialog(
              context,
              l.termsOfService,
              '${l.termsOfService}\n\n'
              '1. Provide accurate information\n'
              '2. No illegal activities\n'
              '3. Fare as shown on platform\n'
              '4. Resolve disputes amicably\n'
              '5. Platform may penalize violations',
            ),
          ),

          const SizedBox(height: 24),

          // ========== 其他 ==========
          _sectionTitle(l.other),
          ListTile(
            leading: _iconBox(Icons.delete_outline, Icons.delete_outline, color: Colors.red),
            title: Text(l.clearCache, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
            subtitle: Text(l.clearCacheDesc, style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white38, size: 16),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (!mounted) return;
              _showSnackBar(l.cacheCleared, Icons.check_circle, const Color(0xFF4CAF50));
            },
          ),
          ListTile(
            leading: _iconBox(Icons.info_outline, Icons.info_outline),
            title: Text(l.aboutApp, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
            subtitle: Text('${l.version} $_appVersion', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white38, size: 16),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'Yangon Taxi',
              applicationVersion: _appVersion,
              applicationIcon: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.local_taxi, color: Color(0xFFFFD700), size: 32),
              ),
              children: [
                Text(
                  'Yangon Taxi - ${l.searchDestination}',
                  style: GoogleFonts.poppins(color: Colors.white54),
                ),
                const SizedBox(height: 8),
                Text(
                  '© 2026 Yangon Taxi. All rights reserved.',
                  style: GoogleFonts.poppins(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _iconBox(IconData activeIcon, IconData _unusedIcon, {Color? color}) {
    final iconColor = color ?? const Color(0xFFFFD700);
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(iconColor == const Color(0xFFFFD700) ? activeIcon : activeIcon, color: iconColor, size: 18),
    );
  }

  Widget _langOption(BuildContext ctx, String name, String flag, int index, LocaleProvider provider) {
    final isSelected = provider.languageCode == provider.getLocaleByIndex(index).languageCode;
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(name, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
      trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFFFFD700)) : null,
      selected: isSelected,
      onTap: () => Navigator.pop(ctx, index),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          title,
          style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontSize: 13, fontWeight: FontWeight.w600),
        ),
      );

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required void Function(bool)? onChanged,
  }) {
    return SwitchListTile(
      secondary: _iconBox(icon, icon),
      title: Text(title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
      subtitle: Text(subtitle, style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11)),
      value: value,
      activeColor: const Color(0xFFFFD700),
      onChanged: onChanged,
    );
  }

  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        title: Text(title, style: GoogleFonts.poppins(color: const Color(0xFFFFD700))),
        content: Text(content, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).close, style: GoogleFonts.poppins(color: const Color(0xFFFFD700))),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    final l = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        title: Text(l.helpSupport, style: GoogleFonts.poppins(color: const Color(0xFFFFD700))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _faqItem(Icons.question_answer, 'How to book a ride?',
                'Enter your destination, choose a vehicle type, and confirm your ride.'),
            const SizedBox(height: 12),
            _faqItem(Icons.payment, 'Payment methods?',
                'Currently supports Cash and KBZ Pay. More options coming soon.'),
            const SizedBox(height: 12),
            _faqItem(Icons.phone, 'Emergency?',
                'Use the SOS button in the app to call emergency services (999).'),
            const SizedBox(height: 12),
            _faqItem(Icons.cancel, 'Cancel a ride?',
                'You can cancel before a driver is assigned. Repeated cancellations may affect your account.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.close, style: GoogleFonts.poppins(color: const Color(0xFFFFD700))),
          ),
        ],
      ),
    );
  }

  Widget _faqItem(IconData icon, String q, String a) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFFFFD700), size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(q, style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(a, style: GoogleFonts.poppins(color: Colors.white60, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }

  void _showContactDialog(BuildContext context) {
    final l = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        title: Text(l.contactUs, style: GoogleFonts.poppins(color: const Color(0xFFFFD700))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _contactItem(Icons.email, 'Email', 'support@yangontaxi.com', () {
              _launchUrl('mailto:support@yangontaxi.com?subject=Yangon Taxi Support');
            }),
            const Divider(color: Colors.white24),
            _contactItem(Icons.language, 'Website', 'www.yangontaxi.com', () {
              _launchUrl('https://www.yangontaxi.com');
            }),
            const Divider(color: Colors.white24),
            _contactItem(Icons.phone, l.phoneNumber, '+95 9 123 456 789', () {
              _launchUrl('tel:+959123456789');
            }),
            const Divider(color: Colors.white24),
            _contactItem(Icons.location_on, 'Address', 'No.123, Merchant Road, Yangon', null),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.close, style: GoogleFonts.poppins(color: const Color(0xFFFFD700))),
          ),
        ],
      ),
    );
  }

  Widget _contactItem(IconData icon, String label, String value, VoidCallback? onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: const Color(0xFFFFD700), size: 20),
      title: Text(label, style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11)),
      subtitle: Text(
        value,
        style: GoogleFonts.poppins(
          color: onTap != null ? const Color(0xFFFFD700) : Colors.white70,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          decoration: onTap != null ? TextDecoration.underline : null,
        ),
      ),
      onTap: onTap,
    );
  }
}
