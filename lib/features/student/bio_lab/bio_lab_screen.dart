import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/badge_service.dart';
import '../../../services/supabase_service.dart';
import '../../../widgets/glass_card.dart';
import 'bio_diagram_painter.dart';
import 'bio_process_data.dart';

class BioLabScreen extends ConsumerStatefulWidget {
  const BioLabScreen({super.key});
  @override
  ConsumerState<BioLabScreen> createState() => _BioLabScreenState();
}

class _BioLabScreenState extends ConsumerState<BioLabScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  BioProcess? _selected;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _onProcessCompleted(String processId) async {
    final user = ref.read(authProvider).value;
    if (user == null) return;
    if (!user.bioLabCompleted.contains(processId)) {
      final updated = [...user.bioLabCompleted, processId];
      await SupabaseService.instance.updateBioLabCompleted(user.id, updated);
      ref.read(authProvider.notifier).refreshCurrentUser();
      if (mounted) {
        await BadgeService.instance.checkAndAward(ref, context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > 700;

    Widget list = _ProcessList(
      tabController: _tabs,
      search: _search,
      onSearch: (v) => setState(() { _search = v; _selected = null; }),
      selected: _selected,
      onSelect: (p) => setState(() => _selected = p),
    );

    if (isWide) {
      return Row(children: [
        SizedBox(width: 300, child: list),
        const VerticalDivider(width: 1),
        Expanded(
          child: _selected == null
              ? _WelcomePanel()
              : _AnimationPanel(
                  key: ValueKey(_selected!.id),
                  process: _selected!,
                  onCompleted: _onProcessCompleted,
                ),
        ),
      ]);
    }

    if (_selected != null) {
      return Column(children: [
        // Back button only — title is already shown in the _AnimationPanel header
        Container(
          color: AppColors.neuSurface,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => setState(() => _selected = null),
              tooltip: 'Back',
            ),
          ]),
        ),
        const Divider(height: 1),
        Expanded(child: _AnimationPanel(
          key: ValueKey(_selected!.id),
          process: _selected!,
          onCompleted: _onProcessCompleted,
        )),
      ]);
    }
    return list;
  }
}

// ── Process list with search + tabs ───────────────────────────────────────

class _ProcessList extends StatelessWidget {
  final TabController tabController;
  final String search;
  final ValueChanged<String> onSearch;
  final BioProcess? selected;
  final ValueChanged<BioProcess> onSelect;

  const _ProcessList({
    required this.tabController,
    required this.search,
    required this.onSearch,
    required this.selected,
    required this.onSelect,
  });

  List<BioProcess> _filter(List<BioProcess> src) {
    if (search.isEmpty) return src;
    final q = search.toLowerCase();
    return src.where((p) =>
        p.title.toLowerCase().contains(q) ||
        p.chapter.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8F5E9), Color(0xFFE3F2FD), Color(0xFFEDE7F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        child: Column(children: [
          Row(children: [
            // Animated flask logo in header
            _AnimatedHeaderFlask(),
            const SizedBox(width: 10),
            const Expanded(
              child: Text('Dynamic Bio Lab',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  overflow: TextOverflow.ellipsis),
            ),
          ]),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search processes…',
              prefixIcon: Icon(Icons.search, size: 18),
              isDense: true,
            ),
            onChanged: onSearch,
          ),
          const SizedBox(height: 8),
          TabBar(
            controller: tabController,
            tabs: const [Tab(text: 'Class 11'), Tab(text: 'Class 12')],
            labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
          ),
        ]),
      ),
      const Divider(height: 1),
      Expanded(
        child: TabBarView(
          controller: tabController,
          children: [
            _ChapterList(processes: _filter(class11Processes), selected: selected, onSelect: onSelect),
            _ChapterList(processes: _filter(class12Processes), selected: selected, onSelect: onSelect),
          ],
        ),
      ),
    ]);
  }
}

class _ChapterList extends StatefulWidget {
  final List<BioProcess> processes;
  final BioProcess? selected;
  final ValueChanged<BioProcess> onSelect;
  const _ChapterList({required this.processes, required this.selected, required this.onSelect});

  @override
  State<_ChapterList> createState() => _ChapterListState();
}

