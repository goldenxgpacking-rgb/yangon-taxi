import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

abstract class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) => Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('zh', 'CN'),
    Locale('en'),
    Locale('my'),
  ];

  // 通用
  String get appTitle;
  String get login;
  String get register;
  String get phoneNumber;
  String get password;
  String get confirm;
  String get cancel;
  String get save;
  String get edit;
  String get delete;
  String get loading;
  String get success;
  String get error;

  // 首页/叫车
  String get home;
  String get enterDestination;
  String get chooseVehicle;
  String get confirmRide;
  String get waitingDriver;
  String get rideInProgress;
  String get tripCompleted;

  // 个人中心
  String get profile;
  String get tripHistory;
  String get savedAddresses;
  String get settings;
  String get referral;
  String get logout;

  // 设置
  String get notificationSettings;
  String get languageSettings;
  String get privacyPolicy;
  String get termsOfService;

  // 支付
  String get payment;
  String get cash;
  String get kbzPay;
  String get payNow;

  // 等级
  String get memberTier;
  String get points;
  String get tripsCompleted;

  // 推荐
  String get referralTitle;
  String get inviteFriends;
  String get shareNow;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['zh', 'en', 'my'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    switch (locale.languageCode) {
      case 'en':
        return AppLocalizationsEn();
      case 'my':
        return AppLocalizationsMy();
      default:
        return AppLocalizationsZh();
    }
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

/// 中文（简体）
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh() : super(const Locale('zh', 'CN'));

  @override String get appTitle => 'Yangon Taxi';
  @override String get login => '登录';
  @override String get register => '注册';
  @override String get phoneNumber => '手机号';
  @override String get password => '密码';
  @override String get confirm => '确认';
  @override String get cancel => '取消';
  @override String get save => '保存';
  @override String get edit => '编辑';
  @override String get delete => '删除';
  @override String get loading => '加载中...';
  @override String get success => '成功';
  @override String get error => '错误';

  @override String get home => '首页';
  @override String get enterDestination => '输入目的地';
  @override String get chooseVehicle => '选择车型';
  @override String get confirmRide => '确认叫车';
  @override String get waitingDriver => '等待司机';
  @override String get rideInProgress => '行程进行中';
  @override String get tripCompleted => '行程已完成';

  @override String get profile => '个人中心';
  @override String get tripHistory => '行程历史';
  @override String get savedAddresses => '常用地址';
  @override String get settings => '设置';
  @override String get referral => '推荐有礼';
  @override String get logout => '退出登录';

  @override String get notificationSettings => '通知设置';
  @override String get languageSettings => '语言设置';
  @override String get privacyPolicy => '隐私政策';
  @override String get termsOfService => '用户协议';

  @override String get payment => '支付';
  @override String get cash => '现金';
  @override String get kbzPay => 'KBZ Pay';
  @override String get payNow => '立即支付';

  @override String get memberTier => '会员等级';
  @override String get points => '积分';
  @override String get tripsCompleted => '已完成行程';

  @override String get referralTitle => '推荐有礼';
  @override String get inviteFriends => '邀请好友';
  @override String get shareNow => '立即分享';
}

