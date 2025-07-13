class PantryItem {
  final String id;
  final String userId;
  final String name;
  final double quantity;
  final String unit;
  final String? expiryDate;
  final String? category;
  final String? notes;
  final bool isExpired;
  final int? daysUntilExpiry;
  final bool isExpiringSoon;
  final String createdAt;
  final String updatedAt;

  const PantryItem({
    required this.id,
    required this.userId,
    required this.name,
    required this.quantity,
    required this.unit,
    this.expiryDate,
    this.category,
    this.notes,
    required this.isExpired,
    this.daysUntilExpiry,
    required this.isExpiringSoon,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PantryItem.fromJson(Map<String, dynamic> json) {
    return PantryItem(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      expiryDate: json['expiry_date'] as String?,
      category: json['category'] as String?,
      notes: json['notes'] as String?,
      isExpired: json['is_expired'] as bool,
      daysUntilExpiry: json['days_until_expiry'] as int?,
      isExpiringSoon: json['is_expiring_soon'] as bool,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'expiry_date': expiryDate,
      'category': category,
      'notes': notes,
      'is_expired': isExpired,
      'days_until_expiry': daysUntilExpiry,
      'is_expiring_soon': isExpiringSoon,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Helper methods
  DateTime? get expiryDateTime {
    if (expiryDate == null) return null;
    return DateTime.tryParse(expiryDate!);
  }

  DateTime get createdDateTime => DateTime.parse(createdAt);
  DateTime get updatedDateTime => DateTime.parse(updatedAt);

  String get displayQuantity {
    if (quantity == quantity.toInt()) {
      return '${quantity.toInt()} $unit';
    }
    return '${quantity.toStringAsFixed(1)} $unit';
  }

  String get categoryDisplayName {
    if (category == null) return 'Uncategorized';
    return category![0].toUpperCase() + category!.substring(1);
  }

  String get expiryDisplayText {
    if (expiryDate == null) return 'No expiry date';
    
    final expiry = expiryDateTime!;
    final now = DateTime.now();
    final difference = expiry.difference(now).inDays;
    
    if (difference < 0) {
      return 'Expired ${(-difference)} day${(-difference) == 1 ? '' : 's'} ago';
    } else if (difference == 0) {
      return 'Expires today';
    } else if (difference == 1) {
      return 'Expires tomorrow';
    } else {
      return 'Expires in $difference days';
    }
  }

  // Copy with method for updates
  PantryItem copyWith({
    String? id,
    String? userId,
    String? name,
    double? quantity,
    String? unit,
    String? expiryDate,
    String? category,
    String? notes,
    bool? isExpired,
    int? daysUntilExpiry,
    bool? isExpiringSoon,
    String? createdAt,
    String? updatedAt,
  }) {
    return PantryItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      expiryDate: expiryDate ?? this.expiryDate,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      isExpired: isExpired ?? this.isExpired,
      daysUntilExpiry: daysUntilExpiry ?? this.daysUntilExpiry,
      isExpiringSoon: isExpiringSoon ?? this.isExpiringSoon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PantryItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PantryItem{id: $id, name: $name, quantity: $quantity, unit: $unit}';
  }
}

class PantryItemCreateRequest {
  final String name;
  final double quantity;
  final String unit;
  final String? expiryDate;
  final String? category;
  final String? notes;

  const PantryItemCreateRequest({
    required this.name,
    required this.quantity,
    this.unit = 'units',
    this.expiryDate,
    this.category,
    this.notes,
  });

  factory PantryItemCreateRequest.fromJson(Map<String, dynamic> json) {
    return PantryItemCreateRequest(
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String? ?? 'units',
      expiryDate: json['expiry_date'] as String?,
      category: json['category'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'expiry_date': expiryDate,
      'category': category,
      'notes': notes,
    };
  }
}

class PantryItemUpdateRequest {
  final String? name;
  final double? quantity;
  final String? unit;
  final String? expiryDate;
  final String? category;
  final String? notes;

  const PantryItemUpdateRequest({
    this.name,
    this.quantity,
    this.unit,
    this.expiryDate,
    this.category,
    this.notes,
  });

  factory PantryItemUpdateRequest.fromJson(Map<String, dynamic> json) {
    return PantryItemUpdateRequest(
      name: json['name'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
      expiryDate: json['expiry_date'] as String?,
      category: json['category'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (quantity != null) data['quantity'] = quantity;
    if (unit != null) data['unit'] = unit;
    if (expiryDate != null) data['expiry_date'] = expiryDate;
    if (category != null) data['category'] = category;
    if (notes != null) data['notes'] = notes;
    return data;
  }
}

class PantryStats {
  final int totalItems;
  final int expiredItems;
  final int expiringSoonItems;
  final Map<String, int> categories;
  final Map<String, int> units;
  final int healthScore;
  final List<String> recommendations;

  const PantryStats({
    required this.totalItems,
    required this.expiredItems,
    required this.expiringSoonItems,
    required this.categories,
    required this.units,
    required this.healthScore,
    required this.recommendations,
  });

  factory PantryStats.fromJson(Map<String, dynamic> json) {
    return PantryStats(
      totalItems: json['total_items'] as int,
      expiredItems: json['expired_items'] as int,
      expiringSoonItems: json['expiring_soon_items'] as int,
      categories: Map<String, int>.from(json['categories'] as Map),
      units: Map<String, int>.from(json['units'] as Map),
      healthScore: json['health_score'] as int,
      recommendations: List<String>.from(json['recommendations'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_items': totalItems,
      'expired_items': expiredItems,
      'expiring_soon_items': expiringSoonItems,
      'categories': categories,
      'units': units,
      'health_score': healthScore,
      'recommendations': recommendations,
    };
  }
}

// Constants for validation and UI
class PantryConstants {
  static const List<String> validUnits = [
    'units', 'pieces', 'items',
    'grams', 'g', 'kg', 'kilograms', 'pounds', 'lbs', 'oz', 'ounces',
    'ml', 'milliliters', 'liters', 'l', 'cups', 'tablespoons', 'teaspoons',
    'cans', 'bottles', 'packages', 'bags'
  ];

  static const List<String> validCategories = [
    'produce', 'dairy', 'meat', 'seafood', 'pantry', 'frozen',
    'bakery', 'beverages', 'canned_goods', 'condiments', 'snacks'
  ];

  static const Map<String, String> categoryDisplayNames = {
    'produce': 'Produce',
    'dairy': 'Dairy',
    'meat': 'Meat',
    'seafood': 'Seafood',
    'pantry': 'Pantry',
    'frozen': 'Frozen',
    'bakery': 'Bakery',
    'beverages': 'Beverages',
    'canned_goods': 'Canned Goods',
    'condiments': 'Condiments',
    'snacks': 'Snacks',
  };

  static const Map<String, String> unitDisplayNames = {
    'units': 'Units',
    'pieces': 'Pieces',
    'items': 'Items',
    'grams': 'Grams',
    'g': 'g',
    'kg': 'Kilograms',
    'kilograms': 'Kilograms',
    'pounds': 'Pounds',
    'lbs': 'lbs',
    'oz': 'Ounces',
    'ounces': 'Ounces',
    'ml': 'Milliliters',
    'milliliters': 'Milliliters',
    'liters': 'Liters',
    'l': 'L',
    'cups': 'Cups',
    'tablespoons': 'Tablespoons',
    'teaspoons': 'Teaspoons',
    'cans': 'Cans',
    'bottles': 'Bottles',
    'packages': 'Packages',
    'bags': 'Bags',
  };
} 