// AutomaticKeepAliveClientMixin keeps the rendered list alive in memory when
// switching between Class 11 / Class 12 tabs — prevents full list rebuild.
class _ChapterListState extends State<_ChapterList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // required by AutomaticKeepAliveClientMixin
    if (widget.processes.isEmpty) {
      return const Center(child: Text('No results', style: TextStyle(color: AppColors.textHint)));
    }
    final grouped = groupByChapter(widget.processes);
    final chapters = grouped.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: chapters.fold<int>(0, (s, c) => s + 1 + grouped[c]!.length),
      itemBuilder: (_, idx) {
        int cur = 0;
        for (final ch in chapters) {
          if (cur == idx) return _ChapterHeader(title: ch);
          cur++;
          for (final p in grouped[ch]!) {
            if (cur == idx) {
              return _ProcessTile(
                process: p,
                selected: widget.selected?.id == p.id,
                onSelect: widget.onSelect,
              );
            }
            cur++;
          }
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _ChapterHeader extends StatelessWidget {
  final String title;
  const _ChapterHeader({required this.title});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
        child: Text(title.toUpperCase(),
            style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: AppColors.textSecondary,
                letterSpacing: 0.8)),
      );
}

class _ProcessTile extends StatelessWidget {
  final BioProcess process;
  final bool selected;
  final ValueChanged<BioProcess> onSelect;
  const _ProcessTile({required this.process, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: selected ? process.color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: selected ? Border.all(color: process.color.withOpacity(0.35), width: 1.2) : null,
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: process.color.withOpacity(0.28),
                    blurRadius: 14,
                    spreadRadius: 2,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: ListTile(
          dense: true,
          leading: Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: process.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Text(process.emoji, style: const TextStyle(fontSize: 16))),
          ),
          title: Text(process.title,
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? process.color : AppColors.textPrimary)),
          subtitle: Text('${process.steps.length} steps',
              style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
          onTap: () { HapticFeedback.selectionClick(); onSelect(process); },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
}

// ── Welcome panel — animated flask filling ────────────────────────────────
class _WelcomePanel extends StatefulWidget {
  @override
  State<_WelcomePanel> createState() => _WelcomePanelState();
}

class _WelcomePanelState extends State<_WelcomePanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _fillCtrl;

  @override
  void initState() {
    super.initState();
    _fillCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _fillCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Animated filling flask orb
          AnimatedBuilder(
            animation: _fillCtrl,
            builder: (_, __) => SizedBox(
              width: 90, height: 90,
              child: CustomPaint(
                painter: _FlaskFillPainter(_fillCtrl.value, AppColors.primary),
              ),
            ),
          ).animate().scale(begin: const Offset(0.8, 0.8), duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 20),
          const Text('Select a Process',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('Choose from ${bioProcesses.length} NEET-based animations',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ]),
      );
}

// ── Main animation panel ──────────────────────────────────────────────────

class _AnimationPanel extends StatefulWidget {
  final BioProcess process;
  final void Function(String processId)? onCompleted;
  const _AnimationPanel({super.key, required this.process, this.onCompleted});
  @override
  State<_AnimationPanel> createState() => _AnimationPanelState();
}

