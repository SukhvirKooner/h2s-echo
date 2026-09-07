import 'enums.dart';
export 'enums.dart';

class Worker {
  final String id;
  final String name;
  final String badge;
  final String department;
  final UserRole role;

  const Worker({
    required this.id,
    required this.name,
    required this.badge,
    required this.department,
    this.role = UserRole.worker,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'badge': badge,
        'department': department,
        'role': role.name,
      };

  factory Worker.fromJson(Map<String, dynamic> j) => Worker(
        id: j['id'] as String,
        name: j['name'] as String,
        badge: j['badge'] as String,
        department: j['department'] as String,
        role: UserRole.values.byName(j['role'] as String? ?? 'worker'),
      );

  Worker copyWith({
    String? id,
    String? name,
    String? badge,
    String? department,
    UserRole? role,
  }) =>
      Worker(
        id: id ?? this.id,
        name: name ?? this.name,
        badge: badge ?? this.badge,
        department: department ?? this.department,
        role: role ?? this.role,
      );
}

class OpticalChannel {
  final String name;
  final double r;
  final double g;
  final double b;
  final double l;
  final double a;
  final double bb;
  final double raw;
  final double normalized;

  const OpticalChannel({
    required this.name,
    required this.r,
    required this.g,
    required this.b,
    required this.l,
    required this.a,
    required this.bb,
    required this.raw,
    required this.normalized,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'r': r,
        'g': g,
        'b': b,
        'l': l,
        'a': a,
        'bb': bb,
        'raw': raw,
        'normalized': normalized,
      };

  factory OpticalChannel.fromJson(Map<String, dynamic> j) => OpticalChannel(
        name: j['name'] as String,
        r: (j['r'] as num).toDouble(),
        g: (j['g'] as num).toDouble(),
        b: (j['b'] as num).toDouble(),
        l: (j['l'] as num).toDouble(),
        a: (j['a'] as num).toDouble(),
        bb: (j['bb'] as num).toDouble(),
        raw: (j['raw'] as num).toDouble(),
        normalized: (j['normalized'] as num).toDouble(),
      );
}

class Fingerprint {
  final double fast;
  final double medium;
  final double slow;

  const Fingerprint({
    required this.fast,
    required this.medium,
    required this.slow,
  });

  Map<String, dynamic> toJson() => {
        'fast': fast,
        'medium': medium,
        'slow': slow,
      };

  factory Fingerprint.fromJson(Map<String, dynamic> j) => Fingerprint(
        fast: (j['fast'] as num).toDouble(),
        medium: (j['medium'] as num).toDouble(),
        slow: (j['slow'] as num).toDouble(),
      );
}

class BaselinePoint {
  final int cycle;
  final double signal;

  const BaselinePoint({required this.cycle, required this.signal});

  Map<String, dynamic> toJson() => {'cycle': cycle, 'signal': signal};

  factory BaselinePoint.fromJson(Map<String, dynamic> j) => BaselinePoint(
        cycle: j['cycle'] as int,
        signal: (j['signal'] as num).toDouble(),
      );
}

class CartridgeCycleEvent {
  final int cycle;
  final String type; // EXPOSURE | RECOVERY
  final DateTime at;
  final String? shiftId;
  final double? dosePpmH;
  final String note;

  const CartridgeCycleEvent({
    required this.cycle,
    required this.type,
    required this.at,
    this.shiftId,
    this.dosePpmH,
    this.note = '',
  });

  Map<String, dynamic> toJson() => {
        'cycle': cycle,
        'type': type,
        'at': at.toIso8601String(),
        'shiftId': shiftId,
        'dosePpmH': dosePpmH,
        'note': note,
      };

  factory CartridgeCycleEvent.fromJson(Map<String, dynamic> j) =>
      CartridgeCycleEvent(
        cycle: j['cycle'] as int,
        type: j['type'] as String,
        at: DateTime.parse(j['at'] as String),
        shiftId: j['shiftId'] as String?,
        dosePpmH: (j['dosePpmH'] as num?)?.toDouble(),
        note: j['note'] as String? ?? '',
      );
}

class Cartridge {
  final String id;
  final String batchLot;
  final String chemistryVersion;
  final String calibrationModel;
  final String calibrationVersion;
  final String revision;
  final DateTime manufacturedAt;
  final DateTime expiresAt;
  final int cycleCount;
  final int maxCycles;
  final CartridgeLifecycle lifecycle;
  final SentinelStatus sentinel;
  final RecoveryStatus recovery;
  final double accuracyPct;
  final bool flaggedRemoved;
  final List<BaselinePoint> baselineHistory;
  final List<CartridgeCycleEvent> cycleHistory;
  final String qrPayload;
  final String validUseInfo;

