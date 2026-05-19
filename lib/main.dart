import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_web_plugins/url_strategy.dart'; // Web routing config
import 'core/constants/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/flashcard_data.dart';
import 'providers/developer_provider.dart';
import 'router/app_router.dart';
import 'services/storage_service.dart';
import 'widgets/exam_toast.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy(); // Removes the '#' from web URLs for SEO and native feel


  // Preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Initialize Hive for local caching
  await Hive.initFlutter();
  await StorageService.instance.init();

  // Seed flashcards into local cache if empty
  await _seedFlashcards();

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const ProviderScope(child: PraeparatioApp()));
}

Future<void> _seedFlashcards() async {
  final existing = StorageService.instance.getFlashcardChapters();
  if (existing.isNotEmpty) return; // already seeded
  await StorageService.instance.saveFlashcardsBatch(FlashcardData.all);
}

class PraeparatioApp extends ConsumerWidget {
  const PraeparatioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'PRAEPARATIO',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light, // Dark mode removed — always light
      routerConfig: router,
      builder: (ctx, child) => ToastOverlay(child: child ?? const SizedBox()),
    );
  }
}
