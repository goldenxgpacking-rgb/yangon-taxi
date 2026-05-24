/// 用户等级系统服务
/// 根据已完成行程数计算等级和积分
class UserTierService {
  /// 等级规则：[最低行程数, 等级名称, 图标, 颜色, 每单积分]
  static const List<Map<String, dynamic>> _tierRules = [
    {'minTrips': 0, 'tier': 'Bronze', 'icon': '🥉', 'color': 0xFFCD7F32, 'pointsPerTrip': 10},
    {'minTrips': 5, 'tier': 'Silver', 'icon': '🥈', 'color': 0xFFC0C0C0, 'pointsPerTrip': 15},
    {'minTrips': 20, 'tier': 'Gold', 'icon': '🥇', 'color': 0xFFFFD700, 'pointsPerTrip': 25},
    {'minTrips': 50, 'tier': 'Platinum', 'icon': '💎', 'color': 0xFFE5E4E2, 'pointsPerTrip': 40},
  ];

  /// 根据已完成行程数获取等级信息
  static Future<Map<String, dynamic>> getTierInfo(int completedTrips) async {
    Map<String, dynamic> currentTier = _tierRules[0];
    Map<String, dynamic> nextTier = _tierRules.length > 1 ? _tierRules[1] : _tierRules[0];

    for (int i = _tierRules.length - 1; i >= 0; i--) {
      if (completedTrips >= _tierRules[i]['minTrips']) {
        currentTier = _tierRules[i];
        nextTier = (i + 1 < _tierRules.length) ? _tierRules[i + 1] : currentTier;
        break;
      }
    }

    final points = _calculatePoints(completedTrips, currentTier['pointsPerTrip']);
    final tripsToNext = (nextTier['minTrips'] == currentTier['minTrips'])
        ? 0
        : (nextTier['minTrips'] as int) - completedTrips;

    return {
      'tier': currentTier['tier'],
      'icon': currentTier['icon'],
      'color': currentTier['color'],
      'points': points,
      'pointsPerTrip': currentTier['pointsPerTrip'],
      'completedTrips': completedTrips,
      'nextTier': nextTier['tier'],
      'nextTierIcon': nextTier['icon'],
      'tripsToNext': tripsToNext,
      'minTripsForNext': nextTier['minTrips'],
    };
  }

  /// 计算总积分
  static int _calculatePoints(int trips, int pointsPerTrip) {
    int total = 0;
    int remaining = trips;
    for (int i = _tierRules.length - 1; i >= 0; i--) {
      final min = _tierRules[i]['minTrips'] as int;
      final ppm = _tierRules[i]['pointsPerTrip'] as int;
      if (remaining >= min) {
        total += (remaining - min + 1) * ppm;
        remaining = min - 1;
      }
    }
    return total;
  }

  /// 获取所有等级列表（用于展示）
  static List<Map<String, dynamic>> getAllTiers() {
    return _tierRules.map((t) => {...t}).toList();
  }

  /// 根据等级名称获取颜色
  static int getTierColor(String tier) {
    final rule = _tierRules.firstWhere(
      (t) => t['tier'] == tier,
      orElse: () => _tierRules[0],
    );
    return rule['color'] as int;
  }
}
