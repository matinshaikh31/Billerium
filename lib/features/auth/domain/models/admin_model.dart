import 'package:equatable/equatable.dart';

class AdminModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;
  final DateTime? lastLogin;

  const AdminModel({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    this.lastLogin,
  });

  AdminModel copyWith({
    String? id,
    String? name,
    String? email,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return AdminModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  @override
  List<Object?> get props => [id, name, email, createdAt, lastLogin];
}

