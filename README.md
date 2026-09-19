# H2S-ECHO

Mobile operator app for the **H2S-ECHO** wearable wristband cartridge — passive hydrogen sulfide (H₂S) exposure recording with CoPc chemistry.

The cartridge stores exposure chemically across three sensing channels (**S1 FAST**, **S2 MEDIUM**, **S3 SLOW**) plus optical references (**REF W**, **REF G**, **REF D**) and a QR identity mark. The phone authenticates the cartridge, manages shifts, captures optical readouts, and syncs digital records to the central web platform. The phone does not sense H₂S continuously.

## Capabilities

- **Wristband QR verification** — authentication, condition/freshness (sentinel + recovery + cycle history), and accuracy check against a configurable pass threshold
- **Shift operations** — worker → shift → cartridge linking, ready-to-wear, live session timer, end-of-shift recovery handoff with Δt readout window
- **Cartridge readout** — cradle capture, multi-stage optical analysis pipeline, dose (ppm·h), exposure pattern (SPIKE / SUSTAINED / INTERMITTENT), confidence, and validity gates
- **Digital records** — full audit chain (WORKER → SHIFT → CARTRIDGE → EXPOSURE → PHOTO → ANALYSIS → RESULT), exposure history with dose trends, cartridge lifecycle timeline
- **Web sync** — smartphone upload queue to the central web platform
- **Roles** — WORKER, SAFETY OFFICER, ADMINISTRATOR

Cartridge lifecycle: **EXPOSED → RECOVERING → BASELINE RECOVERED → READY → NEXT EXPOSURE**

## Requirements

- Flutter stable (3.38+ / Dart 3)
- Xcode (iOS)

## Getting started

```bash
git clone https://github.com/SukhvirKooner/h2s-echo.git
cd h2s-echo
flutter pub get
open -a Simulator   # optional
flutter run
```

## Architecture

| Area | Implementation |
|------|----------------|
| State | Riverpod with a shared app repository (workers, shifts, cartridges, records) |
| Persistence | `shared_preferences` |
| Navigation | `go_router` with custom transitions |
| Charts | `fl_chart` |
| QR rendering | `qr_flutter` |
| Camera | `CameraService` abstraction (`SimulatedCameraService` for Simulator; swap-in for device camera) |
| UI | Material 3, dark industrial safety theme, portrait iPhone layouts |

```
lib/
  models/    domain models & enums
  data/      seed / reference datasets
  state/     AppState repository
  screens/   auth, home, verify, shift, read, history, cartridge, sync, profile
  widgets/   shared UI, charts, viewfinder, steppers
  services/  camera interface
  theme/     colours, typography, constants (e.g. kAccuracyThreshold)
  tools/     operator tools panel (scenario controls, data reset)
```

## Operator flow

1. Scan wristband QR → three-stage verification → **CARTRIDGE READY** (or reject with a clear reason)
2. Create shift → ready to wear → start shift (passive chemical recording on-cartridge)
3. End shift → cartridge **EXPOSED → RECOVERING**; Δt tracking for the validated readout window
4. Read cartridge in the optical cradle → analysis pipeline → **VALID RESULT** or gated **NO RESULT**
5. Review digital record → sync to central web platform

## License

Private / project use unless otherwise specified.
