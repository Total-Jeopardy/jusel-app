/// Canonical product categories and subcategories
/// These match the database schema and Firestore structure
class ProductCategories {
  // Canonical category values (lowercase, singular)
  static const String snack = 'snack';
  static const String drink = 'drink';
  static const String water = 'water';

  // Display names (for UI)
  static const Map<String, String> displayNames = {
    snack: 'Snacks',
    drink: 'Drinks',
    water: 'Water',
  };

  // All categories for UI
  static const List<String> all = [drink, water, snack];

  // Subcategories by category
  static const Map<String, List<String>> subcategories = {
    drink: [
      ProductSubcategories.locallyMade,
      ProductSubcategories.purchased,
    ],
    snack: [
      ProductSubcategories.pie,
      ProductSubcategories.cake,
      ProductSubcategories.pastries,
      ProductSubcategories.springRolls,
      ProductSubcategories.samosas,
    ],
    water: [
      ProductSubcategories.sachetWater,
      ProductSubcategories.bottle,
    ],
  };

  // Display names for subcategories
  static const Map<String, String> subcategoryDisplayNames = {
    ProductSubcategories.sachetWater: 'Sachet Water',
    ProductSubcategories.bottle: 'Bottle',
    ProductSubcategories.locallyMade: 'Locally Made',
    ProductSubcategories.purchased: 'Purchased',
    ProductSubcategories.pie: 'Pie',
    ProductSubcategories.cake: 'Cake',
    ProductSubcategories.pastries: 'Pastries',
    ProductSubcategories.springRolls: 'Spring Rolls',
    ProductSubcategories.samosas: 'Samosas',
  };
}

class ProductSubcategories {
  // Canonical subcategory values (lowercase, with underscores)
  static const String sachetWater = 'sachet_water';
  static const String bottle = 'bottle';
  static const String locallyMade = 'locally_made';
  static const String purchased = 'purchased';
  static const String pie = 'pie';
  static const String cake = 'cake';
  static const String pastries = 'pastries';
  static const String springRolls = 'spring_rolls';
  static const String samosas = 'samosas';
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
  /// Produced = snacks + locally made drinks; water is always purchased
  static bool isProduced({
    required String category,
    String? subcategory,
  }) {
    if (category == ProductCategories.water) {
      return false;
    }

    if (category == ProductCategories.drink) {
      return subcategory == ProductSubcategories.locallyMade;
    }

    if (category == ProductCategories.snack) {
      return true;
    }

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


