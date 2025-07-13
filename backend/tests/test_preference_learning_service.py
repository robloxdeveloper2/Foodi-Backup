"""
Tests for Preference Learning Service (Story 2.2)
"""

import pytest
from unittest.mock import Mock, patch, MagicMock
from datetime import datetime

from src.services.preference_learning_service import PreferenceLearningService
from src.core.models.recipe import Recipe
from src.core.exceptions import UserNotFoundError, ValidationError


@pytest.fixture
def preference_service():
    """Create a preference learning service instance for testing"""
    with patch('src.services.preference_learning_service.UserPreferences') as mock_user_prefs, \
         patch('src.services.preference_learning_service.RecipeRepository') as mock_recipe_repo, \
         patch('src.services.preference_learning_service.UserRepository') as mock_user_repo:
        
        service = PreferenceLearningService()
        service.user_preferences = mock_user_prefs.return_value
        service.recipe_repository = mock_recipe_repo.return_value
        service.user_repository = mock_user_repo.return_value
        return service


@pytest.fixture
def sample_recipe():
    """Create a sample recipe for testing"""
    return Recipe(
        id="recipe-123",
        name="Test Recipe",
        ingredients=[
            {"name": "chicken", "quantity": "2 cups"},
            {"name": "spinach", "quantity": "1 cup"}
        ],
        instructions="Cook the chicken and spinach",
        cuisine_type="Italian",
        prep_time_minutes=30,
        servings=4
    )


@pytest.fixture
def sample_user():
    """Create a sample user for testing"""
    user = Mock()
    user.id = "user-123"
    return user


class TestGetMealSuggestions:
    def test_get_meal_suggestions_success(self, preference_service, sample_user, sample_recipe):
        """Test successful meal suggestions retrieval"""
        # Mock user repository
        preference_service.user_repository.get_user_by_id.return_value = sample_user
        
        # Mock user preferences
        preference_service.user_preferences.get_preferences.return_value = {
            'preferences': {'dietary_restrictions': ['vegetarian']}
        }
        preference_service.user_preferences.get_swipe_preferences.return_value = {}
        preference_service.user_preferences.get_recipe_ratings.return_value = {}
        
        # Mock recipe repository
        preference_service.recipe_repository.get_all_recipes.return_value = [sample_recipe]
        sample_recipe.matches_dietary_restrictions = Mock(return_value=True)
        sample_recipe.to_dict = Mock(return_value={'id': 'recipe-123', 'name': 'Test Recipe'})
        
        # Test
        suggestions = preference_service.get_meal_suggestions("user-123", session_length=5)
        
        # Assertions
        assert len(suggestions) == 1
        assert suggestions[0]['id'] == 'recipe-123'
        preference_service.user_repository.get_user_by_id.assert_called_with("user-123")

    def test_get_meal_suggestions_user_not_found(self, preference_service):
        """Test meal suggestions when user doesn't exist"""
        preference_service.user_repository.get_user_by_id.return_value = None
        
        with pytest.raises(UserNotFoundError):
            preference_service.get_meal_suggestions("nonexistent-user")

    def test_get_meal_suggestions_filters_by_dietary_restrictions(self, preference_service, sample_user, sample_recipe):
        """Test that meal suggestions are filtered by dietary restrictions"""
        preference_service.user_repository.get_user_by_id.return_value = sample_user
        preference_service.user_preferences.get_preferences.return_value = {
            'preferences': {'dietary_restrictions': ['vegan']}
        }
        preference_service.user_preferences.get_swipe_preferences.return_value = {}
        preference_service.user_preferences.get_recipe_ratings.return_value = {}
        
        # Recipe doesn't match dietary restrictions
        sample_recipe.matches_dietary_restrictions = Mock(return_value=False)
        preference_service.recipe_repository.get_all_recipes.return_value = [sample_recipe]
        
        suggestions = preference_service.get_meal_suggestions("user-123")
        
        assert len(suggestions) == 0
        sample_recipe.matches_dietary_restrictions.assert_called_with(['vegan'])


class TestRecordSwipeFeedback:
    def test_record_swipe_feedback_success(self, preference_service, sample_user, sample_recipe):
        """Test successful swipe feedback recording"""
        preference_service.user_repository.get_user_by_id.return_value = sample_user
        preference_service.recipe_repository.get_recipe_by_id.return_value = sample_recipe
        preference_service.user_preferences.record_swipe_feedback.return_value = True
        
        result = preference_service.record_swipe_feedback("user-123", "recipe-123", "like")
        
        assert result['user_id'] == "user-123"
        assert result['recipe_id'] == "recipe-123"
        assert result['action'] == "like"
        assert result['feedback_recorded'] is True
        preference_service.user_preferences.record_swipe_feedback.assert_called_with("user-123", "recipe-123", "like")

    def test_record_swipe_feedback_invalid_action(self, preference_service, sample_user):
        """Test swipe feedback with invalid action"""
        preference_service.user_repository.get_user_by_id.return_value = sample_user
        
        with pytest.raises(ValidationError):
            preference_service.record_swipe_feedback("user-123", "recipe-123", "invalid")

    def test_record_swipe_feedback_user_not_found(self, preference_service):
        """Test swipe feedback when user doesn't exist"""
        preference_service.user_repository.get_user_by_id.return_value = None
        
        with pytest.raises(UserNotFoundError):
            preference_service.record_swipe_feedback("nonexistent-user", "recipe-123", "like")

    def test_record_swipe_feedback_recipe_not_found(self, preference_service, sample_user):
        """Test swipe feedback when recipe doesn't exist"""
        preference_service.user_repository.get_user_by_id.return_value = sample_user
        preference_service.recipe_repository.get_recipe_by_id.return_value = None
        
        with pytest.raises(ValidationError):
            preference_service.record_swipe_feedback("user-123", "nonexistent-recipe", "like")


