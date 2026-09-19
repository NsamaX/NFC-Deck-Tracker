# Unit and widget tests

Run `flutter test --dart-define=GUEST_MODE=true` from the project root.

`guest_mode_test.dart` checks dependency initialization without cloud credentials,
offline sync results, local image paths, and bundled language discovery.

- `architecture_test.dart`: dependency direction, including barrels, parts,
  relative paths, and indirect project dependencies.
- `domain_workflows_test.dart`: deck CRUD, sync outcomes, tag lookup, settings policy.
- `deck_repository_test.dart`: use case → repository → datasource persistence mapping
  with a SQL fake, without a native database.
- `nfc_flow_test.dart`: typed NFC state updates without hardware and existing NDEF format.
