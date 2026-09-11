import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../demo/demo_panel.dart';
import '../../state/app_state.dart';
import '../../theme/app_constants.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class EndShiftScreen extends ConsumerWidget {
  const EndShiftScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final shift = state.activeShift;
    final endedAt = shift?.endedAt ?? state.lastShiftEndedAt;

    return Scaffold(
      appBar: DemoAwareAppBar(
        title: 'SHIFT ENDED',
        onDemoOpen: () => openDemoPanel(context, ref),
        showBack: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const StatusChip(label: 'EXPOSED → RECOVERING', color: AppColors.recovering),
            const SizedBox(height: 16),
            SectionCard(
              child: Column(
                children: [
                  KvRow(label: 'Shift', value: shift?.id ?? '—'),
                  KvRow(label: 'Cartridge', value: shift?.cartridgeId ?? '—'),
                  KvRow(label: 'Worker', value: shift?.workerId ?? '—'),
                  KvRow(
                    label: 'End time',
                    value: endedAt?.toIso8601String().substring(0, 19) ?? '—',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'Δt SINCE SHIFT END',
              child: Column(
                children: [
                  if (endedAt == null)
                    const Text('No end timestamp')
                  else
                    StreamBuilder(
                      stream: Stream.periodic(const Duration(seconds: 1)),
                      builder: (context, _) {
                        final d = DateTime.now().difference(endedAt);
                        final h = d.inHours;
                        final m = d.inMinutes % 60;
                        final s = d.inSeconds % 60;
                        return Text(
                          '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}',
                          style: mono(
                            context,
                            size: 36,
                            weight: FontWeight.w800,
                            color: AppColors.medium,
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 12),
                  const Text(
                    'Validated readout window',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  _ReadoutWindowBand(),
                  const SizedBox(height: 8),
                  Text(
                    '$kReadoutWindowStartH h – $kReadoutWindowEndH h after shift end',
                    style: mono(context, size: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const Spacer(),
            PrimaryButton(
              label: 'READ CARTRIDGE',
              icon: Icons.photo_camera_outlined,
              onPressed: () => context.go('/read/instructions'),
            ),
            const SizedBox(height: 10),
            SecondaryButton(
              label: 'Back to Control Center',
              onPressed: () => context.go('/home'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadoutWindowBand extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final start = (kReadoutWindowStartH / kReadoutWindowEndH) * w * 0.15;
        final bandW = w * 0.7;
        return SizedBox(
          height: 28,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              Positioned(
                left: start,
                width: bandW,
                top: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.valid.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.valid.withValues(alpha: 0.6)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'VALID WINDOW',
                    style: mono(context, size: 10, color: AppColors.valid),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
