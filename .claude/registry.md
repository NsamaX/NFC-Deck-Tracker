# Registry

> Last updated: 2026-09-20
> Verified by `dart run tool/verify_registry.dart`. Update this file whenever a
> port, use case, or entity is added, removed, or gains a public member.

## How to use

Attach this file when asking an AI to work across layers. Presentation may
call only the use cases listed here. Data may implement only the ports listed
here. Anything not listed is internal to its layer.

Each section names its `Source:` directory. Every `.dart` file in that
directory (except the `index.dart` barrel) must appear as a `### Name
(`file`)` entry. Sections marked `Check: members` also compare the bulleted
member names against the class body.

---

## Domain ports

Source: `lib/domain/repository/`
Check: classes, members
Implemented in: `lib/data/repository/`
Consumers: domain use cases only. Presentation must not import these.

`ForLocal` operates on SQLite; `ForRemote` operates on Firestore and returns
`false` on failure. `userId` is empty in Guest mode, and use cases skip remote
calls when it is empty.

### CardRepository (`card.dart`)

- `check` — count cards in a collection with the given name (duplicate check)
- `createForLocal` — insert a card
- `createForRemote` — insert a card under the user's collection
- `deleteForLocal` — delete by collection and card id
- `deleteForRemote` — delete by user, collection, and card id
- `fetchForLocal` — cards of one collection
- `fetchForRemote` — cards of one collection for the user
- `fetchUsedCards` — every card referenced by any deck
- `findForApi` — look up a catalog card by id via the game API
- `findForLocal` — look up a stored card by collection and card id
- `save` — upsert a batch of catalog cards into the local cache
- `updateForLocal` — update a card
- `updateForRemote` — update the user's card

### CardCatalogRepository (`card_catalog.dart`)

- `fetch` — supported games: pages from the game API cached locally; custom collections: `SyncPolicy.reconcile` against the user's remote cards

### CollectionRepository (`collection.dart`)

- `createForLocal` — insert a collection
- `createForRemote` — insert the user's collection
- `deleteForLocal` — delete by id, returns whether a row was removed
- `deleteForRemote` — delete the user's collection
- `fetchForLocal` — all collections
- `fetchForRemote` — the user's collections
- `find` — one collection by id
- `touch` — bump `updatedAt` so a collection sorts as recently used
- `updateForLocal` — update a collection
- `updateForRemote` — update the user's collection

### DeckRepository (`deck.dart`)

- `createForLocal` — insert a deck and its card memberships
- `createForRemote` — insert the user's deck
- `deleteForLocal` — delete by id
- `deleteForRemote` — delete the user's deck
- `fetchCardsInDeck` — card memberships with counts for one deck
- `fetchForLocal` — all decks
- `fetchForRemote` — the user's decks
- `updateForLocal` — update card memberships of a deck (deck metadata is not rewritten; see docs/architecture.md)
- `updateForRemote` — update the user's deck

### DeviceRepository (`device.dart`)

- `connectivityChanges` — stream of online/offline state
- `appVersion` — version string from the package info
- `selectCardImage` — pick an image and copy it into app storage, as `SelectedImage`

### ImageRepository (`image.dart`)

- `delete` — remove stored images by URL or path
- `update` — replace an image, returns the new URL
- `upload` — store an image, returns its URL (local path in Guest mode)

### LocalDataRepository (`local_data.dart`)

- `clear` — wipe every local table and stored preference

### NfcRepository (`nfc.dart`)

- `isAvailable` — whether the device has usable NFC
- `start` — begin a session; with `card` it writes that card to the tag, otherwise it reads; results arrive as `NfcResult`
- `stop` — end the session

### RecordRepository (`record.dart`)

- `createForLocal` — insert a match record
- `createForRemote` — insert the user's record
- `deleteForLocal` — delete by id
- `deleteForRemote` — delete the user's record
- `fetchForLocal` — records of one deck
- `fetchForRemote` — the user's records of one deck
- `import` — fetch a record shared to this user, or null when none exists
- `share` — publish a record to another user
- `updateForLocal` — update a record
- `updateForRemote` — update the user's record

### SessionRepository (`session.dart`)

- `currentUser` — the signed-in `SessionUser`, or null
- `authStateChanges` — stream of sign-in/out transitions
- `signInWithGoogle` — returns `SignInResult`; the Guest binding always reports unavailable
- `signOut` — end the session

