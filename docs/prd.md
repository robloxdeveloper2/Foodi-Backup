# Foodi Product Requirements Document (PRD)

## Goal, Objective and Context

Foodi aims to simplify everyday food decisions by providing intelligent, intuitive, AI-driven technologies. The primary objective is to offer tailored solutions for meal planning, grocery tracking, nutritional goal tracking, and cooking instruction, all within a user's set budget. The application addresses five key pillars of food decision-making: Cost, Nutrition, Preparation, Preferences, and Aptitude, aiming to be a comprehensive solution in a fragmented market.

The context for this product stems from the challenges individuals face in making food decisions due to factors like affordability, time constraints, lack of cooking skills, dietary restrictions, and the desire for better nutrition. Foodi seeks to overcome these hurdles by leveraging generative AI to provide personalized and holistic support.

## Functional Requirements (MVP)

The MVP of Foodi should include functionalities that support the five pillars: Cost, Nutrition, Preparation, Preferences, and Aptitude.

Here's the revised list of MVP functional requirements:

1.  **User Onboarding & Profile Creation**:

      * Allow users to create an account (e.g., email/password, social login).
      * Collect initial demographic data, dietary restrictions, budget information, cooking experience level, and nutritional goals during onboarding.
      * Enable manual refinement of user profile targets and preferences post-onboarding.

2.  **Personalized Meal Planning**:

      * Generate comprehensive meal plans based on user budget, dietary restrictions, nutritional goals, and preferences.
      * Allow users to specify a budget for their eating plans.
      * Provide AI-powered meal recommendations through a "Tinder-like" swiping system for preferences.

3.  **Grocery & Cost Management**:

      * Generate grocery lists based on meal plans.
      * Track grocery prices and allow users to see the cost of their meal plans.

4.  **Nutrition Tracking & Goals**:

      * Enable users to set personalized nutrition plans (e.g., weight gain, loss, muscle building).
      * Implement AI-powered photo calorie/macronutrient tracking.

5.  **Recipe Management & Cooking Assistance**:

      * Provide a catalog of recipes.
      * Generate weekly meal plans with associated grocery lists and cost analysis.
      * Allow users to store their personal recipes.
      * Offer basic cooking instructions and food tutorials.

## Non Functional Requirements (MVP)

1.  **Performance**:
      * **Responsiveness**: The application should load quickly and respond to user interactions within acceptable times (e.g., UI elements respond within 100ms, API calls complete within 500ms).
      * **Meal Plan Generation**: AI-driven meal plan generation should complete within a reasonable timeframe (e.g., under 5 seconds) to provide a fluid user experience.
      * **Photo Analysis**: AI-powered photo calorie/macronutrient tracking should process images and return results efficiently (e.g., under 3 seconds).
2.  **Scalability**:
      * The backend system should be able to support a growing number of concurrent users without significant degradation in performance.
      * The architecture should be designed to handle potential increases in data volume (recipes, user profiles, tracking data).
3.  **Security**:
      * User data (e.g., personal information, dietary preferences, nutritional goals, budget) must be protected with appropriate encryption and access controls.
      * User authentication processes should be secure.
      * The application should be resilient to common web and mobile security vulnerabilities.
4.  **Usability**:
      * The user interface should be intuitive and easy to navigate for users of varying technical aptitudes.
      * Onboarding flows should be clear and guide users effectively through initial setup and preference collection.
      * Error messages should be clear and helpful.
5.  **Reliability & Availability**:
      * The application should be available 24/7 with minimal downtime (e.g., 99.5% uptime).
      * Data persistence should be robust, ensuring no loss of user-generated data.
6.  **Maintainability**:
      * The codebase should be well-structured, documented, and easy for developers to understand and modify.
      * Dependencies should be managed effectively to facilitate updates and upgrades.
7.  **Compatibility**:
      * The Flutter frontend should support recent versions of iOS and Android mobile operating systems, as well as modern web browsers (Chrome, Firefox, Safari, Edge).
      * The Python Flask backend should be compatible with standard deployment environments.

