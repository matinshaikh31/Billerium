import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/admin_model.dart';

class AdminDto {
  final String id;
  final String name;
  final String email;
  final Timestamp createdAt;
  final Timestamp? lastLogin;

  AdminDto({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    this.lastLogin,
  });

  factory AdminDto.fromJson(Map<String, dynamic> json, String id) {
    return AdminDto(
      id: id,
      name: json['name'] as String,
      email: json['email'] as String,
      createdAt: json['createdAt'] as Timestamp,
      lastLogin: json['lastLogin'] as Timestamp?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'createdAt': createdAt,
      'lastLogin': lastLogin,
    };
  }

  AdminModel toModel() {
    return AdminModel(
      id: id,
      name: name,
      email: email,
      createdAt: createdAt.toDate(),
      lastLogin: lastLogin?.toDate(),
    );
  }

  factory AdminDto.fromModel(AdminModel model) {
    return AdminDto(
      id: model.id,
      name: model.name,
      email: model.email,
      createdAt: Timestamp.fromDate(model.createdAt),
      lastLogin: model.lastLogin != null
          ? Timestamp.fromDate(model.lastLogin!)
          : null,
    );
  }
}

