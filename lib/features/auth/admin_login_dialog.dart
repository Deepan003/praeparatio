import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/neu_widgets.dart';

class AdminLoginDialog extends ConsumerStatefulWidget {
  const AdminLoginDialog({super.key});

  @override
  ConsumerState<AdminLoginDialog> createState() => _AdminLoginDialogState();
}

class _AdminLoginDialogState extends ConsumerState<AdminLoginDialog> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;
  bool _isLoading = false;
  String? _errorMsg;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMsg = null; });

    final result = await ref.read(authProvider.notifier).loginAdmin(
      _usernameCtrl.text.trim(),
      _passwordCtrl.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result == AuthResult.success) {
      Navigator.of(context).pop();
      context.go(Routes.adminDashboard);
    } else {
      setState(() => _errorMsg = 'Invalid admin credentials.');
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
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.neuSurface,
            borderRadius: BorderRadius.circular(28),
            boxShadow: AppColors.neuRaisedStrong,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.neuSurface,
                    shape: BoxShape.circle,
                    boxShadow: AppColors.neuRaisedStrong,
                  ),
                  child: const Icon(Icons.admin_panel_settings_rounded,
                      color: AppColors.primary, size: 28),
                ).animate().scale(
                  begin: const Offset(0.4, 0.4),
                  duration: 400.ms,
                  curve: Curves.elasticOut,
                ),

                const SizedBox(height: 18),
                const Text('Admin Portal',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                const Text('Restricted access',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 28),

                NeuTextField(
                  controller: _usernameCtrl,
                  label: 'Admin Username',
                  prefixIcon: Icons.person_outline_rounded,
                  textInputAction: TextInputAction.next,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                NeuTextField(
                  controller: _passwordCtrl,
                  label: 'Admin Password',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: _obscure,
                  onToggleObscure: () =>
                      setState(() => _obscure = !_obscure),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _login(),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Required' : null,
                ),

                if (_errorMsg != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.neuSurface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: AppColors.neuInset,
                      border: Border.all(
                          color: AppColors.error.withOpacity(0.3)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.error_outline_rounded,
                          color: AppColors.error, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_errorMsg!,
                            style: const TextStyle(
                                color: AppColors.error,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600)),
                      ),
                    ]),
                  ).animate().shake(hz: 3, offset: const Offset(5, 0)),
                ],

                const SizedBox(height: 24),
                NeuPrimaryButton(
                  label: 'Access Admin Panel',
                  icon: Icons.login_rounded,
                  onPressed: _isLoading ? null : _login,
                  isLoading: _isLoading,
                  gradient: AppColors.deepGradient,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel',
                      style: TextStyle(color: AppColors.textSecondary)),
                ),
              ],
            ),
          ),
        ).animate()
            .scale(begin: const Offset(0.9, 0.9), duration: 300.ms,
                curve: Curves.easeOut)
            .fadeIn(duration: 200.ms),
      ),
    );
  }
}
