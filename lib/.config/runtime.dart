/// Run with --dart-define=GUEST_MODE=true to use local storage only.
class RuntimeConfig {
  static const guestMode = bool.fromEnvironment('GUEST_MODE');
}
