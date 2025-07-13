import 'package:flutter/material.dart';
import '../models/pantry_item.dart';
import '../services/pantry_service.dart';

class PantryProvider extends ChangeNotifier {
  final PantryService _pantryService = PantryService();
  
  // State variables
  List<PantryItem> _pantryItems = [];
  PantryStats? _pantryStats;
  bool _isLoading = false;
  String? _error;
  
  // Pagination
  int _currentPage = 1;
  int _pageSize = 20;
  int _totalItems = 0;
  int _totalPages = 0;
  bool _hasNextPage = false;
  bool _hasPrevPage = false;
  
  // Filters
  String? _selectedCategory;
  bool _showExpiredOnly = false;
  bool _showExpiringSoon = false;
  String? _searchQuery;
  String _sortBy = 'name';
  String _sortOrder = 'asc';

  // Getters
  List<PantryItem> get pantryItems => _pantryItems;
  PantryStats? get pantryStats => _pantryStats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  int get totalItems => _totalItems;
  int get totalPages => _totalPages;
  bool get hasNextPage => _hasNextPage;
  bool get hasPrevPage => _hasPrevPage;
  
  String? get selectedCategory => _selectedCategory;
  bool get showExpiredOnly => _showExpiredOnly;
  bool get showExpiringSoon => _showExpiringSoon;
  String? get searchQuery => _searchQuery;
  String get sortBy => _sortBy;
  String get sortOrder => _sortOrder;

  // Set auth token
  void setAuthToken(String token) {
    _pantryService.setAuthToken(token);
  }

  void clearAuthToken() {
    _pantryService.clearAuthToken();
    _pantryItems.clear();
    _pantryStats = null;
    notifyListeners();
  }

  // Load pantry items
  Future<void> loadPantryItems({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
    }
    
    _setLoading(true);
    _clearError();

    try {
      final result = await _pantryService.getPantryItems(
        page: _currentPage,
        pageSize: _pageSize,
        category: _selectedCategory,
        expiredOnly: _showExpiredOnly,
        expiringSoon: _showExpiringSoon,
        search: _searchQuery,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
      );

      if (refresh || _currentPage == 1) {
        _pantryItems = result['items'];
      } else {
        _pantryItems.addAll(result['items']);
      }
      
      _totalItems = result['total'];
      _totalPages = result['total_pages'];
      _hasNextPage = result['has_next'];
      _hasPrevPage = result['has_prev'];
      
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Load more items (pagination)
  Future<void> loadMoreItems() async {
    if (_hasNextPage && !_isLoading) {
      _currentPage++;
      await loadPantryItems();
    }
  }

  // Add new pantry item
  Future<bool> addPantryItem(PantryItemCreateRequest request) async {
    _setLoading(true);
    _clearError();

    try {
      final newItem = await _pantryService.createPantryItem(request);
      _pantryItems.insert(0, newItem);
      _totalItems++;
      
      // Refresh stats if available
      if (_pantryStats != null) {
        await loadPantryStats();
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update pantry item
  Future<bool> updatePantryItem(String itemId, PantryItemUpdateRequest request) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedItem = await _pantryService.updatePantryItem(itemId, request);
      final index = _pantryItems.indexWhere((item) => item.id == itemId);
      
      if (index != -1) {
        _pantryItems[index] = updatedItem;
        
        // Refresh stats if available
        if (_pantryStats != null) {
          await loadPantryStats();
        }
        
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete pantry item
  Future<bool> deletePantryItem(String itemId) async {
    _setLoading(true);
    _clearError();

    try {
      await _pantryService.deletePantryItem(itemId);
      _pantryItems.removeWhere((item) => item.id == itemId);
      _totalItems--;
      
      // Refresh stats if available
      if (_pantryStats != null) {
        await loadPantryStats();
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Load pantry statistics
  Future<void> loadPantryStats() async {
    try {
      _pantryStats = await _pantryService.getPantryStats();
      notifyListeners();
    } catch (e) {
      // Don't show error for stats, just log it
      debugPrint('Error loading pantry stats: $e');
    }
  }

  // Cleanup expired items
  Future<bool> cleanupExpiredItems() async {
    _setLoading(true);
    _clearError();

    try {
      final deletedCount = await _pantryService.cleanupExpiredItems();
      
      if (deletedCount > 0) {
        // Refresh the list
        await loadPantryItems(refresh: true);
        
        // Refresh stats
        await loadPantryStats();
      }
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get expiring items
  Future<List<PantryItem>> getExpiringItems({int days = 3}) async {
    try {
      return await _pantryService.getExpiringItems(days: days);
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  // Filter and search methods
  void setCategory(String? category) {
    _selectedCategory = category;
    _currentPage = 1;
    loadPantryItems(refresh: true);
  }

  void setExpiredOnly(bool expiredOnly) {
    _showExpiredOnly = expiredOnly;
    if (expiredOnly) {
      _showExpiringSoon = false;
    }
    _currentPage = 1;
    loadPantryItems(refresh: true);
  }

  void setExpiringSoon(bool expiringSoon) {
    _showExpiringSoon = expiringSoon;
    if (expiringSoon) {
      _showExpiredOnly = false;
    }
    _currentPage = 1;
    loadPantryItems(refresh: true);
  }

  void setSearchQuery(String? query) {
    _searchQuery = query?.trim().isEmpty == true ? null : query?.trim();
    _currentPage = 1;
    loadPantryItems(refresh: true);
  }

  void setSorting(String sortBy, String sortOrder) {
    _sortBy = sortBy;
    _sortOrder = sortOrder;
    _currentPage = 1;
    loadPantryItems(refresh: true);
  }

  void clearFilters() {
    _selectedCategory = null;
    _showExpiredOnly = false;
    _showExpiringSoon = false;
    _searchQuery = null;
    _sortBy = 'name';
    _sortOrder = 'asc';
    _currentPage = 1;
    loadPantryItems(refresh: true);
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  // Get filtered stats
  int get expiredCount => _pantryItems.where((item) => item.isExpired).length;
  int get expiringSoonCount => _pantryItems.where((item) => item.isExpiringSoon).length;
  
  Map<String, int> get categoryCounts {
    final Map<String, int> counts = {};
    for (final item in _pantryItems) {
      final category = item.category ?? 'uncategorized';
      counts[category] = (counts[category] ?? 0) + 1;
    }
    return counts;
  }

  // Find item by ID
  PantryItem? findItemById(String id) {
    try {
      return _pantryItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
} 