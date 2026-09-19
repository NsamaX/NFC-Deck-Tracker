# Integration tests

No Flutter integration tests have been implemented yet.

Before adding tests, add the Flutter SDK's `integration_test` package to
`dev_dependencies` in `pubspec.yaml`. Place tests in this directory using
filenames ending in `_test.dart`.

Once tests exist, run `flutter test integration_test` with a device connected.
Testing NFC interactions requires a compatible physical device and NFC tags.
