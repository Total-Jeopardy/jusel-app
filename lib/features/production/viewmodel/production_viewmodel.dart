import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'production_state.dart';
import '../../../core/services/production_service.dart';

class ProductionViewModel extends StateNotifier<ProductionState> {
  final ProductionService _productionService;

  ProductionViewModel(this._productionService) : super(const ProductionState());

  // -----------------------------
  // FORM FIELD SETTERS
  // -----------------------------

  void setProduct(String? productId) =>
      state = state.copyWith(productId: productId);

  void setQuantity(int? qty) => state = state.copyWith(quantityProduced: qty);

  void setIngredientsCost(double? v) =>
      state = state.copyWith(ingredientsCost: v);

  void setGasCost(double? v) => state = state.copyWith(gasCost: v);

  void setOilCost(double? v) => state = state.copyWith(oilCost: v);

  void setLaborCost(double? v) => state = state.copyWith(laborCost: v);

  void setTransportCost(double? v) => state = state.copyWith(transportCost: v);

  void setPackagingCost(double? v) => state = state.copyWith(packagingCost: v);

  void setOtherCost(double? v) => state = state.copyWith(otherCost: v);

  void setNotes(String? v) => state = state.copyWith(notes: v);

  // -----------------------------
  // SAVE PRODUCTION BATCH
  // -----------------------------

  Future<void> saveBatch(String createdByUserId) async {
    if (state.productId == null) {
      state = state.copyWith(errorMessage: "Please select a product");
      return;
    }

    if (state.quantityProduced == null || state.quantityProduced! <= 0) {
      state = state.copyWith(errorMessage: "Quantity must be > 0");
      return;
    }

    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      final summary = await _productionService.createBatch(
        productId: state.productId!,
        quantityProduced: state.quantityProduced!,
        ingredientsCost: state.ingredientsCost,
        gasCost: state.gasCost,
        oilCost: state.oilCost,
        laborCost: state.laborCost,
        transportCost: state.transportCost,
        packagingCost: state.packagingCost,
        otherCost: state.otherCost,
        notes: state.notes,
        createdByUserId: createdByUserId,
      );

      state = state.copyWith(
        isSaving: false,
        batchId: summary.batchId.toString(),
        totalCost: summary.totalCost,
        unitCost: summary.unitCost,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.toString());
    }
  }

  // -----------------------------
  // RESET FORM
  // -----------------------------
  void resetForm() {
    state = const ProductionState();
  }
}
