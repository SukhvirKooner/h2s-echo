enum UserRole { worker, safetyOfficer, administrator }

enum CartridgeLifecycle {
  ready,
  exposed,
  recovering,
  baselineRecovered,
  expired,
  fault,
  damaged,
  lowAccuracy,
  invalid,
}

enum SentinelStatus { authentic, invalid, fault, damaged }

enum RecoveryStatus { ready, recovering, baselineRecovered, notReady }

enum ExposurePattern { spike, sustained, intermittent }

enum ConfidenceLevel { high, medium, low, indeterminate }

enum ResultValidity { validResult, noResult }

enum SyncStatus { synced, pending, offline }

enum QrDemoOutcome {
  verified,
  faultDamaged,
  lowAccuracy,
  recovering,
  expired,
}

enum ReadDemoOutcome {
  valid,
  retake,
  invalidTime,
  outOfRange,
  channelInconsistency,
}

extension CartridgeLifecycleX on CartridgeLifecycle {
  String get label {
    switch (this) {
      case CartridgeLifecycle.ready:
        return 'READY';
      case CartridgeLifecycle.exposed:
        return 'EXPOSED';
      case CartridgeLifecycle.recovering:
        return 'RECOVERING';
      case CartridgeLifecycle.baselineRecovered:
        return 'BASELINE RECOVERED';
      case CartridgeLifecycle.expired:
        return 'EXPIRED';
      case CartridgeLifecycle.fault:
        return 'DEVICE FAULT DETECTED';
      case CartridgeLifecycle.damaged:
        return 'DAMAGED';
      case CartridgeLifecycle.lowAccuracy:
        return 'ACCURACY BELOW THRESHOLD';
      case CartridgeLifecycle.invalid:
        return 'CARTRIDGE INVALID';
    }
  }
}

extension ExposurePatternX on ExposurePattern {
  String get label {
    switch (this) {
      case ExposurePattern.spike:
        return 'SPIKE';
      case ExposurePattern.sustained:
        return 'SUSTAINED';
      case ExposurePattern.intermittent:
        return 'INTERMITTENT';
    }
  }
}

extension ConfidenceLevelX on ConfidenceLevel {
  String get label {
    switch (this) {
      case ConfidenceLevel.high:
        return 'HIGH';
      case ConfidenceLevel.medium:
        return 'MEDIUM';
      case ConfidenceLevel.low:
        return 'LOW';
      case ConfidenceLevel.indeterminate:
        return 'INDETERMINATE';
    }
  }
}

extension UserRoleX on UserRole {
  String get label {
    switch (this) {
      case UserRole.worker:
        return 'WORKER';
      case UserRole.safetyOfficer:
        return 'SAFETY OFFICER';
      case UserRole.administrator:
        return 'ADMINISTRATOR';
    }
  }
}

extension QrDemoOutcomeX on QrDemoOutcome {
  String get label {
    switch (this) {
      case QrDemoOutcome.verified:
        return 'Verified';
      case QrDemoOutcome.faultDamaged:
        return 'Fault / Damaged';
      case QrDemoOutcome.lowAccuracy:
        return 'Low Accuracy';
      case QrDemoOutcome.recovering:
        return 'Recovering';
      case QrDemoOutcome.expired:
        return 'Expired';
    }
  }
}

extension ReadDemoOutcomeX on ReadDemoOutcome {
  String get label {
    switch (this) {
      case ReadDemoOutcome.valid:
        return 'Valid';
      case ReadDemoOutcome.retake:
        return 'Retake Required';
      case ReadDemoOutcome.invalidTime:
        return 'Invalid Time';
      case ReadDemoOutcome.outOfRange:
        return 'Out of Range';
      case ReadDemoOutcome.channelInconsistency:
        return 'Channel Inconsistency';
    }
  }
}
