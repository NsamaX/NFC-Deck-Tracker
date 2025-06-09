<h1 align="center">📦 Application Source (`lib/`)</h1>

## Overview

The `lib/` directory contains the **entire application source code**, structured using the **Clean Architecture** pattern.  
This structure separates the app into distinct layers to ensure **modularity**, **testability**, and **maintainability**.  
Each layer has a clear responsibility and communicates with other layers through well-defined interfaces.

---

## 🧱 Clean Architecture Layers

1. **Presentation Layer** – UI, interaction, and state management  
2. **Domain Layer**       – Core business logic and use cases  
3. **Data Layer**         – Data access from APIs, databases, etc.  
4. **Injection Layer**    – Dependency registration via service locator  
5. **Config Layer**       – App-wide constants and configurations

---

## 📁 Folder Structure & Responsibilities

```plaintext
lib/
├── .config/                # App-wide constants and configurations
├── .injector/              # Dependency injection setup (via GetIt)
├── data/                   # Data sources, models, and repository implementations
├── domain/                 # Business logic, use cases, and entities
├── presentation/           # UI components, localization, theming, and Cubits
├── util/                   # Reusable utilities (e.g., logger, extensions, helpers)
├── firebase_options.dart   # Firebase configuration file (auto-generated)
├── main.dart               # App entry point and bootstrap logic
````

---

## 🗂️ Detailed Folder Descriptions

### **`.injector/`**

* **Purpose**: Sets up dependency injection using `GetIt`.
* **Files**:

  * `setup_*`: Registers dependencies grouped by layer (e.g., `setup_cubit.dart`, `setup_repository.dart`).
  * `_locator.dart`: Entry point to run all setup functions.
* 📄 [See more](./.injector/README.md)

---

### **`.config/`**

* **Purpose**: Defines static constants used throughout the app.
* **Files**: Game identifiers, environment configurations, base URLs, etc.

---

### **`data/`**

* **Purpose**: Handles all data-related operations.
* **Contains**:

  * `datasource/`: Separated into `api/`, `local/`, and `remote/` for organizing external, local, and cloud data.
  * `model/`: Data Transfer Objects (DTOs) and serializers.
  * `repository/`: Implements domain repository interfaces.
* 📄 [See more](./data/README.md)

---

### **`domain/`**

* **Purpose**: Contains the application's core business rules and logic.
* **Contains**:

  * `entity/`: Core business models (e.g., CardEntity).
  * `mapper/`: Converts data models ↔ domain entities.
  * `usecase/`: Encapsulated application-specific logic.
* 📄 [See more](./domain/README.md)

---

### **`presentation/`**

* **Purpose**: Manages UI rendering, state, localization, and navigation.
* **Contains**:

  * `cubit/`: State management using Cubit/BLoC.
  * `locale/`: i18n and language switching.
  * `page/`: App screens and views.
  * `route/`: Navigation and route generation.
  * `theme/`: Colors, typography, and styling.
  * `widget/`: Reusable UI components.
* 📄 [See more](./presentation/README.md)

---

### **`util/`**

* **Purpose**: General-purpose helper functions and services.
* **Examples**:

  * `logger.dart`: Logging utility
  * `nfc_session_handler.dart`: NFC lifecycle management

---

### **`firebase_options.dart`**

* Auto-generated Firebase configuration file used for `Firebase.initializeApp()`.

---

### **`main.dart`**

* Entry point of the application.
* Initializes bindings, sets orientation, loads environment variables, runs `setupLocator()`, and boots the app.

---

> ℹ️ This documentation provides guidance to developers contributing to the app’s core structure, ensuring a consistent and understandable codebase.
