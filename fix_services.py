import re

# Fix trip_detail_screen.dart - all nullable String usages
with open(r'D:\yangon_taxi\lib\screens\trip_detail_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

replacements = [
    ('trip.dropoffTime,', 'trip.dropoffTime ?? "",'),
    ('trip.driverName,', 'trip.driverName ?? "",'),
    ('trip.vehicleType,', 'trip.vehicleType ?? "",'),
    ('trip.vehicleName,', 'trip.vehicleName ?? "",'),
    ('trip.vehiclePlate,', 'trip.vehiclePlate ?? "",'),
    ('trip.driverRating,', 'trip.driverRating ?? "",'),
    ('trip.driverPhone,', 'trip.driverPhone ?? "",'),
    ('trip.destinationAddress,', 'trip.destinationAddress ?? "",'),
]

for old, new in replacements:
    content = content.replace(old, new)

with open(r'D:\yangon_taxi\lib\screens\trip_detail_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print('trip_detail_screen.dart fixed')

# Fix trip_history_screen.dart
with open(r'D:\yangon_taxi\lib\screens\trip_history_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()
content = content.replace('trip.paymentMethod,', 'trip.paymentMethod ?? "cash",')
with open(r'D:\yangon_taxi\lib\screens\trip_history_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print('trip_history_screen.dart fixed')

# Fix auth_service.dart - the getCurrentUser _client.get call
with open(r'D:\yangon_taxi\lib\services\auth_service.dart', 'r', encoding='utf-8') as f:
    content = f.read()
# Add parser argument to the getCurrentUser call
content = content.replace(
    "return _client.get('/auth/me',\n      parser: (json) => User.fromJson(json as Map<String, dynamic>),\n    );",
    "return _client.get('/auth/me',\n      parser: (json) => User.fromJson(json as Map<String, dynamic>),\n    );"
)
# Actually this won't match since we already fixed auth_service... let me check if it has the parser
# The actual issue is that we need the parser. Let me just fix it directly
if "parser:" not in content.split("getCurrentUser")[1].split("}")[0]:
    content = content.replace(
        "return _client.get('/auth/me',",
        "return _client.get('/auth/me',\n      parser: (json) => User.fromJson(json as Map<String, dynamic>),"
    )
with open(r'D:\yangon_taxi\lib\services\auth_service.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print('auth_service.dart fixed')

# Fix push_notification_service.dart
with open(r'D:\yangon_taxi\lib\services\push_notification_service.dart', 'r', encoding='utf-8') as f:
    content = f.read()
content = content.replace(
    'resolvePlatformSpecificImplementation<IOSInitializationSettings>()',
    'resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()'
)
with open(r'D:\yangon_taxi\lib\services\push_notification_service.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print('push_notification_service.dart fixed')

# Fix trip_service.dart - missing VehicleType import
with open(r'D:\yangon_taxi\lib\services\trip_service.dart', 'r', encoding='utf-8') as f:
    content = f.read()
if "import '../models/enums.dart';" not in content:
    content = content.replace(
        "import 'api_client.dart';",
        "import 'api_client.dart';\nimport '../models/enums.dart';"
    )
with open(r'D:\yangon_taxi\lib\services\trip_service.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print('trip_service.dart fixed')

print('All fixes applied!')
