"""
Tests for Preference Learning API Endpoints (Story 2.2)
"""

import pytest
import json
from unittest.mock import Mock, patch
from flask import Flask
from flask_jwt_extended import JWTManager, create_access_token

from src.main import create_app
from src.core.exceptions import UserNotFoundError, ValidationError


@pytest.fixture
def app():
    """Create test Flask app"""
    app = create_app()
    app.config['TESTING'] = True
    app.config['JWT_SECRET_KEY'] = 'test-secret-key'
    return app


@pytest.fixture
def client(app):
    """Create test client"""
    return app.test_client()


@pytest.fixture
def auth_headers(app):
    """Create authorization headers for testing"""
    with app.app_context():
        access_token = create_access_token(identity='user-123')
        return {'Authorization': f'Bearer {access_token}'}


class TestGetMealSuggestions:
    @patch('src.api.preferences.preference_service')
    def test_get_meal_suggestions_success(self, mock_service, client, auth_headers):
        """Test successful meal suggestions retrieval"""
        mock_suggestions = [
            {'id': 'recipe-1', 'name': 'Recipe 1'},
            {'id': 'recipe-2', 'name': 'Recipe 2'}
        ]
        mock_service.get_meal_suggestions.return_value = mock_suggestions
        
        response = client.get('/api/v1/preferences/recommendations/meals', headers=auth_headers)
        
        assert response.status_code == 200
        data = json.loads(response.data)
        assert data['session_length'] == 2
        assert len(data['suggestions']) == 2
        assert data['user_id'] == 'user-123'

    @patch('src.api.preferences.preference_service')
    def test_get_meal_suggestions_with_custom_length(self, mock_service, client, auth_headers):
        """Test meal suggestions with custom session length"""
        mock_service.get_meal_suggestions.return_value = []
        
        response = client.get(
            '/api/v1/preferences/recommendations/meals?session_length=10',
            headers=auth_headers
        )
        
        assert response.status_code == 200
        mock_service.get_meal_suggestions.assert_called_with('user-123', 10)

    @patch('src.api.preferences.preference_service')
    def test_get_meal_suggestions_user_not_found(self, mock_service, client, auth_headers):
        """Test meal suggestions when user doesn't exist"""
        mock_service.get_meal_suggestions.side_effect = UserNotFoundError("User not found")
        
        response = client.get('/api/v1/preferences/recommendations/meals', headers=auth_headers)
        
        assert response.status_code == 404
        data = json.loads(response.data)
        assert data['error'] == 'user_not_found'

    def test_get_meal_suggestions_unauthorized(self, client):
        """Test meal suggestions without authorization"""
        response = client.get('/api/v1/preferences/recommendations/meals')
        
        assert response.status_code == 401


class TestRecordMealFeedback:
    @patch('src.api.preferences.preference_service')
    def test_record_meal_feedback_success(self, mock_service, client, auth_headers):
        """Test successful swipe feedback recording"""
        mock_result = {
            'user_id': 'user-123',
            'recipe_id': 'recipe-123',
            'action': 'like',
            'timestamp': '2023-10-27T10:00:00',
            'context': 'swiping_session',
            'feedback_recorded': True
        }
        mock_service.record_swipe_feedback.return_value = mock_result
        
        response = client.post(
            '/api/v1/preferences/user-preferences/meal-feedback',
            headers=auth_headers,
            json={'recipe_id': 'recipe-123', 'action': 'like'}
        )
        
        assert response.status_code == 201
        data = json.loads(response.data)
        assert data['action'] == 'like'
        assert data['feedback_recorded'] is True

    @patch('src.api.preferences.preference_service')
    def test_record_meal_feedback_invalid_action(self, mock_service, client, auth_headers):
        """Test swipe feedback with invalid action"""
        response = client.post(
            '/api/v1/preferences/user-preferences/meal-feedback',
            headers=auth_headers,
            json={'recipe_id': 'recipe-123', 'action': 'invalid'}
        )
        
        assert response.status_code == 400
        data = json.loads(response.data)
        assert data['error'] == 'validation_error'

    @patch('src.api.preferences.preference_service')
    def test_record_meal_feedback_missing_data(self, mock_service, client, auth_headers):
        """Test swipe feedback with missing data"""
        response = client.post(
            '/api/v1/preferences/user-preferences/meal-feedback',
            headers=auth_headers,
            json={'recipe_id': 'recipe-123'}  # Missing action
        )
        
        assert response.status_code == 400


