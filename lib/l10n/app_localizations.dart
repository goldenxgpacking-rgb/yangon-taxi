import 'dart:async';
import 'package:flutter/material.dart';

abstract class AppLocalizations {
  AppLocalizations(this.locale);
  final Locale locale;

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('zh', 'CN'),
    Locale('en'),
    Locale('my'),
  ];

  // ===== 通用 =====
  String get appTitle;
  String get login;
  String get register;
  String get phoneNumber;
  String get phoneHint;
  String get password;
  String get confirmPassword;
  String get confirm;
  String get cancel;
  String get save;
  String get edit;
  String get delete;
  String get loading;
  String get success;
  String get error;
  String get close;
  String get back;
  String get yes;
  String get no;
  String get ok;
  String get retry;
  String get noData;
  String get orText;

  // ===== 验证 =====
  String get phoneInvalid;
  String get phoneRequired;
  String get otpSent;
  String get otpHint;
  String get otpInvalid;
  String get otpResend;
  String get otpResendIn;
  String get agreeTerms;
  String get termsLink;

  // ===== 首页 =====
  String get home;
  String get enterDestination;
  String get trips;
  String get myProfile;
  String get whereTo;
  String get savedPlaces;
  String get homeAddr;
  String get workAddr;

  // ===== 目的地 =====
  String get searchDestination;
  String get recentPlaces;
  String get popularPlaces;
  String get noResults;
  String get pickLocation;

  // ===== 车型 =====
  String get chooseVehicle;
  String get vehicleCng;
  String get vehicleOil;
  String get vehicleEv;
  String get vehiclePrivate;
  String get estimatedPrice;
  String get estimatedTime;
  String get vehicleTypeLabel;
  String get feeLabel;

  // ===== 叫车确认 =====
  String get confirmRide;
  String get pickupLocation;
  String get dropoffLocation;
  String get paymentMethod;
  String get nearbyDrivers;
  String get driverArrivingIn;
  String get driverMinAway;

  // ===== 等待司机 =====
  String get searchingDriver;
  String get searchingDesc;
  String get driverAccepted;
  String get driverOnWay;
  String get driverArrived;
  String get driverWaiting;
  String get startRide;
  String get waitingArrive;
  String get cancelRide;
  String get cancelRideConfirm;
  String get callDriver;

  // ===== 行程中 =====
  String get rideInProgress;
  String get headingTo;
  String get remaining;
  String get arriveSoon;
  String get sosButton;
  String get sosTitle;
  String get sosDesc;
  String get sosConfirm;

  // ===== 支付 =====
  String get payment;
  String get selectPayment;
  String get tripFare;
  String get distance;
  String get duration;
  String get cashPayment;
  String get cashDesc;
  String get kbzPay;
  String get kbzDesc;
  String get balance;
  String get insufficientBalance;
  String confirmPay(String currency, int amount);
  String get kbzProcessing;
  String get amount;
  String get txId;
  String get paymentSuccess;
  String get paymentFailed;
  String get payWithCash;
  String get payWithKbz;
  String get paymentSuccessDesc;

  // ===== 评价 =====
  String get rateRide;
  String get rateDesc;
  String get skipRating;
  String get submitRating;
  String get terrible;
  String get bad;
  String get okay;
  String get good;
  String get excellent;

  // ===== 行程历史 =====
  String get tripHistory;
  String get allTrips;
  String get completed;
  String get cancelled;
  String get today;
  String get yesterday;
  String get fare;
  String get noTrips;

  // ===== 行程详情 =====
  String get tripDetail;
  String get tripDate;
  String get tripRoute;
  String get tripVehicle;
  String get tripPayment;
  String get shareTrip;
  String get tripCopied;

  // ===== 个人中心 =====
  String get profile;
  String get editProfile;
  String get name;
  String get email;
  String get avatar;
  String get changeAvatar;
  String get saveChanges;
  String get profileUpdated;

  // ===== 设置 =====
  String get settings;
  String get notifSettings;
  String get pushNotif;
  String get pushNotifDesc;
  String get soundNotif;
  String get soundNotifDesc;
  String get vibrateNotif;
  String get vibrateNotifDesc;
  String get langSettings;
  String get appLanguage;
  String get selectLanguage;
  String get langChanged;
  String get privacyPolicy;
  String get termsOfService;
  String get clearCache;
  String get clearCacheDesc;
  String get cacheCleared;
  String get aboutApp;
  String get other;
  String get version;
  String get checkUpdate;
  String get checkingUpdate;
  String get latestVersion;
  String get newVersionAvailable;
  String get updateNow;
  String get helpSupport;
  String get helpSupportDesc;
  String get contactUs;

  // ===== 等级 =====
  String get memberTier;
  String get points;
  String get tripsCompleted;
  String get regular;
  String get silver;
  String get gold;
  String get platinum;
  String get tierBenefits;
  String get upgradeTo;
  // 等级补充
  String get distanceToNext;
  String get needMore;
  String get maxTier;
  String get currentBadge;
  String get pointsRules;
  String get rulePerTrip;
  String get ruleTier;
  String get ruleRedeem;
  String get ruleInvite;

  // ===== 推荐 =====
  String get referralTitle;
  String get referralDesc;
  String get myReferralCode;
  String get referralReward;
  String get inviteFriends;
  String get shareNow;
  String get copied;
  // 推荐补充
  String get perFriend;
  String get couponReward;
  String get copyCode;
  String get copyShare;
  String get activityRules;
  String get rule1;
  String get rule2;
  String get rule3;
  String get rule4;
  String get rule5;
  String get simulateBtn;
  String get simulateDesc;
  String get shareTextCopied;
  String get invitedLabel;
  String get earnedLabel;
  String inviteSuccess(int count, int amount);
  String codeCopiedMsg(String code);
  String shareMessage(String code, int amount);

  // ===== KBZ Pay =====
  String get kbzPayTitle;
  String get kbzPayDesc;
  String get scanQr;
  String get enterAmount;
  String get kbzPayLink;
  String get kbzLinked;
  String get kbzUnlink;
  String get kbzUnlinkConfirm;
  String get kbzLinkAccount;
  String get kbzNotLinked;
  String get kbzNotLinkedDesc;
  String get choosePaymentMethod;
  String get kbzQRCodePay;
  String get kbzQRCodePayDesc;
  String get kbzAppPay;
  String get kbzAppPayDesc;
  String get scanToPay;
  String get kbzQRPaymentInstructions;
  String get kbzPaying;
  String get kbzPaymentSuccess;
  String get kbzPaymentFailed;
  String get kbzQRGenerateFailed;
  String get kbzPaymentTimeout;
  String get kbzPayFailed;
  String get transactions;
  String get noTransactions;
  String get aboutKBZPay;
  String get unlink;

  // ===== 常用地址 =====
  String get savedAddresses;
  String get addAddress;
  String get editAddress;
  String get addressLabel;
  String setAsHome();
  String setAsWork();

  // ===== SOS =====
  String get emergency;
  String get emergencyCall;
  String get emergencySent;
  String get emergencyDesc;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['zh', 'en', 'my'].contains(locale.languageCode);

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
  bool shouldReload(_AppLocalizationsDelegate old) => true;  // 切换语言时必须重新加载
}

