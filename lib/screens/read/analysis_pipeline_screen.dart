import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../demo/demo_panel.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/charts.dart';
import '../../widgets/common.dart';
import '../../widgets/pipeline_stepper.dart';

class AnalysisPipelineScreen extends ConsumerStatefulWidget {
  const AnalysisPipelineScreen({super.key});

  @override
  ConsumerState<AnalysisPipelineScreen> createState() =>
      _AnalysisPipelineScreenState();
}

class _AnalysisPipelineScreenState extends ConsumerState<AnalysisPipelineScreen> {
  late List<PipelineStep> _steps;
  int _current = 0;
  int _checkCount = 0;
  bool _running = true;

  static const _qualityItems = [
    'Blur',
    'Exposure',
    'Alignment',
    'Framing',
    'Glare',
    'Reference visibility',
    'ROI visibility',
    'Completeness',
  ];

  @override
  void initState() {
    super.initState();
    _steps = _buildSteps();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  List<PipelineStep> _buildSteps() {
    return [
      PipelineStep(
        title: '1. Image Quality',
        subtitle: 'Blur, exposure, alignment, framing, glare, refs, ROI, completeness',
        visual: ChecklistAnim(items: _qualityItems, completedCount: _checkCount),
      ),
      PipelineStep(
        title: '2. QR Reconfirmation',
        subtitle: 'Photographed cartridge matches registered cartridge',
      ),
      PipelineStep(
        title: '3. Optical Reference Processing',
        subtitle: 'REF W / REF G / REF D swatches',
        visual: Row(
          children: const [
            _Swatch(color: Color(0xFFF5F5F5), label: 'REF W'),
            SizedBox(width: 8),
            _Swatch(color: Color(0xFF22C55E), label: 'REF G'),
            SizedBox(width: 8),
            _Swatch(color: Color(0xFF111111), label: 'REF D'),
          ],
        ),
      ),
      PipelineStep(
        title: '4. Sensor ROI Extraction',
        subtitle: 'Boxes over S1 / S2 / S3',
        visual: const Text('S1 FAST · S2 MEDIUM · S3 SLOW regions locked',
            style: TextStyle(fontSize: 12, color: AppColors.accent)),
      ),
      PipelineStep(
        title: '5. Image → Features',
        subtitle: 'RGB and CIELAB per channel',
        visual: Column(
          children: [
            KvRow(label: 'S1 L*a*b*', value: '62.1 / -6.2 / 18.4'),
            KvRow(label: 'S2 L*a*b*', value: '48.3 / -4.1 / 14.2'),
            KvRow(label: 'S3 L*a*b*', value: '41.0 / -2.8 / 11.0'),
          ],
        ),
      ),
      PipelineStep(
        title: '6. Optical Normalization',
        subtitle: 'Raw vs normalized values',
        visual: Column(
          children: [
            KvRow(label: 'S1 raw → norm', value: '0.91 → 0.82'),
            KvRow(label: 'S2 raw → norm', value: '0.54 → 0.48'),
            KvRow(label: 'S3 raw → norm', value: '0.35 → 0.31'),
          ],
        ),
      ),
      PipelineStep(
        title: '7. Digital Fingerprint',
        subtitle: 'FAST / MEDIUM / SLOW',
        visual: FingerprintBars(
          fingerprint: const Fingerprint(fast: 0.82, medium: 0.48, slow: 0.31),
        ),
      ),
      PipelineStep(
        title: '8. Readout Time Gate',
        subtitle: 'Δt vs validated window',
      ),
      PipelineStep(
        title: '9. Recovery State Gate',
        subtitle: 'Cartridge recovery eligibility',
      ),
      PipelineStep(
        title: '10. Channel Consistency',
        subtitle: 'S1/S2/S3 mutual agreement',
      ),
      PipelineStep(
        title: '11. Calibration Domain',
        subtitle: 'Point inside / outside domain region',
        visual: const CalibrationDomainPlot(inside: true),
      ),
      PipelineStep(title: '12. Dose Engine', subtitle: 'ppm·h estimate'),
      PipelineStep(title: '13. Pattern Engine', subtitle: 'SPIKE / SUSTAINED / INTERMITTENT'),
      PipelineStep(title: '14. Confidence Engine', subtitle: 'HIGH / MEDIUM / LOW / INDETERMINATE'),
      PipelineStep(title: '15. Final Validity', subtitle: 'VALID RESULT or NO RESULT'),
    ];
  }

  Future<void> _run() async {
    final notifier = ref.read(appStateProvider.notifier);
    final outcome = ref.read(appStateProvider).demo.readOutcome;
    final cartId = ref.read(appStateProvider).pendingCartridgeId ??
        ref.read(appStateProvider).activeShift?.cartridgeId ??
        'ECH-C-00317';

    // Fail step indices (0-based)
    int? failAt;
    switch (outcome) {
      case ReadDemoOutcome.retake:
        failAt = 0;
      case ReadDemoOutcome.invalidTime:
        failAt = 7;
      case ReadDemoOutcome.outOfRange:
        failAt = 10;
      case ReadDemoOutcome.channelInconsistency:
        failAt = 9;
      case ReadDemoOutcome.valid:
        failAt = null;
    }

    for (var i = 0; i < _steps.length; i++) {
      setState(() {
        _current = i;
        _steps[i].state = PipelineStepState.running;
        if (i == 0) _checkCount = 0;
        // refresh checklist visual
        if (i == 0) {
          _steps[0] = PipelineStep(
            title: _steps[0].title,
            subtitle: _steps[0].subtitle,
            state: PipelineStepState.running,
            visual: ChecklistAnim(items: _qualityItems, completedCount: _checkCount),
          );
        }
      });

      if (i == 0) {
        for (var q = 1; q <= _qualityItems.length; q++) {
          await Future<void>.delayed(Duration(
            milliseconds: ref.read(appStateProvider).demo.fastDelays ? 40 : 90,
          ));
          if (!mounted) return;
          setState(() {
            _checkCount = q;
            _steps[0] = PipelineStep(
              title: _steps[0].title,
              subtitle: _steps[0].subtitle,
              state: PipelineStepState.running,
              visual: ChecklistAnim(items: _qualityItems, completedCount: _checkCount),
            );
          });
        }
      } else {
        await notifier.simulateDelay();
      }

      final fail = failAt == i;
      if (i == 10 && outcome == ReadDemoOutcome.outOfRange) {
        setState(() {
          _steps[i] = PipelineStep(
            title: _steps[i].title,
            subtitle: _steps[i].subtitle,
            state: PipelineStepState.running,
            visual: const CalibrationDomainPlot(inside: false),
          );
        });
      }

      setState(() {
        _steps[i].state = fail ? PipelineStepState.failed : PipelineStepState.success;
      });
      if (fail) break;
    }

    if (!mounted) return;
    final record = await notifier.createReadResult(
      outcome: outcome,
      cartridgeId: cartId,
    );
    if (!mounted) return;
    setState(() => _running = false);

    if (outcome == ReadDemoOutcome.valid) {
      context.go('/read/result/${record.id}');
    } else {
      final reason = record.invalidReason ?? 'NO VALID RESULT';
      context.go('/read/failure/${Uri.encodeComponent(reason)}?id=${record.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DemoAwareAppBar(
        title: 'ANALYSIS PIPELINE',
        onDemoOpen: () => openDemoPanel(context, ref),
        showBack: !_running,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_current + 1) / _steps.length,
              color: AppColors.cyan,
              backgroundColor: AppColors.surface,
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
            ),
            const SizedBox(height: 8),
            Text(
              'Step ${_current + 1} of ${_steps.length}',
              style: mono(context, size: 11, color: AppColors.textMuted),
            ),
            Expanded(
              child: AnimatedStepperPanel(steps: _steps, currentIndex: _current),
            ),
          ],
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  final Color color;
  final String label;
  const _Swatch({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.borderStrong),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: mono(context, size: 9)),
      ],
    );
  }
}
