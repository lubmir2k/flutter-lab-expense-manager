import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:localstorage/localstorage.dart';
import 'package:expense_app/providers/expense_provider.dart';
import 'package:expense_app/models/expense.dart';
import 'package:expense_app/models/chart_data.dart';

@GenerateMocks([LocalStorage])
import 'expense_provider_test.mocks.dart';

void main() {
  group('ExpenseProvider Analytics Tests', () {
    late MockLocalStorage mockStorage;
    late ExpenseProvider provider;
    final now = DateTime.now();

    setUp(() {
      mockStorage = MockLocalStorage();
      when(mockStorage.getItem('expenses')).thenReturn(null);
      provider = ExpenseProvider(mockStorage);
    });

    group('Time Period Filtering', () {
      test('getExpensesByTimePeriod returns empty list when no expenses', () {
        final result =
            provider.getExpensesByTimePeriod(ChartTimePeriod.last3Months);
        expect(result, isEmpty);
      });

      test('getExpensesByTimePeriod returns all expenses for allTime period',
          () {
        // Add expenses from different time periods
        final expense1 = Expense(
          id: '1',
          amount: 100.0,
          categoryId: '1',
          payee: 'Store A',
          note: '',
          date: DateTime(2024, 1, 1),
          tag: 'Food',
        );
        final expense2 = Expense(
          id: '2',
          amount: 200.0,
          categoryId: '1',
          payee: 'Store B',
          note: '',
          date: DateTime(2025, 1, 1),
          tag: 'Food',
        );

        provider.addOrUpdateExpense(expense1);
        provider.addOrUpdateExpense(expense2);

        final result =
            provider.getExpensesByTimePeriod(ChartTimePeriod.allTime);
        expect(result.length, equals(2));
        expect(result, contains(expense1));
        expect(result, contains(expense2));
      });

      test('getExpensesByTimePeriod filters expenses within last 3 months', () {
        // Dart's DateTime constructor handles month rollover automatically
        final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
        final fourMonthsAgo = DateTime(now.year, now.month - 4, now.day);

        final expense1 = Expense(
          id: '1',
          amount: 100.0,
          categoryId: '1',
          payee: 'Recent',
          note: '',
          date: threeMonthsAgo.add(const Duration(days: 1)),
          tag: 'Food',
        );
        final expense2 = Expense(
          id: '2',
          amount: 200.0,
          categoryId: '1',
          payee: 'Old',
          note: '',
          date: fourMonthsAgo,
          tag: 'Food',
        );

        provider.addOrUpdateExpense(expense1);
        provider.addOrUpdateExpense(expense2);

        final result =
            provider.getExpensesByTimePeriod(ChartTimePeriod.last3Months);
        expect(result.length, equals(1));
        expect(result.first.id, equals('1'));
      });

      test('getExpensesByTimePeriod filters expenses within last 6 months', () {
        final sixMonthsAgo = DateTime(now.year, now.month - 6, now.day);
        final sevenMonthsAgo = DateTime(now.year, now.month - 7, now.day);

        final expense1 = Expense(
          id: '1',
          amount: 100.0,
          categoryId: '1',
          payee: 'Recent',
          note: '',
          date: sixMonthsAgo.add(const Duration(days: 1)),
          tag: 'Food',
        );
        final expense2 = Expense(
          id: '2',
          amount: 200.0,
          categoryId: '1',
          payee: 'Old',
          note: '',
          date: sevenMonthsAgo,
          tag: 'Food',
        );

        provider.addOrUpdateExpense(expense1);
        provider.addOrUpdateExpense(expense2);

        final result =
            provider.getExpensesByTimePeriod(ChartTimePeriod.last6Months);
        expect(result.length, equals(1));
        expect(result.first.id, equals('1'));
      });

      test('getExpensesByTimePeriod filters expenses within last 12 months',
          () {
        final twelveMonthsAgo = DateTime(now.year, now.month - 12, now.day);
        final thirteenMonthsAgo = DateTime(now.year, now.month - 13, now.day);

        final expense1 = Expense(
          id: '1',
          amount: 100.0,
          categoryId: '1',
          payee: 'Recent',
          note: '',
          date: twelveMonthsAgo.add(const Duration(days: 1)),
          tag: 'Food',
        );
        final expense2 = Expense(
          id: '2',
          amount: 200.0,
          categoryId: '1',
          payee: 'Old',
          note: '',
          date: thirteenMonthsAgo,
          tag: 'Food',
        );

        provider.addOrUpdateExpense(expense1);
        provider.addOrUpdateExpense(expense2);

        final result =
            provider.getExpensesByTimePeriod(ChartTimePeriod.last12Months);
        expect(result.length, equals(1));
        expect(result.first.id, equals('1'));
      });
    });

    group('Category Chart Data', () {
      test('getCategoryChartData returns empty list when no expenses', () {
        final result =
            provider.getCategoryChartData(ChartTimePeriod.allTime);
        expect(result, isEmpty);
      });

      test('getCategoryChartData calculates totals and percentages correctly',
          () {
        final expense1 = Expense(
          id: '1',
          amount: 100.0,
          categoryId: '1',
          payee: 'Store A',
          note: '',
          date: now,
          tag: 'Food',
        );
        final expense2 = Expense(
          id: '2',
          amount: 150.0,
          categoryId: '1',
          payee: 'Store B',
          note: '',
          date: now,
          tag: 'Food',
        );
        final expense3 = Expense(
          id: '3',
          amount: 250.0,
          categoryId: '2',
          payee: 'Store C',
          note: '',
          date: now,
          tag: 'Transport',
        );

        provider.addOrUpdateExpense(expense1);
        provider.addOrUpdateExpense(expense2);
        provider.addOrUpdateExpense(expense3);

        final result =
            provider.getCategoryChartData(ChartTimePeriod.allTime);

        expect(result.length, equals(2));

        // Find the categories
        final foodCategory =
            result.firstWhere((cat) => cat.categoryId == '1');
        final transportCategory =
            result.firstWhere((cat) => cat.categoryId == '2');

        expect(foodCategory.amount, equals(250.0));
        expect(foodCategory.percentage, equals(50.0)); // 250 / 500 * 100
        expect(foodCategory.categoryName, equals('Food'));

        expect(transportCategory.amount, equals(250.0));
        expect(transportCategory.percentage, equals(50.0));
        expect(transportCategory.categoryName, equals('Transport'));
      });

      test('getCategoryChartData respects time period filter', () {
        final oldExpense = Expense(
          id: '1',
          amount: 100.0,
          categoryId: '1',
          payee: 'Store A',
          note: '',
          date: DateTime(2020, 1, 1),
          tag: 'Food',
        );
        final recentExpense = Expense(
          id: '2',
          amount: 200.0,
          categoryId: '2',
          payee: 'Store B',
          note: '',
          date: now,
          tag: 'Transport',
        );

        provider.addOrUpdateExpense(oldExpense);
        provider.addOrUpdateExpense(recentExpense);

        final result =
            provider.getCategoryChartData(ChartTimePeriod.last3Months);

        expect(result.length, equals(1));
        expect(result.first.categoryId, equals('2'));
        expect(result.first.amount, equals(200.0));
        expect(result.first.percentage, equals(100.0));
      });

      test('getCategoryChartData assigns unique colors to categories', () {
        final expense1 = Expense(
          id: '1',
          amount: 100.0,
          categoryId: '1',
          payee: 'Store A',
          note: '',
          date: now,
          tag: 'Food',
        );
        final expense2 = Expense(
          id: '2',
          amount: 200.0,
          categoryId: '2',
          payee: 'Store B',
          note: '',
          date: now,
          tag: 'Transport',
        );

        provider.addOrUpdateExpense(expense1);
        provider.addOrUpdateExpense(expense2);

        final result =
            provider.getCategoryChartData(ChartTimePeriod.allTime);

        expect(result.length, equals(2));
        // Colors should be different
        expect(result[0].color, isNot(equals(result[1].color)));
      });
    });

    group('Monthly Chart Data', () {
      test('getMonthlyChartData returns empty list when no expenses', () {
        final result =
            provider.getMonthlyChartData(ChartTimePeriod.allTime);
        expect(result, isEmpty);
      });

      test('getMonthlyChartData aggregates expenses by month', () {
        final expense1 = Expense(
          id: '1',
          amount: 100.0,
          categoryId: '1',
          payee: 'Store A',
          note: '',
          date: DateTime(2025, 1, 5),
          tag: 'Food',
        );
        final expense2 = Expense(
          id: '2',
          amount: 150.0,
          categoryId: '1',
          payee: 'Store B',
          note: '',
          date: DateTime(2025, 1, 20),
          tag: 'Food',
        );
        final expense3 = Expense(
          id: '3',
          amount: 200.0,
          categoryId: '2',
          payee: 'Store C',
          note: '',
          date: DateTime(2025, 2, 10),
          tag: 'Transport',
        );

        provider.addOrUpdateExpense(expense1);
        provider.addOrUpdateExpense(expense2);
        provider.addOrUpdateExpense(expense3);

        final result =
            provider.getMonthlyChartData(ChartTimePeriod.allTime);

        expect(result.length, equals(2));

        // Check January total
        final janData =
            result.firstWhere((m) => m.month.month == 1 && m.month.year == 2025);
        expect(janData.amount, equals(250.0)); // 100 + 150

        // Check February total
        final febData =
            result.firstWhere((m) => m.month.month == 2 && m.month.year == 2025);
        expect(febData.amount, equals(200.0));
      });

      test('getMonthlyChartData respects time period filter', () {
        final oldExpense = Expense(
          id: '1',
          amount: 100.0,
          categoryId: '1',
          payee: 'Store A',
          note: '',
          date: DateTime(2020, 1, 1),
          tag: 'Food',
        );
        final recentExpense = Expense(
          id: '2',
          amount: 200.0,
          categoryId: '2',
          payee: 'Store B',
          note: '',
          date: now, // Use current date
          tag: 'Transport',
        );

        provider.addOrUpdateExpense(oldExpense);
        provider.addOrUpdateExpense(recentExpense);

        final result =
            provider.getMonthlyChartData(ChartTimePeriod.last3Months);

        expect(result.length, equals(1));
        expect(result.first.month.year, equals(now.year));
        expect(result.first.month.month, equals(now.month));
        expect(result.first.amount, equals(200.0));
      });

      test('getMonthlyChartData handles single expense', () {
        final expense = Expense(
          id: '1',
          amount: 100.0,
          categoryId: '1',
          payee: 'Store A',
          note: '',
          date: DateTime(2025, 1, 15),
          tag: 'Food',
        );

        provider.addOrUpdateExpense(expense);

        final result =
            provider.getMonthlyChartData(ChartTimePeriod.allTime);

        expect(result.length, equals(1));
        expect(result.first.amount, equals(100.0));
        expect(result.first.month.year, equals(2025));
        expect(result.first.month.month, equals(1));
      });

      test('getMonthlyChartData sorts months chronologically', () {
        final expense1 = Expense(
          id: '1',
          amount: 100.0,
          categoryId: '1',
          payee: 'Store A',
          note: '',
          date: DateTime(2025, 3, 15),
          tag: 'Food',
        );
        final expense2 = Expense(
          id: '2',
          amount: 200.0,
          categoryId: '1',
          payee: 'Store B',
          note: '',
          date: DateTime(2025, 1, 15),
          tag: 'Food',
        );
        final expense3 = Expense(
          id: '3',
          amount: 300.0,
          categoryId: '1',
          payee: 'Store C',
          note: '',
          date: DateTime(2025, 2, 15),
          tag: 'Food',
        );

        provider.addOrUpdateExpense(expense1);
        provider.addOrUpdateExpense(expense2);
        provider.addOrUpdateExpense(expense3);

        final result =
            provider.getMonthlyChartData(ChartTimePeriod.allTime);

        expect(result.length, equals(3));
        expect(result[0].month.month, equals(1)); // January first
        expect(result[1].month.month, equals(2)); // February second
        expect(result[2].month.month, equals(3)); // March third
      });
    });

    group('Total for Period', () {
      test('getTotalForPeriod returns 0 when no expenses', () {
        final result = provider.getTotalForPeriod(ChartTimePeriod.allTime);
        expect(result, equals(0.0));
      });

      test('getTotalForPeriod calculates correct total for all expenses', () {
        final expense1 = Expense(
          id: '1',
          amount: 100.0,
          categoryId: '1',
          payee: 'Store A',
          note: '',
          date: now,
          tag: 'Food',
        );
        final expense2 = Expense(
          id: '2',
          amount: 250.50,
          categoryId: '2',
          payee: 'Store B',
          note: '',
          date: now,
          tag: 'Transport',
        );

        provider.addOrUpdateExpense(expense1);
        provider.addOrUpdateExpense(expense2);

        final result = provider.getTotalForPeriod(ChartTimePeriod.allTime);
        expect(result, equals(350.50));
      });

      test('getTotalForPeriod respects time period filter', () {
        final oldExpense = Expense(
          id: '1',
          amount: 100.0,
          categoryId: '1',
          payee: 'Store A',
          note: '',
          date: DateTime(2020, 1, 1),
          tag: 'Food',
        );
        final recentExpense = Expense(
          id: '2',
          amount: 200.0,
          categoryId: '2',
          payee: 'Store B',
          note: '',
          date: now,
          tag: 'Transport',
        );

        provider.addOrUpdateExpense(oldExpense);
        provider.addOrUpdateExpense(recentExpense);

        final result =
            provider.getTotalForPeriod(ChartTimePeriod.last3Months);
        expect(result, equals(200.0));
      });
    });
  });
}
