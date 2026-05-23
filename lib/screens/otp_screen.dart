import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'home_screen.dart';

class OTPScreen extends StatefulWidget {
  final String phoneNumber;
  final bool isRegistration;

  const OTPScreen({
    super.key,
    required this.phoneNumber,
    this.isRegistration = false,
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> with CodeAutoFill {
  String _otpCode = '';
  int _resendSeconds = 60;
  bool _canResend = false;
  bool _autoFilled = false;
  late TextEditingController _pinController;

  @override
  void initState() {
    super.initState();
    _pinController = TextEditingController();
    _startResendTimer();
    _initSmsAutoFill();
    _simulateAutoFill(); // 测试用：自动填入
  }

  // 初始化 SMS 自动读取
  void _initSmsAutoFill() {
    listenForCode();
  }

  // 自动填入测试验证码（模拟）
  void _simulateAutoFill() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && !_autoFilled) {
        setState(() {
          _otpCode = '123456';
          _autoFilled = true;
        });
        // 直接设置到控制器
        _pinController.text = '123456';
        // 自动验证
        _verifyOTP();
      }
    });
  }

  @override
  void codeUpdated() {
    // 真实 SMS 读取时会触发这里
    if (mounted && code != null && code!.length == 6) {
      setState(() {
        _otpCode = code!;
        _autoFilled = true;
      });
      // 设置到控制器
      _pinController.text = code!;
      _verifyOTP();
    }
  }

  void _startResendTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          if (_resendSeconds > 0) {
            _resendSeconds--;
            _startResendTimer();
          } else {
            _canResend = true;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFD700)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '验证码',
          style: GoogleFonts.poppins(
            color: const Color(0xFFFFD700),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              
              // 提示文字
              Text(
                '我们已向',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.phoneNumber,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFFFD700),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '发送了验证码，请查收',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 50),
              
              // OTP 输入框
              PinCodeTextField(
                appContext: context,
                length: 6,
                onChanged: (value) {
                  _otpCode = value;
                },
                onCompleted: (value) {
                  _otpCode = value;
                  _verifyOTP();
                },
                autoFocus: true,
                animationType: AnimationType.fade,
                animationDuration: const Duration(milliseconds: 300),
                controller: _pinController,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(12),
                  fieldHeight: 56,
                  fieldWidth: 48,
                  activeFillColor: Colors.white.withOpacity(0.1),
                  inactiveFillColor: Colors.white.withOpacity(0.05),
                  selectedFillColor: const Color(0xFFFFD700).withOpacity(0.2),
                  activeColor: const Color(0xFFFFD700),
                  inactiveColor: Colors.white.withOpacity(0.3),
                  selectedColor: const Color(0xFFFFD700),
                ),
                textStyle: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                backgroundColor: Colors.transparent,
                enableActiveFill: true,
              ),
              const SizedBox(height: 40),
              
              // 重发验证码
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '未收到验证码？',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                    ),
                  ),
                  TextButton(
                    onPressed: _canResend
                        ? () {
                            // TODO: 重新发送验证码
                            setState(() {
                              _resendSeconds = 60;
                              _canResend = false;
                            });
                            _startResendTimer();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('验证码已重新发送'),
                                backgroundColor: Color(0xFFFFD700),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        : null,
                    child: Text(
                      _canResend
                          ? '重新发送'
                          : '${_resendSeconds}秒后重发',
                      style: GoogleFonts.poppins(
                        color: _canResend
                            ? const Color(0xFFFFD700)
                            : Colors.white38,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              
              // 验证按钮
              ElevatedButton(
                onPressed: _otpCode.length == 6 ? _verifyOTP : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: const Color(0xFF1A1A2E),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  '验证',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _verifyOTP() {
    // 模拟验证成功（自动验证）
    if (_otpCode == '123456') {
      // 测试用验证码
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('验证成功！正在跳转...'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );
      
      // 延迟 1 秒后跳转（让用户看到成功提示）
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
          );
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('验证码错误，请重试'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    cancel(); // 取消 SMS 监听
    super.dispose();
  }
}
