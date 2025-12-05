/// Canonical product categories and subcategories
/// These match the database schema and Firestore structure
class ProductCategories {
  // Canonical category values (lowercase, singular)
  static const String snack = 'snack';
  static const String drink = 'drink';
  static const String water = 'water';
  static const String bakery = 'bakery';

  // Display names (for UI)
  static const Map<String, String> displayNames = {
    snack: 'Snacks',
    drink: 'Drinks',
    water: 'Water',
    bakery: 'Bakery',
  };

  // All categories for UI
  static const List<String> all = [snack, drink, water, bakery];

  // Subcategories by category
  static const Map<String, List<String>> subcategories = {
    drink: [
      ProductSubcategories.softDrink,
      ProductSubcategories.localDrink,
      ProductSubcategories.juice,
    ],
    snack: [
      ProductSubcategories.chips,
      ProductSubcategories.biscuits,
      ProductSubcategories.candy,
    ],
    water: [],
    bakery: [
      ProductSubcategories.bread,
      ProductSubcategories.pastries,
      ProductSubcategories.cakes,
    ],
  };

  // Display names for subcategories
  static const Map<String, String> subcategoryDisplayNames = {
    ProductSubcategories.softDrink: 'Soft Drink',
    ProductSubcategories.localDrink: 'Local Drink',
    ProductSubcategories.juice: 'Juice',
    ProductSubcategories.chips: 'Chips',
    ProductSubcategories.biscuits: 'Biscuits',
    ProductSubcategories.candy: 'Candy',
    ProductSubcategories.bread: 'Bread',
    ProductSubcategories.pastries: 'Pastries',
    ProductSubcategories.cakes: 'Cakes',
  };
}

class ProductSubcategories {
  // Canonical subcategory values (lowercase, with underscores)
  static const String softDrink = 'soft_drink';
  static const String localDrink = 'local_drink';
  static const String juice = 'juice';
  static const String chips = 'chips';
  static const String biscuits = 'biscuits';
  static const String candy = 'candy';
  static const String bread = 'bread';
  static const String pastries = 'pastries';
  static const String cakes = 'cakes';
}

/// Product status values
class ProductStatus {
  static const String active = 'active';
  static const String inactive = 'inactive';
  static const String soldOut = 'sold_out';
}

/// Helper functions for product categorization
class ProductHelpers {
  /// Determine if a product is produced based on category/subcategory
  /// Produced = locally made snacks / local drinks (juices)
  static bool isProduced({
    required String category,
    String? subcategory,
  }) {
    // Local drinks (juices) are produced
    if (category == ProductCategories.drink &&
        (subcategory == ProductSubcategories.juice ||
            subcategory == ProductSubcategories.localDrink)) {
      return true;
    }

    // Locally made snacks are produced (for now, we'll need business logic to determine this)
    // For now, assume snacks are purchased unless explicitly marked
    // This can be enhanced with a UI toggle or business rules

    return false;
  }

  /// Convert display name to canonical value
  static String? categoryFromDisplay(String displayName) {
    for (final entry in ProductCategories.displayNames.entries) {
      if (entry.value == displayName) {
        return entry.key;
      }
    }
    return null;
  }

  /// Convert canonical value to display name
  static String categoryToDisplay(String canonical) {
    return ProductCategories.displayNames[canonical] ?? canonical;
  }

  /// Convert display name to canonical subcategory value
  static String? subcategoryFromDisplay(String displayName) {
    for (final entry in ProductCategories.subcategoryDisplayNames.entries) {
      if (entry.value == displayName) {
        return entry.key;
      }
    }
    return null;
  }

  /// Convert canonical subcategory to display name
  static String subcategoryToDisplay(String canonical) {
    return ProductCategories.subcategoryDisplayNames[canonical] ?? canonical;
  }
}


