import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../data/seed_data.dart';
import '../demo/demo_scenario.dart';
import '../models/models.dart';
import '../theme/app_constants.dart';

class AppState {
  final bool hydrated;
  final bool loggedIn;
  final UserAccount? user;
  final List<Worker> workers;
  final List<Cartridge> cartridges;
  final List<Shift> shifts;
  final List<ExposureRecord> records;
  final Shift? activeShift;
  final String? pendingCartridgeId;
  final DemoScenario demo;
  final DateTime? lastShiftEndedAt;

  const AppState({
    this.hydrated = false,
    this.loggedIn = false,
    this.user,
    this.workers = const [],
    this.cartridges = const [],
    this.shifts = const [],
    this.records = const [],
    this.activeShift,
    this.pendingCartridgeId,
    this.demo = const DemoScenario(),
    this.lastShiftEndedAt,
  });

  int get pendingSyncCount =>
      records.where((r) => r.syncStatus == SyncStatus.pending).length;

  Cartridge? cartridgeById(String? id) {
    if (id == null) return null;
    try {
      return cartridges.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Worker? workerById(String? id) {
    if (id == null) return null;
    try {
      return workers.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }

  Shift? shiftById(String? id) {
    if (id == null) return null;
    try {
      return shifts.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  ExposureRecord? recordById(String? id) {
    if (id == null) return null;
    try {
      return records.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  AppState copyWith({
    bool? hydrated,
    bool? loggedIn,
    UserAccount? user,
    List<Worker>? workers,
    List<Cartridge>? cartridges,
    List<Shift>? shifts,
    List<ExposureRecord>? records,
    Shift? activeShift,
    String? pendingCartridgeId,
    DemoScenario? demo,
    DateTime? lastShiftEndedAt,
    bool clearActiveShift = false,
    bool clearPendingCartridge = false,
    bool clearUser = false,
    bool clearLastShiftEnded = false,
  }) =>
      AppState(
        hydrated: hydrated ?? this.hydrated,
        loggedIn: loggedIn ?? this.loggedIn,
        user: clearUser ? null : (user ?? this.user),
        workers: workers ?? this.workers,
        cartridges: cartridges ?? this.cartridges,
        shifts: shifts ?? this.shifts,
        records: records ?? this.records,
        activeShift: clearActiveShift ? null : (activeShift ?? this.activeShift),
        pendingCartridgeId: clearPendingCartridge
            ? null
            : (pendingCartridgeId ?? this.pendingCartridgeId),
        demo: demo ?? this.demo,
        lastShiftEndedAt: clearLastShiftEnded
            ? null
            : (lastShiftEndedAt ?? this.lastShiftEndedAt),
      );

  Map<String, dynamic> toJson() => {
        'loggedIn': loggedIn,
        'user': user?.toJson(),
        'workers': workers.map((e) => e.toJson()).toList(),
        'cartridges': cartridges.map((e) => e.toJson()).toList(),
        'shifts': shifts.map((e) => e.toJson()).toList(),
        'records': records.map((e) => e.toJson()).toList(),
        'activeShift': activeShift?.toJson(),
        'pendingCartridgeId': pendingCartridgeId,
        'demo': demo.toJson(),
        'lastShiftEndedAt': lastShiftEndedAt?.toIso8601String(),
      };

  factory AppState.fromJson(Map<String, dynamic> j) => AppState(
        hydrated: true,
        loggedIn: j['loggedIn'] as bool? ?? false,
        user: j['user'] != null
            ? UserAccount.fromJson(j['user'] as Map<String, dynamic>)
            : null,
        workers: (j['workers'] as List? ?? [])
            .map((e) => Worker.fromJson(e as Map<String, dynamic>))
            .toList(),
        cartridges: (j['cartridges'] as List? ?? [])
            .map((e) => Cartridge.fromJson(e as Map<String, dynamic>))
            .toList(),
        shifts: (j['shifts'] as List? ?? [])
            .map((e) => Shift.fromJson(e as Map<String, dynamic>))
            .toList(),
        records: (j['records'] as List? ?? [])
            .map((e) => ExposureRecord.fromJson(e as Map<String, dynamic>))
            .toList(),
        activeShift: j['activeShift'] != null
            ? Shift.fromJson(j['activeShift'] as Map<String, dynamic>)
            : null,
        pendingCartridgeId: j['pendingCartridgeId'] as String?,
        demo: j['demo'] != null
            ? DemoScenario.fromJson(j['demo'] as Map<String, dynamic>)
            : const DemoScenario(),
        lastShiftEndedAt: j['lastShiftEndedAt'] != null
            ? DateTime.parse(j['lastShiftEndedAt'] as String)
            : null,
      );
}

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(const AppState()) {
    _hydrate();
  }

  final _uuid = const Uuid();
  final _rng = Random();

  Future<void> _hydrate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(kPrefsKey);
      if (raw != null) {
        state = AppState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
        return;
      }
    } catch (e) {
      debugPrint('Hydrate failed: $e');
    }
    resetDemoData(persist: true, keepLogin: false);
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(kPrefsKey, jsonEncode(state.toJson()));
    } catch (e) {
      debugPrint('Persist failed: $e');
    }
  }

  void resetDemoData({bool persist = true, bool keepLogin = true}) {
    final workers = SeedData.workers();
    final carts = SeedData.cartridges();
    final shifts = SeedData.historicalShifts(workers);
    final records = SeedData.records(workers, shifts);
    final loggedIn = keepLogin && state.loggedIn;
    final user = keepLogin ? state.user : null;
    state = AppState(
      hydrated: true,
      loggedIn: loggedIn,
      user: loggedIn ? (user ?? SeedData.defaultUser()) : null,
      workers: workers,
      cartridges: carts,
      shifts: shifts,
      records: records,
      demo: const DemoScenario(),
    );
    if (persist) _persist();
  }

  Future<void> login({
    required String email,
    required UserRole role,
  }) async {
    await Future<void>.delayed(Duration(milliseconds: _delayMs()));
    state = state.copyWith(
      loggedIn: true,
      user: UserAccount(
        id: 'U-${role.name.toUpperCase()}-001',
        name: role == UserRole.worker
            ? 'A. Rahman'
            : role == UserRole.safetyOfficer
                ? 'M. Chen'
                : 'H. Patel',
        email: email,
        role: role,
        site: 'North Field Complex',
      ),
    );
    await _persist();
  }

  Future<void> logout() async {
    state = state.copyWith(loggedIn: false, clearUser: true);
    await _persist();
  }

  void setDemo(DemoScenario demo) {
    state = state.copyWith(demo: demo);
    _persist();
  }

  void setOnline(bool online) {
    state = state.copyWith(demo: state.demo.copyWith(online: online));
    if (online) {
      _flushSync();
    } else {
      _persist();
    }
  }

  int _delayMs() {
    if (state.demo.fastDelays) return 200;
    return kDelayMinMs + _rng.nextInt(kDelayMaxMs - kDelayMinMs);
  }

  Future<void> simulateDelay() =>
      Future<void>.delayed(Duration(milliseconds: _delayMs()));

  Cartridge resolveCartridgeForQr(QrDemoOutcome outcome) {
    switch (outcome) {
      case QrDemoOutcome.verified:
        return state.cartridgeById('ECH-C-00317') ?? state.cartridges.first;
      case QrDemoOutcome.faultDamaged:
        return state.cartridgeById('ECH-C-00077') ??
            state.cartridges.firstWhere((c) => c.lifecycle == CartridgeLifecycle.fault);
      case QrDemoOutcome.lowAccuracy:
        return state.cartridgeById('ECH-C-00250') ??
            state.cartridges.firstWhere((c) => c.flaggedRemoved);
      case QrDemoOutcome.recovering:
        return state.cartridgeById('ECH-C-00288') ??
            state.cartridges.firstWhere(
              (c) => c.lifecycle == CartridgeLifecycle.recovering,
            );
      case QrDemoOutcome.expired:
        return state.cartridgeById('ECH-C-00155') ??
            state.cartridges.firstWhere(
              (c) => c.lifecycle == CartridgeLifecycle.expired,
            );
    }
  }

  void setPendingCartridge(String id) {
    state = state.copyWith(pendingCartridgeId: id);
    _persist();
  }

  void clearPendingCartridge() {
    state = state.copyWith(clearPendingCartridge: true);
    _persist();
  }

  void flagCartridgeLowAccuracy(String id) {
    final updated = state.cartridges.map((c) {
      if (c.id != id) return c;
      return c.copyWith(
        flaggedRemoved: true,
        lifecycle: CartridgeLifecycle.lowAccuracy,
        accuracyPct: 84.2,
      );
    }).toList();
    state = state.copyWith(cartridges: updated, clearPendingCartridge: true);
    _persist();
  }

  String generateShiftId() {
    final now = DateTime.now();
    final d = DateFormat('yyyyMMdd').format(now);
    final letter = String.fromCharCode(65 + _rng.nextInt(6));
    return 'SH-$d-$letter';
  }

  Future<Shift> createShift({
    required String workerId,
    required String workArea,
    required String jobOperation,
    required String cartridgeId,
  }) async {
    await simulateDelay();
    final shift = Shift(
      id: generateShiftId(),
      workerId: workerId,
      cartridgeId: cartridgeId,
      workArea: workArea,
      jobOperation: jobOperation,
      active: false,
      calibrationVersionSnapshot:
          state.cartridgeById(cartridgeId)?.calibrationVersion ??
              'H2S-ECHO-CAL-V1',
    );
    state = state.copyWith(
      shifts: [shift, ...state.shifts],
      activeShift: shift,
      pendingCartridgeId: cartridgeId,
    );
    await _persist();
    return shift;
  }

  Future<void> startShift() async {
    final current = state.activeShift;
    if (current == null) return;
    await simulateDelay();
    final started = current.copyWith(
      startedAt: DateTime.now(),
      active: true,
      clearEnded: true,
    );
    final cartId = started.cartridgeId;
    final carts = state.cartridges.map((c) {
      if (c.id != cartId) return c;
      return c.copyWith(lifecycle: CartridgeLifecycle.ready);
    }).toList();
    final shifts = state.shifts.map((s) => s.id == started.id ? started : s).toList();
    state = state.copyWith(
      activeShift: started,
      shifts: shifts,
      cartridges: carts,
      clearLastShiftEnded: true,
    );
    await _persist();
  }

  Future<void> endShift() async {
    final current = state.activeShift;
    if (current == null || !current.active) return;
    final end = DateTime.now();
    final ended = current.copyWith(endedAt: end, active: false);
    final cartId = ended.cartridgeId;
    final carts = state.cartridges.map((c) {
      if (c.id != cartId) return c;
      final nextCycle = c.cycleCount + 1;
      final events = [
        ...c.cycleHistory,
        CartridgeCycleEvent(
          cycle: nextCycle,
          type: 'EXPOSURE',
          at: end,
          shiftId: ended.id,
          note: 'Shift ended – cartridge EXPOSED → RECOVERING',
        ),
      ];
      return c.copyWith(
        lifecycle: CartridgeLifecycle.recovering,
        recovery: RecoveryStatus.recovering,
        cycleCount: nextCycle,
        cycleHistory: events,
      );
    }).toList();
    final shifts = state.shifts.map((s) => s.id == ended.id ? ended : s).toList();
    state = state.copyWith(
      activeShift: ended,
      shifts: shifts,
      cartridges: carts,
      lastShiftEndedAt: end,
    );
    await _persist();
  }

  void fastForwardShift(Duration by) {
    final current = state.activeShift;
    if (current == null || current.startedAt == null) return;
    final started = current.copyWith(
      startedAt: current.startedAt!.subtract(by),
    );
    final shifts = state.shifts.map((s) => s.id == started.id ? started : s).toList();
    state = state.copyWith(activeShift: started, shifts: shifts);
    _persist();
  }

  void clearActiveShiftSession() {
    state = state.copyWith(clearActiveShift: true, clearPendingCartridge: true);
    _persist();
  }

  Future<ExposureRecord> createReadResult({
    required ReadDemoOutcome outcome,
    required String cartridgeId,
  }) async {
    final shift = state.activeShift ??
        (state.shifts.isNotEmpty ? state.shifts.first : null);
    final workerId = shift?.workerId ?? state.workers.first.id;
    final shiftId = shift?.id ?? 'SH-ORPHAN';
    final shiftStart =
        shift?.startedAt ?? DateTime.now().subtract(const Duration(hours: 8));
    final shiftEnd = shift?.endedAt ??
        state.lastShiftEndedAt ??
        DateTime.now().subtract(const Duration(hours: 1));
    final readout = DateTime.now();
    final delta = readout.difference(shiftEnd).inMinutes / 60.0;

    ExposureRecord record;
    switch (outcome) {
      case ReadDemoOutcome.valid:
        final fp = const Fingerprint(fast: 0.82, medium: 0.48, slow: 0.31);
        record = ExposureRecord(
          id: 'XR-${_uuid.v4().substring(0, 8).toUpperCase()}',
          workerId: workerId,
          shiftId: shiftId,
          cartridgeId: cartridgeId,
          shiftStart: shiftStart,
          shiftEnd: shiftEnd,
          readoutAt: readout,
          deltaTH: double.parse(delta.toStringAsFixed(2)),
          dosePpmH: 10.2,
          pattern: ExposurePattern.spike,
          fingerprint: fp,
          channels: [
            SeedData.demoChannel('S1 FAST', fp.fast),
            SeedData.demoChannel('S2 MEDIUM', fp.medium),
            SeedData.demoChannel('S3 SLOW', fp.slow),
            SeedData.demoChannel('REF W', 1.0),
            SeedData.demoChannel('REF G', 0.72),
            SeedData.demoChannel('REF D', 0.05),
          ],
          confidence: ConfidenceLevel.high,
          validity: ResultValidity.validResult,
          cartridgeFit: true,
          recoveryState: 'BASELINE RECOVERED',
          readoutGate: 'VALID',
          syncStatus:
              state.demo.online ? SyncStatus.pending : SyncStatus.pending,
          gates: const {
            'imageQuality': true,
            'qrReconfirm': true,
            'opticalRefs': true,
            'roiExtraction': true,
            'features': true,
            'normalization': true,
            'fingerprint': true,
            'readoutTime': true,
            'recovery': true,
            'channelConsistency': true,
            'calibrationDomain': true,
            'doseEngine': true,
            'patternEngine': true,
            'confidenceEngine': true,
            'finalValidity': true,
          },
        );
        _markCartridgeRecovered(cartridgeId);
        break;
      case ReadDemoOutcome.retake:
        record = _failRecord(
          workerId: workerId,
          shiftId: shiftId,
          cartridgeId: cartridgeId,
          shiftStart: shiftStart,
          shiftEnd: shiftEnd,
          readout: readout,
          delta: delta,
          reason: 'RETAKE REQUIRED',
          gateKey: 'imageQuality',
        );
        break;
      case ReadDemoOutcome.invalidTime:
        record = _failRecord(
          workerId: workerId,
          shiftId: shiftId,
          cartridgeId: cartridgeId,
          shiftStart: shiftStart,
          shiftEnd: shiftEnd,
          readout: readout,
          delta: delta,
          reason: 'INVALID TIME',
          gateKey: 'readoutTime',
          readoutGate: 'INVALID',
        );
        break;
      case ReadDemoOutcome.outOfRange:
        record = _failRecord(
          workerId: workerId,
          shiftId: shiftId,
          cartridgeId: cartridgeId,
          shiftStart: shiftStart,
          shiftEnd: shiftEnd,
          readout: readout,
          delta: delta,
          reason: 'OUT OF RANGE – INDETERMINATE',
          gateKey: 'calibrationDomain',
        );
        break;
      case ReadDemoOutcome.channelInconsistency:
        record = _failRecord(
          workerId: workerId,
          shiftId: shiftId,
          cartridgeId: cartridgeId,
          shiftStart: shiftStart,
          shiftEnd: shiftEnd,
          readout: readout,
          delta: delta,
          reason: 'CHANNEL INCONSISTENCY – INDETERMINATE',
          gateKey: 'channelConsistency',
        );
        break;
    }

    state = state.copyWith(records: [record, ...state.records]);
    await _persist();
    if (state.demo.online && outcome == ReadDemoOutcome.valid) {
      Future<void>.delayed(const Duration(milliseconds: 1600), () {
        markSynced(record.id);
      });
    }
    return record;
  }

  ExposureRecord _failRecord({
    required String workerId,
    required String shiftId,
    required String cartridgeId,
    required DateTime shiftStart,
    required DateTime shiftEnd,
    required DateTime readout,
    required double delta,
    required String reason,
    required String gateKey,
    String readoutGate = 'VALID',
  }) {
    final gates = <String, bool>{
      'imageQuality': true,
      'qrReconfirm': true,
      'opticalRefs': true,
      'roiExtraction': true,
      'features': true,
      'normalization': true,
      'fingerprint': true,
      'readoutTime': true,
      'recovery': true,
      'channelConsistency': true,
      'calibrationDomain': true,
      'doseEngine': false,
      'patternEngine': false,
      'confidenceEngine': false,
      'finalValidity': false,
    };
    gates[gateKey] = false;
    return ExposureRecord(
      id: 'XR-${_uuid.v4().substring(0, 8).toUpperCase()}',
      workerId: workerId,
      shiftId: shiftId,
      cartridgeId: cartridgeId,
      shiftStart: shiftStart,
      shiftEnd: shiftEnd,
      readoutAt: readout,
      deltaTH: double.parse(delta.toStringAsFixed(2)),
      confidence: ConfidenceLevel.indeterminate,
      validity: ResultValidity.noResult,
      invalidReason: reason,
      cartridgeFit: false,
      recoveryState: reason.contains('RECOVERING')
          ? 'RECOVERING'
          : 'BASELINE RECOVERED',
      readoutGate: readoutGate,
      syncStatus: SyncStatus.pending,
      gates: gates,
    );
  }

  void _markCartridgeRecovered(String id) {
    final carts = state.cartridges.map((c) {
      if (c.id != id) return c;
      return c.copyWith(
        lifecycle: CartridgeLifecycle.baselineRecovered,
        recovery: RecoveryStatus.baselineRecovered,
        cycleHistory: [
          ...c.cycleHistory,
          CartridgeCycleEvent(
            cycle: c.cycleCount,
            type: 'RECOVERY',
            at: DateTime.now(),
            note: 'Readout complete – BASELINE RECOVERED',
          ),
        ],
      );
    }).toList();
    state = state.copyWith(cartridges: carts);
  }

  void markSynced(String recordId) {
    final records = state.records.map((r) {
      if (r.id != recordId) return r;
      return r.copyWith(syncStatus: SyncStatus.synced);
    }).toList();
    state = state.copyWith(records: records);
    _persist();
  }

  void _flushSync() {
    final records = state.records
        .map((r) => r.copyWith(syncStatus: SyncStatus.synced))
        .toList();
    state = state.copyWith(records: records);
    _persist();
  }

  Future<void> syncAll() async {
    await simulateDelay();
    if (!state.demo.online) return;
    _flushSync();
  }
}

final appStateProvider =
    StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  return AppStateNotifier();
});