  const Cartridge({
    required this.id,
    required this.batchLot,
    required this.chemistryVersion,
    required this.calibrationModel,
    required this.calibrationVersion,
    required this.revision,
    required this.manufacturedAt,
    required this.expiresAt,
    required this.cycleCount,
    this.maxCycles = 20,
    required this.lifecycle,
    required this.sentinel,
    required this.recovery,
    required this.accuracyPct,
    this.flaggedRemoved = false,
    required this.baselineHistory,
    required this.cycleHistory,
    required this.qrPayload,
    this.validUseInfo = 'Oil & gas / wastewater H₂S passive dosimetry',
  });

  bool get isEligibleForWear =>
      !flaggedRemoved &&
      lifecycle == CartridgeLifecycle.ready &&
      sentinel == SentinelStatus.authentic &&
      recovery == RecoveryStatus.ready &&
      accuracyPct >= 90.0 &&
      DateTime.now().isBefore(expiresAt) &&
      cycleCount < maxCycles;

  Map<String, dynamic> toJson() => {
        'id': id,
        'batchLot': batchLot,
        'chemistryVersion': chemistryVersion,
        'calibrationModel': calibrationModel,
        'calibrationVersion': calibrationVersion,
        'revision': revision,
        'manufacturedAt': manufacturedAt.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
        'cycleCount': cycleCount,
        'maxCycles': maxCycles,
        'lifecycle': lifecycle.name,
        'sentinel': sentinel.name,
        'recovery': recovery.name,
        'accuracyPct': accuracyPct,
        'flaggedRemoved': flaggedRemoved,
        'baselineHistory': baselineHistory.map((e) => e.toJson()).toList(),
        'cycleHistory': cycleHistory.map((e) => e.toJson()).toList(),
        'qrPayload': qrPayload,
        'validUseInfo': validUseInfo,
      };

  factory Cartridge.fromJson(Map<String, dynamic> j) => Cartridge(
        id: j['id'] as String,
        batchLot: j['batchLot'] as String,
        chemistryVersion: j['chemistryVersion'] as String,
        calibrationModel: j['calibrationModel'] as String,
        calibrationVersion: j['calibrationVersion'] as String,
        revision: j['revision'] as String,
        manufacturedAt: DateTime.parse(j['manufacturedAt'] as String),
        expiresAt: DateTime.parse(j['expiresAt'] as String),
        cycleCount: j['cycleCount'] as int,
        maxCycles: j['maxCycles'] as int? ?? 20,
        lifecycle: CartridgeLifecycle.values.byName(j['lifecycle'] as String),
        sentinel: SentinelStatus.values.byName(j['sentinel'] as String),
        recovery: RecoveryStatus.values.byName(j['recovery'] as String),
        accuracyPct: (j['accuracyPct'] as num).toDouble(),
        flaggedRemoved: j['flaggedRemoved'] as bool? ?? false,
        baselineHistory: (j['baselineHistory'] as List)
            .map((e) => BaselinePoint.fromJson(e as Map<String, dynamic>))
            .toList(),
        cycleHistory: (j['cycleHistory'] as List)
            .map((e) => CartridgeCycleEvent.fromJson(e as Map<String, dynamic>))
            .toList(),
        qrPayload: j['qrPayload'] as String,
        validUseInfo: j['validUseInfo'] as String? ??
            'Oil & gas / wastewater H₂S passive dosimetry',
      );

  Cartridge copyWith({
    String? id,
    String? batchLot,
    String? chemistryVersion,
    String? calibrationModel,
    String? calibrationVersion,
    String? revision,
    DateTime? manufacturedAt,
    DateTime? expiresAt,
    int? cycleCount,
    int? maxCycles,
    CartridgeLifecycle? lifecycle,
    SentinelStatus? sentinel,
    RecoveryStatus? recovery,
    double? accuracyPct,
    bool? flaggedRemoved,
    List<BaselinePoint>? baselineHistory,
    List<CartridgeCycleEvent>? cycleHistory,
    String? qrPayload,
    String? validUseInfo,
  }) =>
      Cartridge(
        id: id ?? this.id,
        batchLot: batchLot ?? this.batchLot,
        chemistryVersion: chemistryVersion ?? this.chemistryVersion,
        calibrationModel: calibrationModel ?? this.calibrationModel,
        calibrationVersion: calibrationVersion ?? this.calibrationVersion,
        revision: revision ?? this.revision,
        manufacturedAt: manufacturedAt ?? this.manufacturedAt,
        expiresAt: expiresAt ?? this.expiresAt,
        cycleCount: cycleCount ?? this.cycleCount,
        maxCycles: maxCycles ?? this.maxCycles,
        lifecycle: lifecycle ?? this.lifecycle,
        sentinel: sentinel ?? this.sentinel,
        recovery: recovery ?? this.recovery,
        accuracyPct: accuracyPct ?? this.accuracyPct,
        flaggedRemoved: flaggedRemoved ?? this.flaggedRemoved,
        baselineHistory: baselineHistory ?? this.baselineHistory,
        cycleHistory: cycleHistory ?? this.cycleHistory,
        qrPayload: qrPayload ?? this.qrPayload,
        validUseInfo: validUseInfo ?? this.validUseInfo,
      );
}

class Shift {
  final String id;
  final String workerId;
  final String? cartridgeId;
  final String workArea;
  final String jobOperation;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final bool active;
  final String calibrationVersionSnapshot;

