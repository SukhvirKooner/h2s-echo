import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/seed_data.dart';
import '../../demo/demo_panel.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class NewShiftScreen extends ConsumerStatefulWidget {
  const NewShiftScreen({super.key});

  @override
  ConsumerState<NewShiftScreen> createState() => _NewShiftScreenState();
}

class _NewShiftScreenState extends ConsumerState<NewShiftScreen> {
  String? _workerId;
  late String _shiftId;
  late final TextEditingController _area;
  late final TextEditingController _job;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _shiftId = ref.read(appStateProvider.notifier).generateShiftId();
    final workers = ref.read(appStateProvider).workers;
    _workerId = workers.isNotEmpty ? workers.first.id : null;
    _area = TextEditingController(text: SeedData.workAreas.first);
    _job = TextEditingController(text: SeedData.jobs.first);
  }

  @override
  void dispose() {
    _area.dispose();
    _job.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final cartId = ref.read(appStateProvider).pendingCartridgeId;
    if (cartId == null || _workerId == null) {
      showAppSnack(context, 'Verify a cartridge first', color: AppColors.invalid);
      return;
    }
    setState(() => _busy = true);
    await ref.read(appStateProvider.notifier).createShift(
          workerId: _workerId!,
          workArea: _area.text.trim(),
          jobOperation: _job.text.trim(),
          cartridgeId: cartId,
        );
    if (!mounted) return;
    // Overwrite generated id display with actual
    final created = ref.read(appStateProvider).activeShift;
    if (created != null) _shiftId = created.id;
    setState(() => _busy = false);
    context.go('/shift/ready');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final cartId = state.pendingCartridgeId ?? '—';

    return Scaffold(
      appBar: DemoAwareAppBar(
        title: 'NEW SHIFT',
        onDemoOpen: () => openDemoPanel(context, ref),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SectionCard(
            title: 'LINK',
            child: Column(
              children: [
                KvRow(label: 'Worker → Shift → Cartridge', value: 'ACTIVE'),
                Text(
                  'Creates WORKER → SHIFT → CARTRIDGE link for this session.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            // ignore: deprecated_member_use
            value: _workerId,
            decoration: const InputDecoration(labelText: 'Worker ID'),
            items: [
              for (final w in state.workers)
                DropdownMenuItem(
                  value: w.id,
                  child: Text('${w.id} · ${w.name}'),
                ),
            ],
            onChanged: (v) => setState(() => _workerId = v),
          ),
          const SizedBox(height: 12),
          InputDecorator(
            decoration: const InputDecoration(labelText: 'Shift / Session ID'),
            child: Text(_shiftId, style: mono(context)),
          ),
          const SizedBox(height: 12),
          InputDecorator(
            decoration: const InputDecoration(labelText: 'Cartridge ID (from QR)'),
            child: Text(cartId, style: mono(context, color: AppColors.accent)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _area,
            decoration: const InputDecoration(labelText: 'Work area'),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: [
              for (final a in SeedData.workAreas.take(4))
                ActionChip(
                  label: Text(a, style: const TextStyle(fontSize: 11)),
                  onPressed: () => setState(() => _area.text = a),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _job,
            decoration: const InputDecoration(labelText: 'Job / operation'),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: [
              for (final j in SeedData.jobs.take(4))
                ActionChip(
                  label: Text(j, style: const TextStyle(fontSize: 11)),
                  onPressed: () => setState(() => _job.text = j),
                ),
            ],
          ),
          const SizedBox(height: 12),
          KvRow(
            label: 'Date / time',
            value: DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: _busy ? 'CREATING…' : 'CREATE SHIFT LINK',
            icon: Icons.link,
            onPressed: _busy ? null : _submit,
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: 'Re-scan cartridge QR',
            icon: Icons.qr_code_scanner,
            onPressed: () => context.go('/verify/scan'),
          ),
        ],
      ),
    );
  }
}
