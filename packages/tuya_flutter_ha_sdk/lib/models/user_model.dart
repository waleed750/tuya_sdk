import 'dart:convert';

class ThingSmartUserModel {
  /// The user's uid.
  final String? uid;

  /// The user's username.
  final String? username;

  /// The user's country code.
  final String? countryCode;

  /// The user's email.
  final String? email;

  /// The user's region code.
  final String? regionCode;

  /// The user's phone number.
  final String? phoneNumber;

  /// The user's nickname.
  final String? nickname;

  /// The user's head icon URL.
  ///
  /// This is null if the user has not set a head icon.
  final String? headIconUrl;

  /// The users Temp Unit.
  final String? tempUnit;

  /// The users Time Zone ID.
  final String? timezoneId;

  /// The users Region From.
  final String? regFrom;

  ThingSmartUserModel.fromJson(Map<String, dynamic> json)
    : uid = json['uid'],
      username = json['userName'],
      countryCode = json['countryCode'],
      email = json['email'],
      regionCode = json['regionCode'],
      phoneNumber = json['phoneNumber'],
      nickname = json['snsNickname'],
      headIconUrl =
          json['headIconUrl'].toString().isEmpty
              ? null
              : json['headIconUrl'].toString().startsWith('http')
              ? json['headIconUrl']
              : 'https://images.tuyaeu.com/${json['headIconUrl']}',
      tempUnit = json['tempUnit'],
      timezoneId = json['timezoneId'],
      regFrom = json['regFrom'];

  /// Create a [ThingSmartUserModel] from a Map. Alias for [fromJson].
  factory ThingSmartUserModel.fromMap(Map<String, dynamic> map) =>
      ThingSmartUserModel.fromJson(map);

  /// Convert this model to a Map using the same keys expected by [fromJson].
  Map<String, dynamic> toMap() => {
    'uid': uid,
    'userName': username,
    'countryCode': countryCode,
    'email': email,
    'regionCode': regionCode,
    'phoneNumber': phoneNumber,
    'snsNickname': nickname,
    'headIconUrl': headIconUrl,
    'tempUnit': tempUnit,
    'timezoneId': timezoneId,
    'regFrom': regFrom,
  };

  /// JSON string representation of this model.
  String toJson() => json.encode(toMap());

  /// Backwards-compatible alias for `toMap()` used elsewhere in the project.
  Map<String, dynamic> asMap() => toMap();
}
