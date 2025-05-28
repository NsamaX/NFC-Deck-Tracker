<h1 align="center">📦 Presentation Layer</h1>

## Overview

The `presentation/` layer is responsible for managing the **User Interface (UI)** and **user interactions** within the application.  
It renders the visual components based on the current application state and handles input from users.  
This layer communicates with the domain or application layer (via Cubits or Blocs) to execute logic and reflect changes.

---

## 📁 Folder Structure & Responsibilities

```plaintext
presentation/
├── cubit/      # State management using Cubit or Bloc
├── locale/     # Internationalization (i18n) and localization setup
├── page/       # Individual screens or pages in the application
├── route/      # Application-wide route definitions and navigation
├── theme/      # Global theming: colors, fonts, text styles
├── widget/     # Reusable, shared UI components
````

---

### 🗂️ Detailed Folder Descriptions

* **`cubit/`**

  * Contains Cubit classes and corresponding states used for managing UI state.
  * Each Cubit encapsulates UI-specific business logic and emits states to trigger UI updates.

* **`locale/`**

  * Handles all localization and translation logic.
  * Includes language files, localization delegates, and language switch mechanisms.
  * Supports multi-language UI rendering using internationalization (`i18n`).

* **`page/`**

  * Contains all top-level screens or pages displayed in the app.
  * Each page corresponds to a route and may contain multiple widgets and Cubits.

* **`route/`**

  * Defines and manages app navigation routes.
  * Includes `RouteGenerator`, initial route handling, and observer logic.
  * Ensures centralized routing and consistent navigation across the app.

* **`theme/`**

  * Stores global styling configuration such as color palettes, typography, and widget themes.
  * Ensures UI consistency and supports light/dark modes or custom branding.

* **`widget/`**

  * Contains reusable and modular UI components (e.g., buttons, form fields, cards).
  * Widgets in this folder are intended to be shared across multiple pages to maintain consistency and reduce duplication.

---
