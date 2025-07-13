# **Foodi Frontend Architecture Document**

## **Introduction**

This document defines the architectural guidelines and technical specifications for the Foodi application's user interface, developed using Flutter. It details the overall frontend philosophy, project structure, component design, state management, API interaction, routing, build process, and testing strategy. This document should be used in conjunction with the main Foodi Architecture Document.

## **Overall Frontend Philosophy & Patterns**

* **Declarative UI:** Embrace Flutter's declarative UI paradigm, focusing on describing the UI for a given state.  
* **Component-Based Architecture:** Promote the creation of reusable, composable, and self-contained widgets.  
* **Unidirectional Data Flow:** State changes will flow in a single direction, enhancing predictability and debugging.  
* **Separation of Concerns:** Clearly separate UI (widgets), business logic (state management), and data fetching (API services).  
* **Mobile-First, Responsive Design:** Design and develop for smaller screens first, then progressively enhance for tablets and web, ensuring a consistent and adaptable user experience across various devices.  
* **Fitting Design** This is a lifestyle, food health app so the design should reflect it.
* **Performance-Oriented:** Prioritize smooth animations, fast load times, and efficient rendering through Flutter's capabilities and best practices.  
* **Offline-First (Consideration for Future):** While not MVP, design choices will accommodate future offline capabilities and local data persistence.

## **Detailed Frontend Directory Structure**

The Flutter frontend application will reside in its own Git repository, separate from the backend.

Plaintext  
{frontend-repo-root}/  
├── .github/                     \# CI/CD workflows (e.g., GitHub Actions for Flutter build/deploy)  
│   └── workflows/  
│       └── main.yml  
├── lib/                         \# Application source code  
│   ├── api/                     \# API client definitions, DTOs, service calls to backend  
│   │   └── models/              \# Data Transfer Objects (DTOs) for API requests/responses  
│   │   └── foodi\_api\_client.dart \# Main API client to interact with Flask backend  
│   ├── core/                    \# Core application logic, utilities, constants, domain models  
│   │   ├── constants/           \# Global constants (e.g., API URLs, app names)  
│   │   ├── errors/              \# Custom exception classes  
│   │   ├── utils/               \# Helper functions  
│   │   └── models/              \# Core domain models (e.g., User, Recipe, MealPlan)  
│   ├── data/                    \# Data sources/repositories (e.g., local storage, preferences)  
│   │   └── local\_storage\_service.dart  
│   ├── features/                \# Feature-based organization (modular approach)  
│   │   ├── authentication/      \# User login, registration, logout  
│   │   │   ├── presentation/    \# Widgets, UI, views related to auth  
│   │   │   │   ├── widgets/  
│   │   │   │   └── screens/  
│   │   │   ├── domain/          \# Models, repositories interfaces for auth  
│   │   │   └── data/            \# Implementations of auth repositories, data sources  
│   │   ├── meal\_planning/       \# Meal plan generation, viewing  
│   │   │   ├── presentation/  
│   │   │   ├── domain/  
│   │   │   └── data/  
│   │   ├── recipe\_management/   \# Recipe search, details  
│   │   │   ├── presentation/  
│   │   │   ├── domain/  
│   │   │   └── data/  
│   │   ├── user\_profile/        \# User profile management  
│   │   │   ├── presentation/  
│   │   │   ├── domain/  
│   │   │   └── data/  
│   │   └── shared/              \# Widgets/logic reusable across features (e.g., common buttons)  
│   ├── navigation/              \# Routing logic, route definitions  
│   │   └── app\_router.dart  
│   ├── state/                   \# Centralized state management (e.g., Providers)  
│   │   ├── auth\_state.dart  
│   │   ├── meal\_plan\_state.dart  
│   │   └── providers.dart       \# Central file for defining all providers  
│   ├── theme/                   \# App themes, colors, typography  
│   │   ├── app\_colors.dart  
│   │   └── app\_theme.dart  
│   └── main.dart                \# Main application entry point  
├── test/                        \# Automated tests  
│   ├── unit/                    \# Unit tests (e.g., pure functions, models)  
│   ├── widget/                  \# Widget tests (UI components in isolation)  
│   └── integration/             \# Integration tests (full feature flows, API mocks)  
├── assets/                      \# Static assets (images, fonts, icons)  
│   ├── images/  
│   └── fonts/  
├── pubspec.yaml                 \# Dart/Flutter project dependencies and metadata  
├── pubspec.lock                 \# Auto-generated dependency lock file  
├── README.md                    \# Project overview and setup instructions  
├── analysis\_options.yaml        \# Dart static analysis rules  
└── Dockerfile                   \# Docker build instructions (if containerizing for web deployment)

