class ProductionState {
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;

  // Form fields
  final String? productId;
  final int? quantityProduced;

  final double? ingredientsCost;
  final double? gasCost;
  final double? oilCost;
  final double? laborCost;
  final double? transportCost;
  final double? packagingCost;
  final double? otherCost;

  final String? notes;

  // Save result summary (optional)
  final String? batchId;
  final double? totalCost;
  final double? unitCost;

  const ProductionState({
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.productId,
    this.quantityProduced,
    this.ingredientsCost,
    this.gasCost,
    this.oilCost,
    this.laborCost,
    this.transportCost,
    this.packagingCost,
    this.otherCost,
    this.notes,
    this.batchId,
    this.totalCost,
    this.unitCost,
  });

  ProductionState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? productId,
    int? quantityProduced,
    double? ingredientsCost,
    double? gasCost,
    double? oilCost,
    double? laborCost,
    double? transportCost,
    double? packagingCost,
    double? otherCost,
    String? notes,
    String? batchId,
    double? totalCost,
    double? unitCost,
  }) {
    return ProductionState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      productId: productId ?? this.productId,
      quantityProduced: quantityProduced ?? this.quantityProduced,
      ingredientsCost: ingredientsCost ?? this.ingredientsCost,
      gasCost: gasCost ?? this.gasCost,
      oilCost: oilCost ?? this.oilCost,
      laborCost: laborCost ?? this.laborCost,
      transportCost: transportCost ?? this.transportCost,
      packagingCost: packagingCost ?? this.packagingCost,
      otherCost: otherCost ?? this.otherCost,
      notes: notes ?? this.notes,
      batchId: batchId ?? this.batchId,
      totalCost: totalCost ?? this.totalCost,
      unitCost: unitCost ?? this.unitCost,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProductionState &&
        other.isLoading == isLoading &&
        other.isSaving == isSaving &&
        other.errorMessage == errorMessage &&
        other.productId == productId &&
        other.quantityProduced == quantityProduced &&
        other.ingredientsCost == ingredientsCost &&
        other.gasCost == gasCost &&
        other.oilCost == oilCost &&
        other.laborCost == laborCost &&
        other.transportCost == transportCost &&
        other.packagingCost == packagingCost &&
        other.otherCost == otherCost &&
        other.notes == notes &&
        other.batchId == batchId &&
        other.totalCost == totalCost &&
        other.unitCost == unitCost;
  }

  @override
  int get hashCode {
    return Object.hash(
      isLoading,
      isSaving,
      errorMessage,
      productId,
      quantityProduced,
      ingredientsCost,
      gasCost,
      oilCost,
      laborCost,
      transportCost,
      packagingCost,
      otherCost,
      notes,
      batchId,
      totalCost,
      unitCost,
    );
  }
}
