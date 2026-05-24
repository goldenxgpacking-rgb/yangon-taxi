import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';

class KBZPayScreen extends StatefulWidget {
  final int amount;
  const KBZPayScreen({super.key, this.amount = 0});

  @override
  State<KBZPayScreen> createState() => _KBZPayScreenState();
}

class _KBZPayScreenState extends State<KBZPayScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLinked = false;
  String _kbzPhone = '';
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadKBZData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadKBZData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLinked = prefs.getBool('kbz_linked') ?? false;
      _kbzPhone = prefs.getString('kbz_phone') ?? '';
      // 模拟交易记录
      _transactions = [
        {'id': 'TXN001', 'amount': 2500, 'status': 'success', 'time': '2026-05-24 10:32', 'desc': '打车支付'},
        {'id': 'TXN002', 'amount': 1800, 'status': 'success', 'time': '2026-05-23 18:15', 'desc': '打车支付'},
        {'id': 'TXN003', 'amount': 3200, 'status': 'success', 'time': '2026-05-22 09:05', 'desc': '打车支付'},
      ];
      _isLoading = false;
    });
  }

  Future<void> _linkKBZAccount() async {
    final phoneController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        title: Text('绑定 KBZ Pay', style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('输入您的 KBZ Pay 注册手机号', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: '例：0912345678',
                hintStyle: GoogleFonts.poppins(color: Colors.white38),
                prefixIcon: const Icon(Icons.phone, color: Color(0xFFFFD700), size: 18),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFFFD700))),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('取消', style: GoogleFonts.poppins(color: Colors.white54))),
          ElevatedButton(
            onPressed: () {
              if (phoneController.text.trim().isNotEmpty) {
                Navigator.pop(context, true);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700), foregroundColor: Colors.black),
            child: Text('绑定', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (result == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('kbz_linked', true);
      await prefs.setString('kbz_phone', phoneController.text.trim());
      setState(() {
        _isLinked = true;
        _kbzPhone = phoneController.text.trim();
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('KBZ Pay 绑定成功！', style: GoogleFonts.poppins()), backgroundColor: const Color(0xFF1A1A2E), behavior: SnackBarBehavior.floating),
      );
    }
    phoneController.dispose();
  }

  Future<void> _unlinkKBZ() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        title: Text('解除绑定', style: GoogleFonts.poppins(color: Colors.red)),
        content: Text('确定要解除 KBZ Pay 绑定吗？', style: GoogleFonts.poppins(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('取消', style: GoogleFonts.poppins(color: Colors.white54))),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('解除', style: GoogleFonts.poppins(color: Colors.red)),
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
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFFFFD700)), onPressed: () => Navigator.pop(context)),
        title: Text('KBZ Pay', style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontWeight: FontWeight.w600)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFFD700),
          labelColor: const Color(0xFFFFD700),
          unselectedLabelColor: Colors.white54,
          labelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 13),
          tabs: const [Tab(text: '支付'), Tab(text: '交易记录')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPaymentTab(),
          _buildTransactionTab(),
        ],
      ),
    );
  }

  Widget _buildPaymentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // KBZ Pay 绑定状态
          if (!_isLinked) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  Icon(Icons.account_balance_wallet, size: 48, color: const Color(0xFFFFD700).withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text('未绑定 KBZ Pay', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text('绑定后可使用 KBZ Pay 一键支付打车费', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11), textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _linkKBZAccount,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('绑定 KBZ Pay', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // 已绑定 - 显示付款码
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text('KBZ Pay 付款码', style: GoogleFonts.poppins(color: Colors.black87, fontSize: 13)),
                  const SizedBox(height: 16),
                  // 模拟条形码区域
                  Container(
                    width: 200,
                    height: 120,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('KBZ Pay', style: GoogleFonts.poppins(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          // 模拟条形码
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(20, (i) => Container(
                              width: i.isEven ? 3 : 1,
                              height: 40,
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              color: Colors.black,
                            )),
                          ),
                          const SizedBox(height: 4),
                          Text(_kbzPhone.isNotEmpty ? '****${_kbzPhone.substring(_kbzPhone.length - 4)}' : '********', style: GoogleFonts.poppins(color: Colors.black54, fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('向司机展示此码完成支付', style: GoogleFonts.poppins(color: Colors.black87, fontSize: 11)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 快捷支付金额
            if (widget.amount > 0) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    Text('本次行程费用', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
                    const SizedBox(height: 8),
                    Text('${widget.amount} K', style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontSize: 28, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('模拟：KBZ Pay 支付成功！', style: GoogleFonts.poppins()), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
                          );
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text('确认支付 ${widget.amount} K', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 解绑按钮
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _unlinkKBZ,
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: Text('解除绑定', style: GoogleFonts.poppins(fontSize: 13)),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // KBZ Pay 说明
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('关于 KBZ Pay', style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text('• KBZ Pay 是缅甸主流移动支付方式\n• 绑定后可在行程结束后一键支付\n• 支付安全由 KBZ Bank 保障\n• 当前为演示模式，支付功能将在正式上线后启用', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11), textAlign: TextAlign.left),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTab() {
    if (_transactions.isEmpty) {
      return Center(child: Text('暂无交易记录', style: GoogleFonts.poppins(color: Colors.white38, fontSize: 13)));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _transactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final t = _transactions[i];
        final isSuccess = t['status'] == 'success';
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: isSuccess ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(18)),
                child: Icon(isSuccess ? Icons.check_circle : Icons.error, color: isSuccess ? Colors.green : Colors.red, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t['desc'], style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text(t['time'], style: GoogleFonts.poppins(color: Colors.white38, fontSize: 10)),
                  ],
                ),
              ),
              Text('-${t['amount']} K', style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        );
      },
    );
  }
}
