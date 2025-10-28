import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/models/admin_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../dto/admin_dto.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<AdminModel> login(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = userCredential.user!.uid;

      // Get admin profile from Firestore
      final adminDoc = await _firestore
          .collection(AppConstants.adminsCollection)
          .doc(userId)
          .get();

      if (!adminDoc.exists) {
        // Create admin profile if it doesn't exist
        final newAdmin = AdminDto(
          id: userId,
          name: email.split('@')[0],
          email: email,
          createdAt: Timestamp.now(),
          lastLogin: Timestamp.now(),
        );

        await _firestore
            .collection(AppConstants.adminsCollection)
            .doc(userId)
            .set(newAdmin.toJson());

        return newAdmin.toModel();
      }

      // Update last login
      await updateLastLogin(userId);

      final adminDto = AdminDto.fromJson(adminDoc.data()!, userId);
      return adminDto.toModel();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  @override
  Future<AdminModel?> getCurrentAdmin() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;

      final adminDoc = await _firestore
          .collection(AppConstants.adminsCollection)
          .doc(user.uid)
          .get();

      if (!adminDoc.exists) return null;

      final adminDto = AdminDto.fromJson(adminDoc.data()!, user.uid);
      return adminDto.toModel();
    } catch (e) {
      throw Exception('Failed to get current admin: ${e.toString()}');
    }
  }

  @override
  Future<void> updateLastLogin(String adminId) async {
    try {
      await _firestore
          .collection(AppConstants.adminsCollection)
          .doc(adminId)
          .update({'lastLogin': Timestamp.now()});
    } catch (e) {
      throw Exception('Failed to update last login: ${e.toString()}');
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  @override
  Stream<AdminModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return await getCurrentAdmin();
    });
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Wrong password';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }
}

