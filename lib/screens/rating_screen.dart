import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import '../models/trip.dart';
import '../services/trip_storage.dart';

class RatingScreen extends StatefulWidget {
  final String driverName;
  final String driverRating;
  final String vehiclePlate;
  final int price;
  final String currency;
  final String? tripId;

  const RatingScreen({
    super.key,
    this.driverName = 'U Mya Win',
    this.driverRating = '4.8',
    this.vehiclePlate = 'YUE 123',
    this.price = 1500,
    this.currency = 'K',
    this.tripId,
  });

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _rating = 0; // 评分（1-5星）
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  // 提交评价
  void _submitRating() {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '请选择评分',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // 模拟提交评价（2秒后跳转）
    Future.delayed(const Duration(seconds: 2), () async {
      setState(() { _isSubmitting = false; });

      // 更新行程评分
      if (widget.tripId != null) {
        final trips = await TripStorage.getAllTrips();
        final idx = trips.indexWhere((t) => t.id == widget.tripId);
        if (idx != -1) {
          final updated = Trip(
            id: trips[idx].id,
            pickupAddress: trips[idx].pickupAddress,
            destinationAddress: trips[idx].destinationAddress,
            pickupTime: trips[idx].pickupTime,
            dropoffTime: trips[idx].dropoffTime,
            price: trips[idx].price,
            currency: trips[idx].currency,
            vehicleType: trips[idx].vehicleType,
            vehicleName: trips[idx].vehicleName,
            driverName: trips[idx].driverName,
            driverRating: trips[idx].driverRating,
            vehiclePlate: trips[idx].vehiclePlate,
            status: trips[idx].status,
            rating: _rating,
            comment: _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
            distanceKm: trips[idx].distanceKm,
          );
          await TripStorage.saveTrip(updated);
        }
      }

      // 显示成功提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '评价提交成功！感谢您的反馈。',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // 1秒后返回首页
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
          (route) => false,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        title: Text(
          '评价司机',
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
          // 司机信息
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // 司机头像
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.green,
                    size: 50,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // 司机姓名
                Text(
                  widget.driverName,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // 司机评分
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.star,
                      color: const Color(0xFFFFD700),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.driverRating,
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 14,
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
                
                const SizedBox(height: 8),
                
                // 行程费用
                Text(
                  '费用：${widget.currency} ${widget.price}',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFFFD700),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 评分提示
          Text(
            '请评价此次行程',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 星级评分
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starIndex = index + 1;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _rating = starIndex;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    starIndex <= _rating ? Icons.star : Icons.star_border,
                    color: starIndex <= _rating
                        ? const Color(0xFFFFD700)
                        : Colors.white54,
                    size: 40,
                  ),
                ),
              );
            }),
          ),
          
          const SizedBox(height: 8),
          
          // 评分文字提示
          Text(
            _rating == 0
                ? '点击星星评分'
                : _rating == 1
                    ? '非常差'
                    : _rating == 2
                        ? '一般'
                        : _rating == 3
                            ? '不错'
                            : _rating == 4
                                ? '很好'
                                : '非常满意',
            style: GoogleFonts.poppins(
              color: _rating == 0 ? Colors.white54 : const Color(0xFFFFD700),
              fontSize: 14,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 评价内容输入框
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _commentController,
              maxLines: 4,
              style: GoogleFonts.poppins(
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: '写下对此次行程的评价（可选）',
                hintStyle: GoogleFonts.poppins(
                  color: Colors.white54,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFFFD700),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
          
          const Spacer(),
          
          // 提交评价按钮
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
              onPressed: _isSubmitting ? null : _submitRating,
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
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A1A2E)),
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      '提交评价',
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
}