class _AnimationPanelState extends State<_AnimationPanel>
    with TickerProviderStateMixin {
  int _step = 0;
  bool _auto = false;
  bool _viewAnim = false;
  bool _hasAnimation = false;
  late AnimationController _progressCtrl;
  late AnimationController _stepCtrl;
  late Animation<double> _stepAnim;
  late AnimationController _tCtrl;
  late AnimationController _borderCtrl; // traveling border on play button

  @override
  void initState() {
    super.initState();
    _progressCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _stepCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _stepAnim = CurvedAnimation(parent: _stepCtrl, curve: Curves.easeOutCubic);
    _stepCtrl.forward();
    _tCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _borderCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _hasAnimation = buildBioDiagram(widget.process.id, 0, 0) != null;
    _viewAnim = _hasAnimation;
    if (_hasAnimation) _tCtrl.repeat();
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    _stepCtrl.dispose();
    _tCtrl.dispose();
    _borderCtrl.dispose();
    super.dispose();
  }

  void _goTo(int s) {
    setState(() => _step = s.clamp(0, widget.process.steps.length - 1));
    _stepCtrl.reset();
    _stepCtrl.forward();
    if (_auto) _startAutoProgress();
  }

  void _next() => _goTo(_step + 1);
  void _prev() => _goTo(_step - 1);

  void _startAutoProgress() {
    _progressCtrl.reset();
    _progressCtrl.forward().whenComplete(() {
      if (_auto && mounted && _step < widget.process.steps.length - 1) {
        _goTo(_step + 1);
      } else {
        if (mounted) setState(() => _auto = false);
        // Fire completion callback when auto-play finishes at the last step
        if (mounted && _step >= widget.process.steps.length - 1) {
          widget.onCompleted?.call(widget.process.id);
        }
      }
    });
  }

  void _toggleAuto() {
    HapticFeedback.lightImpact();
    setState(() => _auto = !_auto);
    if (_auto) {
      _startAutoProgress();
      _borderCtrl.repeat();
    } else {
      _progressCtrl.stop();
      _borderCtrl.stop();
      _borderCtrl.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.process;
    final step = p.steps[_step];
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Stack(
      children: [
      SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          isMobile ? 14 : 20, isMobile ? 14 : 20,
          isMobile ? 14 : 20, isMobile ? 60 : 70), // bottom pad for scroll hint
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Header ──────────────────────────────────────────────
        Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: p.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: p.color.withOpacity(0.3)),
            ),
            child: Center(child: Text(p.emoji, style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: -0.3)),
            Text(p.chapter,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: p.color, fontWeight: FontWeight.w600)),
          ])),
        ]).animate().fadeIn(duration: 250.ms),
        const SizedBox(height: 18),

        // ── Step bubbles ─────────────────────────────────────────
        SizedBox(
          height: 32,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: p.steps.length,
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => _goTo(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: i == _step ? 28 : 22,
                height: i == _step ? 28 : 22,
                margin: EdgeInsets.symmetric(horizontal: 3, vertical: i == _step ? 2 : 5),
                decoration: BoxDecoration(
                  color: i < _step
                      ? p.color.withOpacity(0.6)
                      : i == _step
                          ? p.color
                          : AppColors.border,
                  shape: BoxShape.circle,
                ),
                child: i < _step
                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                    : i == _step
                        ? Center(child: Text('${i + 1}',
                            style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w800)))
                        : Center(child: Text('${i + 1}',
                            style: const TextStyle(fontSize: 9, color: AppColors.textHint))),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // ── View toggle (only when animation exists) ─────────────
        if (_hasAnimation) ...[
          _ViewToggle(
            isAnim: _viewAnim,
            color: p.color,
            onChanged: (v) {
              setState(() => _viewAnim = v);
              if (v) _tCtrl.repeat();
              else _tCtrl.stop();
            },
          ),
          const SizedBox(height: 12),
        ],

        // ── Animated diagram (shown in Animation mode) ────────────
        if (_viewAnim)
          AnimatedBuilder(
            animation: _tCtrl,
            builder: (_, __) {
              final diagram = buildBioDiagram(p.id, _step, _tCtrl.value);
              if (diagram == null) return const SizedBox.shrink();
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.neuSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: p.color.withOpacity(0.25), width: 1.2),
                  boxShadow: [BoxShadow(color: p.color.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(19),
                  child: diagram,
                ),
              );
            },
          ),

        // ── Step card (shown in Steps mode) ──────────────────────
        if (!_viewAnim)
        AnimatedBuilder(
          animation: _stepAnim,
          builder: (_, child) => Transform.translate(
            offset: Offset(0, 20 * (1 - _stepAnim.value)),
            child: Opacity(opacity: _stepAnim.value.clamp(0.0, 1.0), child: child),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [p.color.withOpacity(0.08), p.color.withOpacity(0.02)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: p.color.withOpacity(0.25), width: 1.5),
              boxShadow: [BoxShadow(color: p.color.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: p.color, borderRadius: BorderRadius.circular(10)),
                  child: Icon(step.icon, size: 19, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Step ${_step + 1} of ${p.steps.length}',
                      style: TextStyle(fontSize: 10, color: p.color, fontWeight: FontWeight.w700)),
                  Text(step.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: -0.2)),
                ])),
              ]),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(step.detail,
                    style: const TextStyle(fontSize: 13, height: 1.65, color: AppColors.textPrimary)),
              ),
              const SizedBox(height: 12),
              // Auto-progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: AnimatedBuilder(
                  animation: _progressCtrl,
                  builder: (_, __) => LinearProgressIndicator(
                    value: _auto ? _progressCtrl.value : 0,
                    minHeight: 3,
                    backgroundColor: p.color.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(p.color),
                  ),
                ),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 14),

        // ── Controls ──────────────────────────────────────────────
        Row(children: [
          _NavBtn(icon: Icons.arrow_back_rounded, enabled: _step > 0, color: p.color, onTap: _prev),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: _toggleAuto,
              child: AnimatedBuilder(
                animation: _borderCtrl,
                builder: (_, child) => CustomPaint(
                  painter: _auto
                      ? _PlayButtonBorderPainter(_borderCtrl.value, p.color)
                      : null,
                  child: child,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: _auto ? p.color : AppColors.neuSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: _auto ? null : Border.all(color: p.color.withOpacity(0.4)),
                    boxShadow: _auto
                        ? [BoxShadow(color: p.color.withOpacity(0.35), blurRadius: 12)]
                        : null,
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(_auto ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: _auto ? Colors.white : p.color, size: 20),
                    const SizedBox(width: 6),
                    Text(_auto ? 'Pause' : 'Auto Play',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: _auto ? Colors.white : p.color)),
                  ]),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _NavBtn(icon: Icons.arrow_forward_rounded, enabled: _step < p.steps.length - 1, color: p.color, onTap: _next),
        ]),
        const SizedBox(height: 20),

        // ── Key Points ────────────────────────────────────────────
        SolidCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(Icons.star_rounded, color: p.color, size: 16),
              const SizedBox(width: 6),
              const Text('NEET Key Points',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
            ]),
            const SizedBox(height: 12),
            ...p.keyPoints.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      width: 18, height: 18, margin: const EdgeInsets.only(right: 10, top: 1),
                      decoration: BoxDecoration(color: p.color, borderRadius: BorderRadius.circular(5)),
                      child: Center(child: Text('${e.key + 1}',
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800))),
                    ),
                    Expanded(child: Text(e.value,
                        style: const TextStyle(fontSize: 12.5, height: 1.5))),
                  ]),
                )),
          ]),
        ).animate(delay: 100.ms).fadeIn(),

        const SizedBox(height: 16),

        // ── Description ───────────────────────────────────────────
        SolidCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(Icons.info_outline_rounded, color: p.color, size: 16),
              const SizedBox(width: 6),
              const Text('Overview', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
            ]),
            const SizedBox(height: 10),
            Text(p.description, style: const TextStyle(fontSize: 13, height: 1.65, color: AppColors.textSecondary)),
          ]),
        ).animate(delay: 150.ms).fadeIn(),
      ]),
      ),

      // Scroll nudge — sits at bottom edge, just a small gradient fade + hint text
      // IgnorePointer so it never blocks taps on the controls above it
      Positioned(
        bottom: 0, left: 0, right: 0,
        child: IgnorePointer(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.neuBackground.withOpacity(0),
                      AppColors.neuBackground.withOpacity(0.92),
                    ],
                  ),
                ),
              ),
              Container(
                color: AppColors.neuBackground.withOpacity(0.92),
                padding: const EdgeInsets.only(bottom: 6, top: 2),
                child: Center(
                  child: Text(
                    '↓  Key Points & Overview below',
                    style: TextStyle(
                      fontSize: 9.5,
                      color: p.color.withOpacity(0.55),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ).animate(onPlay: (c) => c.repeat(reverse: true))
                   .fadeIn(duration: 900.ms)
                   .then(delay: 1400.ms)
                   .fadeOut(duration: 700.ms),
                ),
              ),
            ],
          ),
        ),
      ),
    ]); // Stack
  }
}

