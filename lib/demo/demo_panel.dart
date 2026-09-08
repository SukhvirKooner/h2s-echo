import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/enums.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

Future<void> openDemoPanel(BuildContext context, WidgetRef ref) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.bgElevated,
    builder: (ctx) => const _DemoPanel(),
  );
}

class _DemoPanel extends ConsumerWidget {
  const _DemoPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final notifier = ref.read(appStateProvider.notifier);
    final demo = state.demo;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderStrong,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'DEMO CONTROL',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Sets the outcome of the NEXT action. Panel leaves no visible trace when closed.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 20),
              const Text('QR RESULT', style: TextStyle(color: AppColors.textMuted, fontSize: 12, letterSpacing: 0.8)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final o in QrDemoOutcome.values)
                    ChoiceChip(
                      label: Text(o.label),
                      selected: demo.qrOutcome == o,
                      onSelected: (_) {
                        notifier.setDemo(demo.copyWith(qrOutcome: o));
                      },
                    ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('READ RESULT', style: TextStyle(color: AppColors.textMuted, fontSize: 12, letterSpacing: 0.8)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final o in ReadDemoOutcome.values)
                    ChoiceChip(
                      label: Text(o.label),
                      selected: demo.readOutcome == o,
                      onSelected: (_) {
                        notifier.setDemo(demo.copyWith(readOutcome: o));
                      },
                    ),
                ],
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Online sync'),
                subtitle: Text(demo.online ? 'SMARTPHONE → CENTRAL WEB PLATFORM' : 'Offline – queue pending'),
                value: demo.online,
                activeThumbColor: AppColors.accent,
                onChanged: (v) => notifier.setOnline(v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Fast-forward delays'),
                subtitle: const Text('Shorten simulated processing for quicker takes'),
                value: demo.fastDelays,
                activeThumbColor: AppColors.accent,
                onChanged: (v) =>
                    notifier.setDemo(demo.copyWith(fastDelays: v)),
              ),
              const SizedBox(height: 8),
              PrimaryButton(
                label: 'FAST-FORWARD SHIFT +8 H',
                icon: Icons.fast_forward,
                onPressed: () {
                  notifier.fastForwardShift(const Duration(hours: 8));
                  Navigator.pop(context);
                  showAppSnack(context, 'Active shift timer jumped +8 h');
                },
              ),
              const SizedBox(height: 10),
              SecondaryButton(
                label: 'RESET DEMO DATA',
                icon: Icons.restart_alt,
                onPressed: () {
                  notifier.resetDemoData();
                  Navigator.pop(context);
                  showAppSnack(context, 'Demo data reset to seed state');
                },
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
