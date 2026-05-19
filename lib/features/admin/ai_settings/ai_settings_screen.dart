import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/ai_service.dart';
import '../../../services/supabase_service.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/glass_card.dart';

class AiSettingsScreen extends ConsumerStatefulWidget {
  const AiSettingsScreen({super.key});

  @override
  ConsumerState<AiSettingsScreen> createState() => _AiSettingsScreenState();
}

class _AiSettingsScreenState extends ConsumerState<AiSettingsScreen> {
  // ── Chatbot (universal OpenAI-compatible) ──────────────────
  final _chatKeyCtrl      = TextEditingController();
  final _chatModelCtrl    = TextEditingController(text: 'llama-3.3-70b-versatile');
  final _chatEndpointCtrl = TextEditingController();
  final _chatLimitCtrl    = TextEditingController(text: '350');
  bool _chatSaving = false;
  bool _chatObscure = true;

  // ── Exam AI (Gemini) ────────────────────────────────────────
  final _examKeyCtrl   = TextEditingController();
  final _examModelCtrl = TextEditingController(text: 'gemini-2.5-flash-preview-05-20');
  bool _examSaving = false;
  bool _examObscure = true;

  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _chatKeyCtrl.dispose();
    _chatModelCtrl.dispose();
    _chatEndpointCtrl.dispose();
    _chatLimitCtrl.dispose();
    _examKeyCtrl.dispose();
    _examModelCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final ck  = await SupabaseService.instance.getSetting('chatbot_api_key');
      final cm  = await SupabaseService.instance.getSetting('chatbot_model');
      final ce  = await SupabaseService.instance.getSetting('chatbot_endpoint');
      final cl  = await SupabaseService.instance.getSetting('chatbot_daily_limit');
      final ek  = await SupabaseService.instance.getSetting('exam_ai_api_key');
      final em  = await SupabaseService.instance.getSetting('exam_ai_model');
      if (!mounted) return;
      setState(() {
        if (ck != null) _chatKeyCtrl.text = ck.toString();
        if (cm != null) _chatModelCtrl.text = cm.toString();
        if (ce != null) _chatEndpointCtrl.text = ce.toString();
        if (cl != null) _chatLimitCtrl.text = cl.toString();
        if (ek != null) _examKeyCtrl.text = ek.toString();
        if (em != null) _examModelCtrl.text = em.toString();
        _loaded = true;
      });
    } catch (_) {
      if (mounted) setState(() => _loaded = true);
    }
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? AppColors.error : AppColors.success,
      duration: Duration(seconds: error ? 4 : 2),
    ));
  }

  Future<void> _saveChatbot() async {
    setState(() => _chatSaving = true);
    try {
      await SupabaseService.instance.setSetting('chatbot_api_key',     _chatKeyCtrl.text.trim());
      await SupabaseService.instance.setSetting('chatbot_model',       _chatModelCtrl.text.trim());
      await SupabaseService.instance.setSetting('chatbot_endpoint',    _chatEndpointCtrl.text.trim());
      await SupabaseService.instance.setSetting('chatbot_daily_limit', int.tryParse(_chatLimitCtrl.text.trim()) ?? 350);
      _snack('Chatbot settings saved!');
    } catch (e) {
      _snack('Failed: $e', error: true);
    } finally {
      if (mounted) setState(() => _chatSaving = false);
    }
  }

  Future<void> _saveExamAi() async {
    setState(() => _examSaving = true);
    try {
      final key   = _examKeyCtrl.text.trim();
      final model = _examModelCtrl.text.trim();
      await SupabaseService.instance.setSetting('exam_ai_api_key', key);
      await SupabaseService.instance.setSetting('exam_ai_model', model.isEmpty ? 'gemini-2.5-flash-preview-05-20' : model);
      // Update in-memory + SharedPreferences so it's usable immediately
      if (key.isNotEmpty) await AiService.instance.saveApiKey(key, model: model.isEmpty ? 'gemini-2.5-flash' : model);
      AiService.instance.setModelName(model.isEmpty ? 'gemini-2.5-flash' : model);
      _snack('Exam AI settings saved!');
    } catch (e) {
      _snack('Failed: $e', error: true);
    } finally {
      if (mounted) setState(() => _examSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AI Configuration', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            const Text(
              'Configure the Biology Doubt Solver chatbot and Exam Question Generator.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 28),

            // ── Section 1: Biology Chatbot ──────────────────────
            _SectionHeader(
              icon: Icons.chat_bubble_outline_rounded,
              color: AppColors.primary,
              title: 'Biology Doubt Solver (Chatbot)',
              subtitle: 'Universal OpenAI-compatible API — works with Groq, OpenAI, Together AI, and more.',
            ),
            const SizedBox(height: 16),

            SolidCard(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Info box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.infoSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.info.withOpacity(0.3)),
                  ),
                  child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Icon(Icons.lightbulb_outline, size: 14, color: AppColors.info),
                      SizedBox(width: 6),
                      Text('Provider & Model Guide', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.info)),
                    ]),
                    SizedBox(height: 6),
                    Text(
                      'Groq (recommended, free):  llama-3.3-70b-versatile  •  llama-3.1-8b-instant\n'
                      'OpenAI:  gpt-4o-mini  •  gpt-4o\n'
                      'Get a free Groq key at:  console.groq.com  →  API Keys\n'
                      'Leave Endpoint blank to use Groq as default.',
                      style: TextStyle(fontSize: 11, color: AppColors.info, height: 1.6),
                    ),
                  ]),
                ),
                const SizedBox(height: 16),

                _KeyField(
                  controller: _chatKeyCtrl,
                  label: 'API Key',
                  hint: 'gsk_... (Groq)  or  sk-... (OpenAI)',
                  obscure: _chatObscure,
                  onToggle: () => setState(() => _chatObscure = !_chatObscure),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _chatModelCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Model Name',
                    hintText: 'llama-3.3-70b-versatile',
                    prefixIcon: Icon(Icons.smart_toy_outlined),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _chatEndpointCtrl,
                  decoration: const InputDecoration(
                    labelText: 'API Endpoint (optional)',
                    hintText: 'Leave blank for Groq default',
                    prefixIcon: Icon(Icons.link_rounded),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _chatLimitCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Daily Question Limit per Student',
                    hintText: '350',
                    prefixIcon: Icon(Icons.timer_outlined),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 20),
                GradientButton(
                  label: 'Save Chatbot Settings',
                  icon: Icons.save_rounded,
                  onPressed: _chatSaving ? () {} : _saveChatbot,
                  isLoading: _chatSaving,
                  width: double.infinity,
                ),
              ]),
            ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 24),

            // ── Section 2: Exam AI ──────────────────────────────
            _SectionHeader(
              icon: Icons.auto_awesome_rounded,
              color: AppColors.accent,
              title: 'Exam Question Generator (Gemini)',
              subtitle: 'Used by admin to auto-generate NEET Biology exam questions.',
            ),
            const SizedBox(height: 16),

            SolidCard(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Icon(Icons.info_outline, size: 14, color: AppColors.primary),
                      SizedBox(width: 6),
                      Text('Gemini Model Names', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.primary)),
                    ]),
                    SizedBox(height: 6),
                    Text(
                      'gemini-2.5-flash-preview-05-20   (current, fastest)\n'
                      'gemini-1.5-flash   •   gemini-1.5-pro\n'
                      'Get a free key at:  aistudio.google.com/app/apikey',
                      style: TextStyle(fontSize: 11, color: AppColors.primary, height: 1.6),
                    ),
                  ]),
                ),
                const SizedBox(height: 16),

                _KeyField(
                  controller: _examKeyCtrl,
                  label: 'Gemini API Key',
                  hint: 'AIza...',
                  obscure: _examObscure,
                  onToggle: () => setState(() => _examObscure = !_examObscure),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _examModelCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Model Name',
                    hintText: 'gemini-2.5-flash-preview-05-20',
                    prefixIcon: Icon(Icons.smart_toy_outlined),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 20),
                GradientButton(
                  label: 'Save Exam AI Settings',
                  icon: Icons.save_rounded,
                  onPressed: _examSaving ? () {} : _saveExamAi,
                  isLoading: _examSaving,
                  width: double.infinity,
                ),
              ]),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  const _SectionHeader({required this.icon, required this.color, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.25)),
          ),
          child: Center(child: Icon(icon, color: color, size: 20)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ]),
        ),
      ]);
}

class _KeyField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscure;
  final VoidCallback onToggle;
  const _KeyField({required this.controller, required this.label, required this.hint, required this.obscure, required this.onToggle});

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: const Icon(Icons.key_rounded),
          isDense: true,
          suffixIcon: IconButton(
            icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18),
            onPressed: onToggle,
          ),
        ),
      );
}
