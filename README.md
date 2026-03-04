# DigiTwin Architecture & Code Guidelines

This repository follows a structured, layered, and feature-based architecture to build the Flutter client for DigiTwin. This document outlines the architectural patterns, state management approach, coding standards, and project organization conventions used across the codebase.

---

## 1. Folder Structure Philosophy

Our app employs a **Feature-Based Folder Structure** with foundational core and shared layers. You can find the source code primarily in the `lib` directory:

```text
lib/
├── core/             # App-wide constants, utilities, themes, and global services
│   ├── constants/    # Fixed variables, route tags, and string literals
│   ├── services/     # Services shared globally (e.g., LocationService, ProfileService)
│   ├── theme/        # Centralized theme config
│   └── utils/        # Pure static utility/helper functions
├── features/         # Subdivided by domain logic/feature
│   ├── ar_view/
│   ├── daily_log/
│   ├── home/
│   ├── instructions/
│   └── onboarding/
└── shared/           # Cross-feature uncoupled elements
    ├── dialogs/      # Application-wide reusable dialogs
    └── widgets/      # Stateless reusable UI elements
```

**Inside each `feature`**, we maintain cohesive subdirectories:
- `models/`: Data representations.
- `screens/`: Complex page-level structural UI pieces.
- `services/`: Specific business logic or external communication for this feature.
- `widgets/`: Feature-local reusable view components.

## 2. Naming Conventions

We strictly adhere to standard Dart & Flutter naming conventions:

- **Files / Directories:** `snake_case` (e.g., `growth_parameters_section.dart`, `ar_view_page.dart`).
- **Classes, Enums, Typedefs:** `PascalCase` (e.g., `HomeScreen`, `DayData`, `AppTheme`).
- **Widgets:** Named with intuitive `PascalCase` appending context where useful (`NoVisualInfoWidget`, `DailyCheckModal`).
- **Services:** `PascalCase` ending with `Service` (e.g., `ProfileService`, `HomeService`, `DailyLogService`).
- **Variables / Methods:** `camelCase` (e.g., `_loadDayData()`, `plantationDate`).
- **Constants:** `SCREAMING_SNAKE_CASE` or `UpperCamelCase` (e.g., `AppConstants.PREF_FARMER_NAME`).

## 3. Separation of Concerns

Logic and presentation are strongly decoupled:

- **Screens (`features/*/screens/`):** Responsible for scaffolding UI, laying out pages, and orchestrating interactions. Screens will rarely have deep business logic. Instead, they interact with Services.
- **Widgets (`features/*/widgets/` & `shared/widgets/`):** Purely presentational (often stateless) elements that accept necessary callbacks and data explicitly.
- **Services (`features/*/services/` & `core/services/`):** Domain logic, HTTP communication, database handling, and business rule orchestration (e.g., `HomeService`, `ProfileService`).
- **Models (`features/*/models/`):** Blueprint mapping raw API data or bundled strings to structured, strictly typed Dart objects (e.g., `DayData.fromRawText(text)`).

## 4. State Management Approach

The project relies on Flutter's native declarative state management.

- **`setState()` via StatefulWidgets:** Currently, state propagation across widget boundaries happens implicitly via native state properties updated with `setState()`.
- Top-level variables and loading states inside Stateful Screens respond sequentially to async futures initiated during `initState()`.
- Data flows top-down, passing state properties to local View components and using callback signatures flowing bottom-up for mutations.
- Persisted basic application facts (like checkmarks or daily constraints) are managed with `SharedPreferences` acting as a localized state tracker.

## 5. Supabase Integration

We utilize the `supabase_flutter` package to interact with our backend. 

- **Initialization:** Supabase initializes immediately in `main.dart` with environment keys.
- **Usage:** Instances query the active client globally through `Supabase.instance.client` inside Service classes (never directly inside the UI).
- **Authentication & Databases:** Services directly hit the necessary tables (e.g., fetching rows from `'profiles'` matching `'id'` constraint to `Supabase.instance.client.auth.currentUser!.id`).

## 6. Shared/Reusable Component Patterns

Design consistency and DRY compliance are maintained using the `shared` layer:
- **`shared/widgets/`:** Pure UI elements utilized in multiple screens. Example: The `FullscreenImageGallery` or `NoVisualInfoWidget` fallback that are called iteratively whenever a screen renders invalid media data.
- **`shared/dialogs/`:** Globally branded modular popups, such as the `CustomCalendarDialog`. 

## 7. Utility and Helper Patterns

The `core/utils/` directory stores logic lacking side-effects.
- Formatted as `static` classes using `private` constructors to discourage instantiation (e.g., `class DayUtils { DayUtils._(); static int calculateTodayDay(...) }`).
- Acts to perform pure date parsing, string concatenation, URL building, and arithmetic independent of context/side-states.

## 8. Theme and Design System Implementation

The UI styling is structurally centralized to guarantee a cohesive feel.
- Defined in `lib/core/theme/app_theme.dart`.
- Defines static palette definitions (`background` = `0xFFFFFDF1`, `primaryOrange` = `0xFFFF9644`, `peach` = `0xFFFFCE99`, `darkBrown` = `0xFF562F00`).
- Generates the singular `ThemeData(colorScheme: ..., textTheme: ...)` instance passed tightly to `MaterialApp` in `main.dart`.
- Screens consume styles via `Theme.of(context)` or directly map from `AppColors.primaryOrange` as needed avoiding hardcoded color hashes elsewhere.

## 9. Error Handling Strategy

Asynchronous Service methods favor protective try-catch boundaries to prevent crash conditions propagating to UI layers.
- API operations default toward gracefulness by returning valid fallbacks if an error resolves (e.g., `return DayData.fallback()` if root-bundle lookup fails).
- `catch (e)` blocks explicitly intercept exceptions (typically Dio HTTP errors or IO Exceptions).
- Errors trigger booleans (e.g., returning `false`) which the calling Screen interprets into simple message `SnackBars`, hiding ugly stack traces from clients.

## 10. Dependency Injection Strategy

We intentionally keep DI logic straightforward using **Native Dart Features** over heavy generic packages (like `get_it` or `provider`).
- Built via Singleton Patterns constructed explicitly with `._()` instances (`static const ProfileService instance = ProfileService._();`).
- Object instances are manually instantiated inside complex container abstractions (`final _homeService = HomeService();` inside the `_HomeScreenState`). This keeps the component lifecycle intuitively tied to the flutter tree.
