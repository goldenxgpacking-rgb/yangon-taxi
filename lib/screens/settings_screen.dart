import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      _isLoading = false;
    });
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
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
        title: Text(l.settings, style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontWeight: FontWeight.w600)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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

          // 语言切换
          _sectionTitle(l.langSettings),
          Consumer<LocaleProvider>(
            builder: (context, provider, _) {
              return ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: const Color(0xFFFFD700).withOpacity(0.1), borderRadius: BorderRadius.circular(18)),
                  child: const Icon(Icons.language, color: Color(0xFFFFD700), size: 18),
                ),
                title: Text(l.appLanguage, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
                subtitle: Text(provider.displayName, style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.w500)),
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

          _sectionTitle(l.privacyPolicy),
          ListTile(
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: const Color(0xFFFFD700).withOpacity(0.1), borderRadius: BorderRadius.circular(18)),
              child: const Icon(Icons.lock, color: Color(0xFFFFD700), size: 18),
            ),
            title: Text(l.privacyPolicy, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white38, size: 16),
            onTap: () => _showDialog(context, l.privacyPolicy,
                'Yangon Taxi ${l.privacyPolicy.toLowerCase()}\n\n• ${l.phoneNumber} info for ride matching\n• Location data for routing\n• Trip records for history'),
          ),
          ListTile(
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: const Color(0xFFFFD700).withOpacity(0.1), borderRadius: BorderRadius.circular(18)),
              child: const Icon(Icons.description, color: Color(0xFFFFD700), size: 18),
            ),
            title: Text(l.termsOfService, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white38, size: 16),
            onTap: () => _showDialog(context, l.termsOfService,
                '${l.termsOfService}\n\n1. Provide accurate information\n2. No illegal activities\n3. Fare as shown on platform\n4. Resolve disputes amicably\n5. Platform may penalize violations'),
          ),

          const SizedBox(height: 24),

          _sectionTitle(l.other),
          ListTile(
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(18)),
              child: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
            ),
            title: Text(l.clearCache, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
            subtitle: Text(l.clearCacheDesc, style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white38, size: 16),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('cached_data');
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l.cacheCleared, style: GoogleFonts.poppins()), backgroundColor: const Color(0xFF1A1A2E), behavior: SnackBarBehavior.floating),
              );
            },
          ),
          ListTile(
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: const Color(0xFFFFD700).withOpacity(0.1), borderRadius: BorderRadius.circular(18)),
              child: const Icon(Icons.info, color: Color(0xFFFFD700), size: 18),
            ),
            title: Text(l.aboutApp, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
            subtitle: Text(l.version, style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11)),
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
              children: [
                Text('Yangon Taxi - ${l.searchDestination}', style: GoogleFonts.poppins(color: Colors.white54)),
              ],
            ),
          ),
        ],
      ),
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

  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        title: Text(title, style: GoogleFonts.poppins(color: const Color(0xFFFFD700))),
        content: Text(content, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context).close, style: GoogleFonts.poppins(color: const Color(0xFFFFD700)))),
        ],
      ),
    );
  }
}
