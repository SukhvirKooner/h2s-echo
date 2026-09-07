import 'dart:math';

import '../models/models.dart';
import '../theme/app_constants.dart';

final _rng = Random(42);

double _r(double a, double b) => a + _rng.nextDouble() * (b - a);

List<BaselinePoint> _baselines(int cycles) {
  return List.generate(
    cycles.clamp(1, 12),
    (i) => BaselinePoint(cycle: i + 1, signal: 0.92 + _r(-0.04, 0.05)),
  );
}

List<OpticalChannel> _channels({
  required double s1n,
  required double s2n,
  required double s3n,
}) {
  OpticalChannel ch(String name, double n) => OpticalChannel(
        name: name,
        r: 40 + n * 80,
        g: 90 + n * 40,
        b: 70 + n * 20,
        l: 35 + n * 40,
        a: -8 + n * 6,
        bb: 12 + n * 10,
        raw: n * 1.15,
        normalized: n,
      );
  return [
    ch('S1 FAST', s1n),
    ch('S2 MEDIUM', s2n),
    ch('S3 SLOW', s3n),
    const OpticalChannel(
      name: 'REF W',
      r: 245,
      g: 245,
      b: 248,
      l: 96,
      a: 0.2,
      bb: 0.1,
      raw: 1.0,
      normalized: 1.0,
    ),
    const OpticalChannel(
      name: 'REF G',
      r: 40,
      g: 180,
      b: 90,
      l: 65,
      a: -40,
      bb: 30,
      raw: 0.72,
      normalized: 0.72,
    ),
    const OpticalChannel(
      name: 'REF D',
      r: 18,
      g: 18,
      b: 20,
      l: 8,
      a: 0,
      bb: 0,
      raw: 0.05,
      normalized: 0.05,
    ),
  ];
}

class SeedData {
  static List<Worker> workers() => const [
        Worker(
          id: 'W-1042',
          name: 'A. Rahman',
          badge: 'BG-8821',
          department: 'Upstream Ops',
        ),
        Worker(
          id: 'W-1108',
          name: 'M. Chen',
          badge: 'BG-9034',
          department: 'Process Safety',
          role: UserRole.safetyOfficer,
        ),
        Worker(
          id: 'W-0917',
          name: 'S. Okonkwo',
          badge: 'BG-7712',
          department: 'Wastewater',
        ),
        Worker(
          id: 'W-1255',
          name: 'J. Alvarez',
          badge: 'BG-8401',
          department: 'Tank Farm',
        ),
        Worker(
          id: 'W-0881',
          name: 'P. Singh',
          badge: 'BG-6609',
          department: 'Flare Ops',
        ),
        Worker(
          id: 'W-1330',
          name: 'L. Novak',
          badge: 'BG-9120',
          department: 'Sour Gas',
        ),
        Worker(
          id: 'W-1074',
          name: 'K. Ibrahim',
          badge: 'BG-7955',
          department: 'Well Pad',
        ),
        Worker(
          id: 'W-1422',
          name: 'T. Brooks',
          badge: 'BG-8550',
          department: 'Compressor Stn',
        ),
        Worker(
          id: 'W-0990',
          name: 'H. Patel',
          badge: 'BG-7011',
          department: 'Admin',
          role: UserRole.administrator,
        ),
        Worker(
          id: 'W-1510',
          name: 'R. Costa',
          badge: 'BG-9288',
          department: 'Pipeline',
        ),
      ];

  static const workAreas = [
    'Sour Gas Well Pad B-7',
    'Wastewater Treatment Unit 3',
    'Tank Farm T-12',
    'Compressor Station CS-4',
    'Flare Knockout Drum',
    'Amine Contactor Train A',
    'Produced Water Pit',
    'Pipeline ROW KP-18',
  ];

  static const jobs = [
    'Pigging Operation',
    'Tank Gauging',
    'Wellhead Maintenance',
    'Sample Collection',
    'Valve Isolation',
    'Confined Space Entry Support',
    'Leak Survey',
    'Filter Change-out',
  ];

