import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/tag.dart';
import '../models/expense_filter_options.dart';
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
}