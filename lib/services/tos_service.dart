import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/tos_screen.dart' show kTosVersion, kTosPrefKey;

class TosService {
  static final TosService instance = TosService._();
  TosService._();

  final _db = Supabase.instance.client;

  /// Returns true if the given user still needs to accept the current TOS version.
  Future<bool> needsAcceptance(String userId) async {
    // Check SharedPreferences first (fast, device-level cache per user)
    final prefs = await SharedPreferences.getInstance();
    final key = '${kTosPrefKey}_$userId';
    final acceptedVersion = prefs.getString(key);
    if (acceptedVersion == kTosVersion) return false;
    return true;
  }

  /// Record acceptance in SharedPreferences AND in the database.
  Future<void> recordAcceptance(String userId) async {
    final now = DateTime.now().toUtc().toIso8601String();

    // 1. Device-side cache — fast check on next open
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${kTosPrefKey}_$userId', kTosVersion);

    // 2. Database — professional audit trail
    try {
      await _db.from('users').update({
        'tos_accepted_at': now,
        'tos_version':     kTosVersion,
      }).eq('id', userId);
    } catch (e) {
      debugPrint('[TosService] DB update failed (non-fatal): $e');
    }
  }
}