  static Cartridge _cart({
    required String id,
    required int cycles,
    required CartridgeLifecycle life,
    required SentinelStatus sentinel,
    required RecoveryStatus recovery,
    required double accuracy,
    bool flagged = false,
    DateTime? expires,
  }) {
    final now = DateTime.now();
    final history = <CartridgeCycleEvent>[];
    for (var c = 1; c <= cycles; c++) {
      history.add(CartridgeCycleEvent(
        cycle: c,
        type: 'EXPOSURE',
        at: now.subtract(Duration(days: (cycles - c) * 4 + 2)),
        shiftId: 'SH-HIST-$id-$c',
        dosePpmH: _r(1.2, 18.5),
        note: 'Shift exposure cycle',
      ));
      history.add(CartridgeCycleEvent(
        cycle: c,
        type: 'RECOVERY',
        at: now.subtract(Duration(days: (cycles - c) * 4 + 1)),
        note: 'Baseline recovery complete',
      ));
    }
    return Cartridge(
      id: id,
      batchLot: 'LOT-26-${id.substring(id.length - 3)}',
      chemistryVersion: 'CoPc-H2S-3CH-v2',
      calibrationModel: 'H2S-ECHO-CAL',
      calibrationVersion: 'H2S-ECHO-CAL-V1',
      revision: 'REV-B',
      manufacturedAt: now.subtract(const Duration(days: 120)),
      expiresAt: expires ?? now.add(const Duration(days: 240)),
      cycleCount: cycles,
      maxCycles: kMaxCartridgeCycles,
      lifecycle: life,
      sentinel: sentinel,
      recovery: recovery,
      accuracyPct: accuracy,
      flaggedRemoved: flagged,
      baselineHistory: _baselines(cycles == 0 ? 1 : cycles),
      cycleHistory: history,
      qrPayload: 'H2SECHO|$id|H2S-ECHO-CAL-V1|REV-B',
    );
  }

  static List<Cartridge> cartridges() {
    final now = DateTime.now();
    return [
      _cart(
        id: 'ECH-C-00317',
        cycles: 3,
        life: CartridgeLifecycle.ready,
        sentinel: SentinelStatus.authentic,
        recovery: RecoveryStatus.ready,
        accuracy: 96.4,
      ),
      _cart(
        id: 'ECH-C-00342',
        cycles: 5,
        life: CartridgeLifecycle.ready,
        sentinel: SentinelStatus.authentic,
        recovery: RecoveryStatus.ready,
        accuracy: 94.1,
      ),
      _cart(
        id: 'ECH-C-00288',
        cycles: 8,
        life: CartridgeLifecycle.recovering,
        sentinel: SentinelStatus.authentic,
        recovery: RecoveryStatus.recovering,
        accuracy: 93.0,
      ),
      _cart(
        id: 'ECH-C-00201',
        cycles: 12,
        life: CartridgeLifecycle.baselineRecovered,
        sentinel: SentinelStatus.authentic,
        recovery: RecoveryStatus.baselineRecovered,
        accuracy: 91.2,
      ),
      _cart(
        id: 'ECH-C-00410',
        cycles: 1,
        life: CartridgeLifecycle.ready,
        sentinel: SentinelStatus.authentic,
        recovery: RecoveryStatus.ready,
        accuracy: 97.8,
      ),
      _cart(
        id: 'ECH-C-00155',
        cycles: 19,
        life: CartridgeLifecycle.expired,
        sentinel: SentinelStatus.authentic,
        recovery: RecoveryStatus.ready,
        accuracy: 88.0,
        expires: now.subtract(const Duration(days: 5)),
      ),
      _cart(
        id: 'ECH-C-00077',
        cycles: 4,
        life: CartridgeLifecycle.fault,
        sentinel: SentinelStatus.fault,
        recovery: RecoveryStatus.notReady,
        accuracy: 62.0,
      ),
      _cart(
        id: 'ECH-C-00390',
        cycles: 6,
        life: CartridgeLifecycle.damaged,
        sentinel: SentinelStatus.damaged,
        recovery: RecoveryStatus.notReady,
        accuracy: 55.0,
      ),
      _cart(
        id: 'ECH-C-00250',
        cycles: 7,
        life: CartridgeLifecycle.lowAccuracy,
        sentinel: SentinelStatus.authentic,
        recovery: RecoveryStatus.ready,
        accuracy: 81.5,
        flagged: true,
      ),
      _cart(
        id: 'ECH-C-00455',
        cycles: 2,
        life: CartridgeLifecycle.ready,
        sentinel: SentinelStatus.authentic,
        recovery: RecoveryStatus.ready,
        accuracy: 95.6,
      ),
      _cart(
        id: 'ECH-C-00301',
        cycles: 9,
        life: CartridgeLifecycle.exposed,
        sentinel: SentinelStatus.authentic,
        recovery: RecoveryStatus.notReady,
        accuracy: 92.3,
      ),
      _cart(
        id: 'ECH-C-00488',
        cycles: 0,
        life: CartridgeLifecycle.ready,
        sentinel: SentinelStatus.authentic,
        recovery: RecoveryStatus.ready,
        accuracy: 98.2,
      ),
      _cart(
        id: 'ECH-C-00199',
        cycles: 14,
        life: CartridgeLifecycle.invalid,
        sentinel: SentinelStatus.invalid,
        recovery: RecoveryStatus.notReady,
        accuracy: 40.0,
      ),
    ];
  }

