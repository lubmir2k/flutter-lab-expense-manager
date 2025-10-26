enum SortBy {
  dateNewest,
  dateOldest,
  amountHighest,
  amountLowest,
}

extension SortByExtension on SortBy {
  String get displayName {
    switch (this) {
      case SortBy.dateNewest:
        return 'Newest First';
      case SortBy.dateOldest:
        return 'Oldest First';
      case SortBy.amountHighest:
        return 'Highest Amount';
      case SortBy.amountLowest:
        return 'Lowest Amount';
    }
  }
}

class ExpenseFilter {
  final DateTime? startDate;
  final DateTime? endDate;

  ExpenseFilter({
    this.startDate,
    this.endDate,
  });

  bool get isActive => startDate != null || endDate != null;

  ExpenseFilter copyWith({
    DateTime? startDate,
    DateTime? endDate,
    bool clearStart = false,
    bool clearEnd = false,
  }) {
    return ExpenseFilter(
      startDate: clearStart ? null : (startDate ?? this.startDate),
      endDate: clearEnd ? null : (endDate ?? this.endDate),
    );
  }

  String getDisplayText() {
    if (!isActive) return '';

    if (startDate != null && endDate != null) {
      return '${_formatDate(startDate!)} - ${_formatDate(endDate!)}';
    } else if (startDate != null) {
      return 'From ${_formatDate(startDate!)}';
    } else if (endDate != null) {
      return 'Until ${_formatDate(endDate!)}';
    }
    return '';
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
