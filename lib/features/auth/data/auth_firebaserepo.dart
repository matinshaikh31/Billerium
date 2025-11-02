import 'package:billing_software/core/services/firebase.dart';
import 'package:billing_software/features/auth/domain/repo/auth_repo.dart';

class AuthFirebaseRepo extends AuthRepo {
  final firebaseAuth = FBAuth.auth;
  @override
  Future<void> login(String email, String password) async {
    await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  @override
  Stream<bool> authStateChanges() {
    return firebaseAuth.authStateChanges().map((user) => user != null);
  }

  @override
  Future<void> forgetPassword(String email) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }
}