  const Shift({
    required this.id,
    required this.workerId,
    this.cartridgeId,
    required this.workArea,
    required this.jobOperation,
    this.startedAt,
    this.endedAt,
    this.active = false,
    this.calibrationVersionSnapshot = 'H2S-ECHO-CAL-V1',
  });

  Duration? get elapsed {
    if (startedAt == null) return null;
    final end = endedAt ?? DateTime.now();
    return end.difference(startedAt!);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'workerId': workerId,
        'cartridgeId': cartridgeId,
        'workArea': workArea,
        'jobOperation': jobOperation,
        'startedAt': startedAt?.toIso8601String(),
        'endedAt': endedAt?.toIso8601String(),
        'active': active,
        'calibrationVersionSnapshot': calibrationVersionSnapshot,
      };

  factory Shift.fromJson(Map<String, dynamic> j) => Shift(
        id: j['id'] as String,
        workerId: j['workerId'] as String,
        cartridgeId: j['cartridgeId'] as String?,
        workArea: j['workArea'] as String,
        jobOperation: j['jobOperation'] as String,
        startedAt: j['startedAt'] != null
            ? DateTime.parse(j['startedAt'] as String)
            : null,
        endedAt:
            j['endedAt'] != null ? DateTime.parse(j['endedAt'] as String) : null,
        active: j['active'] as bool? ?? false,
        calibrationVersionSnapshot:
            j['calibrationVersionSnapshot'] as String? ?? 'H2S-ECHO-CAL-V1',
      );

  Shift copyWith({
    String? id,
    String? workerId,
    String? cartridgeId,
    String? workArea,
    String? jobOperation,
    DateTime? startedAt,
    DateTime? endedAt,
    bool? active,
    String? calibrationVersionSnapshot,
    bool clearCartridge = false,
    bool clearEnded = false,
  }) =>
      Shift(
        id: id ?? this.id,
        workerId: workerId ?? this.workerId,
        cartridgeId: clearCartridge ? null : (cartridgeId ?? this.cartridgeId),
        workArea: workArea ?? this.workArea,
        jobOperation: jobOperation ?? this.jobOperation,
        startedAt: startedAt ?? this.startedAt,
        endedAt: clearEnded ? null : (endedAt ?? this.endedAt),
        active: active ?? this.active,
        calibrationVersionSnapshot:
            calibrationVersionSnapshot ?? this.calibrationVersionSnapshot,
      );
}

class ExposureRecord {
  final String id;
  final String workerId;
  final String shiftId;
  final String cartridgeId;
  final DateTime shiftStart;
  final DateTime shiftEnd;
  final DateTime readoutAt;
  final double deltaTH;
  final double? dosePpmH;
  final ExposurePattern? pattern;
  final Fingerprint? fingerprint;
  final List<OpticalChannel> channels;
  final ConfidenceLevel confidence;
  final ResultValidity validity;
  final String? invalidReason;
  final bool cartridgeFit;
  final String recoveryState;
  final String readoutGate;
  final SyncStatus syncStatus;
  final String softwareVersion;
  final String modelVersion;
  final String calibrationVersion;
  final Map<String, bool> gates;