### SettingsRepository (`settings.dart`)

- `load` — the stored `AppSettings`, with defaults for missing keys
- `save` — persist every field of `AppSettings`; null fields remove their key

---

## Domain services

Source: `lib/domain/service/`
Check: classes

### DomainLogger (`domain_logger.dart`)

Diagnostic sink injected into use cases; `SilentDomainLogger` is the default.
`lib/util/domain_logger.dart` adapts it to `LoggerUtil`.

### SyncPolicy (`sync_policy.dart`)

The single owner of offline-first rules, used by every `Create*`, `Update*`,
`Delete*`, and `Fetch*` use case. `write` calls remote first when signed in and
stores the resulting `isSynced`; `delete` removes local then remote;
`reconcile` imports newer remote rows, uploads unsynced and newer local rows,
then deletes synced local rows missing remotely (rows uploaded in the same
pass are kept). A `RemoteUnavailableException` skips the whole pass.
`SyncTarget<T>` adapts an aggregate's repository to it.

---

## Use cases

Source: `lib/domain/usecase/`
Check: classes
Consumers: presentation blocs and pages, through `PresentationDependencies` or
constructor injection.

All sync behavior comes from `SyncPolicy` (see Domain services); use cases
only decide ids, timestamps, and which repository methods to bind.

### CalculateUsageCardUsecase (`calculate_usage_card.dart`)

`call({deck, record})` — per-card play statistics of one record, as `UsageCardStats`.

### ClearUserDataUsecase (`clear_user_data.dart`)

`call({isGuest})` — delete used-card images when guest, then wipe local data.

### CreateCardUsecase (`create_card.dart`)

`call({userId, card})` — upload the image, insert the card, touch its collection; returns the saved card with its id.

### CreateCollectionUsecase (`create_collection.dart`)

`call({userId, name})` — insert a collection with a generated id; returns it.

### CreateDeckUsecase (`create_deck.dart`)

`call({userId, deck})` — insert a deck, generating an id when empty; returns the saved deck.

### CreateRecordUsecase (`create_record.dart`)

`call({userId, record})` — insert a match record, generating an id when empty; returns the saved record.

### DeleteCardUsecase (`delete_card.dart`)

`call({userId, collectionId, cardId, imageUrl})` — delete the card and its image.

### DeleteCollectionUsecase (`delete_collection.dart`)

`call({userId, collectionId})` — delete a collection.

### DeleteDeckUsecase (`delete_deck.dart`)

`call({userId, deckId})` — delete a deck.

### DeleteRecordUsecase (`delete_record.dart`)

`call({userId, recordId})` — delete a record.

### DeviceUsecase (`device.dart`)

`appVersion()`, `selectCardImage()` — device facade for Settings/About and card image selection.

### FetchCardUsecase (`fetch_card.dart`)

`call({userId, collectionId, batchSize})` — catalog cards through `CardCatalogRepository`.

### FetchCardInDeckUsecase (`fetch_card_in_deck.dart`)

`call({deckId})` — card memberships of one deck.

### FetchCollectionUsecase (`fetch_collection.dart`)

`call({userId})` — collections with the sync policy above.

### FetchDeckUsecase (`fetch_deck.dart`)

`call({userId})` — decks with the sync policy above.

### FetchRecordUsecase (`fetch_record.dart`)

`call({userId, deckId})` — records of one deck with the sync policy above.

### FetchUsedCardDistinctUsecase (`fetch_used_card_distinct.dart`)

`call()` — distinct cards referenced by any deck.

### FindCardFromTagUsecase (`find_card_from_tag.dart`)

`call(tag)` — local lookup, then the game API; throws `INVALID_TAG` on an empty tag.

### GenerateShareDeckClipboardUsecase (`generate_share_deck_clipboard.dart`)

`call({deck, nameLabel, totalLabel})` — plain-text deck list for the clipboard.

### GetCardFromRecordUsecase (`get_card_from_record.dart`)

`call({record, deck})` — cards played in a record, resolved against the deck.

### ImportRecordUsecase (`import_record.dart`)

`call({userId})` — fetch a record shared to this user, or null when none exists.

### InitSettingUsecase (`init_setting.dart`)

`call()` — the stored `AppSettings`.

### NfcSessionUsecase (`nfc_session.dart`)

`isAvailable()`, `start()`, `stop()` — facade over `NfcRepository`.

### SessionUsecase (`session.dart`)