class TestSetRecipeRating:
    @patch('src.api.preferences.preference_service')
    def test_set_recipe_rating_success(self, mock_service, client, auth_headers):
        """Test successful recipe rating"""
        mock_result = {
            'user_id': 'user-123',
            'recipe_id': 'recipe-123',
            'rating': 4.5,
            'timestamp': '2023-10-27T10:00:00',
            'rating_recorded': True
        }
        mock_service.set_recipe_rating.return_value = mock_result
        
        response = client.post(
            '/api/v1/preferences/user-preferences/recipe-ratings',
            headers=auth_headers,
            json={'recipe_id': 'recipe-123', 'rating': 4.5}
        )
        
        assert response.status_code == 201
        data = json.loads(response.data)
        assert data['rating'] == 4.5
        assert data['rating_recorded'] is True

    @patch('src.api.preferences.preference_service')
    def test_set_recipe_rating_invalid_rating(self, mock_service, client, auth_headers):
        """Test recipe rating with invalid rating value"""
        response = client.post(
            '/api/v1/preferences/user-preferences/recipe-ratings',
            headers=auth_headers,
            json={'recipe_id': 'recipe-123', 'rating': 6.0}  # Invalid: > 5.0
        )
        
        assert response.status_code == 400
        data = json.loads(response.data)
        assert data['error'] == 'validation_error'


class TestUpdateIngredientPreference:
    @patch('src.api.preferences.preference_service')
    def test_update_ingredient_preference_success(self, mock_service, client, auth_headers):
        """Test successful ingredient preference update"""
        mock_result = {
            'user_id': 'user-123',
            'ingredient': 'chicken',
            'preference': 'liked',
            'timestamp': '2023-10-27T10:00:00',
            'preference_updated': True
        }
        mock_service.update_ingredient_preference.return_value = mock_result
        
        response = client.post(
            '/api/v1/preferences/user-preferences/ingredients',
            headers=auth_headers,
            json={'ingredient': 'chicken', 'preference': 'liked'}
        )
        
        assert response.status_code == 201
        data = json.loads(response.data)
        assert data['ingredient'] == 'chicken'
        assert data['preference'] == 'liked'
        assert data['preference_updated'] is True

    @patch('src.api.preferences.preference_service')
    def test_update_ingredient_preference_invalid_preference(self, mock_service, client, auth_headers):
        """Test ingredient preference with invalid preference value"""
        response = client.post(
            '/api/v1/preferences/user-preferences/ingredients',
            headers=auth_headers,
            json={'ingredient': 'chicken', 'preference': 'invalid'}
        )
        
        assert response.status_code == 400
        data = json.loads(response.data)
        assert data['error'] == 'validation_error'


class TestSetCuisinePreference:
    @patch('src.api.preferences.preference_service')
    def test_set_cuisine_preference_success(self, mock_service, client, auth_headers):
        """Test successful cuisine preference setting"""
        mock_result = {
            'user_id': 'user-123',
            'cuisine': 'Italian',
            'rating': 5,
            'timestamp': '2023-10-27T10:00:00',
            'preference_updated': True
        }
        mock_service.set_cuisine_preference.return_value = mock_result
        
        response = client.post(
            '/api/v1/preferences/user-preferences/cuisines',
            headers=auth_headers,
            json={'cuisine': 'Italian', 'rating': 5}
        )
        
        assert response.status_code == 201
        data = json.loads(response.data)
        assert data['cuisine'] == 'Italian'
        assert data['rating'] == 5
        assert data['preference_updated'] is True

    @patch('src.api.preferences.preference_service')
    def test_set_cuisine_preference_invalid_rating(self, mock_service, client, auth_headers):
        """Test cuisine preference with invalid rating"""
        response = client.post(
            '/api/v1/preferences/user-preferences/cuisines',
            headers=auth_headers,
            json={'cuisine': 'Italian', 'rating': 6}  # Invalid: > 5
        )
        
        assert response.status_code == 400
        data = json.loads(response.data)
        assert data['error'] == 'validation_error'


class TestGetPreferenceStats:
    @patch('src.api.preferences.UserPreferences')
    def test_get_preference_stats_success(self, mock_user_prefs, client, auth_headers):
        """Test successful preference statistics retrieval"""
        mock_preferences = {
            'swipe_preferences': {'recipe-1': 'like', 'recipe-2': 'dislike'},
            'recipe_ratings': {'recipe-1': 4.5, 'recipe-3': 3.0},
            'ingredient_preferences': {'liked': ['chicken'], 'disliked': ['cilantro']},
            'cuisine_preferences': {'Italian': 5, 'Mexican': 4},
            'prep_time_preference': 'moderate'
        }
        mock_user_prefs.return_value.get_preferences.return_value = mock_preferences
        
        response = client.get('/api/v1/preferences/user-preferences/stats', headers=auth_headers)
        
        assert response.status_code == 200
        data = json.loads(response.data)
        assert data['user_id'] == 'user-123'
        assert data['total_swipes'] == 2
        assert data['likes_count'] == 1
        assert data['dislikes_count'] == 1
        assert data['total_ratings'] == 2
        assert data['prep_time_preference'] == 'moderate'

    @patch('src.api.preferences.UserPreferences')
    def test_get_preference_stats_user_not_found(self, mock_user_prefs, client, auth_headers):
        """Test preference stats when user preferences don't exist"""
        mock_user_prefs.return_value.get_preferences.return_value = None
        
        response = client.get('/api/v1/preferences/user-preferences/stats', headers=auth_headers)
        
        assert response.status_code == 404
        data = json.loads(response.data)
        assert data['error'] == 'user_not_found'


if __name__ == "__main__":
    pytest.main([__file__]) 