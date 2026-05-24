with open(r'D:\yangon_taxi\lib\screens\trip_history_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

fixes = [
    ('trip.paymentMethod,', 'trip.paymentMethod ?? "cash",'),
    ('trip.vehicleName,', 'trip.vehicleName ?? "",'),
    ('trip.driverName,', 'trip.driverName ?? "",'),
    ('trip.vehiclePlate,', 'trip.vehiclePlate ?? "",'),
    ('trip.driverRating,', 'trip.driverRating ?? "",'),
    ('trip.vehicleColor,', 'trip.vehicleColor ?? "",'),
    ('trip.dropoffTime,', 'trip.dropoffTime ?? "",'),
    ('trip.pickupLat,', 'trip.pickupLat ?? "",'),
    ('trip.pickupLng,', 'trip.pickupLng ?? "",'),
    ('trip.destLat,', 'trip.destLat ?? "",'),
    ('trip.destLng,', 'trip.destLng ?? "",'),
]

for old, new in fixes:
    if old in content:
        content = content.replace(old, new)
        print(f'Fixed: {old.strip()}')

with open(r'D:\yangon_taxi\lib\screens\trip_history_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print('Done')
