import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../demo/demo_panel.dart';
import '../../models/enums.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/charts.dart';
import '../../widgets/common.dart';

class ReadResultScreen extends ConsumerWidget {
  final String recordId;
  const ReadResultScreen({super.key, required this.recordId});

  IconData _patternIcon(ExposurePattern? p) {
    switch (p) {
      case ExposurePattern.spike:
        return Icons.bolt;
      case ExposurePattern.sustained:
        return Icons.horizontal_rule;
      case ExposurePattern.intermittent:
        return Icons.graphic_eq;
      case null:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final record = state.recordById(recordId);
    if (record == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('RESULT')),
        body: const EmptyHint(message: 'Record not found'),
      );
    }

    return Scaffold(
      appBar: DemoAwareAppBar(
        title: 'FINAL RESULT',
        onDemoOpen: () => openDemoPanel(context, ref),
        showBack: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Center(child: StatusChip(label: 'VALID RESULT', color: AppColors.valid))
              .animate()
              .scale(begin: const Offset(0.8, 0.8)),
          const SizedBox(height: 20),
          SectionCard(
            title: 'EXPOSURE DOSE',
            child: CountUpText(
              value: record.dosePpmH ?? 0,
              suffix: ' ppm·h',
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: 'EXPOSURE PATTERN',
            child: Row(
              children: [
                Icon(_patternIcon(record.pattern), color: AppColors.cyan, size: 32),
                const SizedBox(width: 12),
                Text(
                  record.pattern?.label ?? '—',
                  style: mono(context, size: 22, weight: FontWeight.w800),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (record.fingerprint != null)
            SectionCard(
              title: 'DIGITAL FINGERPRINT',
              child: FingerprintBars(fingerprint: record.fingerprint!),
            ),
          const SizedBox(height: 12),
          SectionCard(
            child: Column(
              children: [
                KvRow(label: 'Cartridge FIT', value: record.cartridgeFit ? 'FIT' : 'UNFIT'),
                KvRow(label: 'Recovery', value: record.recoveryState),
                KvRow(label: 'Readout', value: record.readoutGate),
                KvRow(label: 'Confidence', value: record.confidence.label),
                KvRow(label: 'Worker ID', value: record.workerId),
                KvRow(label: 'Shift ID', value: record.shiftId),
                KvRow(label: 'Cartridge ID', value: record.cartridgeId),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: 'WHY TWO FINGERPRINTS DIFFER',
            child: const Text(
              '8 ppm × 1 h and 1 ppm × 8 h are both 8 ppm·h but give different FAST / MEDIUM / SLOW fingerprints. Dose alone does not reveal temporal pattern — the three-channel chemical memory does.',
              style: TextStyle(color: AppColors.textSecondary, height: 1.4),
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'VIEW DIGITAL RECORD',
            icon: Icons.article_outlined,
            onPressed: () => context.push('/history/${record.id}'),
          ),
          const SizedBox(height: 10),
          PrimaryButton(
            label: 'WEB SYNC',
            icon: Icons.cloud_upload_outlined,
            onPressed: () => context.push('/sync'),
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: 'Back to Control Center',
            onPressed: () => context.go('/home'),
          ),
        ],
      ),
    );
  }
}
