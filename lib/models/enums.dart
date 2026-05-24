/// 车型枚举
enum VehicleType {
  cngCar('CNG CAR', 'CNG 车', 'CNG ကား'),
  oilCar('OIL CAR', '燃油车', 'ဒီဇယ်ကား'),
  evCar('EV CAR', '电动车', 'လျှပ်စစ်ကား'),
  privateCar('私家车', '私家车', 'ကိုယ်ပိုင်ကား');

  final String code;
  final String labelZh;
  final String labelMy;

  const VehicleType(this.code, this.labelZh, this.labelMy);

  String label(String locale) {
    if (locale == 'my') return labelMy;
    if (locale == 'zh') return labelZh;
    return code;
  }
}

/// 行程状态枚举
enum TripStatus {
  pending('pending', '待确认', 'စောင့်ဆိုင်း'),
  confirmed('confirmed', '已确认', 'အတည်ပြု'),
  arriving('arriving', '司机到达中', 'မော်တော်ယာဉ်ရောက်လာဆဲ'),
  inProgress('in_progress', '行程中', 'ခရီးစဉ်လုပ်ဆောင်နေသည်'),
  completed('completed', '已完成', 'ပြီးဆုံး'),
  cancelled('cancelled', '已取消', 'ပယ်ဖျက်'),
  noShow('no_show', '司机未到', 'မော်တော်ယာဉ်မရောက်');

  final String code;
  final String labelZh;
  final String labelMy;

  const TripStatus(this.code, this.labelZh, this.labelMy);

  String label(String locale) {
    if (locale == 'my') return labelMy;
    if (locale == 'zh') return labelZh;
    return code;
  }
}

/// 支付方式枚举
enum PaymentMethod {
  cash('cash', '现金', 'ငွေသား'),
  kbzPay('kbz_pay', 'KBZ Pay', 'KBZ Pay');

  final String code;
  final String labelZh;
  final String labelMy;

  const PaymentMethod(this.code, this.labelZh, this.labelMy);

  String label(String locale) {
    if (locale == 'my') return labelMy;
    if (locale == 'zh') return labelZh;
    return code;
  }
}

/// 用户等级
enum UserTier {
  regular('regular', '普通会员', 'ပုံမှန်အသုံးပြုသူ', 0),
  silver('silver', '银卡会员', 'ငွေအဆင့်', 500),
  gold('gold', '金卡会员', 'ရွှေအဆင့်', 2000),
  platinum('platinum', '铂金会员', 'ပလတ်တင်နင်း', 5000);

  final String code;
  final String labelZh;
  final String labelMy;
  final int minPoints;

  const UserTier(this.code, this.labelZh, this.labelMy, this.minPoints);

  static UserTier fromPoints(int points) {
    if (points >= 5000) return platinum;
    if (points >= 2000) return gold;
    if (points >= 500) return silver;
    return regular;
  }
}
