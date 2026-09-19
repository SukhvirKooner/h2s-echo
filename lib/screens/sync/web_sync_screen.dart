import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../demo/demo_panel.dart';
import '../../models/enums.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class WebSyncScreen extends ConsumerStatefulWidget {
  const WebSyncScreen({super.key});

  @override
  ConsumerState<WebSyncScreen> createState() => _WebSyncScreenState();
}

class _WebSyncScreenState extends ConsumerState<WebSyncScreen> {
  bool _animating = false;

  Future<void> _sync() async {
    final online = ref.read(appStateProvider).demo.online;
    if (!online) {
      showAppSnack(context, 'Offline – records stay in pending queue', color: AppColors.recovering);
      return;
    }
    setState(() => _animating = true);
    await ref.read(appStateProvider.notifier).syncAll();
    if (!mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _animating = false);
    showAppSnack(context, 'Synced to CENTRAL WEB PLATFORM', color: AppColors.valid);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final pending = state.records.where((r) => r.syncStatus == SyncStatus.pending).toList();
    final online = state.demo.online;

    return Scaffold(
      appBar: DemoAwareAppBar(
        title: 'WEB SYNC',
        onDemoOpen: () => openDemoPanel(context, ref),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            StatusChip(
              label: online ? 'ONLINE' : 'OFFLINE',
              color: online ? AppColors.valid : AppColors.recovering,
              pulse: !online,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _Node(icon: Icons.smartphone, label: 'SMARTPHONE'),
                Expanded(
                  child: _animating
                      ? const Icon(Icons.cloud_upload, color: AppColors.accent)
                          .animate(onPlay: (c) => c.repeat())
                          .moveX(begin: -20, end: 20, duration: 700.ms)
                      : const Icon(Icons.arrow_forward, color: AppColors.textMuted),
                ),
                _Node(icon: Icons.cloud_done, label: 'CENTRAL WEB\nPLATFORM'),
              ],
            ),
            const SizedBox(height: 24),
            SectionCard(
              title: 'PENDING SYNC QUEUE',
              child: pending.isEmpty
                  ? const Text(
                      'Queue empty – all records Synced',
                      style: TextStyle(color: AppColors.textSecondary),
                    )
                  : Column(
                      children: [
                        for (final r in pending.take(8))
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            title: Text(r.id, style: mono(context, size: 12)),
                            subtitle: Text(r.shiftId),
                            trailing: const StatusChip(
                              label: 'PENDING',
                              color: AppColors.recovering,
                            ),
                            onTap: () => context.push('/history/${r.id}'),
                          ),
                      ],
                    ),
            ),
            const Spacer(),
            PrimaryButton(
              label: _animating ? 'UPLOADING…' : 'UPLOAD TO WEB PLATFORM',
              icon: Icons.cloud_upload_outlined,
              onPressed: _animating ? null : _sync,
            ),
            const SizedBox(height: 10),
            SecondaryButton(
              label: online ? 'Simulate offline' : 'Go online',
              onPressed: () {
                ref.read(appStateProvider.notifier).setOnline(!online);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Node extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Node({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, color: AppColors.accent),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: mono(context, size: 10, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
