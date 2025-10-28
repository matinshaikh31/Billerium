import '../models/admin_model.dart';

abstract class AuthRepository {
  Future<AdminModel> login(String email, String password);
  Future<void> logout();
  Future<AdminModel?> getCurrentAdmin();
  Future<void> updateLastLogin(String adminId);
  Future<void> resetPassword(String email);
  Stream<AdminModel?> get authStateChanges;
}

