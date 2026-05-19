import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/animated_logo.dart';
import '../../widgets/neu_widgets.dart';
import 'admin_login_dialog.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;
  bool _isLoading = false;
  bool _showingSkeleton = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _usernameCtrl.addListener(_checkAdminTrigger);
    _passwordCtrl.addListener(_checkAdminTrigger);
  }

  void _checkAdminTrigger() {
    if (_usernameCtrl.text == AppConstants.adminTriggerUsername &&
        _passwordCtrl.text == AppConstants.adminTriggerPassword) {
      _usernameCtrl.clear();
      _passwordCtrl.clear();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const AdminLoginDialog(),
      );
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMsg = null; });

    final result = await ref.read(authProvider.notifier).loginStudent(
      _usernameCtrl.text.trim(),
      _passwordCtrl.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    switch (result) {
      case AuthResult.success:
        final loggedIn = ref.read(authProvider).value;
        if (loggedIn != null && !loggedIn.isAdmin) {
          // Welcome notification on very first login
          if (loggedIn.lastLogin == null) {
            NotificationService.instance.notifyWelcome(
              studentId:   loggedIn.id,
              studentName: loggedIn.name,
            );
          }
        }
        setState(() => _showingSkeleton = true);
        await Future.delayed(const Duration(milliseconds: 1600));
        if (mounted) context.go(Routes.studentDashboard);
      case AuthResult.banned:
        setState(() => _errorMsg = 'Account suspended. Contact your admin.');
      case AuthResult.adminBlocked:
        setState(() => _errorMsg = 'Use the admin portal to sign in.');
      case AuthResult.invalidCredentials:
        setState(() => _errorMsg = 'Incorrect username or password. Please try again.');
    }
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showingSkeleton) return _LoginSkeletonScreen();

    final size = MediaQuery.sizeOf(context);
    final isWide = size.width >= 720;

    return Scaffold(
      backgroundColor: AppColors.neuBackground,
      body: SafeArea(
        child: isWide ? _wideLayout(size) : _mobileLayout(),
      ),
    );
  }

  Widget _wideLayout(Size size) => Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _logoBlock(size: 130, interactive: true),
              const SizedBox(height: 40),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: _loginPanel(),
              ),
            ],
          ),
        ),
      );

  Widget _mobileLayout() => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
        child: Column(children: [
          // Use AnimatedSize so logo collapses smoothly on error
          // — no jarring jump and no replay of the entry animation
          AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOut,
            child: _errorMsg == null
                ? Column(mainAxisSize: MainAxisSize.min, children: [
                    _logoBlock(size: 90, interactive: false),
                    const SizedBox(height: 32),
                  ])
                : const SizedBox(width: double.infinity, height: 8),
          ),
          _loginPanel(),
        ]),
      );

  Widget _logoBlock({required double size, required bool interactive}) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size, height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.neuSurface,
              boxShadow: AppColors.neuRaisedStrong,
            ),
            child: Center(child: AnimatedLogo(size: size * 0.8, interactive: interactive)),
          ).animate().scale(begin: const Offset(0.3, 0.3), duration: 750.ms, curve: Curves.elasticOut),
          const SizedBox(height: 18),
          const Text('PRAEPARATIO',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900,
                  color: AppColors.primary, letterSpacing: 5))
              .animate(delay: 200.ms).fadeIn().slideY(begin: 0.15),
          const SizedBox(height: 6),
          const Text(AppConstants.tagline,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic, height: 1.5))
              .animate(delay: 320.ms).fadeIn(),
        ],
      );

  Widget _loginPanel() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.neuSurface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.neuRaisedStrong,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text('P',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                          letterSpacing: -1)),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome back',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.3)),
                    SizedBox(height: 1),
                    Text('Sign in to continue',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 28),

            // Username field
            NeuTextField(
              controller: _usernameCtrl,
              label: 'Username',
              prefixIcon: Icons.person_outline_rounded,
              textInputAction: TextInputAction.next,
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Please enter your username' : null,
            ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.15),

            const SizedBox(height: 16),

            // Password field
            NeuTextField(
              controller: _passwordCtrl,
              label: 'Password',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: _obscure,
              onToggleObscure: () => setState(() => _obscure = !_obscure),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _login(),
              validator: (v) => v == null || v.isEmpty
                  ? 'Please enter your password' : null,
            ).animate(delay: 180.ms).fadeIn().slideY(begin: 0.15),

                    // Error message — inline, no page jump
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              child: _errorMsg == null
                  ? const SizedBox(width: double.infinity)
                  : Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 11),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.error.withOpacity(0.35)),
                        ),
                        child: Row(children: [
                          const Icon(Icons.error_outline_rounded,
                              color: AppColors.error, size: 16),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(_errorMsg!,
                                style: const TextStyle(
                                    color: AppColors.error,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600)),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _errorMsg = null),
                            child: const Icon(Icons.close_rounded,
                                color: AppColors.error, size: 16),
                          ),
                        ]),
                      ).animate().shake(hz: 3, offset: const Offset(4, 0)),
                    ),
            ),

            const SizedBox(height: 26),

            // Sign-in button
            NeuPrimaryButton(
              label: 'Sign In',
              icon: Icons.login_rounded,
              onPressed: _isLoading ? null : _login,
              isLoading: _isLoading,
            ).animate(delay: 260.ms).fadeIn().slideY(begin: 0.15),

            const SizedBox(height: 20),
            const Center(
              child: Text(
                'PRAEPARATIO — NEET Biology Platform',
                style: TextStyle(
                    fontSize: 10, color: AppColors.textHint),
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: 80.ms).fadeIn(duration: 500.ms).slideY(begin: 0.06);
  }
}