// ============================================================
// 中文（简体）
// ============================================================
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh() : super(const Locale('zh', 'CN'));

  @override String get appTitle => 'Yangon Taxi';
  @override String get login => '登录';
  @override String get register => '注册';
  @override String get phoneNumber => '手机号';
  @override String get phoneHint => '+95 9xxxxxxxxx';
  @override String get password => '密码';
  @override String get confirmPassword => '确认密码';
  @override String get confirm => '确认';
  @override String get cancel => '取消';
  @override String get save => '保存';
  @override String get edit => '编辑';
  @override String get delete => '删除';
  @override String get loading => '加载中...';
  @override String get success => '成功';
  @override String get error => '错误';
  @override String get close => '关闭';
  @override String get back => '返回';
  @override String get yes => '是';
  @override String get no => '否';
  @override String get ok => '确定';
  @override String get retry => '重试';
  @override String get noData => '暂无数据';
  @override String get orText => '或';

  @override String get phoneInvalid => '请输入有效的手机号';
  @override String get phoneRequired => '请输入手机号';
  @override String get otpSent => '验证码已发送';
  @override String get otpHint => '输入6位验证码';
  @override String get otpInvalid => '验证码无效';
  @override String get otpResend => '重新发送';
  @override String get otpResendIn => '重新发送 ';
  @override String get agreeTerms => '我已阅读并同意';
  @override String get termsLink => '《用车服务协议》';

  @override String get home => '首页';
  @override String get enterDestination => '输入目的地';
  @override String get trips => '行程';
  @override String get myProfile => '我的';
  @override String get whereTo => '去哪里？';
  @override String get savedPlaces => '常用地点';
  @override String get homeAddr => '家';
  @override String get workAddr => '公司';

  @override String get searchDestination => '搜索目的地';
  @override String get recentPlaces => '最近去过';
  @override String get popularPlaces => '热门地点';
  @override String get noResults => '未找到结果';
  @override String get pickLocation => '选择位置';

  @override String get chooseVehicle => '选择车型';
  @override String get vehicleCng => 'CNG 汽车';
  @override String get vehicleOil => '汽油车';
  @override String get vehicleEv => '电动车';
  @override String get vehiclePrivate => '私家车';
  @override String get estimatedPrice => '预估价格';
  @override String get estimatedTime => '预计时间';
  @override String get vehicleTypeLabel => '车型';
  @override String get feeLabel => '费用';

  @override String get confirmRide => '确认叫车';
  @override String get pickupLocation => '上车地点';
  @override String get dropoffLocation => '目的地';
  @override String get paymentMethod => '支付方式';
  @override String get nearbyDrivers => '附近司机';
  @override String get driverArrivingIn => '到达';
  @override String get driverMinAway => ' min 到达';

  @override String get searchingDriver => '正在为您寻找司机...';
  @override String get searchingDesc => '预计等待';
  @override String get driverAccepted => '司机已接单';
  @override String get driverOnWay => '司机正在赶来';
  @override String get driverArrived => '司机已到达！';
  @override String get driverWaiting => '正在等候';
  @override String get startRide => '开始行程';
  @override String get waitingArrive => '等待司机到达';
  @override String get cancelRide => '取消叫车';
  @override String get cancelRideConfirm => '确定要取消此次叫车吗？';
  @override String get callDriver => '拨打司机电话';

  @override String get rideInProgress => '行程进行中';
  @override String get headingTo => '前往';
  @override String get remaining => '剩余';
  @override String get arriveSoon => '即将到达';
  @override String get sosButton => 'SOS 紧急按钮';
  @override String get sosTitle => '🚨 紧急求助';
  @override String get sosDesc => '将向紧急联系人发送您的位置信息，并通知平台客服。';
  @override String get sosConfirm => '确认发送';

  @override String get payment => '支付';
  @override String get selectPayment => '选择支付方式';
  @override String get tripFare => '行程费用';
  @override String get distance => '距离';
  @override String get duration => '时长';
  @override String get cashPayment => '现金支付';
  @override String get cashDesc => '向司机支付现金';
  @override String get kbzPay => 'KBZ Pay';
  @override String get kbzDesc => '缅甸KBZ银行电子钱包';
  @override String get balance => '余额';
  @override String get insufficientBalance => '余额不足';
  @override String confirmPay(String currency, int amount) => '确认支付 $currency $amount';
  @override String get kbzProcessing => 'KBZ Pay 处理中...';
  @override String get amount => '金额';
  @override String get txId => '交易号';
  @override String get paymentSuccess => '支付成功！';
  @override String get paymentFailed => '支付失败';
  @override String get payWithCash => '现金支付';
  @override String get payWithKbz => 'KBZ Pay 支付';
  @override String get paymentSuccessDesc => '感谢您使用 Yangon Taxi';

  @override String get rateRide => '评价行程';
  @override String get rateDesc => '您的评价帮助我们提升服务质量';
  @override String get skipRating => '跳过';
  @override String get submitRating => '提交评价';
  @override String get terrible => '很差';
  @override String get bad => '不好';
  @override String get okay => '一般';
  @override String get good => '满意';
  @override String get excellent => '非常好';

  @override String get tripHistory => '行程历史';
  @override String get allTrips => '全部';
  @override String get completed => '已完成';
  @override String get cancelled => '已取消';
  @override String get today => '今天';
  @override String get yesterday => '昨天';
  @override String get fare => '费用';
  @override String get noTrips => '暂无行程记录';

  @override String get tripDetail => '行程详情';
  @override String get tripDate => '日期';
  @override String get tripRoute => '路线';
  @override String get tripVehicle => '车型';
  @override String get tripPayment => '支付方式';
  @override String get shareTrip => '分享行程';
  @override String get tripCopied => '行程已复制到剪贴板';

  @override String get profile => '个人中心';
  @override String get editProfile => '编辑资料';
  @override String get name => '姓名';
  @override String get email => '邮箱';
  @override String get avatar => '头像';
  @override String get changeAvatar => '更换头像';
  @override String get saveChanges => '保存修改';
  @override String get profileUpdated => '资料已更新';

  @override String get settings => '设置';
  @override String get notifSettings => '通知设置';
  @override String get pushNotif => '推送通知';
  @override String get pushNotifDesc => '行程状态、优惠活动通知';
  @override String get soundNotif => '提示音';
  @override String get soundNotifDesc => '新消息提示音';
  @override String get vibrateNotif => '震动提醒';
  @override String get vibrateNotifDesc => '新消息震动提醒';
  @override String get langSettings => '语言设置';
  @override String get appLanguage => '应用语言';
  @override String get selectLanguage => '选择语言';
  @override String get langChanged => '语言已切换，部分页面需重启生效';
  @override String get privacyPolicy => '隐私政策';
  @override String get termsOfService => '用户协议';
  @override String get clearCache => '清除缓存';
  @override String get clearCacheDesc => '清除本地缓存数据';
  @override String get cacheCleared => '缓存已清除';
  @override String get aboutApp => '关于 Yangon Taxi';
  @override String get other => '其他';
  @override String get version => '版本 1.0.0';
  @override String get checkUpdate => '检查更新';
  @override String get checkingUpdate => '正在检查更新...';
  @override String get latestVersion => '已是最新版本';
  @override String get newVersionAvailable => '发现新版本';
  @override String get updateNow => '立即更新';
  @override String get helpSupport => '帮助与支持';
  @override String get helpSupportDesc => '常见问题、联系客服';
  @override String get contactUs => '联系我们';

  @override String get memberTier => '会员等级';
  @override String get points => '积分';
  @override String get tripsCompleted => '已完成行程';
  @override String get regular => '普通会员';
  @override String get silver => '银卡会员';
  @override String get gold => '金卡会员';
  @override String get platinum => '铂金会员';
  @override String get tierBenefits => '会员权益';
  @override String get upgradeTo => '升级至';
  // 等级补充
  @override String get distanceToNext => '距下一等级';
  @override String get needMore => '还需';
  @override String get maxTier => '已达到最高等级！';
  @override String get currentBadge => '当前';
  @override String get pointsRules => '积分规则';
  @override String get rulePerTrip => '每完成1单，获得对应等级积分';
  @override String get ruleTier => '等级越高，每单积分越多';
  @override String get ruleRedeem => '积分可兑换打车券（即将上线）';
  @override String get ruleInvite => '邀请好友额外获得积分奖励';

  @override String get referralTitle => '推荐有礼';
  @override String get referralDesc => '邀请好友注册，双方各得 5000 KS';
  @override String get myReferralCode => '我的推荐码';
  @override String get referralReward => '推荐奖励';
  @override String get inviteFriends => '邀请好友';
  @override String get shareNow => '立即分享';
  @override String get copied => '已复制';
  // 推荐补充
  @override String get perFriend => '每邀请1位好友';
  @override String get couponReward => '打车券奖励';
  @override String get copyCode => '复制邀请码';
  @override String get copyShare => '复制分享文案';
  @override String get activityRules => '活动规则';
  @override String get rule1 => '邀请好友注册 Yangon Taxi';
  @override String get rule2 => '好友首次完成打车行程';
  @override String get rule3 => '你和好友各得奖励';
  @override String get rule4 => '打车券有效期30天';
  @override String get rule5 => '无邀请人数上限，多邀多得';
  @override String get simulateBtn => '📱 模拟：好友通过邀请码注册';
  @override String get simulateDesc => '（演示功能：模拟邀请成功，查看奖励变化）';
  @override String get shareTextCopied => '分享文案已复制，可粘贴到微信/Facebook等发送给好友';
  @override String get invitedLabel => '已邀请';
  @override String get earnedLabel => '累计奖励';
  @override String inviteSuccess(int count, int amount) => '🎉 成功邀请$count位好友，获得 $amount K 打车券！';
  @override String codeCopiedMsg(String code) => '邀请码已复制：$code';
  @override String shareMessage(String code, int amount) => '【Yangon Taxi 推荐有礼】\n邀请码：$code\n注册时填入邀请码，双方各得 $amount K 打车券！';

  @override String get kbzPayTitle => 'KBZ Pay 支付';
  @override String get kbzPayDesc => '扫码或输入金额完成支付';
  @override String get scanQr => '扫描二维码';
  @override String get enterAmount => '输入金额';
  @override String get kbzPayLink => '关联 KBZ Pay 账户';
  @override String get kbzLinked => '绑定成功';
  @override String get kbzUnlink => '解除绑定';
  @override String get kbzUnlinkConfirm => '确定要解除 KBZ Pay 绑定吗？';
  @override String get kbzLinkAccount => '绑定 KBZ Pay 账户';
  @override String get kbzNotLinked => '未绑定 KBZ Pay';
  @override String get kbzNotLinkedDesc => '绑定后可使用 KBZ Pay 一键支付打车费';
  @override String get choosePaymentMethod => '选择支付方式';
  @override String get kbzQRCodePay => 'QR 码支付';
  @override String get kbzQRCodePayDesc => '展示付款码，让司机扫码';
  @override String get kbzAppPay => 'APP 内支付';
  @override String get kbzAppPayDesc => '直接调起 KBZ Pay 完成支付';
  @override String get scanToPay => '扫码支付';
  @override String get kbzQRPaymentInstructions => '扫码支付说明';
  @override String get kbzPaying => '正在支付...';
  @override String get kbzPaymentSuccess => '支付成功！';
  @override String get kbzPaymentFailed => '支付失败';
  @override String get kbzQRGenerateFailed => 'QR 码生成失败';
  @override String get kbzPaymentTimeout => '支付超时，请重试';
  @override String get kbzPayFailed => 'KBZ Pay 支付失败';
  @override String get transactions => '交易记录';
  @override String get noTransactions => '暂无交易记录';
  @override String get aboutKBZPay => '关于 KBZ Pay';
  @override String get unlink => '解除';

  @override String get savedAddresses => '常用地址';
  @override String get addAddress => '添加地址';
  @override String get editAddress => '编辑地址';
  @override String get addressLabel => '地址标签';
  @override String setAsHome() => '设为家';
  @override String setAsWork() => '设为公司';

  @override String get emergency => '紧急求助';
  @override String get emergencyCall => '拨打 999';
  @override String get emergencySent => '已发送紧急求助信息！';
  @override String get emergencyDesc => '将向紧急联系人发送位置并通知客服';
}

