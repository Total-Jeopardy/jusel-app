import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Dimension filters for reports
class ReportFilters {
  final String? productId;
  final String? category;
  final String? paymentMethod; // 'cash' or 'mobile_money' or null for all
  final String? userId; // Staff/user ID or null for all

  const ReportFilters({
    this.productId,
    this.category,
    this.paymentMethod,
    this.userId,
  });

  ReportFilters copyWith({
    String? productId,
    String? category,
    String? paymentMethod,
    String? userId,
    bool clearProduct = false,
    bool clearCategory = false,
    bool clearPaymentMethod = false,
    bool clearUser = false,
  }) {
    return ReportFilters(
      productId: clearProduct ? null : (productId ?? this.productId),
      category: clearCategory ? null : (category ?? this.category),
      paymentMethod:
          clearPaymentMethod ? null : (paymentMethod ?? this.paymentMethod),
      userId: clearUser ? null : (userId ?? this.userId),
    );
  }

  bool get hasFilters =>
      productId != null ||
      category != null ||
      paymentMethod != null ||
      userId != null;

  bool get isEmpty => !hasFilters;
}

class ReportFiltersNotifier extends StateNotifier<ReportFilters> {
  ReportFiltersNotifier() : super(const ReportFilters());

  void setProduct(String? productId) {
    state = state.copyWith(productId: productId);
  }

  void setCategory(String? category) {
    state = state.copyWith(category: category);
  }

  void setPaymentMethod(String? paymentMethod) {
    state = state.copyWith(paymentMethod: paymentMethod);
  }

  void setUser(String? userId) {
    state = state.copyWith(userId: userId);
  }

  void clearAll() {
    state = const ReportFilters();
  }

  void clearProduct() {
    state = state.copyWith(clearProduct: true);
  }

  void clearCategory() {
    state = state.copyWith(clearCategory: true);
  }

  void clearPaymentMethod() {
    state = state.copyWith(clearPaymentMethod: true);
  }

  void clearUser() {
    state = state.copyWith(clearUser: true);
  }
}

final reportFiltersProvider =
    StateNotifierProvider<ReportFiltersNotifier, ReportFilters>((ref) {
  return ReportFiltersNotifier();
});

