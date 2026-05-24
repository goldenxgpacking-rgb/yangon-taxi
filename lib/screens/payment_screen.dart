import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'rating_screen.dart';
import '../l10n/app_localizations.dart';
import '../models/trip.dart';
import '../services/trip_storage.dart';
import '../services/kbz_pay_service.dart';

class PaymentScreen extends StatefulWidget {
  final String pickupAddress;
  final String destinationAddress;
  final String vehicleType;
  final String vehicleName;
  final int price;
  final String currency;
  final String driverName;
  final String driverRating;
  final String vehiclePlate;
  final double? distanceKm;
  final int? durationMin;

  const PaymentScreen({
    super.key,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.vehicleType,
    required this.vehicleName,
    required this.price,
    this.currency = 'K',
    this.driverName = 'U Mya Win',
    this.driverRating = '4.8',
    this.vehiclePlate = 'YUE 123',
    this.distanceKm,
    this.durationMin,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = 'cash';
  bool _isProcessing = false;
  double _kbzBalance = 50000.0;

  @override
  void initState() {
    super.initState();
    _loadKBZBalance();
  }

  Future<void> _loadKBZBalance() async {
    final balance = await KBZPayService.getBalance();
    setState(() => _kbzBalance = balance);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        title: Text(l.payment, style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFD700)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 行程摘要
          _buildTripSummary(l),
          // 支付方式选择
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(l.selectPayment, style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          // 支付方式列表
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildPaymentMethod(l, 'cash', l.cashPayment, Icons.money, Colors.green, l.cashDesc),
                const SizedBox(height: 12),
                _buildPaymentMethod(l, 'kbz_pay', 'KBZ Pay', Icons.account_balance_wallet, Colors.blue, l.kbzDesc),
                if (_selectedPaymentMethod == 'kbz_pay') _buildKBZBalanceCard(l),
              ],
            ),
          ),
          // 确认支付按钮
          _buildPayButton(l),
        ],
      ),
    );
  }

  Widget _buildTripSummary(AppLocalizations l) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(25)),
                child: const Icon(Icons.person, color: Colors.green, size: 30),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.driverName, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Color(0xFFFFD700), size: 14),
                        const SizedBox(width: 4),
                        Text(widget.driverRating, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                        const SizedBox(width: 12),
                        Text(widget.vehiclePlate, style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16), const Divider(color: Colors.white12), const SizedBox(height: 16),
          Row(children: [
            const Icon(Icons.my_location, color: Color(0xFFFFD700), size: 16),
            const SizedBox(width: 12),
            Expanded(child: Text(widget.pickupAddress, style: GoogleFonts.poppins(color: Colors.white, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.location_on, color: Colors.red, size: 16),
            const SizedBox(width: 12),
            Expanded(child: Text(widget.destinationAddress, style: GoogleFonts.poppins(color: Colors.white, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 16), const Divider(color: Colors.white12), const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(l.vehicleTypeLabel, style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
            Text(widget.vehicleName, style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
          ]),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(l.feeLabel, style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
            Text('${widget.currency} ${widget.price}', style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontSize: 18, fontWeight: FontWeight.w700)),
          ]),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(AppLocalizations l, String id, String name, IconData icon, Color color, String desc) {
    final isSelected = _selectedPaymentMethod == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : Colors.white.withOpacity(0.1), width: isSelected ? 2 : 1),
        ),
        child: Row(children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(25)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(desc, style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
          ])),
          if (isSelected) Icon(Icons.check_circle, color: color, size: 24),
        ]),
      ),
    );
  }

  Widget _buildKBZBalanceCard(AppLocalizations l) {
    final hasEnough = _kbzBalance >= widget.price;
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Row(children: [
        const Icon(Icons.account_balance_wallet, color: Colors.blue, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text('${l.balance}: ${_kbzBalance.toStringAsFixed(0)} K', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12))),
        if (!hasEnough)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
            child: Text(l.insufficientBalance, style: GoogleFonts.poppins(color: Colors.red, fontSize: 10)),
          ),
      ]),
    );
  }

  Widget _buildPayButton(AppLocalizations l) {
    final canPay = _selectedPaymentMethod != 'kbz_pay' || _kbzBalance >= widget.price;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: ElevatedButton(
        onPressed: (_isProcessing || !canPay) ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFD700),
          foregroundColor: const Color(0xFF1A1A2E),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 5,
          minimumSize: const Size(double.infinity, 50),
        ),
        child: _isProcessing
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Color(0xFF1A1A2E))))
            : Text(l.confirmPay(widget.currency, widget.price), style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Future<void> _processPayment() async {
    if (_selectedPaymentMethod == 'kbz_pay') {
      await _processKBZPay();
    } else {
      await _processCash();
    }
  }

  Future<void> _processCash() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 1)); // 模拟处理
    setState(() => _isProcessing = false);
    await _saveTripAndNavigate(paymentMethod: 'cash', paymentStatus: 'completed');
  }

  Future<void> _processKBZPay() async {
    // 显示二维码弹窗
    if (!mounted) return;
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _KBZPayDialog(amount: widget.price, currency: widget.currency),
    );
    if (result != null && result['success'] == true) {
      await _loadKBZBalance();
      await _saveTripAndNavigate(
        paymentMethod: 'kbz_pay',
        paymentStatus: 'completed',
        txId: result['transactionId'],
      );
    } else if (result != null && result['success'] == false) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Payment failed'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _saveTripAndNavigate({required String paymentMethod, required String paymentStatus, String? txId}) async {
    final trip = Trip(
      id: Trip.generateId(),
      pickupAddress: widget.pickupAddress,
      destinationAddress: widget.destinationAddress,
      pickupTime: Trip.currentTime(),
      dropoffTime: Trip.currentTime(),
      price: widget.price,
      currency: widget.currency,
      vehicleType: widget.vehicleType,
      vehicleName: widget.vehicleName,
      driverName: widget.driverName,
      driverRating: widget.driverRating,
      vehiclePlate: widget.vehiclePlate,
      status: 'completed',
      distanceKm: widget.distanceKm,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      paymentTransactionId: txId,
    );
    await TripStorage.saveTrip(trip);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => RatingScreen(
          driverName: widget.driverName,
          driverRating: widget.driverRating,
          vehiclePlate: widget.vehiclePlate,
          price: widget.price,
          currency: widget.currency,
          tripId: trip.id,
        ),
      ),
    );
  }
}