// ============================================================
// English
// ============================================================
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn() : super(const Locale('en'));

  @override String get appTitle => 'Yangon Taxi';
  @override String get login => 'Login';
  @override String get register => 'Register';
  @override String get phoneNumber => 'Phone Number';
  @override String get phoneHint => '+95 9xxxxxxxxx';
  @override String get password => 'Password';
  @override String get confirmPassword => 'Confirm Password';
  @override String get confirm => 'Confirm';
  @override String get cancel => 'Cancel';
  @override String get save => 'Save';
  @override String get edit => 'Edit';
  @override String get delete => 'Delete';
  @override String get loading => 'Loading...';
  @override String get success => 'Success';
  @override String get error => 'Error';
  @override String get close => 'Close';
  @override String get back => 'Back';
  @override String get yes => 'Yes';
  @override String get no => 'No';
  @override String get ok => 'OK';
  @override String get retry => 'Retry';
  @override String get noData => 'No data';
  @override String get orText => 'or';

  @override String get phoneInvalid => 'Please enter a valid phone number';
  @override String get phoneRequired => 'Phone number is required';
  @override String get otpSent => 'OTP sent';
  @override String get otpHint => 'Enter 6-digit code';
  @override String get otpInvalid => 'Invalid OTP';
  @override String get otpResend => 'Resend';
  @override String get otpResendIn => 'Resend in ';
  @override String get agreeTerms => 'I agree to the';
  @override String get termsLink => 'Terms of Service';

  @override String get home => 'Home';
  @override String get enterDestination => 'Enter destination';
  @override String get trips => 'Trips';
  @override String get myProfile => 'Profile';
  @override String get whereTo => 'Where to?';
  @override String get savedPlaces => 'Saved Places';
  @override String get homeAddr => 'Home';
  @override String get workAddr => 'Work';

  @override String get searchDestination => 'Search destination';
  @override String get recentPlaces => 'Recent';
  @override String get popularPlaces => 'Popular Places';
  @override String get noResults => 'No results found';
  @override String get pickLocation => 'Pick location';

  @override String get chooseVehicle => 'Choose Vehicle';
  @override String get vehicleCng => 'CNG Car';
  @override String get vehicleOil => 'Oil Car';
  @override String get vehicleEv => 'EV Car';
  @override String get vehiclePrivate => 'Private Car';
  @override String get estimatedPrice => 'Est. Price';
  @override String get estimatedTime => 'Est. Time';
  @override String get vehicleTypeLabel => 'Vehicle';
  @override String get feeLabel => 'Fee';

  @override String get confirmRide => 'Confirm Ride';
  @override String get pickupLocation => 'Pickup';
  @override String get dropoffLocation => 'Destination';
  @override String get paymentMethod => 'Payment';
  @override String get nearbyDrivers => 'Nearby Drivers';
  @override String get driverArrivingIn => 'arriving in';
  @override String get driverMinAway => ' min';

  @override String get searchingDriver => 'Finding your driver...';
  @override String get searchingDesc => 'Estimated wait';
  @override String get driverAccepted => 'Driver accepted';
  @override String get driverOnWay => 'Driver is on the way';
  @override String get driverArrived => 'Driver has arrived!';
  @override String get driverWaiting => 'is waiting';
  @override String get startRide => 'Start Ride';
  @override String get waitingArrive => 'Waiting for driver';
  @override String get cancelRide => 'Cancel Ride';
  @override String get cancelRideConfirm => 'Are you sure you want to cancel?';
  @override String get callDriver => 'Call Driver';

  @override String get rideInProgress => 'Ride in Progress';
  @override String get headingTo => 'Heading to';
  @override String get remaining => 'Remaining';
  @override String get arriveSoon => 'Arriving soon';
  @override String get sosButton => 'SOS Emergency';
  @override String get sosTitle => '🚨 Emergency';
  @override String get sosDesc => 'Your location will be shared with emergency contacts.';
  @override String get sosConfirm => 'Send Alert';

  @override String get payment => 'Payment';
  @override String get selectPayment => 'Select Payment Method';
  @override String get tripFare => 'Trip Fare';
  @override String get distance => 'Distance';
  @override String get duration => 'Duration';
  @override String get cashPayment => 'Cash';
  @override String get cashDesc => 'Pay with cash to driver';
  @override String get kbzPay => 'KBZ Pay';
  @override String get kbzDesc => 'Myanmar KBZ Bank e-wallet';
  @override String get balance => 'Balance';
  @override String get insufficientBalance => 'Insufficient balance';
  @override String confirmPay(String currency, int amount) => 'Confirm Pay $currency $amount';
  @override String get kbzProcessing => 'KBZ Pay processing...';
  @override String get amount => 'Amount';
  @override String get txId => 'Transaction ID';
  @override String get paymentSuccess => 'Payment Successful!';
  @override String get paymentFailed => 'Payment Failed';
  @override String get payWithCash => 'Pay with Cash';
  @override String get payWithKbz => 'Pay with KBZ Pay';
  @override String get paymentSuccessDesc => 'Thank you for using Yangon Taxi';

  @override String get rateRide => 'Rate Your Ride';
  @override String get rateDesc => 'Your feedback helps us improve';
  @override String get skipRating => 'Skip';
  @override String get submitRating => 'Submit';
  @override String get terrible => 'Terrible';
  @override String get bad => 'Bad';
  @override String get okay => 'Okay';
  @override String get good => 'Good';
  @override String get excellent => 'Excellent';

  @override String get tripHistory => 'Trip History';
  @override String get allTrips => 'All';
  @override String get completed => 'Completed';
  @override String get cancelled => 'Cancelled';
  @override String get today => 'Today';
  @override String get yesterday => 'Yesterday';
  @override String get fare => 'fare';
  @override String get noTrips => 'No trips yet';

  @override String get tripDetail => 'Trip Detail';
  @override String get tripDate => 'Date';
  @override String get tripRoute => 'Route';
  @override String get tripVehicle => 'Vehicle';
  @override String get tripPayment => 'Payment';
  @override String get shareTrip => 'Share Trip';
  @override String get tripCopied => 'Trip copied to clipboard';

  @override String get profile => 'Profile';
  @override String get editProfile => 'Edit Profile';
  @override String get name => 'Name';
  @override String get email => 'Email';
  @override String get avatar => 'Avatar';
  @override String get changeAvatar => 'Change Avatar';
  @override String get saveChanges => 'Save Changes';
  @override String get profileUpdated => 'Profile updated';

  @override String get settings => 'Settings';
  @override String get notifSettings => 'Notifications';
  @override String get pushNotif => 'Push Notifications';
  @override String get pushNotifDesc => 'Trip updates and promotions';
  @override String get soundNotif => 'Sound';
  @override String get soundNotifDesc => 'Notification sound';
  @override String get vibrateNotif => 'Vibration';
  @override String get vibrateNotifDesc => 'Haptic feedback';
  @override String get langSettings => 'Language';
  @override String get appLanguage => 'App Language';
  @override String get selectLanguage => 'Select Language';
  @override String get langChanged => 'Language changed. Restart for full effect.';
  @override String get privacyPolicy => 'Privacy Policy';
  @override String get termsOfService => 'Terms of Service';
  @override String get clearCache => 'Clear Cache';
  @override String get clearCacheDesc => 'Clear local cache data';
  @override String get cacheCleared => 'Cache cleared';
  @override String get aboutApp => 'About Yangon Taxi';
  @override String get other => 'Other';
  @override String get version => 'Version 1.0.0';
  @override String get checkUpdate => 'Check for Updates';
  @override String get checkingUpdate => 'Checking for updates...';
  @override String get latestVersion => 'You are on the latest version';
  @override String get newVersionAvailable => 'New version available';
  @override String get updateNow => 'Update Now';
  @override String get helpSupport => 'Help & Support';
  @override String get helpSupportDesc => 'FAQ and customer support';
  @override String get contactUs => 'Contact Us';

  @override String get memberTier => 'Member Tier';
  @override String get points => 'Points';
  @override String get tripsCompleted => 'Trips Completed';
  @override String get regular => 'Regular';
  @override String get silver => 'Silver';
  @override String get gold => 'Gold';
  @override String get platinum => 'Platinum';
  @override String get tierBenefits => 'Benefits';
  @override String get upgradeTo => 'Upgrade to';
  // 等级补充
  @override String get distanceToNext => 'Distance to Next';
  @override String get needMore => 'Need more';
  @override String get maxTier => 'Max tier reached!';
  @override String get currentBadge => 'Current';
  @override String get pointsRules => 'Points Rules';
  @override String get rulePerTrip => 'Per trip completed, earn tier points';
  @override String get ruleTier => 'Higher tier, more points per trip';
  @override String get ruleRedeem => 'Redeem points for ride coupons (coming soon)';
  @override String get ruleInvite => 'Invite friends for bonus points';

  @override String get referralTitle => 'Refer & Earn';
  @override String get referralDesc => 'Invite friends and both get 5000 KS';
  @override String get myReferralCode => 'My Referral Code';
  @override String get referralReward => 'Reward';
  @override String get inviteFriends => 'Invite Friends';
  @override String get shareNow => 'Share Now';
  @override String get copied => 'Copied!';
  // 推荐补充
  @override String get perFriend => 'Per friend invited';
  @override String get couponReward => 'Ride coupon reward';
  @override String get copyCode => 'Copy invite code';
  @override String get copyShare => 'Copy share text';
  @override String get activityRules => 'Activity Rules';
  @override String get rule1 => 'Invite friends to register Yangon Taxi';
  @override String get rule2 => 'Friends complete first ride';
  @override String get rule3 => 'Both get reward';
  @override String get rule4 => 'Coupon valid for 30 days';
  @override String get rule5 => 'No limit on invites';
  @override String get simulateBtn => '📱 Simulate: Friend registers via invite code';
  @override String get simulateDesc => '(Demo: Simulate successful invite)';
  @override String get shareTextCopied => 'Share text copied, paste to WeChat/Facebook etc.';
  @override String get invitedLabel => 'Invited';
  @override String get earnedLabel => 'Earned';
  @override String inviteSuccess(int count, int amount) => '🎉 Successfully invited $count friends, earned $amount K coupon!';
  @override String codeCopiedMsg(String code) => 'Invite code copied: $code';
  @override String shareMessage(String code, int amount) => '[Yangon Taxi Refer & Earn]\nInvite code: $code\nRegister with this code, both get $amount K coupon!';

  @override String get kbzPayTitle => 'KBZ Pay';
  @override String get kbzPayDesc => 'Scan QR or enter amount to pay';
  @override String get scanQr => 'Scan QR Code';
  @override String get enterAmount => 'Enter Amount';
  @override String get kbzPayLink => 'Link KBZ Pay Account';
  @override String get kbzLinked => 'Linked successfully';
  @override String get kbzUnlink => 'Unlink Account';
  @override String get kbzUnlinkConfirm => 'Are you sure you want to unlink KBZ Pay?';
  @override String get kbzLinkAccount => 'Link KBZ Pay Account';
  @override String get kbzNotLinked => 'KBZ Pay Not Linked';
  @override String get kbzNotLinkedDesc => 'Link your KBZ Pay for instant taxi payments';
  @override String get choosePaymentMethod => 'Choose Payment Method';
  @override String get kbzQRCodePay => 'QR Code Payment';
  @override String get kbzQRCodePayDesc => 'Show payment QR code for driver to scan';
  @override String get kbzAppPay => 'In-App Payment';
  @override String get kbzAppPayDesc => 'Pay directly via KBZ Pay app';
  @override String get scanToPay => 'Scan to Pay';
  @override String get kbzQRPaymentInstructions => 'QR Payment Instructions';
  @override String get kbzPaying => 'Processing payment...';
  @override String get kbzPaymentSuccess => 'Payment Successful!';
  @override String get kbzPaymentFailed => 'Payment Failed';
  @override String get kbzQRGenerateFailed => 'QR Code Generation Failed';
  @override String get kbzPaymentTimeout => 'Payment timeout, please retry';
  @override String get kbzPayFailed => 'KBZ Pay Payment Failed';
  @override String get transactions => 'Transactions';
  @override String get noTransactions => 'No transactions yet';
  @override String get aboutKBZPay => 'About KBZ Pay';
  @override String get unlink => 'Unlink';

  @override String get savedAddresses => 'Saved Addresses';
  @override String get addAddress => 'Add Address';
  @override String get editAddress => 'Edit Address';
  @override String get addressLabel => 'Label';
  @override String setAsHome() => 'Set as Home';
  @override String setAsWork() => 'Set as Work';

  @override String get emergency => 'Emergency';
  @override String get emergencyCall => 'Call 999';
  @override String get emergencySent => 'Emergency alert sent!';
  @override String get emergencyDesc => 'Location shared with emergency contacts';
}

