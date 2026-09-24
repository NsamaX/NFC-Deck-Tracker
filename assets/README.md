# assets

Static resources bundled with the app. Every folder is declared under
`flutter: assets:` in `pubspec.yaml`, so new files inside them need no
`pubspec.yaml` change.

## Contents

| Path | Format | Purpose |
| --- | --- | --- |
| `font/` | `.ttf` | Playpen Sans Thai, the app font, in all weights. Registered under `flutter: fonts:`. |
| `icon/` | `.svg` | UI icons. |
| `image/` | `.png` | Screen illustrations and the launcher icon source. |
| `image/game/` | `.png` | Game icons, one per game ID in `lib/.config/game.dart`. |
| `locale/` | `.json` | Translations, one file per language code. |

## Translations

- Each file needs a `language_name` entry, shown in the language picker.
- Keys are grouped into nested objects and read as dotted paths
  (`common.button_ok`).
- Dynamic values use named placeholders such as `{total}`; the caller
  replaces them.
- To add a language, copy `en.json` to `<code>.json` and translate the values.
  The app discovers new files at startup.

## Guidelines

- Use lowercase, hyphenated file names (`internet-lost.png`).
- Compress `.png` files before adding them.
- The launcher icons are generated from `image/icon.png` and
  `image/icon_foreground.png` by `flutter_launcher_icons`.

## Related

- [presentation](../lib/presentation/README.md)
- [Adding a game](../lib/.config/README.md#adding-a-game)
