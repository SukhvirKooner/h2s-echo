import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../demo/demo_panel.dart';
import '../../models/enums.dart';
import '../../state/app_state.dart';
import '../../theme/app_constants.dart';
import '../../theme/app_theme.dart';
import '../../widgets/cartridge_painter.dart';
import '../../widgets/charts.dart';
import '../../widgets/common.dart';
import '../../widgets/pipeline_stepper.dart';

class VerifyPipelineScreen extends ConsumerStatefulWidget {
  const VerifyPipelineScreen({super.key});

  @override
  ConsumerState<VerifyPipelineScreen> createState() =>
      _VerifyPipelineScreenState();
}

class _VerifyPipelineScreenState extends ConsumerState<VerifyPipelineScreen>
    with SingleTickerProviderStateMixin {
  late final List<PipelineStep> _steps;
  int _current = 0;
  late AnimationController _gauge;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _gauge = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    final state = ref.read(appStateProvider);
    final cart = state.cartridgeById(state.pendingCartridgeId) ??
        state.cartridges.first;
    _steps = [
      PipelineStep(
        title: 'AUTHENTICATION',
        subtitle: 'Is this QR a genuine registered H2S-ECHO cartridge?',
        visual: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KvRow(label: 'Cartridge ID', value: cart.id),
            KvRow(label: 'Batch / Lot', value: cart.batchLot),
            KvRow(label: 'Chemistry', value: cart.chemistryVersion),
            KvRow(label: 'Calibration', value: '${cart.calibrationModel}/${cart.calibrationVersion}'),
            KvRow(label: 'Revision', value: cart.revision),
            KvRow(label: 'Valid use', value: cart.validUseInfo, monoValue: false),
            const SizedBox(height: 8),
            Center(
              child: QrImageView(
                data: cart.qrPayload,
                size: 88,
                backgroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
      PipelineStep(
        title: 'CONDITION / FRESHNESS',
        subtitle: 'SENTINEL STATUS + RECOVERY STATUS + CYCLE HISTORY',
        visual: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                StatusChip(label: cart.sentinel.name.toUpperCase()),
                const SizedBox(width: 8),
                StatusChip(label: cart.recovery.name.replaceAllMapped(
                  RegExp(r'[A-Z]'),
                  (m) => ' ${m[0]}',
                ).trim().toUpperCase().replaceAll('_', ' ')),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Cycle ${cart.cycleCount.toString().padLeft(2, '0')} of ${cart.maxCycles}',
              style: mono(context, weight: FontWeight.w700),
            ),
            KvRow(
              label: 'Expires',
              value: DateFormat('yyyy-MM-dd').format(cart.expiresAt),
            ),
            const SizedBox(height: 8),
            BaselineMiniChart(points: cart.baselineHistory),
            const SizedBox(height: 4),
            const Text(
              'Baseline signal vs accepted band',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
      PipelineStep(
        title: 'ACCURACY CHECK',
        subtitle: 'Pass threshold kAccuracyThreshold = ${kAccuracyThreshold.toStringAsFixed(0)}%',
        visual: AnimatedBuilder(
          animation: _gauge,
          builder: (context, _) {
            return Column(
              children: [
                SizedBox(
                  height: 160,
                  child: CustomPaint(
                    painter: AccuracyGaugePainter(
                      value: cart.accuracyPct,
                      threshold: kAccuracyThreshold,
                      anim: _gauge.value,
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 36),
                        child: Text(
                          '${(cart.accuracyPct * _gauge.value).toStringAsFixed(1)}%',
                          style: mono(
                            context,
                            size: 28,
                            weight: FontWeight.w800,
                            color: cart.accuracyPct >= kAccuracyThreshold
                                ? AppColors.valid
                                : AppColors.invalid,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Text(
                  'Required ≥ ${kAccuracyThreshold.toStringAsFixed(0)}%',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            );
          },
        ),
      ),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    final notifier = ref.read(appStateProvider.notifier);
    final outcome = ref.read(appStateProvider).demo.qrOutcome;

    for (var i = 0; i < _steps.length; i++) {
      setState(() {
        _current = i;
        _steps[i].state = PipelineStepState.running;
      });
      if (i == 2) _gauge.forward(from: 0);
      await notifier.simulateDelay();

      // Stage failure logic based on demo outcome
      var fail = false;
      if (i == 0 && outcome == QrDemoOutcome.faultDamaged) {
        // fault may fail auth or condition — fail on stage 2 for damaged story
      }
      if (i == 1) {
        if (outcome == QrDemoOutcome.faultDamaged ||
            outcome == QrDemoOutcome.recovering ||
            outcome == QrDemoOutcome.expired) {
          fail = true;
        }
      }
      if (i == 2 && outcome == QrDemoOutcome.lowAccuracy) {
        fail = true;
      }

      setState(() {
        _steps[i].state = fail ? PipelineStepState.failed : PipelineStepState.success;
      });
      if (fail) break;
    }

    if (!mounted) return;
    setState(() => _done = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    switch (outcome) {
      case QrDemoOutcome.verified:
        context.go('/verify/result/verified');
      case QrDemoOutcome.faultDamaged:
        context.go('/verify/result/fault');
      case QrDemoOutcome.lowAccuracy:
        final id = ref.read(appStateProvider).pendingCartridgeId;
        if (id != null) {
          ref.read(appStateProvider.notifier).flagCartridgeLowAccuracy(id);
        }
        context.go('/verify/result/low_accuracy');
      case QrDemoOutcome.recovering:
        context.go('/verify/result/recovering');
      case QrDemoOutcome.expired:
        context.go('/verify/result/expired');
    }
  }

  @override
  void dispose() {
    _gauge.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DemoAwareAppBar(
        title: 'QR VERIFICATION',
        onDemoOpen: () => openDemoPanel(context, ref),
        showBack: _done,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '3-STAGE VERIFICATION',
              style: mono(context, size: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 4),
            const Text(
              'The phone only photographs and decodes the cartridge. It never senses H₂S continuously.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: (_current + 1) / _steps.length,
              backgroundColor: AppColors.surface,
              color: AppColors.accent,
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: AnimatedStepperPanel(steps: _steps, currentIndex: _current),
            ),
          ],
        ),
      ),
    );
  }
}
