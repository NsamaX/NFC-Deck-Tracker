# 📦 Assets Folder

## Overview
The assets folder contains all static resources used in the nfc_deck_tracker application, organized into subfolders for better management. This app uses the Playpen Sans Thai font for its UI.

---

## 📁 Folder Structure & Responsibilities
- `font/`: Stores font files, exclusively using the .ttf format (e.g., PlaypenSansThai-Regular.ttf).
- `icon/`: Contains icon files, exclusively using the .svg format (e.g., icon_add.svg).
- `image/`: Holds image assets, exclusively using the .png format (e.g., image_landing.png).
- `locale/`: Stores localization files, exclusively using the .json format (e.g., en.json).

---

## ⚙️ Usage
- Add new assets to the appropriate subfolder.
- Update `pubspec.yaml` under `flutter:` > `assets:` to include new files or folders (e.g., - `- assets/image/`).
- Follow naming conventions (e.g., `font_PlaypenSansThai-Bold.ttf`, `icon_button_add.svg`) for consistency.

---

## 🚀 Contribution Guidelines
- Ensure all assets are optimized (e.g., compressed .png images).
- Test UI after adding new assets to verify rendering.
- Use only .ttf, .svg, .png, and .json file formats as specified.
- Update this README if new guidelines or changes are introduced.

---