/// English
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn() : super(const Locale('en'));

  @override String get appTitle => 'Yangon Taxi';
  @override String get login => 'Login';
  @override String get register => 'Register';
  @override String get phoneNumber => 'Phone Number';
  @override String get password => 'Password';
  @override String get confirm => 'Confirm';
  @override String get cancel => 'Cancel';
  @override String get save => 'Save';
  @override String get edit => 'Edit';
  @override String get delete => 'Delete';
  @override String get loading => 'Loading...';
  @override String get success => 'Success';
  @override String get error => 'Error';

  @override String get home => 'Home';
  @override String get enterDestination => 'Enter destination';
  @override String get chooseVehicle => 'Choose vehicle';
  @override String get confirmRide => 'Confirm ride';
  @override String get waitingDriver => 'Waiting for driver';
  @override String get rideInProgress => 'Ride in progress';
  @override String get tripCompleted => 'Trip completed';

  @override String get profile => 'Profile';
  @override String get tripHistory => 'Trip History';
  @override String get savedAddresses => 'Saved Addresses';
  @override String get settings => 'Settings';
  @override String get referral => 'Refer & Earn';
  @override String get logout => 'Log Out';

  @override String get notificationSettings => 'Notification Settings';
  @override String get languageSettings => 'Language Settings';
  @override String get privacyPolicy => 'Privacy Policy';
  @override String get termsOfService => 'Terms of Service';

  @override String get payment => 'Payment';
  @override String get cash => 'Cash';
  @override String get kbzPay => 'KBZ Pay';
  @override String get payNow => 'Pay Now';

  @override String get memberTier => 'Member Tier';
  @override String get points => 'Points';
  @override String get tripsCompleted => 'Trips Completed';

  @override String get referralTitle => 'Refer & Earn';
  @override String get inviteFriends => 'Invite Friends';
  @override String get shareNow => 'Share Now';
}

/// 缅甸语（缅甸文）
class AppLocalizationsMy extends AppLocalizations {
  AppLocalizationsMy() : super(const Locale('my'));

  @override String get appTitle => 'Yangon Taxi';
  @override String get login => 'အကောင့်ဝင်';
  @override String get register => 'အကောင့်ဖွင့';
  @override String get phoneNumber => 'ဖုန်းနံပါတ်';
  @override String get password => 'စကားဝှက်';
  @override String get confirm => 'အတည်ပြု';
  @override String get cancel => 'ပယ်ဖျက်';
  @override String get save => 'သိမ်းဆည်း';
  @override String get edit => 'ပြင်ဆင်';
  @override String get delete => 'ဖျက်သည်';
  @override String get loading => 'ဖွင့နေသည်...';
  @override String get success => 'အောင်ြမင်း';
  @override String get error => 'အမှား';

  @override String get home => 'ပင်မစာမျက်နှာ';
  @override String get enterDestination => 'မှတ်တိုင်ထည့သွင်း';
  @override String get chooseVehicle => 'ကားအမျိုးအစားရွေး';
  @override String get confirmRide => 'ကားခေါ်အတည်ပြု';
  @override String get waitingDriver => 'ဒရိုက်ဘာစောင့ဆိုင်း';
  @override String get rideInProgress => 'ခရီးစဉ်သွားနေသည်';
  @override String get tripCompleted => 'ခရီးစဉ်ပြီးဆုံး';

  @override String get profile => 'ကိုယ်ရေးအချက်အကြောင်း';
  @override String get tripHistory => 'ခရီးစဉ်မှတ်တမ်း';
  @override String get savedAddresses => 'သိမ်းဆည်းထားသောလိပ်စာ';
  @override String get settings => 'ဆက်တင်';
  @override String get referral => 'ဖိတ်ခေါ်ဆုကြေး';
  @override String get logout => 'အကောင့်ထွက်';

  @override String get notificationSettings => 'အကြောင်းကြားချက်ဆက်တင်';
  @override String get languageSettings => 'ဘာသာစကားဆက်တင်';
  @override String get privacyPolicy => 'ကိုယ်ရေးလုံခြုံမှုမူဝါဒ';
  @override String get termsOfService => 'ဝန်ဆောင်မှုစည်းမျဉ်း';

  @override String get payment => 'ငွေပေးချေး';
  @override String get cash => 'ငွေသား';
  @override String get kbzPay => 'KBZ Pay';
  @override String get payNow => 'အခုပေးမည်';

  @override String get memberTier => 'အဆင့်ဝင်';
  @override String get points => 'ပွိုင့်';
  @override String get tripsCompleted => 'ပြီးဆုံးသောခရီးစဉ်';

  @override String get referralTitle => 'ဖိတ်ခေါ်ဆုကြေး';
  @override String get inviteFriends => 'သူငယ်ခင်းဖိတ်ခေါက်';
  @override String get shareNow => 'အခုမျှဝေပါ';
}
