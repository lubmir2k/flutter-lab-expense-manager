import 'package:flutter_test/flutter_test.dart';
import 'package:expense_app/models/expense_filter_options.dart';

void main() {
  group('SortBy Enum Tests', () {
    test('should have exactly 4 sort options', () {
      expect(SortBy.values.length, equals(4));
    });

    test('all SortBy values should have display names', () {
      // Verify each enum value has a non-empty display name
      for (final sortBy in SortBy.values) {
        expect(sortBy.displayName, isNotEmpty);
        expect(sortBy.displayName, isA<String>());
      }
    });

    test('SortBy.dateNewest should have correct display name', () {
      expect(SortBy.dateNewest.displayName, equals('Newest First'));
    });

    test('SortBy.dateOldest should have correct display name', () {
      expect(SortBy.dateOldest.displayName, equals('Oldest First'));
    });

    test('SortBy.amountHighest should have correct display name', () {
      expect(SortBy.amountHighest.displayName, equals('Highest Amount'));
    });

    test('SortBy.amountLowest should have correct display name', () {
      expect(SortBy.amountLowest.displayName, equals('Lowest Amount'));
    });

    test('display names should be unique', () {
      final displayNames = SortBy.values.map((e) => e.displayName).toList();
      final uniqueNames = displayNames.toSet();
      expect(displayNames.length, equals(uniqueNames.length));
    });
  });
}
