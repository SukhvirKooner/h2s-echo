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

class ExposureHistoryScreen extends ConsumerStatefulWidget {
  const ExposureHistoryScreen({super.key});

  @override
  ConsumerState<ExposureHistoryScreen> createState() =>
      _ExposureHistoryScreenState();
}

class _ExposureHistoryScreenState extends ConsumerState<ExposureHistoryScreen> {
  String _filter = 'ALL';
  String? _patternFilter;

  @override
  Widget build(BuildContext context) {
    final records = ref.watch(appStateProvider).records;
    var filtered = records.where((r) {
      if (_filter == 'VALID') return r.validity == ResultValidity.validResult;
      if (_filter == 'INVALID') return r.validity == ResultValidity.noResult;
      return true;
    }).where((r) {
      if (_patternFilter == null) return true;
      return r.pattern?.name == _patternFilter;
    }).toList();

    return Scaffold(
      appBar: DemoAwareAppBar(
        title: 'EXPOSURE HISTORY',
        onDemoOpen: () => openDemoPanel(context, ref),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            title: 'DOSE TREND',
            child: DoseTrendChart(records: records),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final f in ['ALL', 'VALID', 'INVALID'])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(f),
                      selected: _filter == f,
                      onSelected: (_) => setState(() => _filter = f),
                    ),
                  ),
                for (final p in ExposurePattern.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(p.label),
                      selected: _patternFilter == p.name,
                      onSelected: (v) => setState(
                        () => _patternFilter = v ? p.name : null,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${filtered.length} records',
            style: mono(context, size: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 8),
          for (final r in filtered) _RecordTile(record: r),
          if (filtered.isEmpty)
            const EmptyHint(message: 'No records match the current filters'),
        ],
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  final ExposureRecord record;
  const _RecordTile({required this.record});

  @override
  Widget build(BuildContext context) {
    final valid = record.validity == ResultValidity.validResult;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(record.shiftId, style: mono(context, size: 13)),
        subtitle: Text(
          '${DateFormat('dd MMM yyyy HH:mm').format(record.readoutAt)}\n'
          '${record.cartridgeId} · ${record.confidence.label}'
          '${record.pattern != null ? ' · ${record.pattern!.label}' : ''}',
        ),
        isThreeLine: true,
        trailing: valid
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    record.dosePpmH!.toStringAsFixed(1),
                    style: mono(context, weight: FontWeight.w800, color: AppColors.valid),
                  ),
                  Text('ppm·h', style: mono(context, size: 10, color: AppColors.textMuted)),
                ],
              )
            : StatusChip(
                label: record.invalidReason?.split('–').first.trim() ?? 'NO RESULT',
                color: AppColors.invalid,
              ),
        onTap: () => context.push('/history/${record.id}'),
      ),
    );
  }
}