  static List<Shift> historicalShifts(List<Worker> workers) {
    final now = DateTime.now();
    final shifts = <Shift>[];
    for (var i = 0; i < 34; i++) {
      final w = workers[i % workers.length];
      final start = now.subtract(Duration(days: i + 1, hours: 8));
      final end = start.add(Duration(hours: 8 + (i % 3)));
      shifts.add(Shift(
        id: 'SH-2026-${(919 - i).toString().padLeft(4, '0')}-${String.fromCharCode(65 + (i % 6))}',
        workerId: w.id,
        cartridgeId: cartridges()[i % cartridges().length].id,
        workArea: workAreas[i % workAreas.length],
        jobOperation: jobs[i % jobs.length],
        startedAt: start,
        endedAt: end,
        active: false,
      ));
    }
    return shifts;
  }

  static List<ExposureRecord> records(List<Worker> workers, List<Shift> shifts) {
    final list = <ExposureRecord>[];
    final patterns = ExposurePattern.values;
    final confidences = [
      ConfidenceLevel.high,
      ConfidenceLevel.high,
      ConfidenceLevel.medium,
      ConfidenceLevel.high,
      ConfidenceLevel.low,
    ];

    for (var i = 0; i < shifts.length; i++) {
      final s = shifts[i];
      final isInvalid = i % 9 == 0 || i % 11 == 0;
      final pattern = patterns[i % patterns.length];
      final fast = pattern == ExposurePattern.spike
          ? _r(0.75, 0.95)
          : pattern == ExposurePattern.sustained
              ? _r(0.35, 0.55)
              : _r(0.45, 0.70);
      final medium = pattern == ExposurePattern.sustained
          ? _r(0.70, 0.90)
          : _r(0.40, 0.65);
      final slow = pattern == ExposurePattern.intermittent
          ? _r(0.55, 0.80)
          : _r(0.25, 0.55);
      final dose = _r(1.5, 22.0);
      String? reason;
      ResultValidity validity = ResultValidity.validResult;
      ConfidenceLevel conf = confidences[i % confidences.length];
      double? doseOut = double.parse(dose.toStringAsFixed(1));

      if (isInvalid) {
        validity = ResultValidity.noResult;
        doseOut = null;
        conf = ConfidenceLevel.indeterminate;
        if (i % 9 == 0) {
          reason = i % 2 == 0
              ? 'INVALID TIME'
              : 'OUT OF RANGE – INDETERMINATE';
        } else {
          reason = 'CHANNEL INCONSISTENCY – INDETERMINATE';
        }
      }

      final readout = s.endedAt!.add(Duration(hours: 1 + (i % 4)));
      final delta = readout.difference(s.endedAt!).inMinutes / 60.0;

      list.add(ExposureRecord(
        id: 'XR-2026-${(1000 + i).toString()}',
        workerId: s.workerId,
        shiftId: s.id,
        cartridgeId: s.cartridgeId!,
        shiftStart: s.startedAt!,
        shiftEnd: s.endedAt!,
        readoutAt: readout,
        deltaTH: double.parse(delta.toStringAsFixed(2)),
        dosePpmH: doseOut,
        pattern: isInvalid ? null : pattern,
        fingerprint: isInvalid
            ? null
            : Fingerprint(fast: fast, medium: medium, slow: slow),
        channels: isInvalid
            ? const []
            : _channels(s1n: fast, s2n: medium, s3n: slow),
        confidence: conf,
        validity: validity,
        invalidReason: reason,
        cartridgeFit: !isInvalid,
        recoveryState: isInvalid ? 'RECOVERING' : 'BASELINE RECOVERED',
        readoutGate: reason == 'INVALID TIME' ? 'INVALID' : 'VALID',
        syncStatus: i % 7 == 0 ? SyncStatus.pending : SyncStatus.synced,
        gates: {
          'imageQuality': !isInvalid || i % 9 != 0,
          'qrReconfirm': true,
          'readoutTime': reason != 'INVALID TIME',
          'recovery': reason != 'RECOVERING NOT READY',
          'channelConsistency': reason != 'CHANNEL INCONSISTENCY – INDETERMINATE',
          'calibrationDomain': reason != 'OUT OF RANGE – INDETERMINATE',
          'finalValidity': !isInvalid,
        },
      ));
    }
    return list;
  }

  static UserAccount defaultUser() => const UserAccount(
        id: 'U-SO-1108',
        name: 'M. Chen',
        email: 'm.chen@siteops.example',
        role: UserRole.safetyOfficer,
        site: 'North Field Complex',
      );

  static OpticalChannel demoChannel(String name, double n) => OpticalChannel(
        name: name,
        r: 40 + n * 80,
        g: 90 + n * 40,
        b: 70 + n * 20,
        l: 35 + n * 40,
        a: -8 + n * 6,
        bb: 12 + n * 10,
        raw: n * 1.12,
        normalized: n,
      );
}
