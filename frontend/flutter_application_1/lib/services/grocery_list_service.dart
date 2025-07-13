import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class GroceryListService {
  static const String _baseUrl = 'http://localhost:5000/api/v1';
  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    return headers;
  }

  // Generate grocery list from meal plan
  Future<Map<String, dynamic>> generateGroceryListFromMealPlan(
    String mealPlanId, {
    String? listName,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (listName != null) {
        body['list_name'] = listName;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/meal-plans/$mealPlanId/grocery-list'),
        headers: _headers,
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201) {
        return {
          'success': true,
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'error': responseData,
        };
      }
    } catch (e) {
      debugPrint('Error generating grocery list: $e');
      return {
        'success': false,
        'error': {
          'message': 'Network error occurred. Please try again.',
        },
      };
    }
  }

  // Get a specific grocery list
  Future<Map<String, dynamic>> getGroceryList(String listId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/grocery-lists/$listId'),
        headers: _headers,
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'error': responseData,
        };
      }
    } catch (e) {
      debugPrint('Error getting grocery list: $e');
      return {
        'success': false,
        'error': {
          'message': 'Network error occurred. Please try again.',
        },
      };
    }
  }

  // Update grocery list
  Future<Map<String, dynamic>> updateGroceryList(
    String listId, {
    String? name,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) {
        body['name'] = name;
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/grocery-lists/$listId'),
        headers: _headers,
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'error': responseData,
        };
      }
    } catch (e) {
      debugPrint('Error updating grocery list: $e');
      return {
        'success': false,
        'error': {
          'message': 'Network error occurred. Please try again.',
        },
      };
    }
  }

  // Add custom item to grocery list
  Future<Map<String, dynamic>> addCustomItem(
    String listId, {
    required String ingredientName,
    required String quantity,
    String? unit,
  }) async {
    try {
      final body = {
        'ingredient_name': ingredientName,
        'quantity': quantity,
        if (unit != null) 'unit': unit,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/grocery-lists/$listId/items'),
        headers: _headers,
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201) {
        return {
          'success': true,
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'error': responseData,
        };
      }
    } catch (e) {
      debugPrint('Error adding custom item: $e');
      return {
        'success': false,
        'error': {
          'message': 'Network error occurred. Please try again.',
        },
      };
    }
  }

  // Toggle item checked status
  Future<Map<String, dynamic>> toggleItemChecked(String itemId) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/grocery-lists/items/$itemId/toggle'),
        headers: _headers,
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'error': responseData,
        };
      }
    } catch (e) {
      debugPrint('Error toggling item: $e');
      return {
        'success': false,
        'error': {
          'message': 'Network error occurred. Please try again.',
        },
      };
    }
  }

  // Update item quantity
  Future<Map<String, dynamic>> updateItemQuantity(
    String itemId, {
    required String quantity,
    String? unit,
  }) async {
    try {
      final body = {
        'quantity': quantity,
        if (unit != null) 'unit': unit,
      };

      final response = await http.patch(
        Uri.parse('$_baseUrl/grocery-lists/items/$itemId/quantity'),
        headers: _headers,
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'error': responseData,
        };
      }
    } catch (e) {
      debugPrint('Error updating item quantity: $e');
      return {
        'success': false,
        'error': {
          'message': 'Network error occurred. Please try again.',
        },
      };
    }
  }

  // Delete item
  Future<Map<String, dynamic>> deleteItem(String itemId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/grocery-lists/items/$itemId'),
        headers: _headers,
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {
          'success': true,
        };
      } else {
        return {
          'success': false,
          'error': responseData,
        };
      }
    } catch (e) {
      debugPrint('Error deleting item: $e');
      return {
        'success': false,
        'error': {
          'message': 'Network error occurred. Please try again.',
        },
      };
    }
  }

  // Get all user grocery lists
  Future<Map<String, dynamic>> getUserGroceryLists() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/grocery-lists'),
        headers: _headers,
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'error': responseData,
        };
      }
    } catch (e) {
      debugPrint('Error getting grocery lists: $e');
      return {
        'success': false,
        'error': {
          'message': 'Network error occurred. Please try again.',
        },
      };
    }
  }

  // Get grocery list statistics
  Future<Map<String, dynamic>> getGroceryListStatistics(String listId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/grocery-lists/$listId/statistics'),
        headers: _headers,
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'error': responseData,
        };
      }
    } catch (e) {
      debugPrint('Error getting statistics: $e');
      return {
        'success': false,
        'error': {
          'message': 'Network error occurred. Please try again.',
        },
      };
    }
  }

  // Delete grocery list
  Future<Map<String, dynamic>> deleteGroceryList(String listId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/grocery-lists/$listId'),
        headers: _headers,
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {
          'success': true,
        };
      } else {
        return {
          'success': false,
          'error': responseData,
        };
      }
    } catch (e) {
      debugPrint('Error deleting grocery list: $e');
      return {
        'success': false,
        'error': {
          'message': 'Network error occurred. Please try again.',
        },
      };
    }
  }
} 