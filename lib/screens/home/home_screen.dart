import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../demo/demo_panel.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final active = state.activeShift;
    final pendingCart = state.cartridgeById(state.pendingCartridgeId);
    final recent = state.records.take(5).toList();
    final attention = state.cartridges
        .where((c) =>
            c.flaggedRemoved ||
            c.lifecycle == CartridgeLifecycle.fault ||
            c.lifecycle == CartridgeLifecycle.expired ||
            c.lifecycle == CartridgeLifecycle.damaged)
        .take(3)
        .toList();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.accent,
                          onRefresh: () async {
                            await Future<void>.delayed(const Duration(milliseconds: 600));
                            if (!context.mounted) return;
                            showAppSnack(context, 'Control center refreshed');
                          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: BrandLogo(
                          onTripleTap: () => openDemoPanel(context, ref),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Web sync',
                        onPressed: () => context.push('/sync'),
                        icon: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              state.demo.online
                                  ? Icons.cloud_done_outlined
                                  : Icons.cloud_off_outlined,
                              color: state.demo.online
                                  ? AppColors.valid
                                  : AppColors.recovering,
                            ),
                            if (state.pendingSyncCount > 0)
                              Positioned(
                                right: -4,
                                top: -4,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppColors.medium,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${state.pendingSyncCount}',
                                    style: const TextStyle(fontSize: 9, color: Colors.black),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => context.push('/profile'),
                        icon: const Icon(Icons.person_outline),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: GestureDetector(
                    onLongPress: () => openDemoPanel(context, ref),
                    child: Text(
                      'CONTROL CENTER',
                      style: mono(context, size: 12, color: AppColors.textMuted),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (active != null && active.active)
                        _LiveShiftBanner(shift: active)
                            .animate()
                            .fadeIn()
                            .slideY(begin: 0.1, end: 0)
                      else if (active != null && active.endedAt != null)
                        _EndedShiftBanner(shift: active)
                      else
                        SectionCard(
                          title: 'SESSION',
                          child: const Text(
                            'No active shift. Start a new shift after verifying a cartridge.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      const SizedBox(height: 16),
                      if (pendingCart != null) ...[
                        SectionCard(
                          title: 'CARTRIDGE',
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(pendingCart.id, style: mono(context, weight: FontWeight.w700)),
                                    const SizedBox(height: 4),
                                    StatusChip(label: pendingCart.lifecycle.label),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () => context.push('/cartridges/${pendingCart.id}'),
                                child: const Text('History'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      Text(
                        'PRIMARY ACTIONS',
                        style: mono(context, size: 11, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 10),
                      _ActionTile(
                        icon: Icons.qr_code_scanner,
                        title: 'NEW SHIFT',
                        subtitle: 'Verify wristband QR → assign → wear',
                        color: AppColors.accent,
                        onTap: () => context.push('/verify/scan'),
                      ),
                      const SizedBox(height: 10),
                      _ActionTile(
                        icon: Icons.photo_camera_outlined,
                        title: 'READ CARTRIDGE',
                        subtitle: 'Cradle capture → optical analysis pipeline',
                        color: AppColors.cyan,
                        onTap: () => context.push('/read/instructions'),
                      ),
                      const SizedBox(height: 10),
                      _ActionTile(
                        icon: Icons.history,
                        title: 'EXPOSURE HISTORY',
                        subtitle: 'Dose trend, patterns, digital records',
                        color: AppColors.medium,
                        onTap: () => context.push('/history'),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => context.push('/cartridges'),
                              icon: const Icon(Icons.memory),
                              label: const Text('Cartridges'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                if (active != null && active.active) {
                                  context.push('/shift/active');
                                } else if (active != null) {
                                  context.push('/shift/ended');
                                } else {
                                  showAppSnack(context, 'No shift session yet');
                                }
                              },
                              icon: const Icon(Icons.timer_outlined),
                              label: const Text('Session'),
                            ),
                          ),
                        ],
                      ),
                      if (attention.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          'ATTENTION',
                          style: mono(context, size: 11, color: AppColors.invalid),
                        ),
                        const SizedBox(height: 8),
                        for (final c in attention)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.warning_amber, color: AppColors.invalid),
                            title: Text(c.id, style: mono(context)),
                            subtitle: Text(c.lifecycle.label),
                            onTap: () => context.push('/cartridges/${c.id}'),
                          ),
                      ],
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Text(
                            'RECENT EXPOSURE',
                            style: mono(context, size: 11, color: AppColors.textMuted),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => context.push('/history'),
                            child: const Text('See all'),
                          ),
                        ],
                      ),
                      for (final r in recent) _RecentTile(record: r),
                      const SizedBox(height: 24),
                      Text(
                        state.user == null
                            ? ''
                            : '${state.user!.name} · ${state.user!.role.label} · ${state.demo.online ? 'SYNCED / ONLINE' : 'OFFLINE'}',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.4)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 350.ms).slideX(begin: 0.03, end: 0);
  }
}

