import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/enums.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController(text: 'm.chen@siteops.example');
  UserRole _role = UserRole.safetyOfficer;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _busy = true);
    HapticFeedback.mediumImpact();
    await ref.read(appStateProvider.notifier).login(
          email: _email.text.trim(),
          role: _role,
        );
    if (mounted) {
      setState(() => _busy = false);
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0B0F14), Color(0xFF0F1A22), Color(0xFF0B1218)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                const BrandLogo(size: 44)
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.2, end: 0),
                const SizedBox(height: 12),
                Text(
                  'Passive H₂S exposure. Chemical memory on the wrist.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ).animate().fadeIn(delay: 150.ms),
                const SizedBox(height: 36),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Operator email',
                    prefixIcon: Icon(Icons.mail_outline),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'ROLE',
                  style: mono(context, size: 11, color: AppColors.textMuted),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final r in UserRole.values)
                      ChoiceChip(
                        label: Text(r.label),
                        selected: _role == r,
                        onSelected: (_) => setState(() => _role = r),
                      ),
                  ],
                ),
                const SizedBox(height: 28),
                PrimaryButton(
                  label: _busy ? 'SIGNING IN…' : 'SIGN IN',
                  icon: Icons.login,
                  onPressed: _busy ? null : _login,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Demo mode – no network required. All chemistry and imaging are simulated.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
