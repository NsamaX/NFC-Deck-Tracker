# Data layer

Implements `domain/repository` interfaces; public contracts exchange domain
entities instead of persistence models or SDK objects.

- `repository/`: grouped implementations and platform adapters.
- `mapper/`: conversions between storage models and domain entities.
- `model/`: persistence representations and serialization.
- `datasource/local/`: SQLite and SharedPreferences operations.
- `datasource/remote/`: Firestore and Supabase operations.
- `datasource/api/`: game APIs and pagination strategies.
- `datasource/device/`: NDEF encoding/decoding used by the NFC adapter.

`CardCatalogRepositoryImpl` owns API paging and cache bookkeeping. Auth maps
Firebase users to `SessionUser`; Guest uses `GuestSessionRepository`. NFC,
image selection/storage, permissions, app version, and connectivity SDK calls
stay in this layer. QR camera views remain presentation widgets.

Data never imports presentation or `.injector`. See
[architecture](../../docs/architecture.md).
