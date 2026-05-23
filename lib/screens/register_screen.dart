import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  String _completePhoneNumber = '';
  bool _agreeToTerms = false;

  // 验证缅甸手机号（6-11位数字）
  bool _isValidMyanmarPhone(String phone) {
    if (phone.isEmpty) return false;
    // 移除所有空格和特殊字符，只保留数字
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    // 缅甸手机号：6-11位数字
    return digits.length >= 6 && digits.length <= 11;
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
          '注册账号',
          style: GoogleFonts.poppins(
            color: const Color(0xFFFFD700),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              
              // 姓名输入
              _buildTextField(
                controller: _nameController,
                label: '姓名',
                icon: Icons.person,
                hint: '请输入您的姓名',
                onChanged: (value) {
                  setState(() {}); // 触发重建，更新按钮状态
                },
              ),
              const SizedBox(height: 16),
              
              // 手机号输入
              Text(
                '手机号',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              IntlPhoneField(
                controller: _phoneController,
                decoration: InputDecoration(
                  hintText: '请输入手机号',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: const Color(0xFFFFD700).withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFFFD700)),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                dropdownTextStyle: const TextStyle(color: Colors.white),
                initialCountryCode: 'MM',
                disableLengthCheck: true, // 禁用内置长度验证
                onChanged: (phone) {
                  setState(() { // 触发重建，更新按钮状态
                    _completePhoneNumber = phone.completeNumber;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // 邮箱输入（可选）
                _buildTextField(
                  controller: _emailController,
                  label: '邮箱（可选）',
                  icon: Icons.email,
                  hint: '请输入邮箱地址',
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    setState(() {}); // 触发重建，更新按钮状态
                  },
                ),
              const SizedBox(height: 24),
              
              // 用户协议
              Row(
                children: [
                  Checkbox(
                    value: _agreeToTerms,
                    onChanged: (value) {
                      setState(() {
                        _agreeToTerms = value ?? false;
                      });
                    },
                    activeColor: const Color(0xFFFFD700),
                    checkColor: const Color(0xFF1A1A2E),
                  ),
                  Expanded(
                    child: Text(
                      '我已阅读并同意《用户协议》和《隐私政策》',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // 注册按钮
              ElevatedButton(
                onPressed: (_nameController.text.isNotEmpty &&
                        _completePhoneNumber.isNotEmpty &&
                        _isValidMyanmarPhone(_completePhoneNumber) &&
                        _agreeToTerms)
                    ? () {
                        // TODO: 注册逻辑
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OTPScreen(
                              phoneNumber: _completePhoneNumber,
                              isRegistration: true,
                            ),
                          ),
                        );
                      }
                    : null,
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
                  '注册',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
    Function(String)? onChanged, // 添加 onChanged 回调
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged, // 触发重建，更新按钮状态
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white54),
            prefixIcon: Icon(icon, color: const Color(0xFFFFD700)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: const Color(0xFFFFD700).withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFFD700)),
            ),
          ),
        ),
      ],
    );
  }
}
