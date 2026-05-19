import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';
import '../services/ai_service.dart';

const _kSessionUserId   = 'session_user_id';
const _kSessionIsAdmin  = 'session_is_admin';
const _kSessionUserJson = 'session_user_json'; // cached user so offline restore works

final currentUserProvider = StateProvider<UserModel?>((ref) => null);

final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider)?.isAdmin ?? false;
});

class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  AuthNotifier() : super(const AsyncLoading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(_kSessionUserId);

      // No saved session → go to login
      if (userId == null) { state = const AsyncData(null); return; }

      // Try to get fresh data from Supabase
      try {
        final user = await SupabaseService.instance.getUserById(userId);
        if (user != null && !user.isBanned) {
          AuthService.instance.setCurrentUser(user);
          if (user.isAdmin) await AiService.instance.loadSavedKey();
          // Update cache with fresh data
          await _cacheUser(prefs, user);
          state = AsyncData(user);
          return;
        } else if (user != null && user.isBanned) {
          // Definitively banned — clear session
          await _clearSession(prefs);
          state = const AsyncData(null);
          return;
        }
        // user == null means not found in DB — could be deleted; fall through to cache
      } catch (_) {
        // Supabase unreachable (network error, wrong port, 400 from bad schema, etc.)
        // Fall through to local cache so the user isn't force-logged-out
      }

      // Supabase unavailable — try local cache
      final cachedJson = prefs.getString(_kSessionUserJson);
      if (cachedJson != null) {
        try {
          final map = jsonDecode(cachedJson) as Map<String, dynamic>;
          final user = _userFromCache(map);
          AuthService.instance.setCurrentUser(user);
          if (user.isAdmin) await AiService.instance.loadSavedKey();
          state = AsyncData(user);
          return;
        } catch (_) {
          // Cache corrupt — clear and force login
        }
      }

      // Nothing worked — force login (but keep session key so next open can retry)
      state = const AsyncData(null);
    } catch (_) {
      state = const AsyncData(null);
    }
  }

  // ── Session helpers ───────────────────────────────────────────

  Future<void> _saveSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSessionUserId, user.id);
    await prefs.setBool(_kSessionIsAdmin, user.isAdmin);
    await _cacheUser(prefs, user);
  }

  Future<void> _cacheUser(SharedPreferences prefs, UserModel user) async {
    try {
      await prefs.setString(_kSessionUserJson, jsonEncode(_userToCache(user)));
    } catch (_) {}
  }

  Future<void> _clearSession([SharedPreferences? prefs]) async {
    final p = prefs ?? await SharedPreferences.getInstance();
    await p.remove(_kSessionUserId);
    await p.remove(_kSessionIsAdmin);
    await p.remove(_kSessionUserJson);
  }

  Map<String, dynamic> _userToCache(UserModel u) => {
    'id': u.id, 'name': u.name, 'username': u.username,
    'passwordHash': u.passwordHash, 'studentClass': u.studentClass,
    'batch': u.batch, 'prepcoins': u.prepcoins, 'isAdmin': u.isAdmin,
    'isBanned': u.isBanned, 'createdAt': u.createdAt.toIso8601String(),
    'monthlyPayments': u.monthlyPayments,
    'feeExemptMonths': u.feeExemptMonths,
  };

  UserModel _userFromCache(Map<String, dynamic> m) => UserModel(
    id: m['id'], name: m['name'], username: m['username'],
    passwordHash: m['passwordHash'], studentClass: m['studentClass'] ?? '11',
    batch: m['batch'] ?? '11 NEET', prepcoins: m['prepcoins'] ?? 0,
    isAdmin: m['isAdmin'] ?? false, isBanned: m['isBanned'] ?? false,
    createdAt: DateTime.parse(m['createdAt']),
    monthlyPayments: (m['monthlyPayments'] as Map? ?? {})
        .map((k, v) => MapEntry(k.toString(), v == true)),
    feeExemptMonths: List<String>.from(m['feeExemptMonths'] ?? []),
  );

  // ── Auth actions ──────────────────────────────────────────────

  Future<void> refreshCurrentUser() async {
    final current = state.value;
    if (current == null) return;
    try {
      final fresh = await SupabaseService.instance.getUserById(current.id);
      if (fresh != null && !fresh.isBanned) {
        await _saveSession(fresh);
        state = AsyncData(fresh);
      }
    } catch (_) {}
  }

  Future<void> tryRestoreSession() => _init();

  Future<AuthResult> loginStudent(String username, String password) async {
    state = const AsyncLoading();
    try {
      final dbUser = await SupabaseService.instance.getUserByUsername(username);

      if (dbUser != null && !dbUser.isAdmin && !dbUser.isBanned) {
        final hashed = AuthService.hashPassword(password);
        if (dbUser.passwordHash != hashed) {
          state = const AsyncData(null);
          return AuthResult.invalidCredentials;
        }

        // Save session FIRST — so it persists even if the lastLogin update below fails
        await _saveSession(dbUser);
        state = AsyncData(dbUser);

        // Update lastLogin in the background — non-critical, failures won't affect session
        _tryUpdateLastLogin(dbUser);

        return AuthResult.success;
      }

      if (dbUser?.isAdmin == true) { state = const AsyncData(null); return AuthResult.adminBlocked; }
      if (dbUser?.isBanned == true) { state = const AsyncData(null); return AuthResult.banned; }
      state = const AsyncData(null);
      return AuthResult.invalidCredentials;

    } catch (_) {
      // Supabase unreachable — try local
      final result = await AuthService.instance.loginStudent(username, password);
      if (result == AuthResult.success) {
        final u = AuthService.instance.currentUser;
        if (u != null) {
          await _saveSession(u);
          state = AsyncData(u);
        }
      } else {
        state = const AsyncData(null);
      }
      return result;
    }
  }

  // Fire-and-forget lastLogin update — never blocks or fails login
  void _tryUpdateLastLogin(UserModel user) async {
    try {
      user.lastLogin = DateTime.now();
      await SupabaseService.instance.upsertUser(user);
    } catch (_) {} // Non-critical
  }

  Future<AuthResult> loginAdmin(String username, String password) async {
    state = const AsyncLoading();
    final result = await AuthService.instance.loginAdmin(username, password);
    if (result == AuthResult.success) {
      final u = AuthService.instance.currentUser!;
      await _saveSession(u);
      state = AsyncData(u);
      await AiService.instance.loadSavedKey();
    } else {
      state = const AsyncData(null);
    }
    return result;
  }

  void setUser(UserModel user) => state = AsyncData(user);

  Future<void> logout() async {
    AuthService.instance.logout();
    await _clearSession();
    state = const AsyncData(null);
  }

  UserModel? get currentUser => state.value;
}

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>(
  (_) => AuthNotifier(),
);