// ============================================================
// 缅甸语
// ============================================================
class AppLocalizationsMy extends AppLocalizations {
  AppLocalizationsMy() : super(const Locale('my'));

  @override String get appTitle => 'Yangon Taxi';
  @override String get login => 'အကောင့်ဝင်ရန်';
  @override String get register => 'အကောင့်ဖွင့်ရန်';
  @override String get phoneNumber => 'ဖုန်းနံပါတ်';
  @override String get phoneHint => '+95 9xxxxxxxxx';
  @override String get password => 'စကားဝှက်';
  @override String get confirmPassword => 'စကားဝှက်အတည်ပြု';
  @override String get confirm => 'အတည်ပြု';
  @override String get cancel => 'ပယ်ဖျက်';
  @override String get save => 'သိမ်းဆည်း';
  @override String get edit => 'ပြင်ဆင်';
  @override String get delete => 'ဖျက်ရန်';
  @override String get loading => 'ဖွင့်နေသည်...';
  @override String get success => 'အောင်မြင်သည်';
  @override String get error => 'အမှား';
  @override String get close => 'ပိတ်';
  @override String get back => 'နောက်သို့';
  @override String get yes => 'ဟုတ်ကဲ့သည်';
  @override String get no => 'မဟုတ်ပါ';
  @override String get ok => 'ဟုတ်ကဲ့';
  @override String get retry => 'ထပ်မံ';
  @override String get noData => 'ဒေတာမရှိပါ';
  @override String get orText => 'သို့မဟုတ်';

