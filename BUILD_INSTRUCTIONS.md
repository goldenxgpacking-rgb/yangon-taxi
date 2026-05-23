# Yangon Taxi - 构建说明

## 项目状态
✅ **代码已完成** - 所有界面和逻辑已创建

## 项目结构
```
D:\yangon_taxi\
├── lib\
│   ├── main.dart              # 主入口
│   ├── screens\
│   │   ├── login_screen.dart  # 登录界面
│   │   ├── register_screen.dart # 注册界面
│   │   ├── otp_screen.dart   # 验证码界面
│   │   └── home_screen.dart  # 主页界面
│   ├── widgets\              # 通用组件（待扩展）
│   ├── utils\                # 工具类（待扩展）
│   ├── services\             # 服务层（待扩展）
│   └── models\              # 数据模型（待扩展）
├── pubspec.yaml              # 依赖配置
└── SPEC.md                  # 项目规格文档
```

## 功能实现
### ✅ 已完成
1. **用户登录** - 手机号登录界面（缅甸 +95）
2. **用户注册** - 姓名、手机号、邮箱注册
3. **OTP验证** - 6位验证码输入，60秒重发
4. **主页** - 底部导航（首页/订单/我的）
5. **个人中心** - 用户信息、菜单、退出登录

### ⏳ 待实现
1. 后端API对接（Firebase/自定义）
2. 短信验证码发送（OTP逻辑）
3. 地图集成（Google Maps）
4. 支付功能
5. 订单管理

## 如何运行

### 方式1：连接手机/模拟器后运行
```bash
cd D:\yangon_taxi
D:\src\flutter\bin\flutter.bat run
```

### 方式2：构建 APK
```bash
cd D:\yangon_taxi
D:\src\flutter\bin\flutter.bat build apk --debug
```
APK 输出路径：
`D:\yangon_taxi\build\app\outputs\flutter-apk\app-debug.apk`

## 测试账号
- **验证码**：123456（模拟）
- **手机号**：任意缅甸手机号（+95 开头）

## 技术栈
- **Flutter**: 3.41.9
- **Dart**: 3.11.5
- **依赖包**：
  - google_fonts: ^6.1.0
  - intl_phone_field: ^3.0.1
  - pin_code_fields: ^8.0.1
  - shared_preferences: ^2.3.2
  - provider: ^6.1.1

## 设计风格
- **主色调**：#FFD700（仰光金）
- **辅色**：#1A1A2E（深蓝黑）
- **字体**：Poppins（Google Fonts）

## 下一步
1. 连接 Android 手机或启动模拟器
2. 运行 `flutter run` 测试界面
3. 对接后端 API（Firebase Auth 推荐）
4. 实现地图和叫车功能

---
创建时间：2026-05-23
状态：✅ 代码完成 | ⏳ 构建中（如需要可手动构建）
