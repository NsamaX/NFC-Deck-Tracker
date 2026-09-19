# Unit and widget tests

Run `flutter test --dart-define=GUEST_MODE=true` from the project root.

`guest_mode_test.dart` checks dependency initialization without cloud credentials,
offline sync results, local image paths, and bundled language discovery.
