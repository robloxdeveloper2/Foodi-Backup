class GroceryList {
  final String id;
  final String userId;
  final String? mealPlanId;
  final String name;
  final int? totalEstimatedCost;
  final double? totalCostUsd;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  GroceryList({
    required this.id,
    required this.userId,
    this.mealPlanId,
    required this.name,
    this.totalEstimatedCost,
    this.totalCostUsd,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  factory GroceryList.fromJson(Map<String, dynamic> json) {
    return GroceryList(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      mealPlanId: json['meal_plan_id'] as String?,
      name: json['name'] as String,
      totalEstimatedCost: json['total_estimated_cost'] as int?,
      totalCostUsd: _safeToDouble(json['total_cost_usd']),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  static double? _safeToDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'meal_plan_id': mealPlanId,
      'name': name,
      'total_estimated_cost': totalEstimatedCost,
      'total_cost_usd': totalCostUsd,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String get formattedCost {
    if (totalCostUsd != null) {
      return '\$${totalCostUsd!.toStringAsFixed(2)}';
    }
    return 'Cost unknown';
  }

  String get formattedDate {
    return '${createdAt.month}/${createdAt.day}/${createdAt.year}';
  }
}

class GroceryListItem {
  final String id;
  final String groceryListId;
  final String ingredientName;
  final String quantity;
  final String? unit;
  final String? category;
  final int? estimatedCost;
  final double? costUsd;
  final bool isChecked;
  final bool isCustom;
  final DateTime createdAt;

  GroceryListItem({
    required this.id,
    required this.groceryListId,
    required this.ingredientName,
    required this.quantity,
    this.unit,
    this.category,
    this.estimatedCost,
    this.costUsd,
    required this.isChecked,
    required this.isCustom,
    required this.createdAt,
  });

  factory GroceryListItem.fromJson(Map<String, dynamic> json) {
    return GroceryListItem(
      id: json['id'] as String,
      groceryListId: json['grocery_list_id'] as String,
      ingredientName: json['ingredient_name'] as String,
      quantity: json['quantity'] as String,
      unit: json['unit'] as String?,
      category: json['category'] as String?,
      estimatedCost: json['estimated_cost'] as int?,
      costUsd: GroceryList._safeToDouble(json['cost_usd']),
      isChecked: json['is_checked'] as bool? ?? false,
      isCustom: json['is_custom'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'grocery_list_id': groceryListId,
      'ingredient_name': ingredientName,
      'quantity': quantity,
      'unit': unit,
      'category': category,
      'estimated_cost': estimatedCost,
      'cost_usd': costUsd,
      'is_checked': isChecked,
      'is_custom': isCustom,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get displayQuantity {
    if (unit != null && unit!.isNotEmpty) {
      return '$quantity $unit';
    }
    return quantity;
  }

  String get formattedCost {
    if (costUsd != null) {
      return '\$${costUsd!.toStringAsFixed(2)}';
    }
    return '';
  }

  String get categoryDisplayName {
    if (category == null) return 'Other';
    
    switch (category!) {
      case 'produce':
        return 'Produce';
      case 'meat_seafood':
        return 'Meat & Seafood';
      case 'dairy':
        return 'Dairy';
      case 'pantry':
        return 'Pantry';
      case 'frozen':
        return 'Frozen';
      case 'bakery':
        return 'Bakery';
      case 'beverages':
        return 'Beverages';
      case 'canned_goods':
        return 'Canned Goods';
      case 'condiments':
        return 'Condiments';
      case 'snacks':
        return 'Snacks';
      default:
        return 'Other';
    }
  }

  GroceryListItem copyWith({
    String? id,
    String? groceryListId,
    String? ingredientName,
    String? quantity,
    String? unit,
    String? category,
    int? estimatedCost,
    double? costUsd,
    bool? isChecked,
    bool? isCustom,
    DateTime? createdAt,
  }) {
    return GroceryListItem(
      id: id ?? this.id,
      groceryListId: groceryListId ?? this.groceryListId,
      ingredientName: ingredientName ?? this.ingredientName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      costUsd: costUsd ?? this.costUsd,
      isChecked: isChecked ?? this.isChecked,
      isCustom: isCustom ?? this.isCustom,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class GroceryListWithItems {
  final GroceryList groceryList;
  final Map<String, List<GroceryListItem>> itemsByCategory;
  final int totalItems;

  GroceryListWithItems({
    required this.groceryList,
    required this.itemsByCategory,
    required this.totalItems,
  });

  factory GroceryListWithItems.fromJson(Map<String, dynamic> json) {
    final groceryListData = json['grocery_list'] as Map<String, dynamic>;
    final itemsByCategoryData = json['items_by_category'] as Map<String, dynamic>;
    
    final Map<String, List<GroceryListItem>> itemsByCategory = {};
    
    itemsByCategoryData.forEach((category, items) {
      final itemList = (items as List<dynamic>)
          .map((item) => GroceryListItem.fromJson(item as Map<String, dynamic>))
          .toList();
      itemsByCategory[category] = itemList;
    });

    return GroceryListWithItems(
      groceryList: GroceryList.fromJson(groceryListData),
      itemsByCategory: itemsByCategory,
      totalItems: json['total_items'] as int,
    );
  }

  List<GroceryListItem> get allItems {
    return itemsByCategory.values.expand((items) => items).toList();
  }

  List<GroceryListItem> get checkedItems {
    return allItems.where((item) => item.isChecked).toList();
  }

  List<GroceryListItem> get uncheckedItems {
    return allItems.where((item) => !item.isChecked).toList();
  }

  int get checkedCount => checkedItems.length;
  int get uncheckedCount => uncheckedItems.length;
  
  double get completionPercentage {
    if (totalItems == 0) return 0.0;
    return (checkedCount / totalItems) * 100;
  }

  List<String> get categories {
    return itemsByCategory.keys.toList()..sort();
  }

  List<String> get categoriesWithItems {
    return itemsByCategory.entries
        .where((entry) => entry.value.isNotEmpty)
        .map((entry) => entry.key)
        .toList()..sort();
  }
}

class GroceryListStatistics {
  final int totalItems;
  final int checkedItems;
  final int uncheckedItems;
  final int customItems;
  final int recipeItems;
  final double completionPercentage;
  final Map<String, int> categories;
  final int totalEstimatedCostCents;
  final double totalEstimatedCostUsd;

  GroceryListStatistics({
    required this.totalItems,
    required this.checkedItems,
    required this.uncheckedItems,
    required this.customItems,
    required this.recipeItems,
    required this.completionPercentage,
    required this.categories,
    required this.totalEstimatedCostCents,
    required this.totalEstimatedCostUsd,
  });

  factory GroceryListStatistics.fromJson(Map<String, dynamic> json) {
    return GroceryListStatistics(
      totalItems: json['total_items'] as int,
      checkedItems: json['checked_items'] as int,
      uncheckedItems: json['unchecked_items'] as int,
      customItems: json['custom_items'] as int,
      recipeItems: json['recipe_items'] as int,
      completionPercentage: GroceryList._safeToDouble(json['completion_percentage']) ?? 0.0,
      categories: Map<String, int>.from(json['categories'] as Map),
      totalEstimatedCostCents: json['total_estimated_cost_cents'] as int,
      totalEstimatedCostUsd: GroceryList._safeToDouble(json['total_estimated_cost_usd']) ?? 0.0,
    );
  }

  String get formattedTotalCost {
    return '\$${totalEstimatedCostUsd.toStringAsFixed(2)}';
  }

  String get formattedCompletionPercentage {
    return '${completionPercentage.toStringAsFixed(1)}%';
  }
} 