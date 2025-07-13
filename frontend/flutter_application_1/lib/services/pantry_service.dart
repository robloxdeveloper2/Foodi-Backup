import 'package:dio/dio.dart';
import '../models/pantry_item.dart';

class PantryService {
  static const String baseUrl = 'http://localhost:5000/api/v1/pantry';
  final Dio _dio;

  PantryService() : _dio = Dio() {
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.headers = {
      'Content-Type': 'application/json',
    };
  }

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  // Create a new pantry item
  Future<PantryItem> createPantryItem(PantryItemCreateRequest request) async {
    try {
      final response = await _dio.post(
        baseUrl,
        data: request.toJson(),
      );
      
      if (response.statusCode == 201) {
        return PantryItem.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to create pantry item: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errorMessage = e.response?.data['error'] ?? 'Validation failed';
        throw Exception(errorMessage);
      } else if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized access');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Server error occurred');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Get user's pantry items
  Future<Map<String, dynamic>> getPantryItems({
    int page = 1,
    int pageSize = 20,
    String? category,
    bool expiredOnly = false,
    bool expiringSoon = false,
    String? search,
    String sortBy = 'name',
    String sortOrder = 'asc',
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
        'sort_by': sortBy,
        'sort_order': sortOrder,
      };

      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (expiredOnly) {
        queryParams['expired_only'] = 'true';
      }
      if (expiringSoon) {
        queryParams['expiring_soon'] = 'true';
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _dio.get(
        baseUrl,
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200) {
        final data = response.data['data'];
        final items = (data['items'] as List)
            .map((item) => PantryItem.fromJson(item))
            .toList();
        
        return {
          'items': items,
          'total': data['total'],
          'page': data['page'],
          'page_size': data['page_size'],
          'total_pages': data['total_pages'],
          'has_next': data['has_next'],
          'has_prev': data['has_prev'],
        };
      } else {
        throw Exception('Failed to get pantry items: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized access');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Server error occurred');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Get a specific pantry item
  Future<PantryItem> getPantryItem(String itemId) async {
    try {
      final response = await _dio.get('$baseUrl/$itemId');
      
      if (response.statusCode == 200) {
        return PantryItem.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to get pantry item: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Pantry item not found');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized access');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Update a pantry item
  Future<PantryItem> updatePantryItem(String itemId, PantryItemUpdateRequest request) async {
    try {
      final response = await _dio.put(
        '$baseUrl/$itemId',
        data: request.toJson(),
      );
      
      if (response.statusCode == 200) {
        return PantryItem.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to update pantry item: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errorMessage = e.response?.data['error'] ?? 'Validation failed';
        throw Exception(errorMessage);
      } else if (e.response?.statusCode == 404) {
        throw Exception('Pantry item not found');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized access');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Delete a pantry item
  Future<void> deletePantryItem(String itemId) async {
    try {
      final response = await _dio.delete('$baseUrl/$itemId');
      
      if (response.statusCode != 200) {
        throw Exception('Failed to delete pantry item: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Pantry item not found');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized access');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Get pantry statistics
  Future<PantryStats> getPantryStats() async {
    try {
      final response = await _dio.get('$baseUrl/stats');
      
      if (response.statusCode == 200) {
        return PantryStats.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to get pantry stats: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized access');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Cleanup expired items
  Future<int> cleanupExpiredItems() async {
    try {
      final response = await _dio.post('$baseUrl/cleanup');
      
      if (response.statusCode == 200) {
        return response.data['deleted_count'] as int;
      } else {
        throw Exception('Failed to cleanup expired items: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized access');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Get expiring items
  Future<List<PantryItem>> getExpiringItems({int days = 3}) async {
    try {
      final response = await _dio.get(
        '$baseUrl/expiring',
        queryParameters: {'days': days},
      );
      
      if (response.statusCode == 200) {
        final items = response.data['data']['items'] as List;
        return items.map((item) => PantryItem.fromJson(item)).toList();
      } else {
        throw Exception('Failed to get expiring items: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized access');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
} 