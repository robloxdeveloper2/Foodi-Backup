import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../models/grocery_list.dart';
import '../services/grocery_list_service.dart';

class GroceryListProvider with ChangeNotifier {
  final GroceryListService _groceryListService;

  GroceryListProvider(this._groceryListService);

  // Current state
  bool _isGenerating = false;
  bool _isLoading = false;
  String? _error;
  GroceryListWithItems? _currentGroceryList;
  List<GroceryList> _groceryListHistory = [];
  GroceryListStatistics? _currentStatistics;
  
  // Local state for checked items (persists during app session)
  final Map<String, bool> _localCheckedStates = {};

  // Getters
  bool get isGenerating => _isGenerating;
  bool get isLoading => _isLoading;
  String? get error => _error;
  GroceryListWithItems? get currentGroceryList => _getCurrentGroceryListWithLocalStates();
  List<GroceryList> get groceryListHistory => _groceryListHistory;
  GroceryListStatistics? get currentStatistics => _currentStatistics;
  bool get hasGroceryList => _currentGroceryList != null;

  // Helper method to get grocery list with local checked states applied
  GroceryListWithItems? _getCurrentGroceryListWithLocalStates() {
    if (_currentGroceryList == null) return null;

    final updatedItems = <String, List<GroceryListItem>>{};
    
    _currentGroceryList!.itemsByCategory.forEach((category, items) {
      updatedItems[category] = items.map((item) {
        // Apply local checked state if it exists, otherwise use the original state
        final localCheckedState = _localCheckedStates[item.id];
        if (localCheckedState != null) {
          return item.copyWith(isChecked: localCheckedState);
        }
        return item;
      }).toList();
    });

    return GroceryListWithItems(
      groceryList: _currentGroceryList!.groceryList,
      itemsByCategory: updatedItems,
      totalItems: _currentGroceryList!.totalItems,
    );
  }

  // Helper method to safely notify listeners
  void _safeNotifyListeners() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Set auth token
  void setAuthToken(String token) {
    _groceryListService.setAuthToken(token);
  }

  // Clear auth token
  void clearAuthToken() {
    _groceryListService.clearAuthToken();
  }