## User Interaction and Design Goals

  * **Overall Vision & Experience**: The desired experience is **intuitive, personalized, and engaging**, making complex food decisions simple and enjoyable for the user. The look and feel should be **clean, modern, and inviting**, promoting ease of use and a positive interaction with food and nutrition.
  * **Key Interaction Paradigms**:
      * **Personalized Meal Planning**: A "Tinder-like" swiping system for meal recommendations will be a core interaction for preference collection.
      * **Data Input**: Streamlined processes for inputting dietary restrictions, budget, and nutritional goals during onboarding and ongoing use.
      * **Recipe & Tutorial Browse**: Clear, easy-to-navigate interfaces for exploring recipes and accessing cooking instructions and tutorials.
      * **Photo-based Tracking**: An intuitive flow for AI-powered photo calorie/macronutrient tracking.
  * **Core Screens/Views (Conceptual)**:
      * Login/Onboarding Screens
      * User Profile/Settings Screen (for preferences, goals, and budget refinement)
      * Personalized Meal Plan Dashboard/View
      * Grocery List Screen
      * Nutrition Tracking Dashboard
      * Recipe Catalog/Detail Pages
      * Cooking Tutorial/Course Pages
  * **Accessibility Aspirations**: The application should strive for basic accessibility, ensuring usability for users with common visual or motor impairments.
  * **Branding Considerations (High-Level)**: The branding should convey simplicity, health, and intelligence, aligning with the mission to simplify food decisions.
  * **Target Devices/Platforms**:
      * **Mobile-first**: Primary target will be mobile devices (iOS and Android) using Flutter.
      * **Web**: A responsive web application accessible via modern web browsers (Chrome, Firefox, Safari, Edge) using Flutter for web.

## Technical Assumptions

  - **Backend Language/Framework**: Python with Flask will be used for the backend.
  - **Frontend Language/Framework**: Flutter will be used for the frontend, serving both mobile (iOS and Android) and web platforms.
  - **Repository & Service Architecture**: At this initial stage, we will assume a **Polyrepo** structure. This means the Flutter frontend and Python Flask backend will reside in separate repositories. The rationale is to allow independent development and deployment lifecycles for the mobile/web client and the API services, which can simplify team workflows and technology-specific tooling initially.
  - **Database**: We will utilize both **PostgreSQL** for relational data (e.g., user profiles, meal plans, structured recipe data) and **MongoDB** for flexible, unstructured data (e.g., user preferences, AI-generated content, potentially cached food price data). This hybrid approach allows us to leverage the strengths of both database types.
  - **Key Libraries/Services (Backend)**:
      * **Authentication**: Flask-JWT-Extended for token-based authentication.
      * **ORM**: SQLAlchemy with Flask-SQLAlchemy for interacting with PostgreSQL.
      * **NoSQL Driver**: PyMongo for interacting with MongoDB.
      * **API Framework**: Flask-RESTful for building RESTful APIs.
      * **AI Integration**: Python libraries like TensorFlow/PyTorch or scikit-learn for the AI-powered features, depending on the specific model chosen for calorie/macronutrient tracking and meal recommendations.
  - **Key Libraries/Services (Frontend)**:
      * **State Management**: Provider or Riverpod for robust state management.
      * **Networking**: Dio or http package for API communication.
      * **UI Components**: Material Design widgets (default Flutter) for a consistent and modern UI.
      * **Image Picking/Processing**: image\_picker and image library for photo analysis features.
  - **Deployment Platform/Environment**: For the MVP, we will initially target **Google Cloud Platform (GCP)**.
      * Backend: Flask applications can be deployed using Cloud Run (serverless containers) for scalability and ease of deployment.
      * Frontend: Flutter web can be hosted on Firebase Hosting, and Flutter mobile apps can be deployed to Google Play Store and Apple App Store.
  - **Version Control System**: Git will be used, with **GitHub** for repository hosting and collaborative development.

## Testing requirements

To ensure the quality and stability of the Foodi MVP, we will implement the following testing approaches:

1.  **Unit Testing**:
      * Developers will write unit tests for individual functions, methods, and components in both the Flutter frontend and Python Flask backend to ensure they work as expected in isolation.
      * This will cover core business logic, utility functions, and data transformations.
2.  **Integration Testing**:
      * We will conduct integration tests to verify that different modules and services interact correctly. This includes testing the communication between the Flutter frontend and the Flask backend APIs, as well as interactions with the PostgreSQL and MongoDB databases.
      * Focus areas will include user authentication flows, meal plan generation, grocery list creation, and nutrition tracking data persistence.
3.  **End-to-End (E2E) Testing**:
      * E2E tests will simulate real user scenarios to ensure the entire application flow works correctly from start to finish. This will cover key user journeys such as user onboarding, personalized meal plan creation, photo-based food logging, and recipe Browse.
      * These tests will be performed across both mobile (iOS/Android emulators/devices) and web platforms.
4.  **Manual Testing/Exploratory Testing**:
      * Beyond automated tests, a dedicated phase of manual testing will be conducted to uncover usability issues, edge cases, and unexpected behaviors that automated tests might miss.
      * Exploratory testing will be encouraged to allow testers to freely investigate the application.
