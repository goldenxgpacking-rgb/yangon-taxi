import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'l10n/app_localizations.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/home_screen.dart';
import 'screens/destination_screen.dart';
import 'screens/vehicle_selection_screen.dart';
import 'screens/ride_confirmation_screen.dart';
import 'screens/waiting_driver_screen.dart';
import 'screens/ride_in_progress_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/rating_screen.dart';
import 'screens/trip_history_screen.dart';
import 'screens/trip_detail_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/referral_screen.dart';
import 'screens/kbz_pay_screen.dart';
import 'screens/tier_detail_screen.dart';

void main() {
  runApp(const YangonTaxiApp());
}

class YangonTaxiApp extends StatelessWidget {
  const YangonTaxiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yangon Taxi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFFFD700),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFD700),
          primary: const Color(0xFFFFD700),
          secondary: const Color(0xFF1A1A2E),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
      // 多语言支持
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'CN'),
        Locale('en'),
        Locale('my'),
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) return const Locale('zh', 'CN');
        // 缅甸语
        if (locale.languageCode == 'my') return const Locale('my');
        // 英语
        if (locale.languageCode == 'en') return const Locale('en');
        // 默认中文
        return const Locale('zh', 'CN');
      },
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/otp': (context) => const OTPScreen(phoneNumber: '', isRegistration: false),
        '/home': (context) => const HomeScreen(),
        '/destination': (context) => const DestinationScreen(),
        '/trip_history': (context) => const TripHistoryScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/referral': (context) => const ReferralScreen(),
        '/kbz_pay': (context) => const KBZPayScreen(),
        '/tier_detail': (context) => const TierDetailScreen(),
      },
    );
  }
}