// ── Skeleton loading screen shown briefly after successful login ───
class _LoginSkeletonScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 720;
    return Scaffold(
      backgroundColor: AppColors.neuBackground,
      body: SafeArea(
        child: Shimmer.fromColors(
          baseColor: AppColors.border,
          highlightColor: AppColors.neuSurface,
          child: isMobile ? _mobileSkeleton() : _desktopSkeleton(),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _box(double w, double h, {double radius = 12}) => Container(
        width: w, height: h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      );

  Widget _mobileSkeleton() => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 12),
          // Top greeting
          Row(children: [
            _box(44, 44, radius: 22),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _box(130, 14, radius: 7),
              const SizedBox(height: 6),
              _box(90, 10, radius: 5),
            ]),
            const Spacer(),
            _box(36, 36, radius: 18),
          ]),
          const SizedBox(height: 20),
          // Stats row
          Row(children: [
            Expanded(child: _box(double.infinity, 72)),
            const SizedBox(width: 10),
            Expanded(child: _box(double.infinity, 72)),
            const SizedBox(width: 10),
            Expanded(child: _box(double.infinity, 72)),
          ]),
          const SizedBox(height: 20),
          _box(120, 14, radius: 7),
          const SizedBox(height: 12),
          // Card rows
          for (int i = 0; i < 3; i++) ...[
            _box(double.infinity, 80),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 8),
          _box(180, 14, radius: 7),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _box(double.infinity, 100)),
            const SizedBox(width: 10),
            Expanded(child: _box(double.infinity, 100)),
          ]),
        ]),
      );

  Widget _desktopSkeleton() => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            _box(160, 14, radius: 7),
            const Spacer(),
            _box(100, 36),
            const SizedBox(width: 10),
            _box(100, 36),
          ]),
          const SizedBox(height: 20),
          Row(children: [
            for (int i = 0; i < 4; i++) ...[
              Expanded(child: _box(double.infinity, 80)),
              if (i < 3) const SizedBox(width: 14),
            ],
          ]),
          const SizedBox(height: 20),
          Expanded(
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 3, child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _box(140, 14, radius: 7),
                  const SizedBox(height: 12),
                  for (int i = 0; i < 4; i++) ...[
                    _box(double.infinity, 72),
                    const SizedBox(height: 10),
                  ],
                ],
              )),
              const SizedBox(width: 20),
              Expanded(flex: 2, child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _box(100, 14, radius: 7),
                  const SizedBox(height: 12),
                  _box(double.infinity, 220),
                ],
              )),
            ]),
          ),
        ]),
      );
}

