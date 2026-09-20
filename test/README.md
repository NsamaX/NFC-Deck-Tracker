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
- `flows_widget_test.dart`: end-to-end page flows (deck builder, custom card
  create/edit, tracker history) against real blocs and in-memory repositories
  from `support/test_app.dart`; no emulator or Firebase needed.
- `tracker_bloc_test.dart`, `deck_builder_bloc_test.dart`, `bloc_error_test.dart`:
  bloc behavior, including error state.
