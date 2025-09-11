<h1 align="center">🧪 Unit Testing Suite</h1>

## Overview

This project includes a comprehensive unit testing suite to ensure the reliability and functionality of individual components in the `nfc_deck_tracker` application. The unit tests are organized under the `/test/` folder, focusing on validating isolated logic, such as usecases, repositories, and widgets, using mock dependencies. This approach helps maintain a robust and bug-free codebase.

---

## 📁 Folder Structure & Responsibilities

```plaintext
test/               # Contains unit tests for isolated components and logic
├── bloc/           # Tests for BLoC state management logic
├── datasource/     # Tests for data source implementations
├── entity/         # Tests for entity data structures
├── mapper/         # Tests for data mapping logic
├── model/          # Tests for data models
├── page/           # Tests for page-level UI logic
├── repository/     # Tests for repository implementations
├── route/          # Tests for navigation routes
├── usecase/        # Tests for business use cases
├── utility/        # Tests for utility functions
└── widget/         # Tests for widget components
```

---

### 🗂️ Detailed Test Descriptions

* **Unit Tests (`/test/`)**
  - **Purpose:** Validate the behavior of individual components in isolation (e.g., usecases, repositories, widgets) using mock dependencies.
  - **Tools:** Utilizes `test` and `mockito` packages to simulate dependencies and test logic.
  - **Examples:**
    - `usecase/deck_use_case_test.dart`: Tests deck-related business logic with mocked repositories.
    - `widget/nfc_scan_widget_test.dart`: Verifies UI behavior when scanning NFC tags.
    - **Scenarios:** Covers success cases, failures (e.g., no internet, API errors), and edge cases.

---

## ⚙️ Running Tests

1. **Unit Tests:**
   - Run all unit tests: `flutter test test/`
   - Run specific test file: `flutter test test/usecase/deck_use_case_test.dart`

2. **Coverage (Optional):**
   - Generate coverage report: `flutter test --coverage`
   - Analyze with `genhtml` or a similar tool for detailed insights.

---

## 📋 Best Practices

- **Mocking:** Use `mockito` to isolate dependencies and simulate various conditions (e.g., network failure, empty data).
- **Behavior-Driven:** Design tests to mimic real user actions (e.g., button taps, NFC scans) and system states (e.g., offline mode) within isolated components.
- **Naming Convention:** Follow `<feature>_<type>_test.dart` (e.g., `deck_use_case_test.dart`) for consistency.
- **Setup/Teardown:** Use `setUp` and `tearDown` to initialize and clean up test environments.

---

## 🚀 Contribution Guidelines

- Add new test cases for any new feature or bug fix.
- Ensure all tests pass before submitting pull requests.
- Update this README if new test categories or files are added.

---
