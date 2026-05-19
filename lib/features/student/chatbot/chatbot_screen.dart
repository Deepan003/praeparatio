import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/ai_service.dart';
import '../../../services/pdf_service.dart';
import 'package:printing/printing.dart';
import '../../../services/supabase_service.dart';
import '../../../widgets/glass_card.dart';

class ChatbotScreen extends ConsumerStatefulWidget {
  const ChatbotScreen({super.key});

  @override
  ConsumerState<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends ConsumerState<ChatbotScreen> {
  final List<_Message> _messages = [];
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();

  bool _loading = false;
  int _usedToday = 0;
  int _dailyLimit = 350;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _loadUsage();
    _messages.add(_Message.bot(_welcomeMessage()));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  String _welcomeMessage() => '''Hi! 👋 I\'m your NEET Biology Doubt Solver.

I can help you with:
• Any Class 11 & 12 NCERT Biology topic
• Concept explanations, process steps, comparisons
• NEET-level questions and exam tips
• Even if you\'re feeling stressed — I\'m here for that too 💙

A few things to know:
• Daily limit: $_dailyLimit questions
• 💬 Chats are NOT saved — I don\'t remember previous questions
• Each question is answered fresh and independently

What would you like to know today? 🌱''';

  Future<void> _loadUsage() async {
    final user = ref.read(authProvider).value;
    if (user == null) return;
    try {
      final limit = await SupabaseService.instance.getSetting('chatbot_daily_limit');
      final used = await SupabaseService.instance.getChatbotUsageToday(user.id);
      if (mounted) {
        setState(() {
          _dailyLimit = int.tryParse(limit?.toString() ?? '350') ?? 350;
          _usedToday = used;
          _initialized = true;
          // Update welcome message with real limit
          if (_messages.isNotEmpty) {
            _messages[0] = _Message.bot(_welcomeMessage());
          }
        });
      }
    } catch (_) {
      if (mounted) setState(() => _initialized = true);
    }
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _loading) return;

    // Local check first (fast path)
    if (_usedToday >= _dailyLimit) {
      _showLimitReached();
      return;
    }

    _ctrl.clear();
    HapticFeedback.lightImpact();
    setState(() {
      _messages.add(_Message.user(text));
      _loading = true;
    });
    _scrollDown();

    try {
      final user = ref.read(authProvider).value;

      // Server-side recheck before hitting AI — prevents quota bypass via rapid sends
      if (user != null) {
        final serverUsed = await SupabaseService.instance.getChatbotUsageToday(user.id);
        if (serverUsed >= _dailyLimit) {
          if (mounted) {
            setState(() { _usedToday = serverUsed; _loading = false; });
            _showLimitReached();
          }
          return;
        }
      }

      final answer = await AiService.instance.askChatbotQuestion(text);
      if (user != null) {
        await SupabaseService.instance.incrementChatbotUsage(user.id);
      }
      if (mounted) {
        setState(() {
          _usedToday++;
          _loading = false;
          _messages.add(_Message.bot(answer, question: text));
        });
        _scrollDown();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _messages.add(_Message.bot(
            '⚠️ ${e.toString().replaceAll("Exception: ", "")}',
            isError: true,
          ));
        });
        _scrollDown();
      }
    }
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showLimitReached() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Text('⏳', style: TextStyle(fontSize: 22)),
          SizedBox(width: 8),
          Text('Daily Limit Reached'),
        ]),
        content: Text(
          'You\'ve used all $_dailyLimit questions for today.\n\nYour limit resets at midnight. Come back tomorrow! 🌙',
          style: const TextStyle(height: 1.6),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadPdf(_Message msg) async {
    final user = ref.read(authProvider).value;
    try {
      final bytes = await PdfService.chatbotAnswerPdf(
        question: msg.question ?? '',
        answer: msg.text,
        studentName: user?.name ?? 'Student',
      );
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'biology_answer_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
    } catch (e) {
      debugPrint('[Chatbot] PDF generation failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Could not generate PDF. Please try again.'),
          backgroundColor: AppColors.error,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final remaining = (_dailyLimit - _usedToday).clamp(0, _dailyLimit);
    final limitColor = remaining > 100
        ? AppColors.success
        : remaining > 30
            ? AppColors.warning
            : AppColors.error;
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Scaffold(
      backgroundColor: AppColors.neuBackground,
      body: Column(children: [
        // ── Top bar ────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: AppColors.neuSurface,
            border: const Border(bottom: BorderSide(color: AppColors.border)),
            boxShadow: AppColors.neuRaisedSoft,
          ),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                  child: Text('🧬', style: TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Biology Doubt Solver',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                Text('NCERT Class 11 & 12 • Each question is independent',
                    style: TextStyle(
                        fontSize: 10, color: AppColors.textSecondary)),
              ]),
            ),
            // Usage badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: limitColor.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: limitColor.withOpacity(0.35)),
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('$remaining',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: limitColor)),
                Text('left today',
                    style: TextStyle(fontSize: 8, color: limitColor)),
              ]),
            ),
          ]),
        ),

        // ── Chat messages ──────────────────────────────────────
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 14 : 40, vertical: 16),
            itemCount: _messages.length + (_loading ? 1 : 0),
            itemBuilder: (_, i) {
              if (_loading && i == _messages.length) {
                return const _ThinkingBubble();
              }
              return _MessageBubble(
                message: _messages[i],
                onDownload: (!_messages[i].isUser && !_messages[i].isError && _messages[i].question != null)
                    ? () => _downloadPdf(_messages[i])
                    : null,
              );
            },
          ),
        ),

        // ── Info bar: chats not saved ──────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          color: AppColors.infoSurface,
          child: Row(children: [
            const Icon(Icons.info_outline_rounded, size: 13, color: AppColors.info),
            const SizedBox(width: 6),
            Text(
              'Chats are not saved. Each question is independent.',
              style: TextStyle(fontSize: 11, color: AppColors.info.withOpacity(0.9)),
            ),
          ]),
        ),

        // ── Input ──────────────────────────────────────────────
        Container(
          padding: EdgeInsets.fromLTRB(
              16, 10, 16, MediaQuery.of(context).padding.bottom + 10),
          decoration: const BoxDecoration(
            color: AppColors.neuSurface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                maxLines: 3,
                minLines: 1,
                textInputAction: TextInputAction.newline,
                enabled: _usedToday < _dailyLimit && !_loading,
                decoration: InputDecoration(
                  hintText: _usedToday >= _dailyLimit
                      ? 'Daily limit reached. Come back tomorrow!'
                      : 'Ask a biology question…',
                  hintStyle: const TextStyle(fontSize: 13),
                  filled: true,
                  fillColor: AppColors.neuBackground,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: (_loading || _usedToday >= _dailyLimit) ? null : _send,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48, height: 48,
                decoration: BoxDecoration(
                  gradient: (_loading || _usedToday >= _dailyLimit)
                      ? null
                      : AppColors.primaryGradient,
                  color: (_loading || _usedToday >= _dailyLimit)
                      ? AppColors.border
                      : null,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: (_loading || _usedToday >= _dailyLimit)
                      ? null
                      : [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 3))],
                ),
                child: Center(
                  child: _loading
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ── Message model ──────────────────────────────────────────────
class _Message {
  final String text;
  final bool isUser;
  final bool isError;
  final String? question; // original question (for PDF download)

  const _Message({
    required this.text,
    required this.isUser,
    this.isError = false,
    this.question,
  });

  factory _Message.user(String text) => _Message(text: text, isUser: true);
  factory _Message.bot(String text, {bool isError = false, String? question}) =>
      _Message(text: text, isUser: false, isError: isError, question: question);
}

// ── Message bubble ─────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final _Message message;
  final VoidCallback? onDownload;
  const _MessageBubble({required this.message, this.onDownload});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Center(child: Text('🧬', style: TextStyle(fontSize: 14))),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width * 0.78),
                  decoration: BoxDecoration(
                    gradient: isUser ? AppColors.primaryGradient : null,
                    color: isUser
                        ? null
                        : message.isError
                            ? AppColors.errorSurface
                            : AppColors.neuSurface,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isUser ? 18 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 18),
                    ),
                    boxShadow: AppColors.neuRaisedSoft,
                    border: (!isUser && !message.isError)
                        ? Border.all(color: AppColors.border)
                        : null,
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.6,
                      color: isUser
                          ? Colors.white
                          : message.isError
                              ? AppColors.error
                              : AppColors.textPrimary,
                    ),
                  ),
                ),
                // Download PDF button for bot answers
                if (onDownload != null) ...[
                  const SizedBox(height: 5),
                  GestureDetector(
                    onTap: onDownload,
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.picture_as_pdf_rounded,
                          size: 13, color: AppColors.primary.withOpacity(0.7)),
                      const SizedBox(width: 4),
                      Text('Save as PDF',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppColors.primary.withOpacity(0.7),
                              fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ],
              ],
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.08);
  }
}

