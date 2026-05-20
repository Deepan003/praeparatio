import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_colors.dart';

// Current TOS version — bump this string to re-show TOS to all existing users.
const kTosVersion = '1.0';

// SharedPreferences key that stores the accepted version string.
const kTosPrefKey = 'tos_accepted_version_v1';

class TosScreen extends StatefulWidget {
  final VoidCallback onAccepted;
  const TosScreen({super.key, required this.onAccepted});

  @override
  State<TosScreen> createState() => _TosScreenState();
}

class _TosScreenState extends State<TosScreen> {
  final ScrollController _scroll = ScrollController();
  bool _hasScrolledToBottom = false;
  bool _accepting = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scroll.position.pixels >=
        _scroll.position.maxScrollExtent - 60) {
      if (!_hasScrolledToBottom) setState(() => _hasScrolledToBottom = true);
    }
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neuBackground,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text('P',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 18)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text('PRAEPARATIO',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            letterSpacing: 1)),
                  ]),
                  const SizedBox(height: 12),
                  const Text('Terms of Service & Privacy Policy',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 20)),
                  const SizedBox(height: 4),
                  Text('Version $kTosVersion  ·  Effective from first use',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 12)),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),

            // ── Notice banner ────────────────────────────────────
            Container(
              width: double.infinity,
              color: AppColors.infoSurface,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: const Row(children: [
                Icon(Icons.info_outline_rounded, size: 14, color: AppColors.info),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Please read the complete Terms of Service before using PRAEPARATIO.',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.info, height: 1.4),
                  ),
                ),
              ]),
            ),

            // ── Scrollable content ───────────────────────────────
            Expanded(
              child: ListView(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                children: const [
                  _TosSection(
                    title: '1. Acceptance of Terms',
                    icon: Icons.handshake_outlined,
                    body:
                        'By accessing or using the PRAEPARATIO application ("App"), you agree to be bound by these Terms of Service ("Terms"). If you do not agree to these Terms, you may not use the App. These Terms constitute a legally binding agreement between you ("User") and the developer, Deepan Pramanick ("Developer").',
                  ),
                  _TosSection(
                    title: '2. Description of Service',
                    icon: Icons.school_outlined,
                    body:
                        'PRAEPARATIO is a NEET Biology preparation platform providing online examinations, previous year questions (PYQ), animated biology diagrams, flashcards, games, an AI-powered doubt solver, study notes, and performance analytics. The App is intended solely for educational use by registered students of enrolled institutions.',
                  ),
                  _TosSection(
                    title: '3. User Accounts and Eligibility',
                    icon: Icons.person_outline_rounded,
                    body:
                        '• Accounts are created exclusively by authorised administrators. Students cannot self-register.\n'
                        '• You are responsible for maintaining the confidentiality of your login credentials.\n'
                        '• You must not share your account with any other person.\n'
                        '• You must be a currently enrolled student of an institution that has licensed PRAEPARATIO.\n'
                        '• Accounts may be suspended or terminated by your administrator at any time.',
                  ),
                  _TosSection(
                    title: '4. Acceptable Use',
                    icon: Icons.rule_outlined,
                    body:
                        'You agree NOT to:\n'
                        '• Use the App for any purpose other than your personal academic preparation.\n'
                        '• Attempt to reverse-engineer, decompile, or extract source code from the App.\n'
                        '• Share exam questions, answers, or any App content publicly without written permission.\n'
                        '• Attempt to manipulate, falsify, or tamper with exam results, scores, or PrepCoin balances.\n'
                        '• Use automated bots, scripts, or any non-human means to interact with the App.\n'
                        '• Engage in any conduct that disrupts or degrades the App experience for other users.',
                  ),
                  _TosSection(
                    title: '5. Examinations and Scoring',
                    icon: Icons.quiz_outlined,
                    body:
                        '• All online examinations use the official NEET scoring system: +4 for correct answers, −1 for incorrect answers, and 0 for unattempted questions.\n'
                        '• Examination results are final once submitted and confirmed by the user.\n'
                        '• The Developer and your institution are not responsible for technical failures, internet disruptions, or device issues that affect your examination performance.\n'
                        '• Only the first official attempt of any examination is recorded as your formal score. Retakes are available for practice purposes only.',
                  ),
                  _TosSection(
                    title: '6. PrepCoins (Virtual Currency)',
                    icon: Icons.monetization_on_outlined,
                    body:
                        '• PrepCoins are a virtual in-app reward currency with no real-world monetary value and cannot be exchanged for cash or any goods or services outside the App.\n'
                        '• PrepCoins are awarded at the discretion of your institution administrator and governed by the rules set within the App.\n'
                        '• The Developer reserves the right to adjust, reset, or modify PrepCoin balances for legitimate operational reasons.\n'
                        '• Attempts to manipulate PrepCoin balances through unauthorised means will result in account suspension.',
                  ),
                  _TosSection(
                    title: '7. AI Chatbot (Biology Doubt Solver)',
                    icon: Icons.smart_toy_outlined,
                    body:
                        '• The AI chatbot is powered by third-party language model APIs and is intended as a supplementary study aid only.\n'
                        '• Responses generated by the AI may occasionally be inaccurate or incomplete. You should always verify information with your NCERT textbook or a qualified teacher.\n'
                        '• Chat conversations are not stored or retained by the App after the session ends.\n'
                        '• A daily usage limit applies, as configured by your institution administrator.',
                  ),
                  _TosSection(
                    title: '8. Data Privacy and Collection',
                    icon: Icons.privacy_tip_outlined,
                    body:
                        'We collect and process the following data to operate the App:\n'
                        '• Account data: name, username, class, batch (provided by your administrator).\n'
                        '• Activity data: examination results, PYQ attempts, PrepCoin transactions, chatbot usage counts, Bio Lab progress, games played.\n'
                        '• Device data: app version, general usage patterns.\n\n'
                        'We do NOT collect: passwords in plain text (stored as hashed values), payment information, precise location data, or any biometric data.\n\n'
                        'Your data is stored securely on Supabase (PostgreSQL) servers and is accessible only to your institution\'s authorised administrators and the Developer.',
                  ),
                  _TosSection(
                    title: '9. Data Retention and Deletion',
                    icon: Icons.delete_outline_rounded,
                    body:
                        '• Your data is retained for the duration of your enrolment at your institution.\n'
                        '• Upon deletion of your account by your administrator, all associated data — including examination results, badges, PrepCoins, and activity records — is permanently and irreversibly deleted.\n'
                        '• You may request deletion of your account by contacting your institution administrator.',
                  ),
                  _TosSection(
                    title: '10. Intellectual Property',
                    icon: Icons.copyright_outlined,
                    body:
                        '• All content within PRAEPARATIO — including the application code, animated diagrams, game logic, badge designs, and study material — is the intellectual property of the Developer, Deepan Pramanick.\n'
                        '• NCERT biology content referenced within the App remains the property of the National Council of Educational Research and Training (NCERT), Government of India.\n'
                        '• You are granted a limited, non-exclusive, non-transferable licence to use the App solely for personal educational purposes.',
                  ),
                  _TosSection(
                    title: '11. Disclaimers and Limitation of Liability',
                    icon: Icons.warning_amber_outlined,
                    body:
                        '• PRAEPARATIO is provided "as is" without warranties of any kind, express or implied.\n'
                        '• The Developer does not guarantee that the App will be uninterrupted, error-free, or that results achieved through the App will guarantee success in the NEET examination.\n'
                        '• To the maximum extent permitted by applicable law, the Developer shall not be liable for any indirect, incidental, consequential, or punitive damages arising from your use of the App.',
                  ),
                  _TosSection(
                    title: '12. Modifications to Terms',
                    icon: Icons.edit_note_outlined,
                    body:
                        'The Developer reserves the right to update these Terms at any time. When Terms are updated, users will be required to review and accept the new version before continuing to use the App. Continued use of the App after accepting updated Terms constitutes agreement to the revised Terms.',
                  ),
                  _TosSection(
                    title: '13. Governing Law',
                    icon: Icons.gavel_outlined,
                    body:
                        'These Terms shall be governed by and construed in accordance with the laws of India. Any disputes arising from these Terms or your use of the App shall be subject to the exclusive jurisdiction of the courts located in India.',
                  ),
                  _TosSection(
                    title: '14. Contact',
                    icon: Icons.contact_mail_outlined,
                    body:
                        'For any questions, concerns, or requests regarding these Terms or your data, please contact:\n\n'
                        'Deepan Pramanick — Developer\n'
                        'GitHub: github.com/Deepan003\n'
                        'Portfolio: deepan-s-porfolio-9c3a.vercel.app\n'
                        'LinkedIn: linkedin.com/in/deepan-pramanick-3b3b90285',
                  ),
                  SizedBox(height: 8),
                  Divider(color: AppColors.border),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      'By tapping "I Accept", you confirm that you have read, understood, and agree to be bound by these Terms of Service and Privacy Policy.',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.6,
                          fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),

            // ── Accept button ────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                color: AppColors.neuBackground,
                border: const Border(
                    top: BorderSide(color: AppColors.border)),
                boxShadow: AppColors.neuRaisedSoft,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!_hasScrolledToBottom)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        const Icon(Icons.keyboard_arrow_down_rounded,
                            size: 16, color: AppColors.textHint),
                        const SizedBox(width: 4),
                        Text('Scroll down to read all terms',
                            style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textHint)),
                      ]),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _hasScrolledToBottom
                            ? AppColors.primary
                            : AppColors.border,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: _hasScrolledToBottom && !_accepting
                          ? () async {
                              setState(() => _accepting = true);
                              widget.onAccepted();
                            }
                          : null,
                      child: _accepting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Text(
                              _hasScrolledToBottom
                                  ? 'I Accept — Continue to PRAEPARATIO'
                                  : 'Scroll to read all terms first',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 15),
                            ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version $kTosVersion · No decline option — acceptance required to use the app',
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textHint),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TosSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final String body;
  const _TosSection(
      {required this.title, required this.icon, required this.body});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(icon, size: 14, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary)),
              ),
            ]),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.neuSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                body,
                style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                    height: 1.65),
              ),
            ),
          ],
        ),
      );
}
