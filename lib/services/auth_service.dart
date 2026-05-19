import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../core/constants/app_constants.dart';
import 'storage_service.dart';
import 'supabase_service.dart';

enum AuthResult { success, invalidCredentials, banned, adminBlocked }

class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();
  AuthService._();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin == true;

  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  // Check if admin backdoor triggered (4444/4444)
  bool isAdminTrigger(String username, String password) =>
      username == AppConstants.adminTriggerUsername &&
      password == AppConstants.adminTriggerPassword;

  // Student login — any is_admin user is blocked here regardless of credentials
  Future<AuthResult> loginStudent(String username, String password) async {
    final user = StorageService.instance.getUserByUsername(username);
    if (user == null) return AuthResult.invalidCredentials;
    if (user.isAdmin) return AuthResult.adminBlocked;
    if (user.isBanned) return AuthResult.banned;

    final hashed = hashPassword(password);
    if (user.passwordHash != hashed) return AuthResult.invalidCredentials;

    _currentUser = user;
    user.lastLogin = DateTime.now();
    await StorageService.instance.saveUser(user);
    return AuthResult.success;
  }

  // Admin-only login via the secret dialog — checks Supabase database
  Future<AuthResult> loginAdmin(String username, String password) async {
    try {
      final adminUser = await SupabaseService.instance.getUserByUsername(username.trim());
      if (adminUser == null || !adminUser.isAdmin) return AuthResult.invalidCredentials;
      if (adminUser.isBanned) return AuthResult.banned;

      final hashed = hashPassword(password);
      if (adminUser.passwordHash != hashed) return AuthResult.invalidCredentials;

      // Update last login
      adminUser.lastLogin = DateTime.now();
      await SupabaseService.instance.upsertUser(adminUser);

      _currentUser = adminUser;
      return AuthResult.success;
    } catch (_) {
      // If Supabase is unreachable, fail safely — no hardcoded fallback
      return AuthResult.invalidCredentials;
    }
  }

  void setCurrentUser(UserModel user) {
    _currentUser = user;
  }

  void logout() {
    _currentUser = null;
  }

  Future<void> updateCurrentUser() async {
    if (_currentUser == null) return;
    final fresh = StorageService.instance.getUser(_currentUser!.id);
    if (fresh != null) _currentUser = fresh;
  }
}
