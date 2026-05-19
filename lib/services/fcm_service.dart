import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// FCM (Firebase Cloud Messaging) is not yet integrated in this build.
// This stub keeps the app compiling; replace with real Firebase implementation
// once firebase_messaging is added to pubspec.yaml and Firebase is configured.

Future<void> firebaseBackgroundHandler(dynamic message) async {}

class FcmService {
  static final FcmService instance = FcmService._();
  FcmService._();

  static GoRouter? _router;
  static void setRouter(GoRouter router) => _router = router;

  static GlobalKey<NavigatorState>? _navigatorKey;
  static void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }

  Future<void> initialize(String studentId, String batch) async {}
  Future<void> dispose(String studentId, String batch) async {}
}
