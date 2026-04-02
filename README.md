# VaultVibe

VaultVibe is a production-grade Flutter expense tracker built with Clean Architecture, Riverpod, Hive, and secure local storage. It helps users record expenses, manage categories, monitor monthly spending, set budgets, export CSV reports, and protect the app with a PIN lock.

## Overview

VaultVibe is designed as an offline-first personal finance app. All primary data is stored locally on the device using Hive, while sensitive PIN data is stored securely with `flutter_secure_storage`.

The project follows a layered architecture:

- `presentation`: UI, Riverpod providers, state handling
- `domain`: entities, repository contracts, business rules, use cases
- `data`: Hive models, local data sources, repository implementations
- `core`: constants, enums, theme, helpers, shared failures

This separation keeps business logic independent from Flutter widgets and makes the app easier to maintain, test, and scale.

## Key Features

- Expense CRUD with add, edit, and delete flows
- Category management with reassignment-aware deletion
- Monthly dashboard with:
  - total expense
  - category breakdown
  - top spending categories
  - daily average spending
- Monthly budget tracking with health indicators:
  - green: under 70%
  - yellow: 70% to 90%
  - red: above 90%
- Date range and category filtering
- Recurring expense engine with duplicate protection
- CSV export to local device storage
- 4-digit PIN app lock with secure hashed storage
- App lock on startup and app resume
- Offline-first storage using Hive

## Architecture

### Presentation Layer

The presentation layer contains Flutter widgets and Riverpod providers.

Main screens:

- `DashboardScreen`: monthly summary, budget, breakdown, top categories
- `HomeScreen`: expense list, filtering, export, navigation to add/edit
- `ExpenseFormScreen`: expense entry and update form
- `CategoryManagementScreen`: create, edit, delete categories
- `AppLockScreen`: PIN setup and unlock flow
- `AppShellScreen`: app shell, tab navigation, app-lock gate

**Riverpod** is used for:

- dependency injection
- async state management
- filtered list state
- dashboard-derived values
- category actions
- export actions
- lock state transitions

### Domain Layer

The domain layer contains pure Dart business logic with no Flutter imports.

Core entities:

- `Expense`
- `Category`
- `Budget`
- `AppSettings`
- `MonthlySummary`

Repository contracts:

- `ExpenseRepository`
- `CategoryRepository`
- `SettingsRepository`
- `AppLockRepository`

Use cases include:

- `AddExpenseUseCase`
- `UpdateExpenseUseCase`
- `DeleteExpenseUseCase`
- `GetExpensesUseCase`
- `GetAllExpensesUseCase`
- `GetExpensesByFilterUseCase`
- `GetAllCategoriesUseCase`
- `ManageCategoriesUseCase`
- `SetBudgetUseCase`
- `GetMonthlySummaryUseCase`
- `GenerateRecurringExpensesUseCase`
- `ExportCsvUseCase`
- `HasPinUseCase`
- `SetupPinUseCase`
- `VerifyPinUseCase`

### Data Layer

The data layer is responsible for persistence and mapping domain entities to local models.

Hive models:

- `ExpenseModel`
- `CategoryModel`
- `BudgetModel`
- `AppSettingsModel`

Local data sources:

- `HiveExpenseLocalDataSource`
- `HiveCategoryLocalDataSource`
- `HiveSettingsLocalDataSource`
- `SecureLockLocalDataSource`

Storage behavior:

- Expense, category, budget, and app settings data are stored in Hive boxes
- PIN hashes are stored securely using `flutter_secure_storage`
- CSV export files are written to device-accessible storage where possible

## Folder Structure

```text
lib/
├── core/
│   ├── constants/
│   ├── enums/
│   ├── theme/
│   └── utils/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/
│   ├── providers/
│   ├── screens/
│   └── widgets/
└── main.dart
```

## Tech Stack

- Flutter
- Dart
- Riverpod
- Hive
- flutter_secure_storage
- fl_chart
- path_provider
- permission_handler
- crypto
- intl
- uuid

## Business Rules

### Recurring Expenses

Recurring expenses are processed on app startup.

- The app reads `lastRecurringCheck` from settings
- It checks all recurring expenses against the current date
- Missing entries are generated for due periods
- Deterministic generated IDs are used to prevent duplicates
- `lastGeneratedDate` is updated per recurring base expense
- `lastRecurringCheck` is updated globally after processing

This design makes the recurring engine idempotent and able to recover from long inactivity.

### Categories

- There are no mandatory seeded categories
- Categories are fully user-managed
- A category cannot be deleted silently if it is already used
- Used categories must either be reassigned or kept

### App Lock

- First launch requires creating a 4-digit PIN
- PIN is hashed with SHA-256 before storage
- PIN hash is stored in secure storage, not Hive
- The app locks on startup and again when the app resumes
- PIN change is intentionally not exposed in the current flow

### CSV Export

Current CSV export includes these columns:

- `Title`
- `Category_name`
- `Date`
- `Payment method`
- `Amount`
- `Type`
- `Recurring`
- `Recurring_type`

Older export files are cleaned up automatically after 15 days.

## Local Storage

Hive boxes used by the app:

- `expenses`
- `categories`
- `budgets`
- `settings`

Secure storage keys include:

- `pin`

## Permissions

Android permissions currently declared:

- notifications
- external storage read
- external storage write
- manage external storage

These are used primarily to support CSV export to device-visible storage and future notification support.

## Getting Started

### Prerequisites

- Flutter SDK installed
- Dart SDK compatible with Flutter
- Android Studio or VS Code
- Xcode for iOS/macOS builds

### Install Dependencies

```bash
flutter pub get
```

### Generate Code

Run this if you modify Hive models, adapters, or any generated code setup:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Run the App

```bash
flutter run
```

## Development Commands

Analyze the project:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

## Release Build

### Android Release APK

1. Create a keystore
2. Add `android/key.properties`
3. Set the real keystore values:

```properties
storePassword=YOUR_REAL_STORE_PASSWORD
keyPassword=YOUR_REAL_KEY_PASSWORD
keyAlias=vaultvibe
storeFile=/absolute/path/to/your-keystore.jks
```

4. Build the APK:

```bash
flutter build apk --release
```

Generated file:

```text
build/app/outputs/flutter-apk/app-release.apk
```

For smaller ABI-specific builds:

```bash
flutter build apk --release --split-per-abi
```

### Package Identifiers

- Android application ID: `com.vault.vibe`
- iOS bundle ID: `com.vault.vibe`
- App name: `VaultVibe`

## Project Highlights

- Clean Architecture maintained across features
- Business logic separated from UI concerns
- Offline-first by design
- Riverpod-based dependency graph
- Reusable widgets and modular providers
- Generated Hive adapters for strongly typed persistence
- Secure PIN handling with hashed storage

## Current Scope

VaultVibe currently focuses on local personal expense tracking. The app does not yet include:

- cloud sync
- authentication with remote backend
- multi-user collaboration
- push notification workflows

These can be added later without major structural changes because of the current architecture.

## Notes for Contributors

- Keep domain logic Flutter-free
- Preserve the existing folder structure
- Add new behavior through use cases and repository interfaces first
- Keep Hive-specific logic inside the data layer
- Keep Riverpod wiring inside the presentation layer

## License

This project currently does not define a license. Add one before public distribution if needed.
