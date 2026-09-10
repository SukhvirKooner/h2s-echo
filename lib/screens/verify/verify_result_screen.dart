import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../demo/demo_panel.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_constants.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class VerifyResultScreen extends ConsumerWidget {
  final String outcome;

  const VerifyResultScreen({super.key, required this.outcome});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final cart = state.cartridgeById(state.pendingCartridgeId);

    switch (outcome) {
      case 'verified':
        return _ResultScaffold(
          color: AppColors.valid,
          icon: Icons.verified,
          title: 'CARTRIDGE READY',
          body:
              'Authentic, fresh, and accuracy above threshold. Cartridge is eligible for assignment.',
          details: [
            if (cart != null) ...[
              KvRow(label: 'Cartridge', value: cart.id),
              KvRow(label: 'Calibration', value: cart.calibrationVersion),
              KvRow(
                label: 'Accuracy',
                value: '${cart.accuracyPct.toStringAsFixed(1)}%',
              ),
              KvRow(label: 'Status', value: 'READY'),
            ],
          ],
          primaryLabel: 'CONTINUE TO READY-TO-WEAR',
          onPrimary: () => context.go('/shift/new'),
          secondaryLabel: 'Back to home',
          onSecondary: () => context.go('/home'),
          onDemo: () => openDemoPanel(context, ref),
        );
      case 'low_accuracy':
        final measured = cart?.accuracyPct ?? 84.2;
        return _ResultScaffold(
          color: AppColors.invalid,
          icon: Icons.gpp_bad,
          title: 'ACCURACY BELOW THRESHOLD – CARTRIDGE REMOVED FROM USE',
          body:
              'Authentic cartridge, but measured accuracy is below the pass threshold. It is flagged and cannot be assigned.',
          details: [
            KvRow(
              label: 'Measured',
              value: '${measured.toStringAsFixed(1)}%',
            ),
            KvRow(
              label: 'Required',
              value: '≥ ${kAccuracyThreshold.toStringAsFixed(0)}%',
            ),
            if (cart != null) KvRow(label: 'Cartridge', value: cart.id),
            const KvRow(label: 'Flag', value: 'REMOVED FROM USE'),
          ],
          primaryLabel: 'SCAN ANOTHER CARTRIDGE',
          onPrimary: () => context.go('/verify/scan'),
          secondaryLabel: 'Back to home',
          onSecondary: () => context.go('/home'),
          onDemo: () => openDemoPanel(context, ref),
        );
      case 'recovering':
        return _ResultScaffold(
          color: AppColors.recovering,
          icon: Icons.hourglass_top,
          title: 'RECOVERING NOT READY',
          body:
              'Cartridge is still recovering from a prior exposure. It cannot be silently treated as fresh.',
          details: [
            if (cart != null) ...[
              KvRow(label: 'Cartridge', value: cart.id),
              KvRow(label: 'Status', value: 'RECOVERING'),
              KvRow(
                label: 'Cycle',
                value: '${cart.cycleCount} of ${cart.maxCycles}',
              ),
            ],
          ],
          primaryLabel: 'SCAN ANOTHER CARTRIDGE',
          onPrimary: () => context.go('/verify/scan'),
          secondaryLabel: 'Back to home',
          onSecondary: () => context.go('/home'),
          onDemo: () => openDemoPanel(context, ref),
        );
      case 'expired':
        return _ResultScaffold(
          color: AppColors.expired,
          icon: Icons.event_busy,
          title: 'EXPIRED DO NOT USE',
          body: 'Cartridge validity period has ended. Do not assign to a worker.',
          details: [
            if (cart != null) ...[
              KvRow(label: 'Cartridge', value: cart.id),
              KvRow(label: 'Status', value: 'EXPIRED'),
            ],
          ],
          primaryLabel: 'SCAN ANOTHER CARTRIDGE',
          onPrimary: () => context.go('/verify/scan'),
          secondaryLabel: 'Back to home',
          onSecondary: () => context.go('/home'),
          onDemo: () => openDemoPanel(context, ref),
        );
      default:
        return _ResultScaffold(
          color: AppColors.fault,
          icon: Icons.dangerous,
          title: 'DEVICE FAULT DETECTED',
          body:
              'Cartridge failed authentication or condition checks (CARTRIDGE INVALID / DAMAGED / DEVICE FAULT DETECTED).',
          details: [
            if (cart != null) ...[
              KvRow(label: 'Cartridge', value: cart.id),
              KvRow(label: 'Reason', value: cart.lifecycle.label),
            ],
          ],
          primaryLabel: 'SCAN ANOTHER CARTRIDGE',
          onPrimary: () => context.go('/verify/scan'),
          secondaryLabel: 'Back to home',
          onSecondary: () => context.go('/home'),
          onDemo: () => openDemoPanel(context, ref),
        );
    }
  }
}

class _ResultScaffold extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String body;
  final List<Widget> details;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String secondaryLabel;
  final VoidCallback onSecondary;
  final VoidCallback onDemo;

  const _ResultScaffold({
    required this.color,
    required this.icon,
    required this.title,
    required this.body,
    required this.details,
    required this.primaryLabel,
    required this.onPrimary,
    required this.secondaryLabel,
    required this.onSecondary,
    required this.onDemo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DemoAwareAppBar(
        title: 'VERIFICATION RESULT',
        onDemoOpen: onDemo,
        showBack: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.15),
                  border: Border.all(color: color, width: 2),
                ),
                child: Icon(icon, size: 48, color: color),
              )
                  .animate()
                  .scale(begin: const Offset(0.6, 0.6), duration: 400.ms)
                  .fadeIn(),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: color,
                      letterSpacing: 0.4,
                    ),
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 12),
              Text(
                body,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              SectionCard(child: Column(children: details)),
              const Spacer(),
              PrimaryButton(
                label: primaryLabel,
                color: color == AppColors.valid ? null : color,
                onPressed: onPrimary,
              ),
              const SizedBox(height: 10),
              SecondaryButton(label: secondaryLabel, onPressed: onSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
