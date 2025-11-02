abstract class AuthRepo {
  Future<void> login(String email, String password);
  Future<void> logout();
  Stream<bool> authStateChanges();
  Future<void> forgetPassword(String email);
}
