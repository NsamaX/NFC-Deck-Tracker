# Unit and widget tests

Run `flutter test --dart-define=GUEST_MODE=true` from the project root.

`guest_mode_test.dart` checks dependency initialization without cloud credentials,
offline sync results, local image paths, and bundled language discovery.

- `architecture_test.dart`: dependency direction, including barrels, parts,
  relative paths, and indirect project dependencies.
- `domain_workflows_test.dart`: deck CRUD, sync outcomes, tag lookup, settings policy.
- `deck_repository_test.dart`, `catalog_repository_test.dart`: repositories
  against a real in-memory SQLite (`support/sqlite.dart`): deck cards through
  sync, catalog paging, built-in collections surviving collection sync.
- `database_migration_test.dart`: schema upgrades run each version step once
  and roll back on failure.
- `game_api_test.dart`: `ApiClient` retries, request sharing, 404 memory, and
  spacing; the Scryfall adapter against `MockClient`.
- `image_repository_test.dart`: local image files removed when replaced or deleted.
- `share_record_test.dart`: shared records use a valid Firestore path and
  round-trip.
- `pending_delete_test.dart`: rows deleted offline are not imported back; the
  pendingDeletes table after a v1 upgrade.
- `remote_parse_test.dart`: malformed Firestore documents keep local data.
- `card_image_test.dart`: card create/update and guest data clearing when a
  card has no image.
- `update_usecases_test.dart`: collection and record updates with a fixed
  `Clock` and `IdGenerator`.
- `nfc_flow_test.dart`: typed NFC state updates without hardware, the NDEF
  format, typed codec failures, and read-only tags.
- `flows_widget_test.dart`: end-to-end page flows (deck builder, custom card
  create/edit, tracker history) against real blocs and in-memory repositories
  from `support/test_app.dart`; no emulator or Firebase needed.
- `tracker_bloc_test.dart`, `deck_builder_bloc_test.dart`, `bloc_error_test.dart`:
  bloc behavior, including error state.
