import 'dart:convert';

/// Model representing a Home/House returned by the Tuya SDK.
///
/// Example map:
/// {geoName: saudi, inviteName: null, roomIds: , role: 2, managementStatus: true,
///  background: , name: home, admin: true, lon: 0.0, homeStatus: 2,
///  homeId: 256961959, lat: 0.0}
///
///
enum HomeJoinStatus { pending, accepted, rejected, unknown }

HomeJoinStatus mapHomeStatus(int? v) {
  switch (v) {
    case 1:
      return HomeJoinStatus.pending;
    case 2:
      return HomeJoinStatus.accepted;
    case 3:
      return HomeJoinStatus.rejected;
    default:
      return HomeJoinStatus.unknown;
  }
}

class ThingSmartHomeModel {
  final String? geoName;
  final String? inviteName;
  final List<dynamic>? roomIds;
  final int? role;
  final bool? managementStatus;
  final String? background;
  final String? name;
  final bool? admin;
  final double? lon;
  final HomeJoinStatus? homeStatus;
  final int? homeId;
  final double? lat;

  ThingSmartHomeModel({
    required this.geoName,
    this.inviteName,
    required this.roomIds,
    required this.role,
    required this.managementStatus,
    this.background,
    required this.name,
    required this.admin,
    required this.lon,
    required this.homeStatus,
    required this.homeId,
    required this.lat,
  });

  /// Create from a map (commonly the parsed JSON returned by native SDKs).
  ThingSmartHomeModel.fromJson(Map<String, dynamic> json)
    : geoName = (json['geoName'] ?? '').toString(),
      inviteName =
          json['inviteName'] == null || json['inviteName'].toString().isEmpty
              ? null
              : json['inviteName'].toString(),
      // roomIds can be a List or a comma-separated String or empty
      roomIds = _parseRoomIds(json['roomIds']),
      role = _intFrom(json['role']),
      managementStatus = _boolFrom(json['managementStatus']),
      background =
          json['background'] == null || json['background'].toString().isEmpty
              ? null
              : json['background'].toString(),
      name = (json['name'] ?? '').toString(),
      admin = _boolFrom(json['admin']),
      lon = _doubleFrom(json['lon']),
      homeStatus = mapHomeStatus(_intFrom(json['homeStatus'])),
      homeId = _intFrom(json['homeId']),
      lat = _doubleFrom(json['lat']);

  ThingSmartHomeModel copyWith({
    String? geoName,
    String? inviteName,
    List<dynamic>? roomIds,
    int? role,
    bool? managementStatus,
    String? background,
    String? name,
    bool? admin,
    double? lon,
    HomeJoinStatus? homeStatus,
    int? homeId,
    double? lat,
  }) {
    return ThingSmartHomeModel(
      geoName: geoName ?? this.geoName,
      inviteName: inviteName ?? this.inviteName,
      roomIds: roomIds ?? this.roomIds,
      role: role ?? this.role,
      managementStatus: managementStatus ?? this.managementStatus,
      background: background ?? this.background,
      name: name ?? this.name,
      admin: admin ?? this.admin,
      lon: lon ?? this.lon,
      homeStatus: homeStatus ?? this.homeStatus,
      homeId: homeId ?? this.homeId,
      lat: lat ?? this.lat,
    );
  }

  Map<String, dynamic> toMap() => {
    'geoName': geoName,
    'inviteName': inviteName,
    'roomIds': roomIds,
    'role': role,
    'managementStatus': managementStatus,
    'background': background,
    'name': name,
    'admin': admin,
    'lon': lon,
    'homeStatus': homeStatus,
    'homeId': homeId,
    'lat': lat,
  };

  factory ThingSmartHomeModel.fromMap(Map<String, dynamic> map) =>
      ThingSmartHomeModel.fromJson(map);

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'ThingSmartHomeModel(homeId: $homeId, name: $name, geoName: $geoName)';

  // --- helpers ---
  static List<dynamic> _parseRoomIds(dynamic raw) {
    if (raw == null) return <dynamic>[];
    if (raw is List) return raw;
    final s = raw.toString().trim();
    if (s.isEmpty) return <dynamic>[];
    // If comma-separated like "1,2,3"
    try {
      return s
          .split(',')
          .map((e) {
            final t = e.trim();
            if (t.isEmpty) return null;
            final n = int.tryParse(t);
            return n ?? t;
          })
          .where((e) => e != null)
          .toList();
    } catch (_) {
      return <dynamic>[];
    }
  }

  static int _intFrom(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  static double _doubleFrom(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static bool _boolFrom(dynamic v) {
    if (v == null) return false;
    if (v is bool) return v;
    final s = v.toString().toLowerCase();
    return s == 'true' || s == '1';
  }
}
