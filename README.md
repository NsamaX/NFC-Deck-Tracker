# NFC Deck Tracker

A mobile application for managing and tracking trading card game (TCG) decks in real time using NFC technology, developed as a Bachelor's Thesis at Silpakorn University.

## Screenshots

![Screenshot](nfc-deck-tracker.png)

## Features

- **Deck Management**: Create, edit, and organize custom decks across multiple TCGs
- **Card Search**: Search for cards via public game APIs or user-defined collections
- **NFC Integration**: Track and update cards in real time using NFC-enabled tags
- **Custom Cards**: Support for user-created cards with images and metadata
- **Game Analytics**: Record match history, analyze deck usage, and visualize stats

## Local configuration

### Guest mode on an Android emulator

Guest mode stores decks, collections, cards, and settings locally. It skips
Firebase and Supabase initialization, keeps selected images on the device,
and hides Google sign-in and remote card catalogs. Cloud sync and record
sharing are unavailable in this mode. NFC scanning requires a physical device.

On this Windows workspace, a local Android SDK, JDK 21, and the
`NFC_Deck_API_35` emulator are installed under the ignored `.local/` directory.
Start the emulator and app with:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\run-guest.ps1
```

Use `-BuildOnly` to create an x86_64 debug APK, or `-DeviceId <id>` to run on an
already connected device. The script sets tool paths for its process only;
it does not change system-wide settings. It also disables Windows desktop
plugin generation for that shell, so Android development does not require
Windows Developer Mode.

For manual commands in PowerShell:

```powershell
. .\scripts\android-env.ps1
flutter pub get
flutter devices
flutter run -d emulator-5554 --dart-define=GUEST_MODE=true
flutter test --dart-define=GUEST_MODE=true
```

Guest mode needs no real values in `.env`; the launcher copies `.env.example`
if the file is missing. On another machine, install the
[Android toolchain](https://docs.flutter.dev/platform-integration/android/setup)
and create an emulator first. The local SDK and emulator are not part of Git.
This setup uses Flutter 3.41.1, JDK 21, Android SDK 36, and an Android 35 emulator.

Android build compatibility notes: `nfc_manager` 3.x compiles with Kotlin 1.9
language/API compatibility, and Kotlin incremental compilation is disabled to
avoid cache errors when the Pub cache and project are on different Windows
drives. The QR scanner uses the
[compatibility fork](https://pub.dev/packages/qr_code_scanner_plus) at version
2.1.2 to support the newer Android build tools without changing its UI.

### Online mode

Copy `.env.example` to `.env` in the project root, then fill in
`SUPABASE_URL` and `SUPABASE_ANON_KEY` for your Supabase project.
The app already loads this file through `flutter_dotenv`.

`.env` and its local variants are ignored by Git; `.env.example` is the shared
template. Flutter bundles `.env` as an asset, so use the client anon key,
never a service-role key or other server credentials.

Firebase configuration is separate from `.env`. Online mode initializes
Firebase from the native mobile configuration: restore
`android/app/google-services.json` for Android, or configure
`ios/Runner/GoogleService-Info.plist` for iOS. The Android Google Services plugin
is applied when its configuration file exists. Release signing still needs
your own `android/key.properties` and keystore; debug builds use Android's
debug signing and do not require release credentials.

After configuring the project and installing the Flutter SDK, run
`flutter pub get` and `flutter run` (without `GUEST_MODE=true`).

## Demo

| Field          | Value                                        |
|----------------|----------------------------------------------|
| Thesis Title   | NFC Deck Tracker Application                 |
| Student        | Vijuksama Hongthongdaeng (640710759)          |
| Advisor        | Lecturer Apisake Hongwitayakorn              |
| Academic Year  | 2024                                         |
| Department     | Information Technology, Faculty of Science, Silpakorn University |

## License

This project is licensed under the **MIT License**.
