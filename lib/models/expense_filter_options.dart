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
