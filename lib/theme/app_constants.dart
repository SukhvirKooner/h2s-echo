/// Central accuracy pass threshold for QR Stage 3.
/// Change this single constant to adjust the demo pass bar.
const double kAccuracyThreshold = 90.0;

/// Simulated processing delay range (ms).
const int kDelayMinMs = 600;
const int kDelayMaxMs = 1500;

/// Validated readout window after shift end (hours).
const double kReadoutWindowStartH = 0.5;
const double kReadoutWindowEndH = 24.0;

/// Max reusable cycles per cartridge.
const int kMaxCartridgeCycles = 20;

/// Persistence key.
const String kPrefsKey = 'h2s_echo_app_state_v1';