## **Component Breakdown & Implementation Details**

* **Atomic Design Principles (Optional):** Consider applying Atomic Design principles (Atoms, Molecules, Organisms, Templates, Pages) to structure widgets from smallest reusable units to full page layouts.  
* **Stateless vs. Stateful Widgets:**  
  * Prefer StatelessWidget whenever possible for simple UI presentation that doesn't change over time or only responds to external state changes.  
  * Use StatefulWidget only when a widget needs to manage its own internal mutable state (e.g., form input fields, animation controllers). Avoid overusing StatefulWidget and push state management to a dedicated solution.  
* **Widget Tree Composition:** Break down complex UIs into smaller, focused widgets to improve readability, reusability, and testability.  
* **Separation of Concerns within Widgets:**  
  * **Presentation Layer:** Widgets (.dart files under presentation/) should primarily focus on rendering UI based on the state they receive. They should trigger actions (e.g., via Provider or Riverpod consumers/watchers) but not contain complex business logic or directly perform API calls.  
  * **Domain Layer:** Contains pure Dart models and interfaces that represent the business entities and rules.  
  * **Data Layer:** Handles data fetching and persistence, abstracting away the source (API, local storage).  
* **Accessibility:** Utilize Flutter's built-in accessibility features (e.g., Semantics, ExcludeSemantics when appropriate, TextScaler, AccessibleNavigation).

### **Component Naming & Organization**

* **Feature-Based Organization:** Components will be primarily organized by feature (features/authentication/, features/meal\_planning/), promoting modularity.  
* **Widget Suffixes:**  
  * \_screen.dart: Full-page layouts.  
  * \_view.dart: A significant section of a screen that might have its own state.  
  * \_card.dart, \_button.dart, \_input\_field.dart: Reusable UI elements (often in shared/widgets/).  
* **Naming Convention:** snake\_case for filenames, PascalCase for classes.

### **Template for Component Specification**

Markdown  
\#\#\# Component Name: {ComponentName}

