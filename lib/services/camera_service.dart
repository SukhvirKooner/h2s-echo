/// Abstract camera so a real implementation can replace the simulator later.
abstract class CameraService {
  Future<void> initialize();
  Future<String> simulateQrDetection({Duration? delay});
  Future<CapturedFrame> simulateCapture({Duration? delay});
  Future<void> dispose();
  bool get isInitialized;
}

class CapturedFrame {
  final DateTime capturedAt;
  final String simulatedAssetKey;
  final Map<String, dynamic> meta;

  const CapturedFrame({
    required this.capturedAt,
    this.simulatedAssetKey = 'cartridge_viewfinder',
    this.meta = const {},
  });
}

class SimulatedCameraService implements CameraService {
  bool _ready = false;

  @override
  bool get isInitialized => _ready;

  @override
  Future<void> initialize() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _ready = true;
  }

  @override
  Future<String> simulateQrDetection({Duration? delay}) async {
    await Future<void>.delayed(delay ?? const Duration(milliseconds: 1800));
    return 'H2SECHO|ECH-C-00317|H2S-ECHO-CAL-V1|REV-B';
  }

  @override
  Future<CapturedFrame> simulateCapture({Duration? delay}) async {
    await Future<void>.delayed(delay ?? const Duration(milliseconds: 350));
    return CapturedFrame(
      capturedAt: DateTime.now(),
      meta: const {
        'roiVisible': true,
        'refsVisible': true,
        'framing': 'ok',
      },
    );
  }

  @override
  Future<void> dispose() async {
    _ready = false;
  }
}
