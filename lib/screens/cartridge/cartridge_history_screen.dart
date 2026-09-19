import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../demo/demo_panel.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/charts.dart';
import '../../widgets/common.dart';

class CartridgeHistoryScreen extends ConsumerWidget {
  final String? focusId;
  const CartridgeHistoryScreen({super.key, this.focusId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final carts = ref.watch(appStateProvider).cartridges;
    final focus = focusId != null
        ? carts.where((c) => c.id == focusId).cast<Cartridge?>().firstOrNull
        : null;

    return Scaffold(
      appBar: DemoAwareAppBar(
        title: focus != null ? focus.id : 'CARTRIDGE HISTORY',
        onDemoOpen: () => openDemoPanel(context, ref),
      ),
      body: focus != null
          ? _Detail(cartridge: focus)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: carts.length,
              itemBuilder: (context, i) {
                final c = carts[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(c.id, style: mono(context)),
                    subtitle: Text(
                      'Cycle ${c.cycleCount}/${c.maxCycles} · ${c.lifecycle.label}',
                    ),
                    trailing: StatusChip(label: c.lifecycle.label),
                    onTap: () => context.push('/cartridges/${c.id}'),
                  ),
                );
              },
            ),
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final it = iterator;
    if (it.moveNext()) return it.current;
    return null;
  }
}

class _Detail extends StatelessWidget {
  final Cartridge cartridge;
  const _Detail({required this.cartridge});

  @override
  Widget build(BuildContext context) {
    final progress = cartridge.cycleCount / cartridge.maxCycles;
    final fmt = DateFormat('dd MMM yyyy HH:mm');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionCard(
          child: Column(
            children: [
              KvRow(label: 'Batch / Lot', value: cartridge.batchLot),
              KvRow(label: 'Chemistry', value: cartridge.chemistryVersion),
              KvRow(label: 'Calibration', value: cartridge.calibrationVersion),
              KvRow(label: 'Revision', value: cartridge.revision),
              KvRow(label: 'Accuracy', value: '${cartridge.accuracyPct.toStringAsFixed(1)}%'),
              StatusChip(label: cartridge.lifecycle.label),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: 'LIFECYCLE LIMIT',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cycle ${cartridge.cycleCount.toString().padLeft(2, '0')} of ${cartridge.maxCycles}',
                style: mono(context, weight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress.clamp(0, 1),
                  minHeight: 10,
                  backgroundColor: AppColors.surface,
                  color: progress > 0.85 ? AppColors.invalid : AppColors.accent,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: 'BASELINE',
          child: BaselineMiniChart(points: cartridge.baselineHistory),
        ),
        const SizedBox(height: 12),
        Text(
          'LIFECYCLE TIMELINE',
          style: mono(context, size: 11, color: AppColors.textMuted),
        ),
        const SizedBox(height: 8),
        if (cartridge.cycleHistory.isEmpty)
          const EmptyHint(message: 'No cycle events yet')
        else
          for (final e in cartridge.cycleHistory.reversed)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(
                  e.type == 'EXPOSURE' ? Icons.science : Icons.restart_alt,
                  color: e.type == 'EXPOSURE' ? AppColors.medium : AppColors.valid,
                ),
                title: Text(
                  'Cycle ${e.cycle.toString().padLeft(2, '0')} · ${e.type}',
                  style: mono(context, size: 13),
                ),
                subtitle: Text(
                  '${fmt.format(e.at)}\n${e.note}'
                  '${e.dosePpmH != null ? '\nDose ${e.dosePpmH!.toStringAsFixed(1)} ppm·h' : ''}',
                ),
                isThreeLine: true,
              ),
            ),
      ],
    );
  }
}
