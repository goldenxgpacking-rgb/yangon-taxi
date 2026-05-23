import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'rating_screen.dart';
import '../models/trip.dart';
import '../services/trip_storage.dart';

class PaymentScreen extends StatefulWidget {
  final String pickupAddress;
  final String destinationAddress;
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
  String _selectedPaymentMethod = 'cash'; // 默认现金支付

  // 支付方式列表
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'cash',
      'name': '现金支付',
      'icon': Icons.money,
      'color': Colors.green,
      'description': '下车时支付现金',
    },
    {
      'id': 'kbz_pay',
      'name': 'KBZ Pay',
      'icon': Icons.account_balance_wallet,
      'color': Colors.blue,
      'description': '缅甸KBZ银行电子钱包',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        title: Text(
          '支付费用',
          style: GoogleFonts.poppins(
            color: const Color(0xFFFFD700),
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFD700)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 行程摘要
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFFD700).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // 司机信息
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.green,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.driverName,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: const Color(0xFFFFD700),
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.driverRating,
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                widget.vehiclePlate,
                                style: GoogleFonts.poppins(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                const Divider(color: Colors.white12),
                const SizedBox(height: 16),
                
                // 行程路线
                Row(
                  children: [
                    const Icon(Icons.my_location, color: Color(0xFFFFD700), size: 16),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.pickupAddress,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.red, size: 16),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.destinationAddress,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                const Divider(color: Colors.white12),
                const SizedBox(height: 16),
                
                // 车型和费用
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '车型',
                      style: GoogleFonts.poppins(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      widget.vehicleName,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '费用',
                      style: GoogleFonts.poppins(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${widget.currency} ${widget.price}',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFFFD700),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // 支付方式选择
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '选择支付方式',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // 支付方式列表
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _paymentMethods.length,
              itemBuilder: (context, index) {
                final method = _paymentMethods[index];
                final isSelected = _selectedPaymentMethod == method['id'];
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPaymentMethod = method['id'];
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? method['color'].withOpacity(0.1)
                          : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? method['color']
                            : Colors.white.withOpacity(0.1),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: method['color'].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Icon(
                            method['icon'],
                            color: method['color'],
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                method['name'],
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                method['description'],
                                style: GoogleFonts.poppins(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: method['color'],
                            size: 24,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // 确认支付按钮
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                // TODO: 处理支付逻辑
                _processPayment();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: const Color(0xFF1A1A2E),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(
                '确认支付 ${widget.currency} ${widget.price}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 处理支付
  void _processPayment() {
    // 显示支付处理中
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
            ),
            const SizedBox(height: 16),
            Text(
              '支付处理中...',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );

    // 模拟支付处理（2秒后跳转）
    Future.delayed(const Duration(seconds: 2), () async {
      Navigator.pop(context); // 关闭处理中对话框

      // 保存行程到本地
      final now = DateTime.now();
      final pickupTime = DateTime(now.year, now.month, now.day, now.hour - 1, now.minute);
      final trip = Trip(
        id: Trip.generateId(),
        pickupAddress: widget.pickupAddress,
        destinationAddress: widget.destinationAddress,
        pickupTime: Trip.currentTime(),
        dropoffTime: Trip.currentTime(),
        price: widget.price,
        currency: widget.currency,
        vehicleType: _selectedPaymentMethod == 'cash' ? 'cash' : 'kbz',
        vehicleName: widget.vehicleName,
        driverName: widget.driverName,
        driverRating: widget.driverRating,
        vehiclePlate: widget.vehiclePlate,
        status: 'completed',
        distanceKm: widget.distanceKm,
      );
      await TripStorage.saveTrip(trip);

      // 跳转到评价页面
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
    });
  }
}