// KBZ Pay 二维码支付弹窗
class _KBZPayDialog extends StatefulWidget {
  final int amount;
  final String currency;
  const _KBZPayDialog({required this.amount, required this.currency});

  @override
  State<_KBZPayDialog> createState() => _KBZPayDialogState();
}

class _KBZPayDialogState extends State<_KBZPayDialog> {
  bool _isProcessing = true;
  bool _isSuccess = false;
  String _message = '';
  String _txId = '';

  @override
  void initState() {
    super.initState();
    _startPayment();
  }

  Future<void> _startPayment() async {
    final result = await KBZPayService.processPayment(
      amount: widget.amount.toDouble(),
      tripId: 'TRIP${DateTime.now().millisecondsSinceEpoch}',
    );
    if (!mounted) return;
    setState(() {
      _isProcessing = false;
      _isSuccess = result['success'];
      _message = result['message'];
      _txId = result['transactionId'] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      backgroundColor: const Color(0xFF2A2A3E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isProcessing) ...[
            const SizedBox(height: 16),
            const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFFFFD700))),
            const SizedBox(height: 16),
            Text(l.kbzProcessing, style: GoogleFonts.poppins(color: Colors.white)),
            const SizedBox(height: 8),
            // 显示二维码（模拟）
            Container(
              width: 180, height: 180,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
              child: QrImageView(
                data: KBZPayService.generateQRData(merchantId: 'YANGONTAXI', amount: widget.amount.toDouble(), tripId: 'TRIPX'),
                version: QrVersions.auto,
                size: 156,
              ),
            ),
            const SizedBox(height: 8),
            Text('${l.amount}: ${widget.currency} ${widget.amount}', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
          ] else if (_isSuccess) ...[
            const SizedBox(height: 16),
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            Text(l.paymentSuccess, style: GoogleFonts.poppins(color: Colors.green, fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('${l.txId}: $_txId', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11)),
            const SizedBox(height: 4),
            Text('${l.amount}: ${widget.currency} ${widget.amount}', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, {'success': true, 'transactionId': _txId}),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700)),
              child: Text(l.ok, style: GoogleFonts.poppins(color: const Color(0xFF1A1A2E))),
            ),
          ] else ...[
            const SizedBox(height: 16),
            const Icon(Icons.error, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(l.paymentFailed, style: GoogleFonts.poppins(color: Colors.red, fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(_message, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              TextButton(onPressed: () => Navigator.pop(context, {'success': false}), child: Text(l.cancel, style: GoogleFonts.poppins(color: Colors.white54))),
              ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700)), child: Text(l.retry, style: GoogleFonts.poppins(color: const Color(0xFF1A1A2E)))),
            ]),
          ],
        ],
      ),
    );
  }
}
