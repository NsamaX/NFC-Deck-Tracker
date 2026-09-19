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

Copy `.env.example` to `.env` in the project root, then fill in
`SUPABASE_URL` and `SUPABASE_ANON_KEY` for your Supabase project.
The app already loads this file through `flutter_dotenv`.

`.env` and its local variants are ignored by Git; `.env.example` is the shared
template. Flutter bundles `.env` as an asset, so use the client anon key,
never a service-role key or other server credentials.

Firebase configuration is separate from `.env`. Restore or generate
`lib/firebase_options.dart` and the Firebase configuration files for your target
platform (for Android, `android/app/google-services.json`) before running the
app. The Android build also references local release signing settings in
`android/key.properties` and `android/app/proguard-rules.pro`, which are absent
from this checkout and need to be configured before building.

After configuring the project and installing the Flutter SDK, run
`flutter pub get` and `flutter run`.

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