  @override String get phoneInvalid => 'တော်မှန်ကောင်းသောဖုန်းနံပါတ်ဖြည့်ပါ';
  @override String get phoneRequired => 'ဖုန်းနံပါတ်လေးလာပါ';
  @override String get otpSent => 'စကားဝှက်စတင်ပေးပါသည်';
  @override String get otpHint => '၆လုံးအကွက်သင်္ချာထည့်ပါ';
  @override String get otpInvalid => 'စကားဝှက်မှားနေပါသည်';
  @override String get otpResend => 'ထပ်ပေး';
  @override String get otpResendIn => 'ထပ်ပေးရန် ';
  @override String get agreeTerms => 'ကျေးဇူးတင်ပြီးသော်';
  @override String get termsLink => 'ဝန်ဆောင်မှုစည်းမျဉ်း';

  @override String get home => 'ပင်မစာမျက်နှာ';
  @override String get enterDestination => 'မှတ်တိုင်ထည့်ပါ';
  @override String get trips => 'ခရီးစဉ်များ';
  @override String get myProfile => 'ကိုယ်ရေးအချက်';
  @override String get whereTo => 'ဘယ်သို့သွားမည်？';
  @override String get savedPlaces => 'သိမ်းဆည်းထားသောနေရာ';
  @override String get homeAddr => 'နေအိမ်';
  @override String get workAddr => 'အလုပ်ခရီး';

