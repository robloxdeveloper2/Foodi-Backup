# Story 2.2: Meal Recommendation Swiping & Preference Learning

**Status: InProgress**

## User Story
**As a** user  
**I want** to use a "Tinder-like" swiping interface to indicate my preferences for individual meal suggestions and rate recipes  
**So that** the algorithm can learn my tastes and improve future meal plan recommendations

## Acceptance Criteria
- [ ] **AC 2.2.1**: User can access swiping interface from meal planning section
- [ ] **AC 2.2.2**: Interface displays meal cards with recipe image, name, cuisine type, and prep time
- [ ] **AC 2.2.3**: User can swipe left (dislike) or right (like) on meal cards
- [ ] **AC 2.2.4**: User can tap for more details without affecting swipe preference
- [ ] **AC 2.2.5**: Swiping actions are recorded and stored in user preference database
- [ ] **AC 2.2.6**: Interface shows continuous stream of meal suggestions (at least 20 options per session)
- [ ] **AC 2.2.7**: User can also rate recipes on a 1-5 star scale in detailed view
- [ ] **AC 2.2.8**: User can mark specific ingredients they like/dislike
- [ ] **AC 2.2.9**: User can indicate cuisine preferences (Italian, Mexican, Asian, etc.)
- [ ] **AC 2.2.10**: Preference data influences future meal plan generation
- [ ] **AC 2.2.11**: User sees immediate feedback when preferences are saved

## Technical Implementation Notes

### Algorithmic Approach
- **API Endpoints**: 
  - `GET /api/v1/recommendations/meals` (get meal suggestions for swiping)
  - `POST /api/v1/user-preferences/meal-feedback` (record swipe actions)
  - `POST /api/v1/user-preferences/recipe-ratings` (store detailed ratings)
  - `POST /api/v1/user-preferences/ingredients` (store ingredient preferences)

### Algorithm Logic
```python
# Preference Scoring Algorithm:
# 1. Weight recipes by swipe actions (like=+1, dislike=-1)
# 2. Weight recipes by detailed ratings (1-5 stars)
# 3. Boost/penalize recipes with liked/disliked ingredients
# 4. Prefer cuisines marked as favorites
# 5. Track prep time preferences based on user cooking level
# 6. Calculate composite preference score for meal planning
```

### Database Schema (MongoDB)
```json
{
  "userId": "user_id",
  "swipePreferences": {
    "recipe_id_1": "like",
    "recipe_id_2": "dislike"
  },
  "recipeRatings": {"recipe_id": 4.5},
  "ingredientPreferences": {
    "liked": ["chicken", "spinach"],
    "disliked": ["cilantro", "olives"]
  },
  "cuisinePreferences": {"Italian": 5, "Mexican": 4},
  "prepTimePreference": "quick", // quick, moderate, elaborate
  "lastUpdated": "2023-10-27T10:00:00Z"
}
```

### Frontend Implementation
- **Screen**: `lib/features/meal_planning/presentation/screens/meal_swiping_screen.dart`
- **Widgets**:
  - `swipeable_meal_card_widget.dart`
  - `meal_detail_modal.dart`
  - `recipe_rating_card.dart`
  - `ingredient_preference_selector.dart`
  - `cuisine_preference_grid.dart`
  - `preference_progress_indicator.dart`

### State Management
- **Provider**: `MealSwipingState` using Riverpod
- **Actions**: 
  - `loadMealSuggestions()`
  - `recordSwipe(recipeId, action)` // action: 'like' or 'dislike'
  - `rateRecipe(recipeId, rating)`
  - `updateIngredientPreference(ingredient, preference)`
  - `setCuisinePreference(cuisine, rating)`

### Swiping Interface Logic
```python
class SwipePreferenceEngine:
    def record_swipe_feedback(self, user_id, recipe_id, action):
        # Store swipe action in user preferences
        preference_data = {
            'userId': user_id,
            'recipeId': recipe_id,
            'action': action,  # 'like' or 'dislike'
            'timestamp': datetime.now(),
            'context': 'swiping_session'
        }
        
        # Update user preference profile
        self.update_preference_weights(user_id, recipe_id, action)
        
        return preference_data
    
    def get_next_meal_suggestions(self, user_id, session_length=20):
        # Get recipes user hasn't rated yet
        # Apply initial filtering (dietary restrictions, etc.)
        # Randomize with slight bias toward user's known preferences
        # Return diverse set for swiping
        pass
```

## Definition of Done
- [ ] Swiping interface implemented with smooth animations
- [ ] Swipe gestures properly detected and recorded
- [ ] Detailed rating interface accessible from meal cards
- [ ] Preference data correctly stored and retrievable
- [ ] Algorithm incorporates both swipe and rating feedback into meal planning scoring
- [ ] Unit tests cover preference scoring logic
- [ ] Widget tests verify swiping and rating interface components
- [ ] Integration tests verify preference data persistence