\-   \*\*Purpose:\*\* {Brief description of the component's function and responsibility.}  
\-   \*\*Location:\*\* \`lib/features/{feature\_name}/presentation/widgets/{component\_name}.dart\` (or \`screens/\`, \`shared/\`)  
\-   \*\*Inputs (Props):\*\*  
    \-   \`propName: type\` \- {Description of purpose, required/optional}  
\-   \*\*Outputs (Callbacks):\*\*  
    \-   \`onEventName: Function(param1, param2)\` \- {Description of when this callback is triggered and what data it provides.}  
\-   \*\*State Management:\*\* {How does this component interact with the state management solution? e.g., "Consumes \`AuthState\` from Provider," "Manages internal \`TextEditingController\` state."}  
\-   \*\*Dependencies:\*\* {Other components or services it relies on.}  
\-   \*\*Usage Example (Dart):\*\*  
    \`\`\`dart  
    // Example usage in parent widget  
    @override  
    Widget build(BuildContext context) {  
      return ComponentName(  
        propName: someValue,  
        onEventName: (param1, param2) {  
          // Handle event  
        },  
      );  
    }  
    \`\`\`  
\-   \*\*Accessibility Considerations:\*\* {Specific accessibility features, e.g., semantic labels, keyboard navigation, contrast.}  
\-   \*\*Responsiveness Notes:\*\* {How the component adapts to different screen sizes.}

## **State Management In-Depth**

* **Solution:** Riverpod (a compile-time safe Provider) for robust and scalable state management.  
* **Philosophy:** Maintain a clear separation between UI, business logic, and data. State is managed centrally and exposed to widgets via providers.  
* **Types of State:**  
  * **Application State:** Global state accessible throughout the app (e.g., authentication status, user profile, theme settings). Managed by top-level providers.  
  * **Feature State:** State specific to a particular feature (e.g., current meal plan, search results). Managed by feature-specific providers.  
  * **Widget State:** Local state managed by StatefulWidget for temporary UI interactions (e.g., form input controllers, animation states).

### **Store Structure / Slices**

* **lib/state/providers.dart:** Central file to define all Provider instances.  
* **Feature-Specific State Files:**  
  * lib/state/auth\_state.dart: Defines AuthState (e.g., AsyncNotifier or Notifier for user authentication, login/logout logic, token management).  
  * lib/state/meal\_plan\_state.dart: Defines MealPlanState (e.g., managing the current meal plan, generation status, user preferences for planning).  
  * lib/state/{feature}\_state.dart: For other features, containing relevant business logic and state.  
* **AsyncValue for Async Operations:** Use AsyncValue (from Riverpod) to represent the state of asynchronous operations, clearly handling loading, data, and error states in a unified way.

### **Key Selectors**

* **Purpose:** Riverpod's watch and select methods serve as "selectors" to efficiently listen to specific parts of the state and rebuild only relevant widgets.  
* **Usage:**  
  * ref.watch(someProvider): Listen to the entire provider's state.  
  * ref.watch(someProvider.select((state) \=\> state.someProperty)): Optimize rebuilds by only listening to changes in someProperty.

### **Key Actions / Reducers / Thunks**

* **Notifier/AsyncNotifier:** Riverpod's Notifier and AsyncNotifier classes will encapsulate the business logic and state mutations.  
* **Actions/Methods:** Public methods within Notifier classes will represent "actions" that trigger state changes (e.g., loginUser(), generateMealPlan(), updateProfile()).  
* **Side Effects:** Asynchronous operations (API calls, database interactions) will be handled within AsyncNotifier methods, using AsyncValue to manage loading and error states. These methods will update the state directly upon completion.

## **API Interaction Layer**

* **Client/Service Structure:**

  * **lib/api/models/:** Contains Dart models (DTOs) that mirror the backend API request and response structures, often generated using json\_serializable to facilitate JSON parsing.  
  * **lib/api/foodi\_api\_client.dart:** A central API client (e.g., using http package or dio) that handles:  
    * Base URL configuration.  
    * Adding authentication headers (JWT token).  
    * Serialization/deserialization of requests/responses.  
    * Basic error handling for network/HTTP errors.  
  * **lib/data/{feature}\_repository.dart:** Feature-specific repositories (e.g., AuthRepository, MealPlanRepository) that abstract the API calls. These repositories will use the FoodiApiClient and transform raw API responses into domain-level models before passing them to the state management layer.  
* **Error Handling & Retries (Frontend):**

  * The FoodiApiClient will catch network-level errors and HTTP status codes (e.g., 401 Unauthorized, 500 Internal Server Error).  
  * Common error types (e.g., NetworkError, UnauthorizedError, ServerError) will be defined in lib/core/errors/.  
  * The AuthRepository will handle UnauthorizedError specifically, potentially triggering a logout or token refresh flow.  
  * Retries with exponential backoff will be considered for idempotent API calls encountering transient network errors, if required by NFRs (not initially for MVP).  
  * User-friendly error messages will be displayed via UI feedback mechanisms (e.g., snackbars, dialogs) based on the translated error types.

## **Routing Strategy**

* **Solution:** GoRouter for declarative, deep-linkable routing.  
* **Philosophy:** Centralize route definitions, making navigation predictable and testable. Support deep linking for consistent user experience.  
* **Route Definitions:**  
  * **lib/navigation/app\_router.dart:** Defines all application routes using GoRouter.  
  * Named routes will be used for clarity and ease of navigation (e.g., '/login', '/home', '/meal-plan-details/:id').  
* **Route Guards / Protection:**  
  * GoRouter's redirect mechanism will be used to implement route guards.  
  * **Authentication Guard:** Prevent unauthenticated users from accessing protected routes. If a protected route is accessed without authentication, redirect to the login screen.  
  * **Role-Based Guard (Future):** If user roles are introduced, redirect based on user permissions.  
  * **Initial Redirects:** Handle initial routing based on authentication status (e.g., if already logged in, go to home; otherwise, go to login/onboarding).

## **Build, Bundling, and Deployment**

* **Build Process & Scripts:**  
  * **Local Development:** flutter run for hot reload and quick iteration.  
  * **Build for Release:** flutter build apk (Android), flutter build ios (iOS), flutter build web (Web).  
  * **CI/CD:** GitHub Actions workflows (.github/workflows/main.yml) will automate build processes.  
* **Key Bundling Optimizations:**  
  * **Tree Shaking:** Flutter automatically performs tree shaking, removing unused code.  
  * **DCE (Dead Code Elimination):** Dart's dart2js compiler performs DCE for web builds.  
  * **Image Optimization:** Compress and optimize images (PNG, JPEG) for smaller file sizes. Use appropriate image formats (e.g., WebP for web).  
  * **Font Subseting:** Only include necessary font glyphs to reduce font file size.  
  * **Obfuscation/Minification:** Applied automatically by Flutter release builds for improved security and smaller size.  
* **Deployment to CDN/Hosting:**  
  * **Mobile Apps:** Deploy to Google Play Store and Apple App Store.  
  * **Web App:** Host static web files (generated by flutter build web) on Google Cloud Storage with Cloud CDN for low-latency delivery. Configure Firebase Hosting or a custom domain.

## **Frontend Testing Strategy**

* **Frameworks:** Flutter's built-in testing utilities (flutter\_test, test).  
* **Unit Tests:**  
  * **Scope:** Test pure functions, domain models, utility classes, and business logic independent of UI.  
  * **Location:** test/unit/  
  * **Mocking:** Use mockito for mocking dependencies.  
* **Widget Tests:**  
  * **Scope:** Test individual UI widgets in isolation, ensuring they render correctly, respond to input, and update state as expected.  
  * **Location:** test/widget/  
  * **Tools:** WidgetTester provided by flutter\_test.  
* **Integration Tests:**  
  * **Scope:** Test interactions between multiple widgets, feature flows, and API integration (with mocked API responses).  
  * **Location:** test/integration/  
  * **Tools:** integration\_test package. Run on a real device or emulator.  
* **Test Coverage:** Aim for high test coverage, particularly for core logic and critical UI components.  
* **Testing Environment:**  
  * Run tests in a local development environment.  
  * Automate tests in CI/CD pipelines (GitHub Actions).

## **Browser / Device Support Matrix**

* **Mobile (Android & iOS):**  
  * Android: Latest 3 major versions.  
  * iOS: Latest 3 major versions.  
* **Web (Desktop & Mobile Browser):**  
  * Desktop: Chrome (latest), Firefox (latest), Safari (latest), Edge (latest).  
  * Mobile Browsers: Chrome (latest on Android), Safari (latest on iOS).  
* **Minimum Screen Resolutions:**  
  * Mobile: 360x640 logical pixels (smallest common phone size).  
  * Tablet: 600x960 logical pixels.  
  * Desktop: 1280x800 logical pixels.  
* **Operating System Support:** Android, iOS, Web (via standard web browsers).  
* **Hardware Requirements:** Standard smartphone/tablet/desktop hardware capable of running modern Flutter apps.

### **Progressive Enhancement & Fallbacks (for Web, if applicable)**

* **JavaScript Requirement & Progressive Enhancement:**  
  * Baseline: Core application functionality REQUIRES JavaScript enabled in the browser.  
  * No-JS Experience: Not applicable for a Flutter web application; Flutter heavily relies on JavaScript for rendering and interactivity. Users without JavaScript enabled will not be able to run the application.  
* **CSS Compatibility & Fallbacks:** Flutter compiles Dart to HTML/CSS/JS, largely abstracting away direct CSS compatibility concerns. The Flutter engine handles cross-browser rendering consistently.  
* **Accessibility Fallbacks:** Flutter includes robust accessibility APIs. Ensure Semantics widgets are used correctly to provide meaningful descriptions for assistive technologies.