  @override String get searchDestination => 'မှတ်တိုင်ရှာရန်';
  @override String get recentPlaces => 'recent';
  @override String get popularPlaces => 'လူကြိုဆိုများသောနေရာ';
  @override String get noResults => 'ရှာမတွေ့ပါ';
  @override String get pickLocation => 'နေရာရွေးချယ်ပါ';

  @override String get chooseVehicle => 'ကားအမျိုးရွေးချယ်ပါ';
  @override String get vehicleCng => 'CNG ကား';
  @override String get vehicleOil => 'ဆန်ကား';
  @override String get vehicleEv => 'အိန်ဂျင်ကား';
  @override String get vehiclePrivate => 'ကိုယ်ပိုင်ကား';
  @override String get estimatedPrice => 'ခန့်မှန်းငွေ';
  @override String get estimatedTime => 'ခန့်မှန်းအချိန်';
  @override String get vehicleTypeLabel => 'ကားအမျိုး';
  @override String get feeLabel => 'ခ';

  @override String get confirmRide => 'ကားခေါ်အတည်ပြု';
  @override String get pickupLocation => 'ပေါ်တွင်ပါဝင်ရန်';
  @override String get dropoffLocation => 'ဆုံးရွှေရန်';
  @override String get paymentMethod => 'ငွေပေးချေးနည်း';
  @override String get nearbyDrivers => 'အနီးဝန်းကျင်ဒရိုက်';
  @override String get driverArrivingIn => 'ခံတွင်း';
  @override String get driverMinAway => 'မိနစ်';

  @override String get searchingDriver => 'ဒရိုက်ဘာကြည့်နေပါသည်...';
  @override String get searchingDesc => 'ခန့်မှန်းစောင့်ဆိုင်းချိန်';
  @override String get driverAccepted => 'ဒရိုက်ခံခဲ့ပါသည်';
  @override String get driverOnWay => 'ဒရိုက်လမ်းတွင်ရောက်နေပါသည်';
  @override String get driverArrived => 'ဒရိုက်ရောက်ပြီးပါပြီ！';
  @override String get driverWaiting => 'စောင့်ဆိုင်းနေသည်';
  @override String get startRide => 'ခရီးစဉ်';
  @override String get waitingArrive => 'ဒရိုက်စောင့်ဆိုင်းနေ';
  @override String get cancelRide => 'ကားခေါ်မှုပယ်';
  @override String get cancelRideConfirm => 'ကားခေါ်မှုပယ်ပေးမလား？';
  @override String get callDriver => 'ဒရိုက်ကိုဖုန်းဆက်';