// ── Animation / Steps toggle pill ─────────────────────────────────────────
class _ViewToggle extends StatelessWidget {
  final bool isAnim;
  final Color color;
  final ValueChanged<bool> onChanged;
  const _ViewToggle({required this.isAnim, required this.color, required this.onChanged});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.neuBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            padding: const EdgeInsets.all(3),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              _pill('Animation', Icons.auto_awesome_rounded, true),
              _pill('Steps', Icons.list_alt_rounded, false),
            ]),
          ),
        ],
      );

  Widget _pill(String label, IconData icon, bool animMode) {
    final sel = isAnim == animMode;
    return GestureDetector(
      onTap: () => onChanged(animMode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: sel ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          boxShadow: sel ? [BoxShadow(color: color.withOpacity(0.25), blurRadius: 6, offset: const Offset(0, 2))] : null,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 13, color: sel ? Colors.white : AppColors.textHint),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: sel ? Colors.white : AppColors.textHint)),
        ]),
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final Color color;
  final VoidCallback onTap;
  const _NavBtn({required this.icon, required this.enabled, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: enabled ? color.withOpacity(0.1) : AppColors.neuBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: enabled ? color.withOpacity(0.3) : AppColors.border),
          ),
          child: Icon(icon, color: enabled ? color : AppColors.textHint, size: 22),
        ),
      );
}