`authStateChanges()`, `signInWithGoogle()`, `signOut()` — facade over `SessionRepository`.

### ShareRecordUsecase (`share_record.dart`)

`call({userId, shareRecord})` — publish a record to another user.

### SummarizeRecordUsecase (`summarize_record.dart`)

`call({deck, record, stats})` — pure `RecordSummary` (totals, share of the deck played, unused cards) for the insight panel.

### TrackingInteractionUsecase (`tracking_interaction.dart`)

`call({deck, logs, tag})` — apply one NFC scan to the live tracker; returns `TrackingInteractionResult`.

### UpdateCardUsecase (`update_card.dart`)

`call({userId, card, oldImageUrl})` — replace the image when it changed from `oldImageUrl`, then update the card; reached from the card page's save action when editing a custom card.

### UpdateCardInDeckUsecase (`update_card_in_deck.dart`)

`call({cardInDeck, card, quantity})` — pure list update of a deck's card counts.

### UpdateCollectionUsecase (`update_collection.dart`)

`call({userId, collection})` — update a collection.

### UpdateDeckUsecase (`update_deck.dart`)

`call({userId, deck})` — update a deck with a fresh `updatedAt`; returns the saved deck.

### UpdateRecordUsecase (`update_record.dart`)

`call({userId, record})` — update a record.

### UpdateSettingUsecase (`update_setting.dart`)

`call(settings)` — persist a whole `AppSettings`; callers derive it with `copyWith`.

---

## Entities

Source: `lib/domain/entity/`
Check: classes
Consumers: every layer. Data maps these to models in `lib/data/mapper/`.
Ids, names, card lists, and `isSynced` are non-null; an empty string or list
means "not set yet" (a blank form), so guards test `isEmpty`, never `null`.

### AppSettings (`app_settings.dart`)

Typed preferences: `locale`, `isDark`, `showNfcTutorial`, and optional
`guestId`, `recentId`, `recentGame`. `copyWith(clearGuestId: true)` signs a
guest out; `isGuest` is `guestId != null`.

### CardEntity (`card.dart`)

A card in a collection: ids, name, description, image URL, game-specific fields. `copyWith(clearImageUrl: true)` (and `clearDescription`, `clearAdditionalData`) reset an optional field to null.

### CardInDeckEntity (`card_in_deck.dart`)

A card with its count inside a deck.

### CollectionEntity (`collection.dart`)

A user-defined or game catalog collection.

### DataEntity (`data.dart`)

One tracker log line: card, `PlayerAction`, timestamp.

### DeckEntity (`deck.dart`)

A deck with its cards, game, timestamps, and `isSynced`.

### NfcResult (`nfc_result.dart`)

Typed NFC outcome (`NfcResultKind`, `NfcNotice`) that replaces raw `NfcTag`/`Ndef` in presentation.

### PageEntity (`page.dart`)

Pagination cursor for catalog fetches.

### RecordEntity (`record.dart`)

A match record: deck, logs, result, timestamps.

### RecordSummary (`record_summary.dart`)

Aggregate figures of one record over its deck, computed by `SummarizeRecordUsecase`.

### SelectedImage (`selected_image.dart`)

Result of image selection with `ImageSelectionStatus`.

### SessionUser (`session_user.dart`)

Signed-in user (id, name, email, photo) and `SignInResult`; never a Firebase `User`.

### ShareRecordEntity (`share_record.dart`)

A record packaged for sharing between users.

### TagEntity (`tag.dart`)

Payload read from an NFC tag: collection id and card id.

### UsageCardStats (`usage_card_stats.dart`)

Per-card statistics computed from a record.

---

## Values

Source: `lib/domain/value/`
Check: classes

### PlayerAction (`player_action.dart`)

Enumerated action recorded on each tracker interaction.

### RemoteUnavailableException (`remote_unavailable.dart`)

Thrown by remote reads when Firestore is unconfigured or the query fails, so
callers can tell "no data" from "could not read". `Fetch*` use cases catch it
and return local data without syncing.

---

## Presentation dependencies

`lib/presentation/dependencies.dart` defines `PresentationDependencies`, the
only thing pages may read from `PresentationScope`. Its `userId` getter is the
signed-in Firebase uid or an empty string for guests; pages must not derive
it from the guest id. `.injector/
presentation_dependencies.dart` builds it from GetIt. Add a field there when a
page needs a new bloc or use case; do not resolve GetIt from presentation.