  @override String get rideInProgress => 'ခရီးစဉ်သွားနေသည်';
  @override String get headingTo => 'ပြောင်းလဲနေသောဝင်း';
  @override String get remaining => 'ကျန်ရှိ';
  @override String get arriveSoon => 'မကြာမီရောက်မည်';
  @override String get sosButton => 'SOS အရေးပါကြီး';
  @override String get sosTitle => '🚨 အရေးပါကြီး';
  @override String get sosDesc => 'သင့်နေရာကိုအရေးပါသူများကိုဖော်ကျဉ်းပေးမည်';
  @override String get sosConfirm => 'အကြောင်းကြားပေး';

  @override String get payment => 'ငွေပေးချေး';
  @override String get selectPayment => 'ငွေပေးချေးနည်းရွေးချယ်ပါ';
  @override String get tripFare => 'ခရီးစဉ်ခရန်းထားငွေ';
  @override String get distance => 'အကွာအဝေး';
  @override String get duration => 'သက်တမ်း';
  @override String get cashPayment => 'ငွေသားပေး';
  @override String get cashDesc => 'ဒရိုက်ဘာထံမှ ငွေသားပေးချေး';
  @override String get kbzPay => 'KBZ Pay';
  @override String get kbzDesc => 'မြန်မာ KBZ ဘဏ် e-wallet';
  @override String get balance => 'လက်ကျန်';
  @override String get insufficientBalance => 'လက်ကျန်မလုံလောက်ပါ';
  @override String confirmPay(String currency, int amount) => 'အတည်ပြေး $currency $amount';
  @override String get kbzProcessing => 'KBZ Pay ဆောင်ရွက်နေသည်...';
  @override String get amount => 'ပမာဏ';
  @override String get txId => 'အရောင်းအဝယ် ID';
  @override String get paymentSuccess => 'ငွေပေးချေးအောင်မြင်ပါသည်！';
  @override String get paymentFailed => 'ငွေပေးချေးမအောင်မြင်ပါ';
  @override String get payWithCash => 'ငွေသားဖြင့်ပေး';
  @override String get payWithKbz => 'KBZ Pay ဖြင့်ပေး';
  @override String get paymentSuccessDesc => 'Yangon Taxi ကိုအသုံးပြုခြင်းအတွက်ကျေးဇူးတင်ပါသည်';

  @override String get rateRide => 'ခရီးစဉ်သုံးသပ်ချက်';
  @override String get rateDesc => 'သင့်အမြင်ကိုပေးခြင်းဖြင့်တိုးတက်မြှင့်တင်ပါမည်';
  @override String get skipRating => 'ကျေးဇူးပြန်';
  @override String get submitRating => 'တင်ပေးသည်';
  @override String get terrible => 'အလွန်အရမ်း';
  @override String get bad => 'အရမ်း';
  @override String get okay => 'အသက်ရှူသော';
  @override String get good => 'ကောင်းမွန်သော';
  @override String get excellent => 'အလွန်ကောင်းမွန်သော';

  @override String get tripHistory => 'ခရီးစဉ်မှတ်တမ်း';
  @override String get allTrips => 'အားလုံး';
  @override String get completed => 'ပြီးဆုံး';
  @override String get cancelled => 'ပယ်ဖျက်';
  @override String get today => 'ယနေ့';
  @override String get yesterday => 'မနက်';
  @override String get fare => 'ခရန်းထားငွေ';
  @override String get noTrips => 'ခရီးစဉ်မရှိသေးပါ';

  @override String get tripDetail => 'ခရီးစဉ်အသေးစိတ်';
  @override String get tripDate => 'နေ့ရက်';
  @override String get tripRoute => 'လမ်းကြောင်း';
  @override String get tripVehicle => 'ကားအမျိုး';
  @override String get tripPayment => 'ငွေပေးချေးနည်း';
  @override String get shareTrip => 'ခရီးစဉ်ဖျော်ဖြေ';
  @override String get tripCopied => 'ခရီးစဉ်ကိုကိုယ်ပိုင်းတင်သွင်းချက်သို့ကူးယူပါသည်';

  @override String get profile => 'ကိုယ်ရေးအချက်';
  @override String get editProfile => 'ကိုယ်ရေးအချက်ပြင်ဆင်';
  @override String get name => 'အမည်';
  @override String get email => 'အီးမေးလ်';
  @override String get avatar => 'ဖွဲတင်ပုံ';
  @override String get changeAvatar => 'ပုံပြင်ရန်';
  @override String get saveChanges => 'ပြင်လဲမှုသိမ်း';
  @override String get profileUpdated => 'ကိုယ်ရေးအချက်ပြင်လဲပြီး';

  @override String get settings => 'ဆက်တင်စနစ်';
  @override String get notifSettings => 'အကြောင်းကြားချက်ဆက်တင်';
  @override String get pushNotif => 'အကြောင်းကြားချက်ဖြတ်ဆို';
  @override String get pushNotifDesc => 'ခရီးစဉ်အခြေအနေနှင့်ဖြိုးဖြိုးဖော်ကြောမှု';
  @override String get soundNotif => 'အသက်သွင်းသက်တမ်း';
  @override String get soundNotifDesc => 'အသစ်စကားအသက်သွင်းသက်တမ်း';
  @override String get vibrateNotif => 'ခပ်ကစားခြင်း';
  @override String get vibrateNotifDesc => 'အသစ်အကြောင်းကြားချက်ခပ်ကစားအကြောင်းကြားချက်';
  @override String get langSettings => 'ဘာသာစကား';
  @override String get appLanguage => 'အက်ပ်ဘာသာစကား';
  @override String get selectLanguage => 'ဘာသာစကားရွေးချယ်ပါ';
  @override String get langChanged => 'ဘာသာစကားပြောင်းလဲပြီး။ အပြည့်အဝနေရာတို့ကိုဖွင့်ထုတ်ပါ။';
  @override String get privacyPolicy => 'ကိုယ်ရေးလုံခြုံမှုမူဝါဒ';
  @override String get termsOfService => 'ဝန်ဆောင်မှုစည်းမျဉ်း';
  @override String get clearCache => 'ကုန်ဆုံးသိမ်းဆည်းမှုဖျက်';
  @override String get clearCacheDesc => 'ဒေါင်းမြှုပ်နှံသိမ်းဆည်းမှုဖျက်';
  @override String get cacheCleared => 'ကုန်ဆုံးသိမ်းဆည်းမှုဖျက်ပြီး';
  @override String get aboutApp => 'Yangon Taxi အကြောင်း';
  @override String get other => 'အခြား';
  @override String get version => 'ဗားရှင်း 1.0.0';
  @override String get checkUpdate => 'ဗားရှင်းစစ်ဆေး';
  @override String get checkingUpdate => 'ဗားရှင်းစစ်ဆေးနေ...';
  @override String get latestVersion => '� новшая версия'; // placeholder
  @override String get newVersionAvailable => 'ဗားရှင်းသစ်ရ';
  @override String get updateNow => 'အပ်ဒိတ်ယခုလုပ်';
  @override String get helpSupport => 'အကူအညီနှင့်ထောက်ပံ့မှု';
  @override String get helpSupportDesc => 'မေးခွန်းများနှင့်ဖောက်သည်ဝန်ဆောင်မှု';
  @override String get contactUs => 'ကျွန်ုပ်တို့အားဆက်သွယ်';

