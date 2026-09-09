import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../demo/demo_panel.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final user = state.user;

    return Scaffold(
      appBar: DemoAwareAppBar(
        title: 'PROFILE',
        onDemoOpen: () => openDemoPanel(context, ref),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.accent.withValues(alpha: 0.2),
              child: Text(
                user?.name.substring(0, 1) ?? '?',
                style: const TextStyle(fontSize: 32, color: AppColors.accent, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            child: Column(
              children: [
                KvRow(label: 'Name', value: user?.name ?? '—', monoValue: false),
                KvRow(label: 'Email', value: user?.email ?? '—', monoValue: false),
                KvRow(label: 'Role', value: user?.role.label ?? '—'),
                KvRow(label: 'Site', value: user?.site ?? '—', monoValue: false),
                KvRow(label: 'Account ID', value: user?.id ?? '—'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'ROLES',
            child: const Text(
              'WORKER · SAFETY OFFICER · ADMINISTRATOR\n\n'
              'Role selects demo permissions presentation. All flows remain available for the video demo.',
              style: TextStyle(color: AppColors.textSecondary, height: 1.4),
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'OPEN DEMO PANEL',
            icon: Icons.science_outlined,
            onPressed: () => openDemoPanel(context, ref),
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: 'Reset demo data',
            icon: Icons.restart_alt,
            onPressed: () {
              ref.read(appStateProvider.notifier).resetDemoData();
              showAppSnack(context, 'Demo data reset');
            },
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: 'Sign out',
            icon: Icons.logout,
            onPressed: () async {
              await ref.read(appStateProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}
