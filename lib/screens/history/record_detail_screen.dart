import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../demo/demo_panel.dart';
import '../../models/enums.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/charts.dart';
import '../../widgets/common.dart';

class RecordDetailScreen extends ConsumerWidget {
  final String recordId;
  const RecordDetailScreen({super.key, required this.recordId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final r = state.recordById(recordId);
    if (r == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('DIGITAL RECORD')),
        body: const EmptyHint(message: 'Record not found'),
      );
    }

    final fmt = DateFormat('yyyy-MM-dd HH:mm:ss');
    final valid = r.validity == ResultValidity.validResult;

    return Scaffold(
      appBar: DemoAwareAppBar(
        title: 'DIGITAL RECORD',
        onDemoOpen: () => openDemoPanel(context, ref),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          StatusChip(
            label: valid ? 'VALID RESULT' : (r.invalidReason ?? 'NO RESULT'),
            color: valid ? AppColors.valid : AppColors.invalid,
          ),
          const SizedBox(height: 16),
          _AuditChain(),
          const SizedBox(height: 16),
          _Expand(
            title: 'IDENTITY',
            children: [
              KvRow(label: 'Record', value: r.id),
              KvRow(label: 'Worker ID', value: r.workerId),
              KvRow(label: 'Shift ID', value: r.shiftId),
              KvRow(label: 'Cartridge ID', value: r.cartridgeId),
            ],
          ),
          _Expand(
            title: 'CARTRIDGE',
            children: [
              KvRow(label: 'FIT', value: r.cartridgeFit ? 'FIT' : 'UNFIT'),
              KvRow(label: 'Recovery', value: r.recoveryState),
            ],
          ),
          _Expand(
            title: 'TIME',
            children: [
              KvRow(label: 'Start', value: fmt.format(r.shiftStart)),
              KvRow(label: 'End', value: fmt.format(r.shiftEnd)),
              KvRow(label: 'Readout', value: fmt.format(r.readoutAt)),
              KvRow(label: 'Δt (h)', value: r.deltaTH.toStringAsFixed(2)),
              KvRow(label: 'Readout gate', value: r.readoutGate),
            ],
          ),
          _Expand(
            title: 'OPTICAL',
            children: [
              if (r.channels.isEmpty)
                const Text('No optical features (failed reading)',
                    style: TextStyle(color: AppColors.textSecondary))
              else
                for (final c in r.channels)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '${c.name}: RGB(${c.r.toStringAsFixed(0)},${c.g.toStringAsFixed(0)},${c.b.toStringAsFixed(0)}) '
                      'L*a*b*(${c.l.toStringAsFixed(1)},${c.a.toStringAsFixed(1)},${c.bb.toStringAsFixed(1)}) '
                      'raw ${c.raw.toStringAsFixed(2)} → norm ${c.normalized.toStringAsFixed(2)}',
                      style: mono(context, size: 11),
                    ),
                  ),
            ],
          ),
          _Expand(
            title: 'CHEMICAL',
            children: [
              if (r.fingerprint != null) ...[
                FingerprintBars(fingerprint: r.fingerprint!),
                KvRow(label: 'FAST', value: r.fingerprint!.fast.toStringAsFixed(2)),
                KvRow(label: 'MEDIUM', value: r.fingerprint!.medium.toStringAsFixed(2)),
                KvRow(label: 'SLOW', value: r.fingerprint!.slow.toStringAsFixed(2)),
              ] else
                const Text('No fingerprint on failed reading',
                    style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
          _Expand(
            title: 'ANALYTICAL',
            children: [
              if (valid) ...[
                KvRow(label: 'Dose', value: '${r.dosePpmH!.toStringAsFixed(1)} ppm·h'),
                KvRow(label: 'Pattern', value: r.pattern?.label ?? '—'),
              ] else
                const Text(
                  'No dose number is shown on a failed reading.',
                  style: TextStyle(color: AppColors.invalid),
                ),
              KvRow(label: 'Confidence', value: r.confidence.label),
              KvRow(label: 'Validity', value: valid ? 'VALID RESULT' : 'NO RESULT'),
              const SizedBox(height: 8),
              for (final e in r.gates.entries)
                Row(
                  children: [
                    Icon(
                      e.value ? Icons.check_circle : Icons.cancel,
                      size: 16,
                      color: e.value ? AppColors.valid : AppColors.invalid,
                    ),
                    const SizedBox(width: 8),
                    Text(e.key, style: mono(context, size: 12)),
                  ],
                ),
            ],
          ),
          _Expand(
            title: 'TRACEABILITY',
            children: [
              KvRow(label: 'Calibration', value: r.calibrationVersion),
              KvRow(label: 'Software', value: r.softwareVersion),
              KvRow(label: 'Model', value: r.modelVersion),
              KvRow(label: 'Sync', value: r.syncStatus.name.toUpperCase()),
              if (r.invalidReason != null)
                KvRow(label: 'Invalid reason', value: r.invalidReason!),
            ],
          ),
        ],
      ),
    );
  }
}

class _Expand extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Expand({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(title, style: mono(context, size: 12, weight: FontWeight.w800)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: children,
      ),
    );
  }
}

class _AuditChain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const nodes = [
      'WORKER',
      'SHIFT',
      'CARTRIDGE',
      'EXPOSURE',
      'PHOTO',
      'ANALYSIS',
      'RESULT',
    ];
    return SectionCard(
      title: 'AUDIT CHAIN',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < nodes.length; i++) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.5)),
                ),
                child: Text(nodes[i], style: mono(context, size: 10, weight: FontWeight.w700)),
              ),
              if (i < nodes.length - 1)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(Icons.arrow_forward, size: 14, color: AppColors.textMuted),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
