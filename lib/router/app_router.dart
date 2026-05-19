import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/routes.dart';
import '../providers/auth_provider.dart';

// Screens
import '../features/splash/splash_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/admin/admin_shell.dart';
import '../features/admin/dashboard/admin_dashboard.dart';
import '../features/admin/exam_engine/exam_engine_screen.dart';
import '../features/admin/exam_engine/exam_creator_screen.dart';
import '../features/admin/exam_engine/exam_statistics_screen.dart';
import '../features/admin/database/database_screen.dart';
import '../features/admin/pyq_admin/pyq_upload_screen.dart';
import '../features/admin/notes_admin/notes_admin_screen.dart';
import '../features/admin/student_activity/student_activity_screen.dart';
import '../features/admin/credits/credits_screen.dart';
import '../features/admin/developer/developer_admin_screen.dart';
import '../features/admin/ai_settings/ai_settings_screen.dart';
import '../features/admin/batch_management/batch_management_screen.dart';
import '../features/admin/notifications/send_notification_screen.dart';
import '../features/student/student_shell.dart';
import '../features/student/dashboard/student_dashboard.dart';
import '../features/student/online_test/online_test_screen.dart';
import '../features/student/cbt/cbt_portal.dart';
import '../features/student/cbt/exam_result_screen.dart';
import '../features/student/pyq/pyq_screen.dart';
import '../features/student/flashcards/flashcard_screen.dart';
import '../features/student/flashcards/flashcard_viewer.dart';
import '../features/student/lesson_planner/lesson_planner_screen.dart';
import '../features/student/glossary/glossary_screen.dart';
import '../features/student/bio_lab/bio_lab_screen.dart';
import '../features/student/games/games_screen.dart';
import '../features/student/history/history_screen.dart';
import '../features/student/chatbot/chatbot_screen.dart';
import '../features/student/notes/notes_screen.dart';
import '../features/student/external_links/external_links_screen.dart';
import '../features/student/results/offline_results_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _adminShellKey  = GlobalKey<NavigatorState>(debugLabel: 'admin');
final _studentShellKey = GlobalKey<NavigatorState>(debugLabel: 'student');

// GoRouter is created ONCE and refreshed (not recreated) when auth changes.
// Previously, ref.watch(authProvider) inside Provider<GoRouter> created a NEW
// GoRouter on every auth state change — corrupting the navigator stack and
// causing the "stuck on refresh" bug.
final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Routes.splash,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final user      = authState.value;
      final isLoading = authState.isLoading;

      final isSplash = state.matchedLocation == Routes.splash;
      final isLogin  = state.matchedLocation == Routes.login;

      if (isLoading) return isSplash ? null : Routes.splash;
      if (user == null && !isSplash && !isLogin) return Routes.login;
      if (user != null && (isSplash || isLogin)) {
        return user.isAdmin ? Routes.adminDashboard : Routes.studentDashboard;
      }
      return null;
    },
    routes: [
      GoRoute(path: Routes.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(path: Routes.login,  builder: (_, __) => const LoginScreen()),

      // ── CBT and Result are OUTSIDE every shell so they render full-screen
      //    with no navigation bar — students cannot navigate away mid-exam.
      GoRoute(path: Routes.cbt, builder: (_, s) => CBTPortal(
        examId:   s.pathParameters['examId']!,
        forceNew: s.uri.queryParameters['forceNew'] == 'true',
      )),
      GoRoute(path: Routes.examResult, builder: (_, s) => ExamResultScreen(
        examId:   s.pathParameters['examId']!,
        resultId: s.uri.queryParameters['resultId'],
      )),

      // ---- ADMIN SHELL ----
      ShellRoute(
        navigatorKey: _adminShellKey,
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(path: Routes.adminDashboard, builder: (_, __) => const AdminDashboard()),
          GoRoute(path: Routes.adminExamEngine, builder: (_, __) => const ExamEngineScreen()),
          GoRoute(path: Routes.adminExamCreate, builder: (_, s) {
            final examId = s.uri.queryParameters['examId'];
            final settingsOnly = s.uri.queryParameters['settingsOnly'] == 'true';
            return ExamCreatorScreen(examId: examId, settingsOnly: settingsOnly);
          }),
          GoRoute(path: Routes.adminExamStats,
            builder: (_, s) => ExamStatisticsScreen(examId: s.pathParameters['examId']!)),
          GoRoute(path: Routes.adminDatabase,        builder: (_, __) => const DatabaseScreen()),
          GoRoute(path: Routes.adminPyqUpload,       builder: (_, __) => const PYQUploadScreen()),
          GoRoute(path: Routes.adminNotesLinks,      builder: (_, __) => const NotesAdminScreen()),
          GoRoute(path: Routes.adminStudentActivity, builder: (_, __) => const StudentActivityScreen()),
          GoRoute(path: Routes.adminCredits,         builder: (_, __) => const CreditsScreen()),
          GoRoute(path: Routes.adminBatches,         builder: (_, __) => const BatchManagementScreen()),
          GoRoute(path: Routes.adminNotifications,   builder: (_, __) => const SendNotificationScreen()),
          GoRoute(path: Routes.adminDeveloper,       builder: (_, __) => const DeveloperAdminScreen()),
          GoRoute(path: Routes.adminAiSettings,      builder: (_, __) => const AiSettingsScreen()),
        ],
      ),

      // ---- STUDENT SHELL ----
      ShellRoute(
        navigatorKey: _studentShellKey,
        builder: (context, state, child) => StudentShell(child: child),
        routes: [
          GoRoute(path: Routes.studentDashboard,      builder: (_, __) => const StudentDashboard()),
          GoRoute(path: Routes.studentOnlineTests,    builder: (_, __) => const OnlineTestScreen()),
          GoRoute(path: Routes.studentPyq,            builder: (_, __) => const PYQScreen()),
          GoRoute(path: Routes.studentFlashcards,     builder: (_, __) => const FlashcardScreen()),
          GoRoute(path: Routes.studentFlashcardViewer,
            builder: (_, s) => FlashcardViewer(chapter: Uri.decodeComponent(s.pathParameters['chapter']!))),
          GoRoute(path: Routes.studentLessonPlanner,  builder: (_, __) => const LessonPlannerScreen()),
          GoRoute(path: Routes.studentGlossary,       builder: (_, __) => const GlossaryScreen()),
          GoRoute(path: Routes.studentBioLab,         builder: (_, __) => const BioLabScreen()),
          GoRoute(path: Routes.studentGames,          builder: (_, __) => const GamesScreen()),
          GoRoute(path: Routes.studentHistory,        builder: (_, __) => const HistoryScreen()),
          GoRoute(path: Routes.studentChatbot,        builder: (_, __) => const ChatbotScreen()),
          GoRoute(path: Routes.studentNotes,          builder: (_, __) => const NotesScreen()),
          GoRoute(path: Routes.studentLinks,          builder: (_, __) => const ExternalLinksScreen()),
          GoRoute(path: Routes.studentOfflineResults, builder: (_, __) => const OfflineResultsScreen()),
        ],
      ),
    ],
  );

  // When auth state changes, just refresh the router's redirect — do NOT recreate it
  ref.listen<AsyncValue>(authProvider, (_, __) => router.refresh());

  return router;
});