class _LiveShiftBanner extends StatelessWidget {
  final Shift shift;
  const _LiveShiftBanner({required this.shift});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'ACTIVE SHIFT',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const StatusChip(label: 'ACTIVE', pulse: true),
              const Spacer(),
              TextButton(
                onPressed: () => context.push('/shift/active'),
                child: const Text('Open'),
              ),
            ],
          ),
          KvRow(label: 'Shift', value: shift.id),
          KvRow(label: 'Worker', value: shift.workerId),
          KvRow(label: 'Area', value: shift.workArea, monoValue: false),
          _LiveTimer(startedAt: shift.startedAt!),
        ],
      ),
    );
  }
}

class _EndedShiftBanner extends StatelessWidget {
  final Shift shift;
  const _EndedShiftBanner({required this.shift});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'LAST SHIFT',
      child: Column(
        children: [
          Row(
            children: [
              const StatusChip(label: 'EXPOSED → RECOVERING', color: AppColors.recovering),
              const Spacer(),
              TextButton(
                onPressed: () => context.push('/shift/ended'),
                child: const Text('Δt'),
              ),
            ],
          ),
          KvRow(label: 'Shift', value: shift.id),
          KvRow(label: 'Cartridge', value: shift.cartridgeId ?? '—'),
        ],
      ),
    );
  }
}

class _LiveTimer extends StatefulWidget {
  final DateTime startedAt;
  const _LiveTimer({required this.startedAt});

  @override
  State<_LiveTimer> createState() => _LiveTimerState();
}

class _LiveTimerState extends State<_LiveTimer> {
  late final ticker = Stream.periodic(const Duration(seconds: 1));

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: ticker,
      builder: (context, _) {
        final d = DateTime.now().difference(widget.startedAt);
        final h = d.inHours.toString().padLeft(2, '0');
        final m = (d.inMinutes % 60).toString().padLeft(2, '0');
        final s = (d.inSeconds % 60).toString().padLeft(2, '0');
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            '$h:$m:$s',
            style: mono(context, size: 28, weight: FontWeight.w700, color: AppColors.accent),
          ),
        );
      },
    );
  }
}

class _RecentTile extends StatelessWidget {
  final ExposureRecord record;
  const _RecentTile({required this.record});

  @override
  Widget build(BuildContext context) {
    final valid = record.validity == ResultValidity.validResult;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(record.id, style: mono(context, size: 13)),
      subtitle: Text(
        '${DateFormat('dd MMM HH:mm').format(record.readoutAt)} · ${record.cartridgeId}',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: valid
          ? Text(
              '${record.dosePpmH!.toStringAsFixed(1)} ppm·h',
              style: mono(context, size: 12, color: AppColors.valid),
            )
          : StatusChip(label: record.invalidReason ?? 'NO RESULT', color: AppColors.invalid),
      onTap: () => context.push('/history/${record.id}'),
    );
  }
}
