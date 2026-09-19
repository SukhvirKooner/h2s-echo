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

class QrScanScreen extends ConsumerStatefulWidget {
  const QrScanScreen({super.key});

  @override
  ConsumerState<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends ConsumerState<QrScanScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scan;
  late final CameraService _camera;
  bool _scanning = false;
  bool _locked = false;
  String? _payload;

  @override
  void initState() {
    super.initState();
    _camera = SimulatedCameraService();
    _scan = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _camera.initialize();
    Future<void>.delayed(const Duration(milliseconds: 400), _autoScan);
  }

  Future<void> _autoScan() async {
    if (!mounted || _scanning) return;
    setState(() => _scanning = true);
    final delay = ref.read(appStateProvider).demo.fastDelays
        ? const Duration(milliseconds: 500)
        : const Duration(milliseconds: 1800);
    final payload = await _camera.simulateQrDetection(delay: delay);
    if (!mounted) return;
    HapticFeedback.heavyImpact();
    setState(() {
      _locked = true;
      _payload = payload;
      _scanning = false;
    });
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    final cart = ref
        .read(appStateProvider.notifier)
        .resolveCartridgeForQr(ref.read(appStateProvider).demo.qrOutcome);
    ref.read(appStateProvider.notifier).setPendingCartridge(cart.id);
    context.push('/verify/pipeline');
  }

  @override
  void dispose() {
    _scan.dispose();
    _camera.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.viewfinder,
      appBar: DemoAwareAppBar(
        title: 'WRISTBAND QR',
        onDemoOpen: () => openDemoPanel(context, ref),
        actions: [
          IconButton(
            tooltip: 'Rescan',
            onPressed: _locked
                ? () {
                    setState(() {
                      _locked = false;
                      _payload = null;
                    });
                    _autoScan();
                  }
                : null,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _scan,
            builder: (context, _) {
              return ViewfinderOverlay(
                scanProgress: _locked ? 0 : _scan.value,
                locked: _locked,
              );
            },
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 40,
            child: SafeArea(
              child: Column(
                children: [
                  Text(
                    _locked
                        ? 'Cartridge QR detected'
                        : 'Align QR on wristband cartridge within the frame',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  if (_payload != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _payload!,
                      style: mono(context, size: 11, color: AppColors.accent),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(),
                  ],
                  const SizedBox(height: 16),
                  if (!_locked)
                    const ShimmerBox(height: 8, width: 160)
                  else
                    const StatusChip(label: 'AUTHENTICATING…', pulse: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
