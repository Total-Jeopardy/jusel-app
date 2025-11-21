import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final String role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  AppUser({
    required this.uid,
    required this.email,
    required this.phone,
    required this.name,
    required this.role,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'role': role,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt == null ? null : Timestamp.fromDate(updatedAt!),
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      role: json['role'] as String,
      isActive: json['isActive'] as bool,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: json['updatedAt'] == null
          ? null
          : (json['updatedAt'] as Timestamp).toDate(),
    );
  }
}
