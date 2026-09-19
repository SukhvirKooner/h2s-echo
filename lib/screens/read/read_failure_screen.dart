import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../demo/demo_panel.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class ReadFailureScreen extends ConsumerWidget {
  final String reason;
  final String? recordId;

  const ReadFailureScreen({
    super.key,
    required this.reason,
    this.recordId,
  });

  String get _title {
    final r = reason.toUpperCase();
    if (r.contains('RETAKE')) return 'RETAKE REQUIRED';
    if (r.contains('INVALID TIME')) return 'INVALID TIME';
    if (r.contains('OUT OF RANGE')) return 'OUT OF RANGE – INDETERMINATE';
    if (r.contains('CHANNEL')) return 'CHANNEL INCONSISTENCY – INDETERMINATE';
    if (r.contains('RECOVERING')) return 'RECOVERING NOT READY';
    if (r.contains('EXPIRED')) return 'EXPIRED DO NOT USE';
    if (r.contains('CARTRIDGE INVALID')) return 'CARTRIDGE INVALID';
    return 'NO VALID RESULT';
  }

  String get _body {
    switch (_title) {
      case 'RETAKE REQUIRED':
        return 'Image quality checks failed (blur, exposure, alignment, framing, glare, or ROI visibility). No dose is reported. Recapture the cartridge in the cradle.';
      case 'INVALID TIME':
        return 'Readout Δt is outside the validated window. No dose number is shown for a failed reading.';
      case 'OUT OF RANGE – INDETERMINATE':
        return 'Calibration domain gate failed. Result is INDETERMINATE — no exposure dose is reported.';
      case 'CHANNEL INCONSISTENCY – INDETERMINATE':
        return 'S1 / S2 / S3 channels disagree beyond tolerance. Result is INDETERMINATE — no dose is shown.';
      case 'RECOVERING NOT READY':
        return 'Cartridge recovery state gate failed. Cartridge is not ready for validated readout.';
      case 'EXPIRED DO NOT USE':
        return 'Cartridge is expired and must not be used for exposure reporting.';
      case 'CARTRIDGE INVALID':
        return 'Cartridge identity or condition is invalid for analysis.';
      default:
        return 'Critical gates did not all pass. Decision rule: all critical gates pass = VALID RESULT, otherwise NO RESULT. No dose is shown.';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: DemoAwareAppBar(
        title: 'READ FAILURE',
        onDemoOpen: () => openDemoPanel(context, ref),
        showBack: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.invalid.withValues(alpha: 0.15),
                  border: Border.all(color: AppColors.invalid, width: 2),
                ),
                child: const Icon(Icons.cancel_outlined, size: 44, color: AppColors.invalid),
              ).animate().shake(hz: 3, duration: 400.ms),
              const SizedBox(height: 20),
              Text(
                _title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.invalid,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                _body,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 20),
              const SectionCard(
                child: Text(
                  'No dose number is ever shown on a failed reading.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const Spacer(),
              if (_title == 'RETAKE REQUIRED')
                PrimaryButton(
                  label: 'RETAKE CAPTURE',
                  icon: Icons.photo_camera,
                  onPressed: () => context.go('/read/capture'),
                )
              else
                PrimaryButton(
                  label: 'TRY ANOTHER READ',
                  icon: Icons.refresh,
                  onPressed: () => context.go('/read/instructions'),
                ),
              const SizedBox(height: 10),
              if (recordId != null)
                SecondaryButton(
                  label: 'Open failed record audit',
                  onPressed: () => context.push('/history/$recordId'),
                ),
              const SizedBox(height: 10),
              SecondaryButton(
                label: 'Back to Control Center',
                onPressed: () => context.go('/home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
