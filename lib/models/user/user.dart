class UserModel {
  const UserModel({
    required this.uid,
    required this.name,
    required this.phone,
    required this.email,
    this.createdAt,
    this.updatedAt,
  });

  final String uid;
  final String name;
  final String phone;
  final String email;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: (data['uid'] as String?) ?? '',
      name: (data['name'] as String?) ?? '',
      phone: (data['phone'] as String?) ?? '',
      email: (data['email'] as String?) ?? '',
      createdAt: _dateTimeFromValue(data['createdAt']),
      updatedAt: _dateTimeFromValue(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name.trim(),
      'phone': phone,
      'email': email.trim().toLowerCase(),
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? phone,
    String? email,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime? _dateTimeFromValue(Object? value) {
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is DateTime) return value;
    return null;
  }
}