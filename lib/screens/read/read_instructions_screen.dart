import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../demo/demo_panel.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class ReadInstructionsScreen extends ConsumerWidget {
  const ReadInstructionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: DemoAwareAppBar(
        title: 'READ CARTRIDGE',
        onDemoOpen: () => openDemoPanel(context, ref),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CAPTURE SETUP',
              style: mono(context, size: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _Step(n: '1', text: 'Remove cartridge from wristband after recovery window opens.'),
                  _Step(n: '2', text: 'Place cartridge in the fixed optical cradle.'),
                  _Step(n: '3', text: 'Ensure S1 / S2 / S3 and REF W / G / D are visible.'),
                  _Step(n: '4', text: 'Capture photo – phone decodes chemical memory optically.'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Text(
                'The cartridge records the exposure; the phone only photographs and decodes it. The phone never senses H₂S continuously.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            const Spacer(),
            PrimaryButton(
              label: 'OPEN CAPTURE',
              icon: Icons.photo_camera,
              onPressed: () => context.push('/read/capture'),
            ),
            const SizedBox(height: 10),
            SecondaryButton(
              label: 'Back to home',
              onPressed: () => context.go('/home'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final String n;
  final String text;
  const _Step({required this.n, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(n, style: mono(context, weight: FontWeight.w800, color: AppColors.accent)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
