import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:h2s_echo/main.dart';
import 'package:h2s_echo/models/models.dart';
import 'package:h2s_echo/router/app_router.dart';
import 'package:h2s_echo/state/app_state.dart';

/// Avoid pumpAndSettle — the app has repeating animations (scan line, chips, timers).
Future<void> _pumpFrames(WidgetTester tester, {int frames = 25, int ms = 40}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(Duration(milliseconds: ms));
  }
}

Future<void> _shot(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
  String name,
) async {
  await tester.pump(const Duration(milliseconds: 100));
  await binding.convertFlutterSurfaceToImage();
  await binding.takeScreenshot(name);
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('presentation screenshot tour', (tester) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const ProviderScope(child: H2sEchoApp()));

    for (var i = 0; i < 50; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      try {
        final container = ProviderScope.containerOf(
          tester.element(find.byType(H2sEchoApp)),
        );
        if (container.read(appStateProvider).hydrated) break;
      } catch (_) {}
    }
    await _pumpFrames(tester, frames: 20);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(H2sEchoApp)),
    );
    final notifier = container.read(appStateProvider.notifier);
    final router = container.read(routerProvider);

    await _shot(binding, tester, '01_login');

    await notifier.login(
      email: 'm.chen@siteops.example',
      role: UserRole.safetyOfficer,
    );
    await _pumpFrames(tester, frames: 30);
    await _shot(binding, tester, '02_home_control_center');

    notifier.setPendingCartridge('ECH-C-00317');
    final shift = await notifier.createShift(
      workerId: 'W-1042',
      workArea: 'Sour Gas Well Pad B-7',
      jobOperation: 'Pigging Operation',
      cartridgeId: 'ECH-C-00317',
    );
    await _pumpFrames(tester);

    Future<void> go(String path) async {
      router.go(path);
      await _pumpFrames(tester, frames: 30);
    }

    await go('/verify/result/verified');
    await _shot(binding, tester, '03_verify_cartridge_ready');

    await go('/verify/result/fault');
    await _shot(binding, tester, '04_verify_device_fault');

    await go('/verify/result/low_accuracy');
    await _shot(binding, tester, '05_verify_low_accuracy');

    await go('/verify/result/recovering');
    await _shot(binding, tester, '06_verify_recovering');

    await go('/shift/new');
    await _shot(binding, tester, '07_new_shift_form');

    await go('/shift/ready');
    await _shot(binding, tester, '08_ready_to_wear');

    await notifier.startShift();
    notifier.fastForwardShift(const Duration(hours: 2, minutes: 17));
    await go('/shift/active');
    await _shot(binding, tester, '09_active_shift');

    await notifier.endShift();
    await go('/shift/ended');
    await _shot(binding, tester, '10_shift_ended_delta_t');

    await go('/read/instructions');
    await _shot(binding, tester, '11_read_instructions');

    final valid = await notifier.createReadResult(
      outcome: ReadDemoOutcome.valid,
      cartridgeId: 'ECH-C-00317',
    );
    await go('/read/result/${valid.id}');
    await _pumpFrames(tester, frames: 40); // count-up + charts
    await _shot(binding, tester, '12_valid_result');

    await go(
      '/read/failure/${Uri.encodeComponent('RETAKE REQUIRED')}?id=${valid.id}',
    );
    await _shot(binding, tester, '13_failure_retake');

    await go(
      '/read/failure/${Uri.encodeComponent('OUT OF RANGE – INDETERMINATE')}',
    );
    await _shot(binding, tester, '14_failure_out_of_range');

    await go('/history');
    await _pumpFrames(tester, frames: 35);
    await _shot(binding, tester, '15_exposure_history');

    final recordId = container.read(appStateProvider).records.first.id;
    await go('/history/$recordId');
    await _shot(binding, tester, '16_digital_record');

    await go('/cartridges');
    await _shot(binding, tester, '17_cartridge_list');

    await go('/cartridges/ECH-C-00317');
    await _pumpFrames(tester, frames: 35);
    await _shot(binding, tester, '18_cartridge_lifecycle');

    await go('/sync');
    await _shot(binding, tester, '19_web_sync');

    await go('/profile');
    await _shot(binding, tester, '20_profile');

    // Capture viewfinder before auto-nav advances far
    router.go('/verify/scan');
    await tester.pump(const Duration(milliseconds: 500));
    await _shot(binding, tester, '21_qr_viewfinder');

    expect(shift.id, isNotEmpty);
  });
}
