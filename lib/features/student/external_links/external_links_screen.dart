import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/batch_model.dart';
import '../../../models/note_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/batch_provider.dart';
import '../../../services/supabase_service.dart';
import '../../../widgets/glass_card.dart';

final _linksProvider = StreamProvider.family<List<NoteModel>, String>((ref, batch) async* {
  final batches = await ref.watch(batchesProvider.future)
      .catchError((_) => <BatchModel>[]);
  final classLevel = batches
      .where((b) => b.name == batch)
      .map((b) => b.classLevel)
      .firstOrNull ?? _classLevelFallback(batch);

  await for (final all in SupabaseService.instance.streamAllNotes()) {
    yield all.where((n) {
      if (!n.isLink) return false;
      if (n.visibility == 'all') return true;
      if (n.visibility == '11') return true;
      if (n.visibility == '12') return classLevel == '12' || classLevel == 'neet';
      if (n.visibility == 'neet') return classLevel == 'neet';
      return false;
    }).toList();
  }
});

String _classLevelFallback(String batch) {
  if (batch == 'NEET Exclusive') return 'neet';
  if (batch.contains('12')) return '12';
  return '11';
}

class ExternalLinksScreen extends ConsumerWidget {
  const ExternalLinksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;
    if (user == null) return const SizedBox.shrink();

    final linksAsync = ref.watch(_linksProvider(user.batch));

    return linksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (links) {
        if (links.isEmpty) {
          return const Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.link_off, size: 60, color: AppColors.textHint),
              SizedBox(height: 12),
              Text('No external links available yet', style: TextStyle(color: AppColors.textHint)),
            ]),
          );
        }

        final sections = <String, List<NoteModel>>{};
        for (final n in links) {
          sections.putIfAbsent(n.sectionName, () => []).add(n);
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: sections.entries.map((entry) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                child: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.primary)),
              ),
              ...entry.value.asMap().entries.map((e) {
                final link = e.value;
                final host = Uri.tryParse(link.link)?.host ?? '';
                final icon = _iconForHost(host);

                return SolidCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  onTap: () => _openLink(context, link.link),
                  child: Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.infoSurface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(child: Text(icon, style: const TextStyle(fontSize: 20))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(link.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                            Text(host, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      const Icon(Icons.open_in_new, size: 16, color: AppColors.info),
                    ],
                  ),
                ).animate(delay: (e.key * 30).ms).fadeIn();
              }),
            ],
          )).toList(),
        );
      },
    );
  }

  String _iconForHost(String host) {
    if (host.contains('youtube')) return '▶️';
    if (host.contains('drive.google')) return '📁';
    if (host.contains('notion')) return '📓';
    if (host.contains('docs.google')) return '📄';
    return '🔗';
  }

  Future<void> _openLink(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
