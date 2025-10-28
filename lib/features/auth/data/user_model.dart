import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class TuyaUserModel {
  final String? uid;
  final String? email;
  TuyaUserModel({this.uid, this.email});

  TuyaUserModel copyWith({String? uid, String? email}) {
    return TuyaUserModel(uid: uid ?? this.uid, email: email ?? this.email);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'uid': uid, 'email': email};
  }

  factory TuyaUserModel.fromMap(Map<String, dynamic> map) {
    return TuyaUserModel(
      uid: map['uid'] != null ? map['uid'] as String : null,
      email: map['email'] != null ? map['email'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory TuyaUserModel.fromJson(String source) =>
      TuyaUserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'TuyaUserModel(uid: $uid, email: $email)';

  @override
  bool operator ==(covariant TuyaUserModel other) {
    if (identical(this, other)) return true;

    return other.uid == uid && other.email == email;
  }

  @override
  int get hashCode => uid.hashCode ^ email.hashCode;
}
