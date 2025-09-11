<h1 align="center">🧪 Integration Testing Suite</h1>

## Overview

This project includes a comprehensive integration testing suite to ensure the reliability and functionality of the `nfc_deck_tracker` application by validating the interaction between multiple layers (UI, domain, and data). The integration tests are organized under the `/integration_test/` folder, focusing on simulating real user behavior and end-to-end workflows to maintain a robust and bug-free application.

---

## 📁 Folder Structure & Responsibilities

```plaintext
integration_test/  # Contains integration tests for end-to-end workflows
├── app_test.dart   # Tests the entire app flow
└── nfc_flow_test.dart  # Tests NFC-related user interactions
```

---

### 🗂️ Detailed Test Descriptions

* **Integration Tests (`/integration_test/`)**
  - **Purpose:** Validate the interaction between multiple components (e.g., UI with domain logic and data layers) and simulate real user behavior.
  - **Tools:** Utilizes `integration_test` and `flutter_driver` packages to mimic user actions like tapping, scanning, or navigating.
  - **Examples:**
    - `app_test.dart`: Ensures the app launches, navigates correctly, and handles authentication flows.
    - `nfc_flow_test.dart`: Tests the complete NFC scan-to-deck-save workflow, including online/offline states.
    - **Scenarios:** Includes real-world conditions such as network interruptions, NFC detection, and multi-step user interactions.

---

## ⚙️ Running Tests

1. **Integration Tests:**
   - Run all integration tests: `flutter test integration_driver --target=integration_test/app_test.dart`
   - Ensure a device or emulator is connected for real interaction testing.

2. **Coverage (Optional):**
   - Generate coverage report (if supported): `flutter test --coverage integration_test/`
   - Analyze with `genhtml` or a similar tool for detailed insights (note: coverage for integration tests may require additional setup).

---

## 📋 Best Practices

- **Realistic Simulation:** Design tests to mimic actual user actions (e.g., tapping buttons, scanning NFC tags) and system states (e.g., offline mode).
- **Environment Setup:** Ensure a connected device or emulator is ready before running tests.
- **Naming Convention:** Follow `<feature>_test.dart` (e.g., `nfc_flow_test.dart`) for consistency.
- **Setup/Teardown:** Use `setUpAll` and `tearDownAll` to prepare and clean up the test environment, especially for device-specific setups.

---

## 🚀 Contribution Guidelines

- Add new test cases for any new feature or end-to-end workflow.
- Ensure all tests pass before submitting pull requests.
- Update this README if new test files or scenarios are added.

---