// ── Thinking animation bubble ──────────────────────────────────
class _ThinkingBubble extends StatefulWidget {
  const _ThinkingBubble();

  @override
  State<_ThinkingBubble> createState() => _ThinkingBubbleState();
}

class _ThinkingBubbleState extends State<_ThinkingBubble> {
  static const _texts = [
    'Thinking...',
    'Firing neurons...',
    'Consulting NCERT...',
    'Processing your question...',
    'Searching biology knowledge...',
    'Formulating answer...',
    'Almost there...',
  ];
  int _idx = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1600), (_) {
      if (mounted) setState(() => _idx = (_idx + 1) % _texts.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Center(child: Text('🧬', style: TextStyle(fontSize: 14))),
          ),
          const SizedBox(width: 8),
          Container(
            constraints:
                BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.72),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.neuSurface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: AppColors.neuRaisedSoft,
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 3 bouncing dots — classic chat "typing" indicator
                _BouncingDots(),
                const SizedBox(height: 10),
                // Rotating thinking text
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                              begin: const Offset(0, 0.15), end: Offset.zero)
                          .animate(anim),
                      child: child,
                    ),
                  ),
                  child: Text(
                    _texts[_idx],
                    key: ValueKey(_idx),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary.withOpacity(0.8),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Skeleton lines
                const _SkeletonLine(width: 220, delay: 0),
                const SizedBox(height: 7),
                const _SkeletonLine(width: 180, delay: 150),
                const SizedBox(height: 7),
                const _SkeletonLine(width: 200, delay: 300),
                const SizedBox(height: 7),
                const _SkeletonLine(width: 140, delay: 450),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

class _SkeletonLine extends StatefulWidget {
  final double width;
  final int delay;
  const _SkeletonLine({required this.width, required this.delay});

  @override
  State<_SkeletonLine> createState() => _SkeletonLineState();
}

class _SkeletonLineState extends State<_SkeletonLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
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
        builder: (_, __) => Container(
          width: widget.width,
          height: 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Color.lerp(
              AppColors.border,
              AppColors.primary.withOpacity(0.15),
              _ctrl.value,
            ),
          ),
        ),
      );
}

// ── 3-dot bounce typing indicator ─────────────────────────────
class _BouncingDots extends StatefulWidget {
  @override
  State<_BouncingDots> createState() => _BouncingDotsState();
}

class _BouncingDotsState extends State<_BouncingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1050))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final phase = i / 3.0;
            final t = ((_ctrl.value - phase + 1.0) % 1.0);
            final bounce = (t < 0.5 ? t * 2 : (1 - t) * 2).clamp(0.0, 1.0);
            return Container(
              margin: const EdgeInsets.only(right: 4),
              width: 7,
              height: 7,
              transform: Matrix4.translationValues(0, -6 * bounce, 0),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.5 + bounce * 0.5),
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
      );
}