  const ExposureRecord({
    required this.id,
    required this.workerId,
    required this.shiftId,
    required this.cartridgeId,
    required this.shiftStart,
    required this.shiftEnd,
    required this.readoutAt,
    required this.deltaTH,
    this.dosePpmH,
    this.pattern,
    this.fingerprint,
    this.channels = const [],
    required this.confidence,
    required this.validity,
    this.invalidReason,
    this.cartridgeFit = true,
    this.recoveryState = 'BASELINE RECOVERED',
    this.readoutGate = 'VALID',
    this.syncStatus = SyncStatus.synced,
    this.softwareVersion = 'H2S-ECHO-APP-1.0.0',
    this.modelVersion = 'PATTERN-ENGINE-V2',
    this.calibrationVersion = 'H2S-ECHO-CAL-V1',
    this.gates = const {},
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'workerId': workerId,
        'shiftId': shiftId,
        'cartridgeId': cartridgeId,
        'shiftStart': shiftStart.toIso8601String(),
        'shiftEnd': shiftEnd.toIso8601String(),
        'readoutAt': readoutAt.toIso8601String(),
        'deltaTH': deltaTH,
        'dosePpmH': dosePpmH,
        'pattern': pattern?.name,
        'fingerprint': fingerprint?.toJson(),
        'channels': channels.map((e) => e.toJson()).toList(),
        'confidence': confidence.name,
        'validity': validity.name,
        'invalidReason': invalidReason,
        'cartridgeFit': cartridgeFit,
        'recoveryState': recoveryState,
        'readoutGate': readoutGate,
        'syncStatus': syncStatus.name,
        'softwareVersion': softwareVersion,
        'modelVersion': modelVersion,
        'calibrationVersion': calibrationVersion,
        'gates': gates,
      };

  factory ExposureRecord.fromJson(Map<String, dynamic> j) => ExposureRecord(
        id: j['id'] as String,
        workerId: j['workerId'] as String,
        shiftId: j['shiftId'] as String,
        cartridgeId: j['cartridgeId'] as String,
        shiftStart: DateTime.parse(j['shiftStart'] as String),
        shiftEnd: DateTime.parse(j['shiftEnd'] as String),
        readoutAt: DateTime.parse(j['readoutAt'] as String),
        deltaTH: (j['deltaTH'] as num).toDouble(),
        dosePpmH: (j['dosePpmH'] as num?)?.toDouble(),
        pattern: j['pattern'] != null
            ? ExposurePattern.values.byName(j['pattern'] as String)
            : null,
        fingerprint: j['fingerprint'] != null
            ? Fingerprint.fromJson(j['fingerprint'] as Map<String, dynamic>)
            : null,
        channels: (j['channels'] as List? ?? [])
            .map((e) => OpticalChannel.fromJson(e as Map<String, dynamic>))
            .toList(),
        confidence: ConfidenceLevel.values.byName(j['confidence'] as String),
        validity: ResultValidity.values.byName(j['validity'] as String),
        invalidReason: j['invalidReason'] as String?,
        cartridgeFit: j['cartridgeFit'] as bool? ?? true,
        recoveryState: j['recoveryState'] as String? ?? 'BASELINE RECOVERED',
        readoutGate: j['readoutGate'] as String? ?? 'VALID',
        syncStatus: SyncStatus.values.byName(j['syncStatus'] as String? ?? 'synced'),
        softwareVersion: j['softwareVersion'] as String? ?? 'H2S-ECHO-APP-1.0.0',
        modelVersion: j['modelVersion'] as String? ?? 'PATTERN-ENGINE-V2',
        calibrationVersion:
            j['calibrationVersion'] as String? ?? 'H2S-ECHO-CAL-V1',
        gates: Map<String, bool>.from(j['gates'] as Map? ?? {}),
      );

  ExposureRecord copyWith({
    SyncStatus? syncStatus,
    String? invalidReason,
  }) =>
      ExposureRecord(
        id: id,
        workerId: workerId,
        shiftId: shiftId,
        cartridgeId: cartridgeId,
        shiftStart: shiftStart,
        shiftEnd: shiftEnd,
        readoutAt: readoutAt,
        deltaTH: deltaTH,
        dosePpmH: dosePpmH,
        pattern: pattern,
        fingerprint: fingerprint,
        channels: channels,
        confidence: confidence,
        validity: validity,
        invalidReason: invalidReason ?? this.invalidReason,
        cartridgeFit: cartridgeFit,
        recoveryState: recoveryState,
        readoutGate: readoutGate,
        syncStatus: syncStatus ?? this.syncStatus,
        softwareVersion: softwareVersion,
        modelVersion: modelVersion,
        calibrationVersion: calibrationVersion,
        gates: gates,
      );
}

class UserAccount {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String site;

  const UserAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.site,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role.name,
        'site': site,
      };

  factory UserAccount.fromJson(Map<String, dynamic> j) => UserAccount(
        id: j['id'] as String,
        name: j['name'] as String,
        email: j['email'] as String,
        role: UserRole.values.byName(j['role'] as String),
        site: j['site'] as String,
      );
}
