# Epic 2: Personalized Meal Planning & Recommendation Engine (Algorithmic Prototype)

## Epic Goal
Provide users with algorithmically-driven personalized meal plans and recommendations based on their profile, using rule-based systems to deliver tailored eating guidance that respects budget, dietary restrictions, and nutritional goals. This epic includes the core meal planning functionality and associated grocery list management.

## Epic Dependencies
- ✅ Epic 1: User Onboarding & Profile Management (COMPLETED)
- User profile data must be accessible via the existing user management system
- Core recipe database needs to be seeded with initial recipe data

## Epic Technical Context
This epic will implement algorithmic meal planning functionality using:
- **Backend**: Flask API endpoints with rule-based meal planning algorithms
- **Frontend**: Flutter screens for meal plan display, swiping interface, and grocery management
- **Data Storage**: PostgreSQL for meal plans, recipes, and grocery lists; MongoDB for user preferences
- **Algorithm**: Deterministic matching based on user constraints and scoring systems

## User Stories in this Epic
- **Story 2.1**: Algorithm-Based Meal Plan Generation (8 pts)
- **Story 2.2**: Meal Recommendation Swiping & Preference Learning (8 pts)
- **Story 2.3**: Smart Meal Plan Display and Nutritional Tracking (6 pts)
- **Story 2.4**: Intelligent Meal Substitution System (7 pts)
- **Story 2.5**: Automatic Grocery List Generation (6 pts)

**Total Story Points: 35**

## Algorithm Design Summary

### Core Meal Planning Algorithm
```python
def generate_meal_plan(user_profile, duration_days):
    # 1. Calculate daily nutritional targets
    # 2. Filter recipe database by dietary restrictions  
    # 3. Score each recipe using multi-factor algorithm
    # 4. Use constraint satisfaction to select optimal meals
    # 5. Apply variety and balance rules
    # 6. Validate against budget and nutritional goals
```

### Recipe Scoring Formula
```python
score = (nutritional_fit * 0.4) + 
        (cost_efficiency * 0.3) + 
        (user_preference * 0.2) + 
        (variety_bonus * 0.1)
```

### Preference Learning (Swiping + Rating)
```python
# Combines "Tinder-like" swiping with detailed ratings
preference_score = (swipe_feedback * 0.6) + (detailed_ratings * 0.4)
```

## Epic Acceptance Criteria
- [ ] Users can generate personalized meal plans using algorithmic matching
- [ ] "Tinder-like" swiping interface for meal preference collection works smoothly
- [ ] Preference learning system improves recommendations over time
- [ ] Nutritional analysis provides meaningful insights and recommendations
- [ ] Meal substitution system maintains plan integrity while allowing customization
- [ ] Automatic grocery list generation consolidates ingredients correctly
- [ ] All algorithmic systems perform within NFR requirements (<5 seconds for generation)

## Dependencies & Blockers
- **Recipe Database**: Seed data with nutritional information and estimated costs
- **User Profile Data**: Complete user preferences from Epic 1
- **Cost Estimation**: Basic ingredient pricing (can use fixed estimates for prototype)
- **Ingredient Database**: Structured ingredient data for grocery list consolidation

## Testing Strategy
- **Unit Tests**: Algorithmic recommendation logic, meal plan generation algorithms, grocery list consolidation
- **Integration Tests**: API endpoints, database interactions, Flutter-backend communication  
- **Widget Tests**: Swiping interface, meal plan display components, grocery list management
- **E2E Tests**: Complete meal plan generation, preference learning, and grocery list creation flow

## Alignment with PRD
This epic directly implements:
- **PRD Epic 2**: Personalized Meal Planning & Recommendation Engine
  - ✅ Story 2.1: Algorithm-based meal plan generation (was "AI-Generated Meal Plan")
  - ✅ Story 2.2: "Tinder-like" swiping interface for meal recommendations
- **PRD Epic 3**: Grocery & Cost Management (integrated into Epic 2 for logical cohesion)
  - ✅ Story 2.5: Automatic grocery list generation (was Epic 3 Story 3.1)
  - ✅ Cost estimation integrated throughout (was Epic 3 Story 3.2)

## Development Priority
1. **Story 2.1** (Meal Plan Generation) - Foundation functionality
2. **Story 2.3** (Display & Tracking) - User interaction layer  
3. **Story 2.2** (Swiping & Preferences) - Core PRD interaction paradigm
4. **Story 2.5** (Grocery Lists) - Essential utility feature
5. **Story 2.4** (Substitution) - Advanced customization 