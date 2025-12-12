import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PeriodFilter {
  today,
  yesterday,
  last7Days,
  last30Days,
  thisWeek,
  thisMonth,
  thisQuarter,
  thisYear,
  custom,
}

class PeriodFilterState {
  final PeriodFilter filter;
  final DateTimeRange? customRange;

  PeriodFilterState({
    required this.filter,
    this.customRange,
  });

  PeriodFilterState copyWith({
    PeriodFilter? filter,
    DateTimeRange? customRange,
  }) {
    return PeriodFilterState(
      filter: filter ?? this.filter,
      customRange: customRange ?? this.customRange,
    );
  }
}

class PeriodFilterNotifier extends StateNotifier<PeriodFilterState> {
  PeriodFilterNotifier()
      : super(PeriodFilterState(filter: PeriodFilter.today));

  void setFilter(PeriodFilter filter) {
    state = state.copyWith(filter: filter);
  }

  void setCustomRange(DateTimeRange range) {
    state = state.copyWith(
      filter: PeriodFilter.custom,
      customRange: range,
    );
  }

  DateTimeRange getDateRange() {
    if (state.filter == PeriodFilter.custom && state.customRange != null) {
      return state.customRange!;
    }
    return PeriodFilterHelper.getDateRangeForFilter(state.filter);
  }

  String getDisplayName() {
    switch (state.filter) {
      case PeriodFilter.today:
        return 'Today';
      case PeriodFilter.yesterday:
        return 'Yesterday';
      case PeriodFilter.last7Days:
        return 'Last 7 Days';
      case PeriodFilter.last30Days:
        return 'Last 30 Days';
      case PeriodFilter.thisWeek:
        return 'This Week';
      case PeriodFilter.thisMonth:
        return 'This Month';
      case PeriodFilter.thisQuarter:
        return 'This Quarter';
      case PeriodFilter.thisYear:
        return 'This Year';
      case PeriodFilter.custom:
        if (state.customRange != null) {
          final start = state.customRange!.start;
          final end = state.customRange!.end;
          return '${_formatDate(start)} - ${_formatDate(end)}';
        }
        return 'Custom Range';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

final periodFilterProvider =
    StateNotifierProvider<PeriodFilterNotifier, PeriodFilterState>((ref) {
  return PeriodFilterNotifier();
});

/// Pure helper class for computing date ranges from period filters
/// without mutating any state
class PeriodFilterHelper {
  /// Get date range for a given period filter (pure function, no side effects)
  static DateTimeRange getDateRangeForFilter(PeriodFilter filter) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (filter) {
      case PeriodFilter.today:
        return DateTimeRange(start: today, end: now);

      case PeriodFilter.yesterday:
        final yesterday = today.subtract(const Duration(days: 1));
        final endOfYesterday = yesterday.add(const Duration(days: 1))
            .subtract(const Duration(seconds: 1));
        return DateTimeRange(start: yesterday, end: endOfYesterday);

      case PeriodFilter.last7Days:
        final start = today.subtract(const Duration(days: 7));
        return DateTimeRange(start: start, end: now);

      case PeriodFilter.last30Days:
        final start = today.subtract(const Duration(days: 30));
        return DateTimeRange(start: start, end: now);

      case PeriodFilter.thisWeek:
        // Start of week (Monday)
        final weekday = now.weekday;
        final startOfWeek = today.subtract(Duration(days: weekday - 1));
        return DateTimeRange(start: startOfWeek, end: now);

      case PeriodFilter.thisMonth:
        final startOfMonth = DateTime(now.year, now.month, 1);
        return DateTimeRange(start: startOfMonth, end: now);

      case PeriodFilter.thisQuarter:
        final quarter = (now.month - 1) ~/ 3;
        final startOfQuarter = DateTime(now.year, quarter * 3 + 1, 1);
        return DateTimeRange(start: startOfQuarter, end: now);

      case PeriodFilter.thisYear:
        final startOfYear = DateTime(now.year, 1, 1);
        return DateTimeRange(start: startOfYear, end: now);

      case PeriodFilter.custom:
        // Custom range should be handled by the notifier
        throw ArgumentError('Custom range must be provided via PeriodFilterState');
    }
  }
}
