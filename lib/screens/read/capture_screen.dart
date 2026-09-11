import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../demo/demo_panel.dart';
import '../../services/camera_service.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/cartridge_painter.dart';
import '../../widgets/common.dart';

class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key});

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen>
    with SingleTickerProviderStateMixin {
  late final CameraService _camera;
  late final AnimationController _scan;
  bool _flash = false;
  bool _capturing = false;

  @override
  void initState() {
    super.initState();
    _camera = SimulatedCameraService()..initialize();
    _scan = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scan.dispose();
    _camera.dispose();
    super.dispose();
  }

  Future<void> _shutter() async {
    if (_capturing) return;
    setState(() {
      _capturing = true;
      _flash = true;
    });
    HapticFeedback.heavyImpact();
    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (mounted) setState(() => _flash = false);
    await _camera.simulateCapture(
      delay: Duration(
        milliseconds: ref.read(appStateProvider).demo.fastDelays ? 150 : 350,
      ),
    );
    if (!mounted) return;
    context.push('/read/pipeline');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.viewfinder,
      appBar: DemoAwareAppBar(
        title: 'CAPTURE',
        onDemoOpen: () => openDemoPanel(context, ref),
      ),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _scan,
            builder: (context, _) => ViewfinderOverlay(
              scanProgress: _scan.value,
              showRoiLabels: true,
            ),
          ),
          if (_flash)
            Positioned.fill(
              child: Container(color: Colors.white)
                  .animate()
                  .fadeOut(duration: 200.ms),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 36,
            child: Column(
              children: [
                const Text(
                  'S1 · S2 · S3 · REF W · REF G · REF D · QR',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _capturing ? null : _shutter,
                  child: Container(
                    width: 74,
                    height: 74,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.shutter, width: 4),
                    ),
                    padding: const EdgeInsets.all(5),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.shutter,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _capturing ? 'Capturing…' : 'Shutter',
                  style: mono(context, size: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
