# data

Implements the `domain/repository` interfaces and owns storage, serialization,
and platform I/O. Public contracts return domain entities, never models or SDK
objects.

## Contents

| Path | Purpose |
| --- | --- |
| `repository/` | Repository implementations and platform adapters, one per aggregate. |
| `model/` | Persistence representations and serialization. |
| `mapper/` | Conversions between models and domain entities. |
| `datasource/local/` | SQLite and SharedPreferences access, one class per aggregate. |
| `datasource/remote/` | Firestore and Supabase access, one class per aggregate. |
| `datasource/api/` | Game card APIs, paging strategies, and `ServiceFactory`. |
| `datasource/device/` | NDEF encoding and decoding for the NFC adapter. |

## Notes

- `CardCatalogRepositoryImpl` owns API paging and cache bookkeeping.
- Auth maps Firebase users to `SessionUser`; Guest mode uses
  `GuestSessionRepository`.
- NFC, image, permission, app version, and connectivity SDK calls stay here.
  QR camera views stay in presentation.

## Rules

- Never import `presentation/` or `.injector/`.
- Adding a field touches one model, one mapper, and the matching local and
  remote data source.

## Related

- [Working guide](../../.claude/guide.md)
- [domain](../domain/README.md)
- [Adding a game](../.config/README.md#adding-a-game)