class TestSetRecipeRating:
    def test_set_recipe_rating_success(self, preference_service, sample_user, sample_recipe):
        """Test successful recipe rating"""
        preference_service.user_repository.get_user_by_id.return_value = sample_user
        preference_service.recipe_repository.get_recipe_by_id.return_value = sample_recipe
        preference_service.user_preferences.set_recipe_rating.return_value = True
        
        result = preference_service.set_recipe_rating("user-123", "recipe-123", 4.5)
        
        assert result['user_id'] == "user-123"
        assert result['recipe_id'] == "recipe-123"
        assert result['rating'] == 4.5
        assert result['rating_recorded'] is True

    def test_set_recipe_rating_invalid_rating(self, preference_service, sample_user):
        """Test recipe rating with invalid rating value"""
        preference_service.user_repository.get_user_by_id.return_value = sample_user
        
        with pytest.raises(ValidationError):
            preference_service.set_recipe_rating("user-123", "recipe-123", 6.0)  # Invalid: > 5.0
        
        with pytest.raises(ValidationError):
            preference_service.set_recipe_rating("user-123", "recipe-123", 0.5)  # Invalid: < 1.0


class TestIngredientPreferences:
    def test_update_ingredient_preference_success(self, preference_service, sample_user):
        """Test successful ingredient preference update"""
        preference_service.user_repository.get_user_by_id.return_value = sample_user
        preference_service.user_preferences.update_ingredient_preferences.return_value = True
        
        result = preference_service.update_ingredient_preference("user-123", "chicken", "liked")
        
        assert result['user_id'] == "user-123"
        assert result['ingredient'] == "chicken"
        assert result['preference'] == "liked"
        assert result['preference_updated'] is True

    def test_update_ingredient_preference_invalid_preference(self, preference_service, sample_user):
        """Test ingredient preference update with invalid preference"""
        preference_service.user_repository.get_user_by_id.return_value = sample_user
        
        with pytest.raises(ValidationError):
            preference_service.update_ingredient_preference("user-123", "chicken", "invalid")


class TestCuisinePreferences:
    def test_set_cuisine_preference_success(self, preference_service, sample_user):
        """Test successful cuisine preference setting"""
        preference_service.user_repository.get_user_by_id.return_value = sample_user
        preference_service.user_preferences.set_cuisine_preference.return_value = True
        
        result = preference_service.set_cuisine_preference("user-123", "Italian", 5)
        
        assert result['user_id'] == "user-123"
        assert result['cuisine'] == "Italian"
        assert result['rating'] == 5
        assert result['preference_updated'] is True

    def test_set_cuisine_preference_invalid_rating(self, preference_service, sample_user):
        """Test cuisine preference with invalid rating"""
        preference_service.user_repository.get_user_by_id.return_value = sample_user
        
        with pytest.raises(ValidationError):
            preference_service.set_cuisine_preference("user-123", "Italian", 6)  # Invalid: > 5
        
        with pytest.raises(ValidationError):
            preference_service.set_cuisine_preference("user-123", "Italian", 0)  # Invalid: < 1


class TestPreferenceScoring:
    def test_calculate_preference_score_new_user(self, preference_service):
        """Test preference score calculation for new user"""
        preference_service.user_preferences.get_preferences.return_value = None
        
        recipe = Mock()
        score = preference_service.calculate_preference_score("user-123", recipe)
        
        assert score == 0.5  # Neutral score for new users

    def test_calculate_preference_score_with_swipe_data(self, preference_service, sample_recipe):
        """Test preference score with swipe data"""
        user_prefs = {
            "user_id": "user-123",
            "swipe_preferences": {"recipe-123": "like"},
            "recipe_ratings": {},
            "ingredient_preferences": {"liked": [], "disliked": []},
            "cuisine_preferences": {},
            "prep_time_preference": "moderate"
        }
        preference_service.user_preferences.get_preferences.return_value = user_prefs
        sample_recipe.id = "recipe-123"
        
        score = preference_service.calculate_preference_score("user-123", sample_recipe)
        
        assert score > 0.5  # Should be higher than neutral due to like

    def test_calculate_preference_score_with_rating_data(self, preference_service, sample_recipe):
        """Test preference score with rating data"""
        user_prefs = {
            "user_id": "user-123",
            "swipe_preferences": {},
            "recipe_ratings": {"recipe-123": 4.5},
            "ingredient_preferences": {"liked": [], "disliked": []},
            "cuisine_preferences": {},
            "prep_time_preference": "moderate"
        }
        preference_service.user_preferences.get_preferences.return_value = user_prefs
        sample_recipe.id = "recipe-123"
        
        score = preference_service.calculate_preference_score("user-123", sample_recipe)
        
        assert score > 0.5  # Should be higher than neutral due to good rating


if __name__ == "__main__":
    pytest.main([__file__]) 