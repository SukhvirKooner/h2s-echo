import '../models/enums.dart';

/// Controls outcomes for the next demo action. Invisible once closed.
class DemoScenario {
  final QrDemoOutcome qrOutcome;
  final ReadDemoOutcome readOutcome;
  final bool online;
  final bool fastDelays;

  const DemoScenario({
    this.qrOutcome = QrDemoOutcome.verified,
    this.readOutcome = ReadDemoOutcome.valid,
    this.online = true,
    this.fastDelays = false,
  });

  DemoScenario copyWith({
    QrDemoOutcome? qrOutcome,
    ReadDemoOutcome? readOutcome,
    bool? online,
    bool? fastDelays,
  }) =>
      DemoScenario(
        qrOutcome: qrOutcome ?? this.qrOutcome,
        readOutcome: readOutcome ?? this.readOutcome,
        online: online ?? this.online,
        fastDelays: fastDelays ?? this.fastDelays,
      );

  Map<String, dynamic> toJson() => {
        'qrOutcome': qrOutcome.name,
        'readOutcome': readOutcome.name,
        'online': online,
        'fastDelays': fastDelays,
      };

  factory DemoScenario.fromJson(Map<String, dynamic> j) => DemoScenario(
        qrOutcome: QrDemoOutcome.values.byName(
          j['qrOutcome'] as String? ?? 'verified',
        ),
        readOutcome: ReadDemoOutcome.values.byName(
          j['readOutcome'] as String? ?? 'valid',
        ),
        online: j['online'] as bool? ?? true,
        fastDelays: j['fastDelays'] as bool? ?? false,
      );
}
