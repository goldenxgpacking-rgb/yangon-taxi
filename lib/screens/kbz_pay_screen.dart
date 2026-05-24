import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../l10n/app_localizations.dart';
import '../services/kbz_pay_deeplink_service.dart';
import '../services/kbz_pay_api_service.dart';

/// KBZ Pay 支付与账户管理页面
/// 支持：绑定账号、QR 码支付、Deep Link 调起、交易记录
class KBZPayScreen extends StatefulWidget {
  final int amount;
  final String? tripId;
  final String? callbackRoute; // 支付完成后跳转的路由

  const KBZPayScreen({
    super.key,
    this.amount = 0,
    this.tripId,
    this.callbackRoute,
  });

  @override
  State<KBZPayScreen> createState() => _KBZPayScreenState();
}

class _KBZPayScreenState extends State<KBZPayScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 账户状态
  bool _isLinked = false;
  String _kbzPhone = '';
  double _balance = 0;

  // 支付状态
  bool _isPaying = false;
  String? _currentQRData;
  String? _currentQRId;
  String? _paymentOrderId;
  Timer? _pollTimer;
  int _pollCount = 0;

  // 交易记录
  bool _isLoadingTransactions = false;
  List<KBZTransaction> _transactions = [];
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadKBZData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadKBZData() async {
    final prefs = await SharedPreferences.getInstance();
    final balance = prefs.getDouble('kbz_balance') ?? 50000.0;
    setState(() {
      _isLinked = prefs.getBool('kbz_linked') ?? false;
      _kbzPhone = prefs.getString('kbz_phone') ?? '';
      _balance = balance;
      _isLoadingHistory = false;
    });
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoadingTransactions = true);
    // 尝试从 API 获取真实交易记录
    final txList = await KBZPayApiService.getTransactionHistory(limit: 20);
    if (mounted) {
      setState(() {
        _transactions = txList.isEmpty ? _getMockTransactions() : txList;
        _isLoadingTransactions = false;
      });
    }
  }

  List<KBZTransaction> _getMockTransactions() {
    return [
      KBZTransaction(
        transactionId: 'KBZ${DateTime.now().millisecondsSinceEpoch - 86400000}',
        orderId: 'TRIP_20240524_001',
        amount: widget.amount > 0 ? widget.amount.toDouble() : 2500,
        status: KBZPaymentState.paid,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        paidAt: DateTime.now().subtract(const Duration(hours: 2)),
        description: 'Yangon Taxi - Ride payment',
      ),
      KBZTransaction(
        transactionId: 'KBZ${DateTime.now().millisecondsSinceEpoch - 172800000}',
        orderId: 'TRIP_20240523_002',
        amount: 1800,
        status: KBZPaymentState.paid,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        paidAt: DateTime.now().subtract(const Duration(days: 1)),
        description: 'Yangon Taxi - Ride payment',
      ),
      KBZTransaction(
        transactionId: 'KBZ${DateTime.now().millisecondsSinceEpoch - 259200000}',
        orderId: 'TRIP_20240522_003',
        amount: 3200,
        status: KBZPaymentState.paid,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        paidAt: DateTime.now().subtract(const Duration(days: 2)),
        description: 'Yangon Taxi - Ride payment',
      ),
    ];
  }

  // ============== 绑定账号 ==============

  Future<void> _linkKBZAccount() async {
    final l = AppLocalizations.of(context);
    final phoneController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l.kbzLinkAccount,
          style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your KBZ Pay registered phone number',
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: '09XXXXXXXXX',
                hintStyle: GoogleFonts.poppins(color: Colors.white38),
                prefixIcon: const Icon(Icons.phone, color: Color(0xFFFFD700), size: 18),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFFFD700)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.orange, size: 14),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Demo mode: Any phone number works',
                      style: GoogleFonts.poppins(color: Colors.orange, fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.cancel, style: GoogleFonts.poppins(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              if (phoneController.text.trim().isNotEmpty &&
                  phoneController.text.trim().length >= 9) {
                Navigator.pop(ctx, true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
            ),
            child: Text(l.confirm, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (result == true) {
      final phone = phoneController.text.trim();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('kbz_linked', true);
      await prefs.setString('kbz_phone', phone);
      setState(() {
        _isLinked = true;
        _kbzPhone = phone;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('KBZ Pay $phone ${l.kbzLinked}',
              style: GoogleFonts.poppins()),
          backgroundColor: const Color(0xFF1A1A2E),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    phoneController.dispose();
  }

  Future<void> _unlinkKBZ() async {
    final l = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l.kbzUnlink, style: GoogleFonts.poppins(color: Colors.red)),
        content: Text(
          l.kbzUnlinkConfirm,
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.cancel, style: GoogleFonts.poppins(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.unlink, style: GoogleFonts.poppins(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('kbz_linked', false);
      await prefs.remove('kbz_phone');
      setState(() {
        _isLinked = false;
        _kbzPhone = '';
      });
    }
  }

  // ============== QR 码支付 ==============

  Future<void> _generateQRCode() async {
    final l = AppLocalizations.of(context);
    setState(() => _isPaying = true);

    final orderId = 'YANGON_TAXI_${DateTime.now().millisecondsSinceEpoch}';

    final result = await KBZPayApiService.generateQRCode(
      amount: widget.amount.toDouble(),
      orderId: orderId,
      description: 'Yangon Taxi Ride Payment',
    );

    if (mounted) {
      if (result.success || result.qrData != null) {
        setState(() {
          _currentQRData = result.qrData;
          _currentQRId = result.qrId;
          _paymentOrderId = orderId;
          _isPaying = false;
        });
        // 开始轮询支付状态
        if (!result.isMockData) {
          _startPaymentPolling(orderId);
        }
      } else {
        setState(() => _isPaying = false);
        _showError(l.kbzQRGenerateFailed, result.errorMessage ?? '');
      }
    }
  }

  void _startPaymentPolling(String orderId) {
    _pollTimer?.cancel();
    _pollCount = 0;
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      _pollCount++;
      if (_pollCount > 40) {
        // 2 分钟后超时
        timer.cancel();
        if (mounted) _showTimeout();
        return;
      }
      final status = await KBZPayApiService.checkPaymentStatus(orderId);
      if (!mounted) return;
      if (status.isPaid) {
        timer.cancel();
        _onPaymentSuccess(status.transactionId);
      } else if (status.isFailed) {
        timer.cancel();
        _showError(AppLocalizations.of(context).kbzPaymentFailed, status.errorMessage ?? '');
      }
    });
  }

  void _onPaymentSuccess(String transactionId) {
    final l = AppLocalizations.of(context);
    // 更新余额
    final newBalance = _balance - widget.amount;
    _saveBalance(newBalance);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 40),
            ),
            const SizedBox(height: 16),
            Text(l.kbzPaymentSuccess,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              'Transaction ID: $transactionId',
              style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11),
            ),
            const SizedBox(height: 4),
            Text(
              'Amount: ${widget.amount} K',
              style: GoogleFonts.poppins(color: Color(0xFFFFD700), fontSize: 13),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context, {'success': true, 'transactionId': transactionId});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
            ),
            child: Text('OK', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showError(String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title: $message', style: GoogleFonts.poppins(fontSize: 12)),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showTimeout() {
    final l = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l.kbzPaymentTimeout, style: GoogleFonts.poppins(fontSize: 12)),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _saveBalance(double balance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('kbz_balance', balance);
    if (mounted) setState(() => _balance = balance);
  }

  // ============== Deep Link 支付 ==============

  Future<void> _payViaDeepLink() async {
    final l = AppLocalizations.of(context);
    final orderId = 'YANGON_TAXI_${DateTime.now().millisecondsSinceEpoch}';

    setState(() => _isPaying = true);

    final result = await KBZPayDeeplinkService.launchKBZPay(
      amount: widget.amount.toDouble(),
      orderId: orderId,
    );

    if (mounted) {
      setState(() => _isPaying = false);

      if (result.success) {
        _paymentOrderId = orderId;
        // KBZ Pay 已打开，开始轮询支付结果
        _startPaymentPolling(orderId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l.kbzPaying, style: GoogleFonts.poppins()),
            backgroundColor: const Color(0xFF1A1A2E),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      } else if (result.canInstall) {
        _showInstallPrompt();
      } else {
        _showError(l.kbzPayFailed, result.errorMessage ?? '');
      }
    }
  }

  void _showInstallPrompt() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Install KBZ Pay', style: GoogleFonts.poppins(color: const Color(0xFFFFD700))),
        content: Text(
          'KBZ Pay is not installed. Download it to pay directly from your KBZ Pay account.',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              KBZPayDeeplinkService.openKBZPayDownloadPage();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
            ),
            child: Text('Download', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ============== UI 构建 ==============

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

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
          l.kbzPay,
          style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontWeight: FontWeight.w600),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFFD700),
          labelColor: const Color(0xFFFFD700),
          unselectedLabelColor: Colors.white54,
          labelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
          tabs: [
            Tab(text: l.payment),
            Tab(text: l.transactions),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPaymentTab(l),
          _buildTransactionTab(l),
        ],
      ),
    );
  }

  Widget _buildPaymentTab(AppLocalizations l) {
    if (!_isLinked) {
      return _buildUnlinkedState(l);
    }

    if (_currentQRData != null && widget.amount > 0) {
      return _buildQRPaymentState(l);
    }

    return _buildLinkedState(l);
  }

  Widget _buildUnlinkedState(AppLocalizations l) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.account_balance_wallet, size: 40, color: Color(0xFFFFD700)),
            ),
            const SizedBox(height: 24),
            Text(l.kbzNotLinked, style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              l.kbzNotLinkedDesc,
              style: GoogleFonts.poppins(color: Colors.white54, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _linkKBZAccount,
                icon: const Icon(Icons.link, color: Colors.black),
                label: Text(l.kbzLinkAccount, style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildInfoCard(l),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkedState(AppLocalizations l) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KBZ Pay 头部卡片
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('KBZ Pay', style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                          Text(
                            _kbzPhone.isNotEmpty ? '****${_kbzPhone.substring(_kbzPhone.length > 4 ? _kbzPhone.length - 4 : 0)}' : '',
                            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('Linked', style: GoogleFonts.poppins(color: Colors.white, fontSize: 10)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(l.balance, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11)),
                      const SizedBox(height: 4),
                      Text(
                        '${_balance.toStringAsFixed(0)} K',
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 金额显示
          if (widget.amount > 0) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Column(
                children: [
                  Text(l.tripFare, style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.amount} K',
                    style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontSize: 36, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 支付方式选择
            Text(l.choosePaymentMethod, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),

            // QR 码支付
            _buildPaymentMethod(
              icon: Icons.qr_code_2,
              title: l.kbzQRCodePay,
              subtitle: l.kbzQRCodePayDesc,
              onTap: _isPaying ? null : _generateQRCode,
              isLoading: _isPaying,
            ),
            const SizedBox(height: 12),

            // App 内支付 (Deep Link)
            _buildPaymentMethod(
              icon: Icons.open_in_new,
              title: l.kbzAppPay,
              subtitle: l.kbzAppPayDesc,
              onTap: _isPaying ? null : _payViaDeepLink,
              isLoading: _isPaying,
            ),

            const SizedBox(height: 24),
          ],

          // 解绑按钮
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _unlinkKBZ,
              icon: const Icon(Icons.link_off, size: 16),
              label: Text(l.kbzUnlink, style: GoogleFonts.poppins(fontSize: 13)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          const SizedBox(height: 24),
          _buildInfoCard(l),
        ],
      ),
    );
  }

  Widget _buildQRPaymentState(AppLocalizations l) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(l.scanToPay, style: GoogleFonts.poppins(color: Colors.black54, fontSize: 12)),
                const SizedBox(height: 12),
                QrImageView(
                  data: _currentQRData ?? '',
                  version: QrVersions.auto,
                  size: 220,
                  backgroundColor: Colors.white,
                  errorCorrectionLevel: QrErrorCorrectLevel.M,
                ),
                const SizedBox(height: 12),
                Text(
                  '${widget.amount} K',
                  style: GoogleFonts.poppins(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(Icons.info_outline, color: Color(0xFFFFD700), size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.kbzQRPaymentInstructions,
                              style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          Text(
                            '1. Open KBZ Pay app\n2. Tap "Scan QR"\n3. Scan the QR code above\n4. Confirm payment',
                            style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (_pollCount > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFFD700)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Waiting for payment... (${_pollCount * 3}s)',
                    style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                _pollTimer?.cancel();
                setState(() {
                  _currentQRData = null;
                  _currentQRId = null;
                  _pollCount = 0;
                });
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white54,
                side: const BorderSide(color: Colors.white24),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(l.cancel, style: GoogleFonts.poppins()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFFD700)),
                      )
                    : Icon(icon, color: const Color(0xFFFFD700), size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: GoogleFonts.poppins(color: Colors.white38, fontSize: 11)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionTab(AppLocalizations l) {
    if (_isLoadingHistory) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)));
    }

    if (_transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long, color: Colors.white24, size: 48),
            const SizedBox(height: 16),
            Text(l.noTransactions, style: GoogleFonts.poppins(color: Colors.white38, fontSize: 14)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTransactions,
      color: const Color(0xFFFFD700),
      backgroundColor: const Color(0xFF2A2A3E),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _transactions.length,
        itemBuilder: (context, i) {
          final tx = _transactions[i];
          final isPaid = tx.status == KBZPaymentState.paid;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: isPaid
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    isPaid ? Icons.check_circle : Icons.pending,
                    color: isPaid ? Colors.green : Colors.orange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.description ?? 'KBZ Pay Payment',
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tx.transactionId,
                        style: GoogleFonts.poppins(color: Colors.white38, fontSize: 10),
                      ),
                      Text(
                        _formatDate(tx.paidAt ?? tx.createdAt),
                        style: GoogleFonts.poppins(color: Colors.white38, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '-${tx.amount.toStringAsFixed(0)} K',
                      style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isPaid ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isPaid ? 'PAID' : 'PENDING',
                        style: GoogleFonts.poppins(
                          color: isPaid ? Colors.green : Colors.orange,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(AppLocalizations l) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Color(0xFFFFD700), size: 16),
              const SizedBox(width: 8),
              Text(l.aboutKBZPay, style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '• KBZ Pay is Myanmar\'s leading mobile payment\n'
            '• Bind once, pay instantly every ride\n'
            '• Secured by KBZ Bank\n'
            '• Current: Demo mode (no real charges)\n'
            '• Real API: Contact KBZ Bank for merchant account',
            style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11, height: 1.6),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