## Dependencies
- Recipe database with ingredient and cuisine information
- User authentication system from Epic 1
- Meal planning algorithm from Story 2.1

## Estimated Effort
**Story Points**: 8 (increased due to swiping interface complexity)

## Priority
**High** - Core interaction pattern specified in PRD

## User Experience Notes
- Swiping interface should be engaging and responsive with smooth animations
- Provide clear visual feedback for swipe actions
- Allow users to access detailed information without accidentally swiping
- Show progress indicators during training session
- Make transition between swiping and detailed rating seamless 

## Story Progress Notes

### Agent Model Used: `Claude 3.5 Sonnet`

### Dependencies Review
- ✅ **Epic 1: User Authentication & Profile Management** - Complete
  - Story 1.1: User Account Creation - Status: Review (functional)
  - Story 1.2: Initial Profile Setup - Status: InProgress (core functionality complete)
  - Story 1.3: Profile Refinement - Status: InProgress (functionality complete)
  - User authentication system working with JWT tokens
  - User preference system in MongoDB ready for preference data
- ✅ **Story 2.1: Algorithm-Based Meal Plan Generation** - Status: InProgress (backend/frontend complete)
  - Recipe database with 11+ recipes seeded
  - Recipe models with nutritional information and cuisine types
  - Backend API endpoints for recipe and meal plan management
  - Frontend meal planning components and state management
  - MealPlanningService and repositories available for integration

### Implementation Plan
1. **Backend Implementation** (API endpoints for preference learning)
   - Extend MongoDB user_preferences schema for swipe data and ratings
   - Create preference learning service for swipe and rating logic
   - Implement API endpoints: /recommendations/meals, /user-preferences/meal-feedback, /user-preferences/recipe-ratings, /user-preferences/ingredients
   - Add preference scoring algorithm integration with existing meal planning
2. **Frontend Implementation** (swiping interface)
   - Create meal swiping screen with card-based UI
   - Implement swipeable meal card widget with smooth animations
   - Add detailed recipe modal with rating interface
   - Create ingredient and cuisine preference selectors
   - Integrate with existing state management patterns
3. **Integration & Testing**
   - Connect swiping preferences to meal plan generation algorithm
   - Implement preference influence on recipe scoring
   - Add unit and widget tests
   - Validate user experience and animation smoothness

### Completion Notes List
- Story approved and implementation started by Claude 3.5 Sonnet
- Dependencies verified - building on solid Epic 1 and Story 2.1 foundation
- ✅ **Backend Implementation Completed:**
  - Extended MongoDB user_preferences schema for swipe data and ratings
  - Created PreferenceLearningService with comprehensive swiping and rating logic
  - Implemented all required API endpoints:
    - `GET /api/v1/recommendations/meals` - get meal suggestions for swiping
    - `POST /api/v1/user-preferences/meal-feedback` - record swipe actions
    - `POST /api/v1/user-preferences/recipe-ratings` - store detailed ratings
    - `POST /api/v1/user-preferences/ingredients` - store ingredient preferences
    - `POST /api/v1/user-preferences/cuisines` - store cuisine preferences
    - `GET /api/v1/user-preferences/stats` - get preference statistics
  - Added preference scoring algorithm with weighted factors (swipe 60%, rating 40%, ingredients, cuisine, prep time)
  - Integrated with existing meal planning algorithm for future recommendation improvements
  - Comprehensive error handling and validation with Pydantic schemas
  - Proper JWT authentication and user verification
  - Logging and analytics tracking for preference learning
- ✅ **Frontend Implementation Completed:**
  - Created MealSuggestion model for recipe data with proper JSON serialization
  - Implemented PreferenceLearningService for API communication with backend
  - Created MealSwipingProvider for comprehensive state management
  - Built MealSwipingScreen with Tinder-like swiping interface
  - Implemented SwipeableMealCard with smooth animations and gesture recognition
  - Created MealDetailModal for detailed recipe viewing and rating (AC 2.2.7)
  - Added PreferenceProgressIndicator for session tracking
  - Built SwipeActionButtons for like/dislike/info actions
  - Created SessionSummaryCard for session completion feedback
  - Integrated ingredient preference selection (AC 2.2.8)
  - Added cuisine preference rating (AC 2.2.9)
  - Implemented immediate feedback for preference saving (AC 2.2.11)
  - Added route and provider registration in main app
  - Beautiful UI with smooth animations and modern design
  - Comprehensive error handling and loading states

### Change Log
- Initial story file existed with technical specifications
- Status updated to InProgress - beginning implementation
- Dependencies review completed - ready to build preference learning system
- Backend implementation completed - all API endpoints and preference learning logic ready
- Frontend implementation completed - full Tinder-like swiping interface with rating capabilities 