5.  **Performance Testing**:
      * Initial performance tests will be conducted to validate the non-functional requirements related to responsiveness, meal plan generation time, and photo analysis speed, as outlined in the Non-Functional Requirements section.
      * This will involve load testing on critical API endpoints to assess scalability under anticipated user loads.
6.  **User Acceptance Testing (UAT)**:
      * A small group of target users will be involved in UAT to validate that the MVP meets their needs and expectations from a user perspective. Their feedback will be crucial for iterating on the product post-MVP.

## Epic Overview

Here are the Epics for Foodi's MVP, aligning with the functional requirements:

### Epic 1: User Onboarding & Profile Management

  * **Goal**: Enable users to easily join Foodi and set up their personalized profiles with initial preferences and goals.

#### User Stories:

  * **Story 1.1: Account Creation**:
      * As a new user, I want to create an account with my email and password, or via a social login (e.g., Google, Apple), so that I can access Foodi's features.
      * *Acceptance Criteria*:
          * User can register using email/password.
          * User can register using Google/Apple ID.
          * System securely stores user credentials.
          * User receives a confirmation upon successful registration.
  * **Story 1.2: Initial Profile Setup**:
      * As a new user, I want to provide my demographic data, dietary restrictions (e.g., vegan, gluten-free), budget range, cooking experience level, and nutritional goals (e.g., weight loss, muscle gain) during onboarding, so that Foodi can generate personalized recommendations.
      * *Acceptance Criteria*:
          * Onboarding flow clearly prompts for required information.
          * User can select multiple dietary restrictions.
          * User can define a budget range.
          * User can select cooking experience level (e.g., beginner, intermediate, advanced).
          * User can select primary nutritional goals.
          * All entered data is saved to the user's profile.
  * **Story 1.3: Profile Refinement**:
      * As a registered user, I want to be able to access and refine my profile details, including dietary restrictions, budget, cooking experience, and nutritional goals, so that I can update my personalized Foodi experience at any time.
      * *Acceptance Criteria*:
          * User can navigate to a profile settings screen.
          * User can edit all initial profile setup information.
          * Changes are saved and reflected in recommendations.

### Epic 2: Personalized Meal Planning & Recommendation Engine

  * **Goal**: Provide users with AI-driven personalized meal plans and intuitive recommendations based on their profile.

#### User Stories:

  * **Story 2.1: AI-Generated Meal Plan**:
      * As a user, I want Foodi to generate comprehensive daily and weekly meal plans based on my specified budget, dietary restrictions, nutritional goals, and preferences, so that I have a structured eating guide.
      * *Acceptance Criteria*:
          * Meal plan includes breakfast, lunch, dinner, and optional snacks.
          * Meal plan adheres to specified budget (e.g., total cost within X% of budget).
          * Meal plan respects all selected dietary restrictions.
          * Meal plan considers primary nutritional goals.
          * Generated meal plan is dynamic and adjustable.
  * **Story 2.2: Meal Recommendation Swiping**:
      * As a user, I want to use a "Tinder-like" swiping interface to indicate my preferences for individual meal suggestions, so that the AI can learn my tastes and improve future recommendations.
      * *Acceptance Criteria*:
          * User can swipe left (dislike) or right (like) on meal cards.
          * Swiping actions inform the recommendation algorithm.
          * User sees a continuous stream of meal suggestions.

### Epic 3: Grocery & Cost Management

  * **Goal**: Help users manage their grocery shopping efficiently and stay within their food budget.

#### User Stories:

  * **Story 3.1: Automatic Grocery List Generation**:
      * As a user, I want Foodi to automatically generate a consolidated grocery list from my selected meal plan, so that I can easily prepare for shopping.
      * *Acceptance Criteria*:
          * Grocery list aggregates ingredients from all meals in the plan.
          * Quantities are calculated based on recipes and servings.
          * List is organized (e.g., by grocery aisle/category).
  * **Story 3.2: Meal Plan Cost Estimation**:
      * As a user, I want to see an estimated cost for my generated meal plan and individual recipes, so that I can manage my budget effectively.
      * *Acceptance Criteria*:
          * Each meal plan displays a total estimated cost.
          * Individual recipes show estimated ingredient costs.
          * Cost calculations are reasonably accurate based on available data (initial dummy data).

### Epic 4: Nutrition Tracking & Goal Attainment

  * **Goal**: Enable users to track their nutritional intake and progress towards their health goals.

