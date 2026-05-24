import 'enums.dart';

/// 用户模型
class User {
  final String id;
  final String phone;
  final String? email;
  final String? name;
  final String? avatarUrl;
  final int points;
  final UserTier tier;
  final String? referralCode;
  final DateTime createdAt;

  User({
    required this.id,
    required this.phone,
    this.email,
    this.name,
    this.avatarUrl,
    this.points = 0,
    this.tier = UserTier.regular,
    this.referralCode,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      name: json['name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      points: json['points'] as int? ?? 0,
      tier: UserTier.values.firstWhere(
        (t) => t.code == json['tier'],
        orElse: () => UserTier.regular,
      ),
      referralCode: json['referral_code'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'email': email,
      'name': name,
      'avatar_url': avatarUrl,
      'points': points,
      'tier': tier.code,
      'referral_code': referralCode,
      'created_at': createdAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? phone,
    String? email,
    String? name,
    String? avatarUrl,
    int? points,
    UserTier? tier,
    String? referralCode,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      points: points ?? this.points,
      tier: tier ?? this.tier,
      referralCode: referralCode ?? this.referralCode,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// 常用地址模型
class SavedAddress {
  final String id;
  final String label;
  final double lat;
  final double lng;
  final String address;
  final bool isHome;
  final bool isWork;

  SavedAddress({
    required this.id,
    required this.label,
    required this.lat,
    required this.lng,
    required this.address,
    this.isHome = false,
    this.isWork = false,
  });

  factory SavedAddress.fromJson(Map<String, dynamic> json) {
    return SavedAddress(
      id: json['id'] as String,
      label: json['label'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      address: json['address'] as String,
      isHome: json['is_home'] as bool? ?? false,
      isWork: json['is_work'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'lat': lat,
      'lng': lng,
      'address': address,
      'is_home': isHome,
      'is_work': isWork,
    };
  }
}