  // Generate grocery list from meal plan
  Future<bool> generateGroceryListFromMealPlan(
    String mealPlanId, {
    String? listName,
  }) async {
    _isGenerating = true;
    _error = null;
    _safeNotifyListeners();

    try {
      final response = await _groceryListService.generateGroceryListFromMealPlan(
        mealPlanId,
        listName: listName,
      );

      if (response['success'] == true) {
        // Store current checked ingredient names before updating the list
        final checkedIngredientNames = <String>{};
        if (_currentGroceryList != null) {
          for (final items in _currentGroceryList!.itemsByCategory.values) {
            for (final item in items) {
              final isCheckedLocally = _localCheckedStates[item.id] ?? item.isChecked;
              if (isCheckedLocally) {
                checkedIngredientNames.add(item.ingredientName.toLowerCase().trim());
              }
            }
          }
        }
        
        _currentGroceryList = GroceryListWithItems.fromJson(response['data']);
        
        // Clear old local states and restore for matching ingredients
        _clearLocalCheckedStates();
        if (checkedIngredientNames.isNotEmpty) {
          for (final items in _currentGroceryList!.itemsByCategory.values) {
            for (final item in items) {
              if (checkedIngredientNames.contains(item.ingredientName.toLowerCase().trim())) {
                _localCheckedStates[item.id] = true;
              }
            }
          }
        }
        
        await _refreshGroceryListHistory(); // Refresh history to include new list
        _isGenerating = false;
        _safeNotifyListeners();
        return true;
      } else {
        _error = response['error']?['message'] ?? 'Failed to generate grocery list';
        _isGenerating = false;
        _safeNotifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'An unexpected error occurred: ${e.toString()}';
      _isGenerating = false;
      _safeNotifyListeners();
      return false;
    }
  }

  // Load a specific grocery list
  Future<bool> loadGroceryList(String listId) async {
    _isLoading = true;
    _error = null;
    _safeNotifyListeners();

    try {
      final response = await _groceryListService.getGroceryList(listId);

      if (response['success'] == true) {
        // Only clear local checked states if we're loading a different list
        final currentListId = _currentGroceryList?.groceryList.id;
        print('Loading grocery list. Current: $currentListId, New: $listId');
        print('Local checked states before: $_localCheckedStates');
        
        if (currentListId != listId) {
          print('Clearing local states because loading different list');
          _clearLocalCheckedStates();
        } else {
          print('Keeping local states because loading same list');
        }
        
        _currentGroceryList = GroceryListWithItems.fromJson(response['data']);
        print('Local checked states after: $_localCheckedStates');
        _isLoading = false;
        _safeNotifyListeners();
        return true;
      } else {
        _error = response['error']?['message'] ?? 'Failed to load grocery list';
        _isLoading = false;
        _safeNotifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'An unexpected error occurred: ${e.toString()}';
      _isLoading = false;
      _safeNotifyListeners();
      return false;
    }
  }

  // Toggle item checked status (now works locally)
  bool toggleItemChecked(String itemId) {
    if (_currentGroceryList == null) return false;

    // Find the current state of the item
    bool currentState = false;
    bool itemFound = false;
    
    // Check if we have a local state for this item
    if (_localCheckedStates.containsKey(itemId)) {
      currentState = _localCheckedStates[itemId]!;
      itemFound = true;
    } else {
      // Check the original state from the grocery list
      for (final items in _currentGroceryList!.itemsByCategory.values) {
        for (final item in items) {
          if (item.id == itemId) {
            currentState = item.isChecked;
            itemFound = true;
            break;
          }
        }
        if (itemFound) break;
      }
    }

    if (!itemFound) return false;

    // Toggle the state and store it locally
    _localCheckedStates[itemId] = !currentState;
    print('Toggled item $itemId from $currentState to ${!currentState}');
    print('Local checked states: $_localCheckedStates');
    
    // Notify listeners to update UI immediately (synchronously)
    notifyListeners();
    return true;
  }

  // Update item quantity
  Future<bool> updateItemQuantity(
    String itemId, {
    required String quantity,
    String? unit,
  }) async {
    if (_currentGroceryList == null) return false;

    try {
      final response = await _groceryListService.updateItemQuantity(
        itemId,
        quantity: quantity,
        unit: unit,
      );

      if (response['success'] == true) {
        // Store current local states before reloading
        final currentLocalStates = Map<String, bool>.from(_localCheckedStates);
        
        // Reload the grocery list to get updated data including cost recalculations
        await loadGroceryList(_currentGroceryList!.groceryList.id);
        
        // Restore local states after reload
        _localCheckedStates.addAll(currentLocalStates);
        _safeNotifyListeners();
        
        return true;
      } else {
        _error = response['error']?['message'] ?? 'Failed to update item quantity';
        _safeNotifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'An unexpected error occurred: ${e.toString()}';
      _safeNotifyListeners();
      return false;
    }
  }

  // Add custom item
  Future<bool> addCustomItem(
    String listId, {
    required String ingredientName,
    required String quantity,
    String? unit,
  }) async {
    try {
      final response = await _groceryListService.addCustomItem(
        listId,
        ingredientName: ingredientName,
        quantity: quantity,
        unit: unit,
      );

      if (response['success'] == true) {
        // Store current local states before reloading
        final currentLocalStates = Map<String, bool>.from(_localCheckedStates);
        
        // Reload the grocery list to include the new item
        await loadGroceryList(listId);
        
        // Restore local states after reload
        _localCheckedStates.addAll(currentLocalStates);
        _safeNotifyListeners();
        
        return true;
      } else {
        _error = response['error']?['message'] ?? 'Failed to add custom item';
        _safeNotifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'An unexpected error occurred: ${e.toString()}';
      _safeNotifyListeners();
      return false;
    }
  }

  // Delete item
  Future<bool> deleteItem(String itemId) async {
    if (_currentGroceryList == null) return false;

    try {
      final response = await _groceryListService.deleteItem(itemId);

      if (response['success'] == true) {
        // Remove the item from local checked states
        _localCheckedStates.remove(itemId);
        
        // Remove the item from local state
        final updatedItems = <String, List<GroceryListItem>>{};
        int newTotalItems = _currentGroceryList!.totalItems;
        
        _currentGroceryList!.itemsByCategory.forEach((category, items) {
          final filteredItems = items.where((item) => item.id != itemId).toList();
          if (filteredItems.length < items.length) {
            newTotalItems--;
          }
          if (filteredItems.isNotEmpty) {
            updatedItems[category] = filteredItems;
          }
        });

        _currentGroceryList = GroceryListWithItems(
          groceryList: _currentGroceryList!.groceryList,
          itemsByCategory: updatedItems,
          totalItems: newTotalItems,
        );

        _safeNotifyListeners();
        return true;
      } else {
        _error = response['error']?['message'] ?? 'Failed to delete item';
        _safeNotifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'An unexpected error occurred: ${e.toString()}';
      _safeNotifyListeners();
      return false;
    }
  }

  // Load grocery list history
  Future<bool> loadGroceryListHistory() async {
    _isLoading = true;
    _error = null;
    _safeNotifyListeners();

    try {
      final response = await _groceryListService.getUserGroceryLists();

      if (response['success'] == true) {
        final groceryListsData = response['data']['grocery_lists'] as List<dynamic>;
        _groceryListHistory = groceryListsData
            .map((data) => GroceryList.fromJson(data as Map<String, dynamic>))
            .toList();
        _isLoading = false;
        _safeNotifyListeners();
        return true;
      } else {
        _error = response['error']?['message'] ?? 'Failed to load grocery list history';
        _isLoading = false;
        _safeNotifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'An unexpected error occurred: ${e.toString()}';
      _isLoading = false;
      _safeNotifyListeners();
      return false;
    }
  }

  // Load statistics for current grocery list
  Future<bool> loadStatistics() async {
    if (_currentGroceryList == null) return false;

    try {
      final response = await _groceryListService.getGroceryListStatistics(
        _currentGroceryList!.groceryList.id,
      );

      if (response['success'] == true) {
        _currentStatistics = GroceryListStatistics.fromJson(response['data']);
        _safeNotifyListeners();
        return true;
      } else {
        debugPrint('Failed to load statistics: ${response['error']?['message']}');
        return false;
      }
    } catch (e) {
      debugPrint('Error loading statistics: ${e.toString()}');
      return false;
    }
  }

  // Update grocery list name
  Future<bool> updateGroceryListName(String listId, String newName) async {
    try {
      final response = await _groceryListService.updateGroceryList(
        listId,
        name: newName,
      );

      if (response['success'] == true) {
        // Update local state if this is the current list
        if (_currentGroceryList?.groceryList.id == listId) {
          final updatedGroceryList = GroceryList.fromJson(response['data']);
          _currentGroceryList = GroceryListWithItems(
            groceryList: updatedGroceryList,
            itemsByCategory: _currentGroceryList!.itemsByCategory,
            totalItems: _currentGroceryList!.totalItems,
          );
        }
        
        // Update in history as well
        final historyIndex = _groceryListHistory.indexWhere((list) => list.id == listId);
        if (historyIndex >= 0) {
          _groceryListHistory[historyIndex] = GroceryList.fromJson(response['data']);
        }
        
        _safeNotifyListeners();
        return true;
      } else {
        _error = response['error']?['message'] ?? 'Failed to update grocery list name';
        _safeNotifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'An unexpected error occurred: ${e.toString()}';
      _safeNotifyListeners();
      return false;
    }
  }

  // Delete grocery list
  Future<bool> deleteGroceryList(String listId) async {
    try {
      final response = await _groceryListService.deleteGroceryList(listId);

      if (response['success'] == true) {
        // Clear current list if it was deleted
        if (_currentGroceryList?.groceryList.id == listId) {
          _currentGroceryList = null;
          _currentStatistics = null;
        }
        
        // Remove from history
        _groceryListHistory.removeWhere((list) => list.id == listId);
        
        _safeNotifyListeners();
        return true;
      } else {
        _error = response['error']?['message'] ?? 'Failed to delete grocery list';
        _safeNotifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'An unexpected error occurred: ${e.toString()}';
      _safeNotifyListeners();
      return false;
    }
  }

  // Clear current grocery list
  void clearCurrentGroceryList() {
    _currentGroceryList = null;
    _currentStatistics = null;
    _error = null;
    _safeNotifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    _safeNotifyListeners();
  }

  // Private helper method to refresh history
  Future<void> _refreshGroceryListHistory() async {
    try {
      await loadGroceryListHistory();
    } catch (e) {
      // Don't fail the main operation if history refresh fails
      debugPrint('Failed to refresh grocery list history: $e');
    }
  }

  // Get items for a specific category
  List<GroceryListItem> getItemsForCategory(String category) {
    if (_currentGroceryList == null) return [];
    return _currentGroceryList!.itemsByCategory[category] ?? [];
  }

  // Get all categories with items
  List<String> getCategoriesWithItems() {
    if (_currentGroceryList == null) return [];
    return _currentGroceryList!.categoriesWithItems;
  }

  // Clear local checked states
  void _clearLocalCheckedStates() {
    _localCheckedStates.clear();
  }

  // Clear all local state (useful when switching lists or logging out)
  void clearLocalState() {
    _clearLocalCheckedStates();
    _safeNotifyListeners();
  }
} 