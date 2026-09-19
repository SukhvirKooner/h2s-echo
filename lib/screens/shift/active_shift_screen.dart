import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../demo/demo_panel.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class ActiveShiftScreen extends ConsumerStatefulWidget {
  const ActiveShiftScreen({super.key});

  @override
  ConsumerState<ActiveShiftScreen> createState() => _ActiveShiftScreenState();
}

class _ActiveShiftScreenState extends ConsumerState<ActiveShiftScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  bool _ending = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _end() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgElevated,
        title: const Text('End shift?'),
        content: const Text(
          'Cartridge state will become EXPOSED → RECOVERING. A Δt counter starts for the validated readout window.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('END SHIFT')),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _ending = true);
    await ref.read(appStateProvider.notifier).endShift();
    if (!mounted) return;
    context.go('/shift/ended');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final shift = state.activeShift;
    if (shift == null || shift.startedAt == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('ACTIVE SHIFT')),
        body: EmptyHint(
          message: 'No active shift. Start one from Control Center.',
          icon: Icons.timer_off_outlined,
        ),
      );
    }

    return Scaffold(
      appBar: DemoAwareAppBar(
        title: 'ACTIVE SHIFT',
        onDemoOpen: () => openDemoPanel(context, ref),
        showBack: true,
        actions: [
          IconButton(
            tooltip: 'Home',
            onPressed: () => context.go('/home'),
            icon: const Icon(Icons.home_outlined),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const StatusChip(label: 'ACTIVE', pulse: true),
            const SizedBox(height: 16),
            StreamBuilder(
              stream: Stream.periodic(const Duration(seconds: 1)),
              builder: (context, _) {
                final d = DateTime.now().difference(shift.startedAt!);
                final h = d.inHours.toString().padLeft(2, '0');
                final m = (d.inMinutes % 60).toString().padLeft(2, '0');
                final s = (d.inSeconds % 60).toString().padLeft(2, '0');
                return Text(
                  '$h:$m:$s',
                  style: mono(context, size: 48, weight: FontWeight.w800, color: AppColors.accent),
                );
              },
            ),
            const SizedBox(height: 8),
            Text(shift.id, style: mono(context, color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            SectionCard(
              child: Column(
                children: [
                  const Text(
                    'Passive recording in progress – cartridge is storing exposure chemically',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  AnimatedBuilder(
                    animation: _pulse,
                    builder: (context, _) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _ChannelDot(label: 'S1 FAST', t: _pulse.value),
                          _ChannelDot(label: 'S2 MEDIUM', t: (_pulse.value + 0.3) % 1),
                          _ChannelDot(label: 'S3 SLOW', t: (_pulse.value + 0.6) % 1),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Text(
                      'The phone is not measuring H₂S. The wearable wristband cartridge records exposure; the phone only photographs and decodes it later.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(),
            const SizedBox(height: 16),
            SectionCard(
              child: Column(
                children: [
                  KvRow(label: 'Worker', value: shift.workerId),
                  KvRow(label: 'Cartridge', value: shift.cartridgeId ?? '—'),
                  KvRow(label: 'Area', value: shift.workArea, monoValue: false),
                  KvRow(label: 'Job', value: shift.jobOperation, monoValue: false),
                ],
              ),
            ),
            const Spacer(),
            PrimaryButton(
              label: _ending ? 'ENDING…' : 'END SHIFT',
              icon: Icons.stop_circle_outlined,
              color: AppColors.invalid,
              onPressed: _ending ? null : _end,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChannelDot extends StatelessWidget {
  final String label;
  final double t;
  const _ChannelDot({required this.label, required this.t});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.accent.withValues(alpha: 0.35 + t * 0.65),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.3 * t),
                blurRadius: 8,
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: mono(context, size: 9, color: AppColors.textMuted)),
      ],
    );
  }
}