#### User Stories:

  * **Story 4.1: AI Photo Calorie/Macronutrient Tracking**:
      * As a user, I want to be able to take a photo of my meal and have Foodi's AI automatically identify the food and estimate its calories and macronutrients (protein, carbs, fat), so that I can easily log my intake.
      * *Acceptance Criteria*:
          * User can upload or take a photo of food.
          * AI identifies common food items with reasonable accuracy.
          * AI provides estimated calorie, protein, carb, and fat content.
          * Logged food is added to daily nutrition summary.
  * **Story 4.2: Daily Nutrition Summary**:
      * As a user, I want to view a daily summary of my calorie and macronutrient intake, alongside my personalized goals, so that I can monitor my progress.
      * *Acceptance Criteria*:
          * Dashboard displays current day's total calories, protein, carbs, and fat.
          * Goals for each metric are clearly visible.
          * Visual indicators show progress towards goals.

### Epic 5: Recipe Management & Cooking Assistance

  * **Goal**: Provide users with a diverse recipe catalog and tools to simplify cooking.

#### User Stories:

  * **Story 5.1: Recipe Catalog Browse**:
      * As a user, I want to browse a catalog of recipes, filterable by dietary restrictions, meal type, and cuisine, so that I can discover new dishes.
      * *Acceptance Criteria*:
          * User can search and filter recipes.
          * Recipe cards display key information (e.g., name, prep time, estimated cost, dietary tags).
          * Clicking a recipe card shows detailed view.
  * **Story 5.2: Recipe Details & Instructions**:
      * As a user, when I select a recipe, I want to view its full ingredients list, step-by-step cooking instructions, estimated preparation time, and nutritional information, so that I can prepare the dish.
      * *Acceptance Criteria*:
          * Clear, numbered instructions are provided.
          * Ingredient quantities are listed.
          * Prep time and cook time are displayed.
          * Basic nutritional info is present for each recipe.
  * **Story 5.3: Personal Recipe Saving**:
      * As a user, I want to be able to save recipes from the Foodi catalog or add my own personal recipes, so that I can easily access my favorites.
      * *Acceptance Criteria*:
          * User can "favorite" or "save" existing Foodi recipes.
          * User can input and save new custom recipes (ingredients, instructions).
          * Saved recipes are accessible from a dedicated "My Recipes" section.
  * **Story 5.4: Basic Cooking Tutorials**:
      * As a user, I want to access simple, step-by-step food tutorials (e.g., how to chop an onion, basic sautéing) within the app, so that I can improve my cooking aptitude.
      * *Acceptance Criteria*:
          * A dedicated section for tutorials exists.
          * Tutorials provide clear, concise instructions (text/images/short videos).
          * Tutorials cover fundamental cooking techniques.

## Key Reference Documents

This section will contain links to important related documents as they are created:

  * [Foodi Architecture Document](https://www.google.com/search?q=link-to-architecture-doc-once-created) (To be created by the Architect based on this PRD)
  * [Foodi Frontend Architecture Document](https://www.google.com/search?q=link-to-frontend-architecture-doc-once-created) (To be created by the Architect/Frontend Architect)
  * [Foodi UX/UI Specification](https://www.google.com/search?q=link-to-uxui-spec-once-created) (To be created by the Design Architect)

## Out of Scope Ideas Post MVP

To maintain focus on the core MVP value proposition and achieve timely delivery, the following features and ideas are explicitly considered out of scope for the initial release and will be prioritized for future iterations:

  * **Monetization Features**:
      * Tiered subscription model (Basic and Pro)
      * Free trial periods
      * Partnerships with food influencers for paid microtransaction packages
      * Advanced payment methods integration beyond core App Store/Play Store/Stripe.
  * **Advanced Social Features**:
      * User-to-user sharing of meal plans or recipes.
      * Community forums or in-app messaging.
  * **Enhanced AI/Personalization beyond MVP**:
      * Real-time dynamic price tracking across multiple grocery stores.
      * Predictive analytics for future food preferences or health outcomes.
      * Integration with smart kitchen appliances.
  * **Expanded Content/Integrations**:
      * Professional chef sponsored cooking courses
      * Direct integration with third-party delivery services or meal kit providers.
      * Extensive worldwide recipe database beyond initial curated selection.
  * **Gamification**:
      * Badges, leaderboards, or challenge systems for nutrition or cooking achievements.
  * **Advanced Reporting**:
      * Detailed historical trend analysis for nutrition or spending beyond simple daily summaries.

## Change Log

| Version | Date         | Author       | Description                                  |
| :------ | :----------- | :----------- | :------------------------------------------- |
| 0.1     | 2025-05-27   | John (PM AI) | Initial draft based on Business Plan & user input. |
| 0.2     | 2025-05-27   | John (PM AI) | Removed Subscription/Monetization from MVP. |

```
```