  @override String get memberTier => 'အဆင့်ဝင်အဖွဲ့ဝင်မှု';
  @override String get points => 'တိုက်';
  @override String get tripsCompleted => 'ပြီးဆုံးခရီးစဉ်များ';
  @override String get regular => 'ပုဂ္ဂလထီး';
  @override String get silver => 'ငွေသံတုံး';
  @override String get gold => 'ငွေသံ';
  @override String get platinum => 'ပလက်တီနူး';
  @override String get tierBenefits => 'အကျိုးကျက်များ';
  @override String get upgradeTo => 'တိုးတက်';

  @override String get referralTitle => 'ဖိတ်ခေါ်ဆုကြေး';
  @override String get referralDesc => 'သူငယ်ခင်းဖိတ်ခေါက်ပြီး 5000 KS စုစုပေါင်းရှိပါ';
  @override String get myReferralCode => 'ကိုယ်ပိုင်ဖိတ်ခေါ်ကုဒ်';
  @override String get referralReward => 'ဆုကြေး';
  @override String get inviteFriends => 'သူငယ်ခင်းဖိတ်ခေါက်';
  @override String get shareNow => 'အခုမျှဝေ';
  @override String get copied => 'ကူးယူပြီး';

  @override String get kbzPayTitle => 'KBZ Pay ငွေပေးချေး';
  @override String get kbzPayDesc => 'QR ဖြတ်ပြီးငွေပေးပါ';
  @override String get scanQr => 'QR ကုဒ်ဖြတ်';
  @override String get enterAmount => 'ပမာဏထည့်ရန်';
  @override String get kbzPayLink => 'KBZ Pay အကောင့်ချိတ်ဆက်';
  @override String get kbzLinked => 'ချိတ်ဆက်အောင်မြင်ပါသည်';
  @override String get kbzUnlink => 'ချိတ်ဆက်ပယ်ဖျက်';
  @override String get kbzUnlinkConfirm => 'KBZ Pay ချိတ်ဆက်မှုပယ်ဖျက်မှာသေချာပါသလား?';
  @override String get kbzLinkAccount => 'KBZ Pay အကောင့်ချိတ်ဆက်';
  @override String get kbzNotLinked => 'KBZ Pay မချိတ်ဆက်ရသေး';
  @override String get kbzNotLinkedDesc => 'ချိတ်ဆက်ပါက KBZ Pay ဖြင့်ခရီးစရိတ်ချက်ချင်းပေးနိုင်';
  @override String get choosePaymentMethod => 'ငွေပေးချေးနည်းရွေး';
  @override String get kbzQRCodePay => 'QR ကုဒ်ငွေပေးချေး';
  @override String get kbzQRCodePayDesc => 'ငွေပေးချေး QR ကုဒ်ပြနေ';
  @override String get kbzAppPay => 'App ငွေပေးချေး';
  @override String get kbzAppPayDesc => 'KBZ Pay App ဖြင့်ငွေပေးချေး';
  @override String get scanToPay => 'QR ဖြတ်ပေးချေး';
  @override String get kbzQRPaymentInstructions => 'QR ငွေပေးချေးညွှန်ကြားချက်';
  @override String get kbzPaying => 'ငွေပေးချေးဆောင်ရွက်နေ...';
  @override String get kbzPaymentSuccess => 'ငွေပေးချေးအောင်မြင်ပါသည်！';
  @override String get kbzPaymentFailed => 'ငွေပေးချေးမအောင်မြင်';
  @override String get kbzQRGenerateFailed => 'QR ကုဒ်ထုတ်မအောင်မြင်';
  @override String get kbzPaymentTimeout => 'ငွေပေးချေးအချိန်ကုန်သွားပါ';
  @override String get kbzPayFailed => 'KBZ Pay ငွေပေးချေးမအောင်မြင်';
  @override String get transactions => 'ငွေစာရင်း';
  @override String get noTransactions => 'ငွေစာရင်းမရှိသေး';
  @override String get aboutKBZPay => 'KBZ Pay အကြောင်း';
  @override String get unlink => 'ချိတ်ဆက်ပယ်ဖျက်';

  @override String get savedAddresses => 'သိမ်းဆည်းထားသောလိပ်စာများ';
  @override String get addAddress => 'လိပ်စာထည့်ရန်';
  @override String get editAddress => 'လိပ်စာပြင်ဆင်ရန်';
  @override String get addressLabel => 'အမည်ပေါင်း';
  @override String setAsHome() => 'နေအိမ်အဖြစ်သတ်မှတ်';
  @override String setAsWork() => 'အလုပ်ခရီးအဖြစ်သတ်မှတ်';

  @override String get emergency => 'အရေးပါကြီးကမ်းကွင်း';
  @override String get emergencyCall => '999 ကိုဖုန်းဆက်';
  @override String get emergencySent => 'အရေးပါကြီးအကြောင်းကြားချက်ပေးပြီး！';
  @override String get emergencyDesc => 'အရေးပါသူများသို့နေရာဖော်ကျဉ်းပေးပါမည်';
}
