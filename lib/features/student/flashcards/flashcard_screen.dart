import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/flashcard_data.dart';
import '../../../core/constants/ncert_chapters.dart';
import '../../../core/constants/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/glass_card.dart';

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  String _classFilter = 'all';

  @override
  Widget build(BuildContext context) {
    // Group by chapter from hardcoded data
    final all = FlashcardData.all;
    // Sort by class (11 before 12) then chapter number within class
    final chapters = all.map((f) => f.chapter).toSet().toList()
      ..sort((a, b) {
        final ca = NcertChapters.classFor(a);
        final cb = NcertChapters.classFor(b);
        if (ca != cb) return ca.compareTo(cb);
        return NcertChapters.chapterNumber(a)
            .compareTo(NcertChapters.chapterNumber(b));
      });

    final filtered = _classFilter == 'all'
        ? chapters
        : chapters.where((ch) {
            final cls = NcertChapters.classFor(ch);
            return cls == _classFilter;
          }).toList();

    final countMap = <String, int>{};
    for (final f in all) {
      countMap[f.chapter] = (countMap[f.chapter] ?? 0) + 1;
    }

    return Column(
      children: [
        // Header — stacked on mobile so chips don't overlap subtitle
        Container(
          color: AppColors.neuSurface,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Expanded(
                  child: Text('Flashcards',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                ),
                _ClassChip('All', 'all', _classFilter,
                    () => setState(() => _classFilter = 'all')),
                const SizedBox(width: 6),
                _ClassChip('11', '11', _classFilter,
                    () => setState(() => _classFilter = '11')),
                const SizedBox(width: 6),
                _ClassChip('12', '12', _classFilter,
                    () => setState(() => _classFilter = '12')),
              ]),
              const SizedBox(height: 2),
              const Text('NCERT Biology · tap a chapter to start',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 280,
              childAspectRatio: 1.4,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
            ),
            itemCount: filtered.length,
            itemBuilder: (_, i) {
              final ch = filtered[i];
              final count = countMap[ch] ?? 0;
              final cls = NcertChapters.classFor(ch);
              final chNum = NcertChapters.chapterNumber(ch);
              final clsColor = cls == '11' ? AppColors.batch11 : AppColors.batch12;

              return SolidCard(
                padding: EdgeInsets.zero,
                onTap: () => context.go(
                  Routes.studentFlashcardViewer
                      .replaceAll(':chapter', Uri.encodeComponent(ch)),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              clsColor.withOpacity(0.15),
                              clsColor.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Ch $chNum',
                              style: TextStyle(
                                  fontSize: 24, // reduced: was 28, caused overlap
                                  fontWeight: FontWeight.w900,
                                  color: clsColor.withOpacity(0.6)),
                            ),
                            const SizedBox(height: 4), // explicit gap — prevents overlap
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: clsColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                'Class $cls',
                                style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: clsColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ch,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: AppColors.textPrimary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$count cards',
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate(delay: (i * 25).ms).fadeIn(duration: 200.ms);
            },
          ),
        ),
      ],
    );
  }
}

Widget _ClassChip(String label, String value, String current, VoidCallback onTap) =>
    GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: current == value ? AppColors.primary : AppColors.neuBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color:
                  current == value ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color:
                  current == value ? Colors.white : AppColors.textSecondary),
        ),
      ),
    );
