import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../demo/demo_panel.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class ReadyToWearScreen extends ConsumerStatefulWidget {
  const ReadyToWearScreen({super.key});

  @override
  ConsumerState<ReadyToWearScreen> createState() => _ReadyToWearScreenState();
}

class _ReadyToWearScreenState extends ConsumerState<ReadyToWearScreen> {
  bool _worn = false;
  bool _busy = false;

  Future<void> _wear() async {
    setState(() {
      _worn = true;
      _busy = true;
    });
    await ref.read(appStateProvider.notifier).simulateDelay();
    if (!mounted) return;
    setState(() => _busy = false);
    showAppSnack(context, 'Cartridge marked worn on wrist');
  }

  Future<void> _start() async {
    if (!_worn) {
      showAppSnack(context, 'Wear cartridge first', color: AppColors.recovering);
      return;
    }
    setState(() => _busy = true);
    await ref.read(appStateProvider.notifier).startShift();
    if (!mounted) return;
    context.go('/shift/active');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final shift = state.activeShift;
    final cart = state.cartridgeById(shift?.cartridgeId ?? state.pendingCartridgeId);
    final worker = state.workerById(shift?.workerId);

    return Scaffold(
      appBar: DemoAwareAppBar(
        title: 'READY TO WEAR',
        onDemoOpen: () => openDemoPanel(context, ref),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SectionCard(
              child: Column(
                children: [
                  KvRow(label: 'Cartridge ID', value: cart?.id ?? '—'),
                  KvRow(label: 'Worker', value: '${worker?.id ?? '—'} · ${worker?.name ?? ''}'),
                  KvRow(label: 'Shift', value: shift?.id ?? '—'),
                  KvRow(label: 'Status', value: 'READY'),
                  KvRow(
                    label: 'Calibration',
                    value: cart?.calibrationVersion ?? 'H2S-ECHO-CAL-V1',
                  ),
                  KvRow(label: 'Readiness', value: _worn ? 'WORN' : 'PENDING WEAR'),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.05, end: 0),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _worn ? AppColors.valid : AppColors.border,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _worn ? Icons.check_circle : Icons.watch,
                    size: 48,
                    color: _worn ? AppColors.valid : AppColors.accent,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _worn
                        ? 'Wristband cartridge secured'
                        : 'Place cartridge on worker wrist and confirm',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Spacer(),
            PrimaryButton(
              label: _worn ? 'WEAR CONFIRMED' : 'WEAR CARTRIDGE',
              icon: Icons.back_hand_outlined,
              onPressed: _worn || _busy ? null : _wear,
            ),
            const SizedBox(height: 10),
            PrimaryButton(
              label: _busy ? 'STARTING…' : 'START SHIFT',
              icon: Icons.play_arrow,
              color: AppColors.valid,
              onPressed: !_worn || _busy ? null : _start,
            ),
          ],
        ),
      ),
    );
  }
}