// ── Animated flask fill painter for welcome panel ─────────────────────────
class _FlaskFillPainter extends CustomPainter {
  final double t; // 0→1 pinging (reverse: true)
  final Color color;
  _FlaskFillPainter(this.t, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final r = size.width / 2;

    // Outer ring
    canvas.drawCircle(Offset(cx, cy), r,
        Paint()..color = color.withOpacity(0.10)..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(cx, cy), r - 1,
        Paint()..color = color.withOpacity(0.25)..style = PaintingStyle.stroke..strokeWidth = 2);

    // Liquid fill — clipped to circle
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r - 2)));

    final fillLevel = 0.25 + t * 0.5; // fills from 25% to 75%
    final waveY = size.height * (1 - fillLevel);

    // Wave path
    final waveAmp = 5.0;
    final wavePath = Path();
    wavePath.moveTo(0, waveY);
    for (double x = 0; x <= size.width; x += 2) {
      final y = waveY + waveAmp * math.sin((x / size.width) * 2 * math.pi + t * 2 * math.pi);
      wavePath.lineTo(x, y);
    }
    wavePath.lineTo(size.width, size.height);
    wavePath.lineTo(0, size.height);
    wavePath.close();

    canvas.drawPath(wavePath, Paint()..color = color.withOpacity(0.20)..style = PaintingStyle.fill);

    // Shimmer highlight inside liquid
    final shimmerPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
        Rect.fromCenter(center: Offset(cx - r * 0.2, waveY + (size.height - waveY) * 0.35),
            width: r * 0.5, height: (size.height - waveY) * 0.3),
        shimmerPaint);

    canvas.restore();

    // Science icon in center
    final tp = TextPainter(
      text: const TextSpan(text: '🧬', style: TextStyle(fontSize: 30)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  @override
  bool shouldRepaint(_FlaskFillPainter old) => old.t != t;
}

// ── Traveling border painter for the play button ──────────────────────────
class _PlayButtonBorderPainter extends CustomPainter {
  final double t;
  final Color color;
  _PlayButtonBorderPainter(this.t, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rRect = RRect.fromRectXY(rect.deflate(1.5), 14, 14);
    final shader = SweepGradient(
      colors: [
        color, color.withOpacity(0.1), Colors.white.withOpacity(0.8),
        color.withOpacity(0.1), color,
      ],
      transform: GradientRotation(t * 2 * math.pi),
    ).createShader(rect);

    // Glow layer
    canvas.drawRRect(rRect, Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    // Sharp layer
    canvas.drawRRect(rRect, Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(_PlayButtonBorderPainter old) => old.t != t;
}

// ── Animated flask logo for the Bio Lab header ────────────────
class _AnimatedHeaderFlask extends StatefulWidget {
  @override
  State<_AnimatedHeaderFlask> createState() => _AnimatedHeaderFlaskState();
}

class _AnimatedHeaderFlaskState extends State<_AnimatedHeaderFlask>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => SizedBox(
          width: 30,
          height: 30,
          child: CustomPaint(
            painter: _FlaskFillPainter(_ctrl.value, AppColors.primary),
          ),
        ),
      );
}
