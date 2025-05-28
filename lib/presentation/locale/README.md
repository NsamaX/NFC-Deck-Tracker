<h1 align="center">🌐 Localization System</h1>

## Overview

This folder (`lib/presentation/locale/`) contains all **logic related to localization and internationalization (i18n)** for the application.  
It provides the mechanisms required to load translation files, switch app languages at runtime, and integrate seamlessly with Flutter's localization APIs.

> 🔤 The actual translation files (`.json`) are located in: `assets/locale/`

---

## 📁 Folder Structure

```plaintext
presentation/locale/
├── language_manager.dart           # Handles supported languages and language switching logic
├── localization_delegate.dart      # Custom Flutter localization delegate
├── localization.dart               # Loads and retrieves localized strings
````

---

## 🗂️ Related Assets

```plaintext
assets/locale/
├── en.json      # English translations
├── th.json      # Thai translations
├── fr.json      # French translations
```

Each JSON file represents a supported locale and contains key-value pairs used for UI translations.

---

## ➕ How to Add a New Language

To add support for a new language:

1. Create a `.json` file in `assets/locale/` using the language code (e.g. `es.json`, `de.json`)
2. Copy the structure from an existing file such as `en.json`
3. Translate all values into the new language
4. Add the language code to `supportedLanguages` in `language_manager.dart`

Once completed, the app will automatically detect and load the new language based on user selection or device settings.

---

## 🔣 Placeholder Usage

Use **named placeholders** when inserting dynamic content into translation strings. For example:

```json
"greeting": "Hello, {name}!"
```

At runtime, `{name}` will be replaced with the actual value provided by the app.

---
