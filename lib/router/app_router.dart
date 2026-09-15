import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/auth/login_screen.dart';
import '../screens/cartridge/cartridge_history_screen.dart';
import '../screens/history/exposure_history_screen.dart';
import '../screens/history/record_detail_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/read/analysis_pipeline_screen.dart';
import '../screens/read/capture_screen.dart';
import '../screens/read/read_failure_screen.dart';
import '../screens/read/read_instructions_screen.dart';
import '../screens/read/read_result_screen.dart';
import '../screens/shift/active_shift_screen.dart';
import '../screens/shift/end_shift_screen.dart';
import '../screens/shift/new_shift_screen.dart';
import '../screens/shift/ready_to_wear_screen.dart';
import '../screens/sync/web_sync_screen.dart';
import '../screens/verify/qr_scan_screen.dart';
import '../screens/verify/verify_pipeline_screen.dart';
import '../screens/verify/verify_result_screen.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

CustomTransitionPage<void> _fadeSlide(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondary, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.04, 0.02),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

GoRouter createRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: _RouterRefresh(ref),
    redirect: (context, state) {
      final app = ref.read(appStateProvider);
      if (!app.hydrated) return null;
      final loggingIn = state.matchedLocation == '/login';
      if (!app.loggedIn && !loggingIn) return '/login';
      if (app.loggedIn && loggingIn) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        pageBuilder: (c, s) => _fadeSlide(s, const LoginScreen()),
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (c, s) => _fadeSlide(s, const HomeScreen()),
      ),
      GoRoute(
        path: '/verify/scan',
        pageBuilder: (c, s) => _fadeSlide(s, const QrScanScreen()),
      ),
      GoRoute(
        path: '/verify/pipeline',
        pageBuilder: (c, s) => _fadeSlide(s, const VerifyPipelineScreen()),
      ),
      GoRoute(
        path: '/verify/result/:outcome',
        pageBuilder: (c, s) => _fadeSlide(
          s,
          VerifyResultScreen(outcome: s.pathParameters['outcome']!),
        ),
      ),
      GoRoute(
        path: '/shift/new',
        pageBuilder: (c, s) => _fadeSlide(s, const NewShiftScreen()),
      ),
      GoRoute(
        path: '/shift/ready',
        pageBuilder: (c, s) => _fadeSlide(s, const ReadyToWearScreen()),
      ),
      GoRoute(
        path: '/shift/active',
        pageBuilder: (c, s) => _fadeSlide(s, const ActiveShiftScreen()),
      ),
      GoRoute(
        path: '/shift/ended',
        pageBuilder: (c, s) => _fadeSlide(s, const EndShiftScreen()),
      ),
      GoRoute(
        path: '/read/instructions',
        pageBuilder: (c, s) => _fadeSlide(s, const ReadInstructionsScreen()),
      ),
      GoRoute(
        path: '/read/capture',
        pageBuilder: (c, s) => _fadeSlide(s, const CaptureScreen()),
      ),
      GoRoute(
        path: '/read/pipeline',
        pageBuilder: (c, s) => _fadeSlide(s, const AnalysisPipelineScreen()),
      ),
      GoRoute(
        path: '/read/result/:id',
        pageBuilder: (c, s) => _fadeSlide(
          s,
          ReadResultScreen(recordId: s.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/read/failure/:reason',
        pageBuilder: (c, s) => _fadeSlide(
          s,
          ReadFailureScreen(
            reason: Uri.decodeComponent(s.pathParameters['reason']!),
            recordId: s.uri.queryParameters['id'],
          ),
        ),
      ),
      GoRoute(
        path: '/history',
        pageBuilder: (c, s) => _fadeSlide(s, const ExposureHistoryScreen()),
      ),
      GoRoute(
        path: '/history/:id',
        pageBuilder: (c, s) => _fadeSlide(
          s,
          RecordDetailScreen(recordId: s.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/cartridges',
        pageBuilder: (c, s) => _fadeSlide(s, const CartridgeHistoryScreen()),
      ),
      GoRoute(
        path: '/cartridges/:id',
        pageBuilder: (c, s) => _fadeSlide(
          s,
          CartridgeHistoryScreen(focusId: s.pathParameters['id']),
        ),
      ),
      GoRoute(
        path: '/sync',
        pageBuilder: (c, s) => _fadeSlide(s, const WebSyncScreen()),
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (c, s) => _fadeSlide(s, const ProfileScreen()),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: Text('Route not found: ${state.uri}', style: const TextStyle(color: Colors.white)),
      ),
    ),
  );
}

class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(this.ref) {
    ref.listen(appStateProvider, (prev, next) => notifyListeners());
  }
  final Ref ref;
}

final routerProvider = Provider<GoRouter>((ref) => createRouter(ref));
