import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../../widgets/skeleton.dart';
import 'pdf_viewer_screen.dart';

final _notesProvider = StreamProvider.family<List<NoteModel>, String>((ref, batch) async* {
  // Resolve class level from the batches table; fall back to name-based guess
  final batches = await ref.watch(batchesProvider.future)
      .catchError((_) => <BatchModel>[]);
  final classLevel = batches
      .where((b) => b.name == batch)
      .map((b) => b.classLevel)
      .firstOrNull ?? _classLevelFallback(batch);

  await for (final all in SupabaseService.instance.streamAllNotes()) {
    yield all.where((n) {
      if (n.isPrivate) return false;
      if (n.visibility == 'all') return true;
      if (n.visibility == '11') return true;           // all levels see class-11 notes
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

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  final Set<String> _collapsed = {};

  void _toggleSection(String sec) =>
      setState(() => _collapsed.contains(sec) ? _collapsed.remove(sec) : _collapsed.add(sec));

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).value;
    if (user == null) return const SizedBox.shrink();

    final notesAsync = ref.watch(_notesProvider(user.batch));

    return notesAsync.when(
      loading: () => const SkeletonNotes(),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (notes) {
        if (notes.isEmpty) {
          return const _NotesEmptyState();
        }

        // Sort by sortOrder then group by section (preserving insertion order = sort order)
        final sorted = [...notes]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        final sectionOrder = <String>[];
        final sections = <String, List<NoteModel>>{};
        for (final n in sorted) {
          if (!sectionOrder.contains(n.sectionName)) sectionOrder.add(n.sectionName);
          sections.putIfAbsent(n.sectionName, () => []).add(n);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(14),
          itemCount: sectionOrder.length,
          itemBuilder: (_, i) {
            final sec = sectionOrder[i];
            final items = sections[sec]!;
            final isCollapsed = _collapsed.contains(sec);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Section header (tappable to collapse) ──────
                GestureDetector(
                  onTap: () => _toggleSection(sec),
                  child: Container(
                    margin: EdgeInsets.only(top: i > 0 ? 14 : 0, bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: Row(children: [
                      AnimatedRotation(
                        turns: isCollapsed ? -0.25 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(Icons.keyboard_arrow_down_rounded,
                            color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.folder_rounded, color: AppColors.primary, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(sec,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: AppColors.primary)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6)),
                        child: Text('${items.length}',
                            style: const TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w700,
                                color: AppColors.primary)),
                      ),
                      const SizedBox(width: 6),
                      Text(isCollapsed ? 'Show' : 'Hide',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ]),
                  ),
                ),

                // ── Notes (hidden when collapsed) ───────────────
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 250),
                  crossFadeState: isCollapsed
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: Column(
                    children: items.asMap().entries.map((e) {
                      final note = e.value;
                      final isLink = note.isLink;
                      return SolidCard(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                        onTap: () { HapticFeedback.lightImpact(); _openNote(context, note); },
                        child: Row(children: [
                          Container(
                            width: 38, height: 38,
                            decoration: BoxDecoration(
                              color: isLink ? AppColors.infoSurface : AppColors.errorSurface,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              isLink ? Icons.link_rounded : Icons.picture_as_pdf_rounded,
                              color: isLink ? AppColors.info : AppColors.error,
                              size: 19,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(note.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700, fontSize: 13.5)),
                              Text(
                                isLink ? 'External link · tap to open' : 'PDF · tap to view',
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.textSecondary)),
                            ]),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isLink ? AppColors.infoSurface : AppColors.primarySurface,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(
                                isLink ? Icons.open_in_new_rounded : Icons.chrome_reader_mode_outlined,
                                size: 12,
                                color: isLink ? AppColors.info : AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(isLink ? 'Open' : 'View',
                                  style: TextStyle(
                                      fontSize: 11, fontWeight: FontWeight.w700,
                                      color: isLink ? AppColors.info : AppColors.primary)),
                            ]),
                          ),
                        ]),
                      ).animate(delay: (e.key * 25).ms).fadeIn(duration: 180.ms);
                    }).toList(),
                  ),
                  secondChild: const SizedBox.shrink(),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openNote(BuildContext context, NoteModel note) {
    if (note.isLink) {
      launchUrl(Uri.parse(note.link), mode: LaunchMode.externalApplication);
      return;
    }
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => PdfViewerScreen(title: note.name, url: note.link),
      ),
    );
  }
}

// ── Animated notes empty state ────────────────────────────────
class _NotesEmptyState extends StatefulWidget {
  const _NotesEmptyState();

  @override
  State<_NotesEmptyState> createState() => _NotesEmptyStateState();
}

class _NotesEmptyStateState extends State<_NotesEmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _draw;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..forward();
    _draw = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _draw,
                builder: (_, __) => CustomPaint(
                  size: const Size(100, 120),
                  painter: _NotebookPainter(_draw.value),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No Notes Yet',
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary),
              ).animate(delay: 800.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 8),
              Text(
                'Your admin will upload study material here.\nCheck back soon!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textHint,
                    height: 1.6),
              ).animate(delay: 1000.ms).fadeIn(duration: 400.ms),
            ],
          ),
        ),
      );
}

class _NotebookPainter extends CustomPainter {
  final double progress;
  _NotebookPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final bookPaint = Paint()
      ..color = AppColors.primarySurface
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final linePaint = Paint()
      ..color = AppColors.primary.withOpacity(0.25)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final pencilPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;

    // Notebook body
    final bookRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(10, 10, size.width - 20, size.height - 20),
      const Radius.circular(12),
    );
    canvas.drawRRect(bookRect, bookPaint);
    canvas.drawRRect(bookRect, borderPaint);

    // Spine
    canvas.drawLine(
      const Offset(26, 10), Offset(26, size.height - 10), borderPaint);

    // Ruled lines that draw in progressively
    for (int i = 0; i < 4; i++) {
      final t = ((progress - i * 0.15) / 0.4).clamp(0.0, 1.0);
      if (t <= 0) continue;
      final y = 35.0 + i * 18.0;
      canvas.drawLine(
        Offset(36, y),
        Offset(36 + (size.width - 55) * t, y),
        linePaint,
      );
    }

    // Pencil (appears at end of animation, angled across corner)
    final pencilT = ((progress - 0.6) / 0.4).clamp(0.0, 1.0);
    if (pencilT > 0) {
      canvas.save();
      canvas.translate(size.width - 8, 8);
      canvas.rotate(-0.7);
      final pR = Rect.fromLTWH(-5, -28 * pencilT, 10, 28 * pencilT);
      canvas.drawRRect(
        RRect.fromRectAndRadius(pR, const Radius.circular(2)),
        pencilPaint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_NotebookPainter old) => old.progress != progress;
}
