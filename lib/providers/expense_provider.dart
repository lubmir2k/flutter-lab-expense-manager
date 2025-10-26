import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/tag.dart';
import '../models/expense_filter_options.dart';
import '../models/chart_data.dart';
import 'package:localstorage/localstorage.dart';
import 'dart:convert';
class ExpenseProvider with ChangeNotifier {
  final LocalStorage storage;
  // List of expenses
  List<Expense> _expenses = [];
  // Sorting state
  SortBy _sortBy = SortBy.dateNewest;
  // Cache for sorted expenses
  List<Expense>? _cachedSortedExpenses;
  bool _sortedExpensesCacheValid = false;
  // List of categories
  final List<ExpenseCategory> _categories = [
    ExpenseCategory(id: '1', name: 'Food', isDefault: true),
    ExpenseCategory(id: '2', name: 'Transport', isDefault: true),
    ExpenseCategory(id: '3', name: 'Entertainment', isDefault: true),
    ExpenseCategory(id: '4', name: 'Office', isDefault: true),
    ExpenseCategory(id: '5', name: 'Gym', isDefault: true),
  ];
  // List of tags
  final List<Tag> _tags = [
    Tag(id: '1', name: 'Breakfast'),
    Tag(id: '2', name: 'Lunch'),
    Tag(id: '3', name: 'Dinner'),
    Tag(id: '4', name: 'Treat'),
    Tag(id: '5', name: 'Cafe'),
    Tag(id: '6', name: 'Restaurant'),
    Tag(id: '7', name: 'Train'),
    Tag(id: '8', name: 'Vacation'),
    Tag(id: '9', name: 'Birthday'),
    Tag(id: '10', name: 'Diet'),
    Tag(id: '11', name: 'MovieNight'),
    Tag(id: '12', name: 'Tech'),
    Tag(id: '13', name: 'CarStuff'),
    Tag(id: '14', name: 'SelfCare'),
    Tag(id: '15', name: 'Streaming'),
  ];
  // Getters
  List<Expense> get expenses => _expenses;
  List<ExpenseCategory> get categories => _categories;
  List<Tag> get tags => _tags;
  SortBy get sortBy => _sortBy;

  // Get sorted expenses (cached for performance)
  List<Expense> get sortedExpenses {
    if (_sortedExpensesCacheValid && _cachedSortedExpenses != null) {
      return _cachedSortedExpenses!;
    }

    _cachedSortedExpenses = List<Expense>.from(_expenses)
      ..sort((a, b) {
        switch (_sortBy) {
          case SortBy.dateNewest:
            return b.date.compareTo(a.date);
          case SortBy.dateOldest:
            return a.date.compareTo(b.date);
          case SortBy.amountHighest:
            return b.amount.compareTo(a.amount);
          case SortBy.amountLowest:
            return a.amount.compareTo(b.amount);
        }
      });

    _sortedExpensesCacheValid = true;
    return _cachedSortedExpenses!;
  }

  // Invalidate sorted expenses cache
  void _invalidateSortedExpensesCache() {
    _sortedExpensesCacheValid = false;
  }

