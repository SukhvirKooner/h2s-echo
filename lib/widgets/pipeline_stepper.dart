import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_theme.dart';

enum PipelineStepState { pending, running, success, failed }

class PipelineStep {
  final String title;
  final String? subtitle;
  final Widget? visual;
  PipelineStepState state;

  PipelineStep({
    required this.title,
    this.subtitle,
    this.visual,
    this.state = PipelineStepState.pending,
  });
}

class AnimatedStepperPanel extends StatelessWidget {
  final List<PipelineStep> steps;
  final int currentIndex;

  const AnimatedStepperPanel({
    super.key,
    required this.steps,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: steps.length,
      itemBuilder: (context, i) {
        final step = steps[i];
        final active = i == currentIndex;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StepIndicator(state: step.state, index: i + 1),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: active || step.state != PipelineStepState.pending
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                      ),
                    ),
                    if (step.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        step.subtitle!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    if (step.visual != null &&
                        (step.state == PipelineStepState.running ||
                            step.state == PipelineStepState.success)) ...[
                      const SizedBox(height: 8),
                      step.visual!,
                    ],
                  ],
                ),
              ),
            ],
          ),
        )
            .animate(target: step.state == PipelineStepState.pending ? 0 : 1)
            .fadeIn(duration: 300.ms)
            .slideX(begin: 0.04, end: 0);
      },
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final PipelineStepState state;
  final int index;

  const _StepIndicator({required this.state, required this.index});

  @override
  Widget build(BuildContext context) {
    Color color;
    Widget child;
    switch (state) {
      case PipelineStepState.pending:
        color = AppColors.borderStrong;
        child = Text(
          '$index',
          style: mono(context, size: 11, color: AppColors.textMuted),
        );
      case PipelineStepState.running:
        color = AppColors.cyan;
        child = const SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        );
      case PipelineStepState.success:
        color = AppColors.valid;
        child = const Icon(Icons.check, size: 16, color: Colors.white);
      case PipelineStepState.failed:
        color = AppColors.invalid;
        child = const Icon(Icons.close, size: 16, color: Colors.white);
    }
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: child,
    );
  }
}

class ChecklistAnim extends StatelessWidget {
  final List<String> items;
  final int completedCount;

  const ChecklistAnim({
    super.key,
    required this.items,
    required this.completedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < items.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Icon(
                  i < completedCount ? Icons.check_circle : Icons.circle_outlined,
                  size: 16,
                  color: i < completedCount ? AppColors.valid : AppColors.textMuted,
                ),
                const SizedBox(width: 8),
                Text(
                  items[i],
                  style: TextStyle(
                    fontSize: 12,
                    color: i < completedCount
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

Future<void> runPipeline({
  required List<PipelineStep> steps,
  required void Function(void Function()) setState,
  required Future<void> Function() delay,
  bool Function(int index)? shouldFailAt,
}) async {
  for (var i = 0; i < steps.length; i++) {
    setState(() {
      steps[i].state = PipelineStepState.running;
    });
    HapticFeedback.selectionClick();
    await delay();
    final fail = shouldFailAt?.call(i) ?? false;
    setState(() {
      steps[i].state = fail ? PipelineStepState.failed : PipelineStepState.success;
    });
    if (fail) {
      HapticFeedback.heavyImpact();
      return;
    }
    HapticFeedback.lightImpact();
  }
}