  ExpenseProvider(this.storage) {
    _loadExpensesFromStorage();
  }
  void _loadExpensesFromStorage() {
    var storedExpenses = storage.getItem('expenses');
    if (storedExpenses != null) {
      try {
        _expenses = List<Expense>.from(
          (jsonDecode(storedExpenses) as List).map((item) => Expense.fromJson(item)),
        );
      } catch (e, s) {
        // Log the error and stack trace for better debugging
        debugPrint('Failed to load expenses from storage. Error: $e\nStack trace: $s');
        // Clear corrupted data for expenses only
        storage.removeItem('expenses');
        _expenses = [];
      }
      _invalidateSortedExpensesCache();
      notifyListeners();
    }
  }
  void _saveExpensesToStorage() {
    storage.setItem(
        'expenses', jsonEncode(_expenses.map((e) => e.toJson()).toList()));
  }
  void addOrUpdateExpense(Expense expense) {
    int index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      // Update existing expense
      _expenses[index] = expense;
    } else {
      // Add new expense
      _expenses.add(expense);
    }
    _invalidateSortedExpensesCache();
    _saveExpensesToStorage(); // Save the updated list to local storage
    notifyListeners();
  }
  // Add a category
  void addCategory(ExpenseCategory category) {
    if (!_categories.any((cat) => cat.name == category.name)) {
      _categories.add(category);
      notifyListeners();
    }
  }
  // Delete a category
  void deleteCategory(String id) {
    _categories.removeWhere((category) => category.id == id);
    notifyListeners();
  }
  // Add a tag
  void addTag(Tag tag) {
    if (!_tags.any((t) => t.name == tag.name)) {
      _tags.add(tag);
      notifyListeners();
    }
  }
  // Delete a tag
  void deleteTag(String id) {
    _tags.removeWhere((tag) => tag.id == id);
    notifyListeners();
  }
  void removeExpense(String id) {
    _expenses.removeWhere((expense) => expense.id == id);
    _invalidateSortedExpensesCache();
    _saveExpensesToStorage(); // Save the updated list to local storage
    notifyListeners();
  }

  // SORTING
  void setSortBy(SortBy sortBy) {
    _sortBy = sortBy;
    _invalidateSortedExpensesCache();
    notifyListeners();
  }

  // ANALYTICS METHODS

  /// Get expenses filtered by time period
  List<Expense> getExpensesByTimePeriod(ChartTimePeriod period) {
    if (period == ChartTimePeriod.allTime) {
      return List.from(_expenses);
    }

    final now = DateTime.now();
    final months = period.months!;

    // Dart's DateTime constructor handles negative months automatically
    final cutoffDate = DateTime(now.year, now.month - months, now.day);

    return _expenses.where((expense) {
      return expense.date.isAfter(cutoffDate) || expense.date.isAtSameMomentAs(cutoffDate);
    }).toList();
  }

  /// Get category chart data with totals and percentages
  ///
  /// [colors] - Optional list of colors for categories. If not provided, uses default palette.
  List<CategoryChartData> getCategoryChartData(
    ChartTimePeriod period, {
    List<Color>? colors,
  }) {
    final filteredExpenses = getExpensesByTimePeriod(period);

    if (filteredExpenses.isEmpty) {
      return [];
    }

    // Calculate total for percentages
    final grandTotal = filteredExpenses.fold<double>(
      0.0,
      (sum, expense) => sum + expense.amount,
    );

    // Group expenses by category and calculate totals
    final Map<String, double> categoryTotals = {};
    for (final expense in filteredExpenses) {
      categoryTotals[expense.categoryId] =
          (categoryTotals[expense.categoryId] ?? 0.0) + expense.amount;
    }

    // Use provided colors or default palette
    final categoryColors = colors ?? [
      Colors.deepPurple,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.indigo,
      Colors.cyan,
    ];

    // Create CategoryChartData list
    final List<CategoryChartData> chartDataList = [];
    int colorIndex = 0;

    for (final entry in categoryTotals.entries) {
      final category = _categories.firstWhere(
        (cat) => cat.id == entry.key,
        orElse: () => ExpenseCategory(id: entry.key, name: 'Unknown'),
      );

      final percentage = grandTotal > 0 ? (entry.value / grandTotal) * 100 : 0.0;
      final color = categoryColors[colorIndex % categoryColors.length];

      chartDataList.add(CategoryChartData(
        categoryId: entry.key,
        categoryName: category.name,
        amount: entry.value,
        percentage: percentage,
        color: color,
      ));

      colorIndex++;
    }

    // Sort by amount descending
    chartDataList.sort((a, b) => b.amount.compareTo(a.amount));

    return chartDataList;
  }

  /// Get monthly chart data for spending trends
  List<MonthlyChartData> getMonthlyChartData(ChartTimePeriod period) {
    final filteredExpenses = getExpensesByTimePeriod(period);

    if (filteredExpenses.isEmpty) {
      return [];
    }

    // Group expenses by month
    final Map<DateTime, double> monthlyTotals = {};

    for (final expense in filteredExpenses) {
      // Normalize to first day of month for grouping
      final monthKey = DateTime(expense.date.year, expense.date.month, 1);
      monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0.0) + expense.amount;
    }

    // Convert to MonthlyChartData list
    final chartDataList = monthlyTotals.entries.map((entry) {
      return MonthlyChartData(
        month: entry.key,
        amount: entry.value,
      );
    }).toList();

    // Sort chronologically
    chartDataList.sort((a, b) => a.month.compareTo(b.month));

    return chartDataList;
  }

  /// Get total spending for a time period
  double getTotalForPeriod(ChartTimePeriod period) {
    final filteredExpenses = getExpensesByTimePeriod(period);
    return filteredExpenses.fold<double>(
      0.0,
      (sum, expense) => sum + expense.amount,
    );
  }
}