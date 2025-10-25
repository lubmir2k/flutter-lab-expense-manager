import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../models/tag.dart';

class ExpenseProvider with ChangeNotifier {
  final LocalStorage storage;
  
  // Private lists for the state
  List<Expense> _expenses = [];
  List<Category> _categories = [];
  List<Tag> _tags = [];

  // Public getters to access the state
  List<Expense> get expenses => _expenses;
  List<Category> get categories => _categories;
  List<Tag> get tags => _tags;

  // Constructor: Loads all data upon initialization
  ExpenseProvider(this.storage) {
    _loadExpensesFromStorage();
    _loadCategoriesFromStorage();
    _loadTagsFromStorage();
  }

  // ====================================================================
  // 1. EXPENSE MANAGEMENT
  // ====================================================================

  void _loadExpensesFromStorage() async {
    await storage.ready;
    var storedExpenses = storage.getItem('expenses');
    if (storedExpenses != null) {
      _expenses = List<Expense>.from(
        (storedExpenses as List).map((item) => Expense.fromJson(item)),
      );
      notifyListeners();
    }
  }

  void _saveExpensesToStorage() {
    storage.setItem('expenses', _expenses.map((e) => e.toJson()).toList());
  }

  void addExpense(Expense expense) {
    _expenses.add(expense);
    _saveExpensesToStorage();
    notifyListeners();
  }

  void addOrUpdateExpense(Expense expense) {
    int index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense;
    } else {
      _expenses.add(expense);
    }
    _saveExpensesToStorage();
    notifyListeners();
  }

  void removeExpense(String id) {
    _expenses.removeWhere((expense) => expense.id == id);
    _saveExpensesToStorage();
    notifyListeners();
  }

  // ====================================================================
  // 2. CATEGORY MANAGEMENT
  // ====================================================================

  void _loadCategoriesFromStorage() async {
    await storage.ready;
    var storedCategories = storage.getItem('categories');
    if (storedCategories != null) {
      _categories = List<Category>.from(
        (storedCategories as List).map((item) => Category.fromJson(item)),
      );
      notifyListeners();
    }
  }

  void _saveCategoriesToStorage() {
    storage.setItem('categories', _categories.map((c) => c.toJson()).toList());
  }

  void addCategory(Category category) {
    _categories.add(category);
    _saveCategoriesToStorage();
    notifyListeners();
  }

  void removeCategory(String id) {
    _categories.removeWhere((category) => category.id == id);
    // Note: In a robust app, you'd also check and update/remove related expenses here!
    _saveCategoriesToStorage();
    notifyListeners();
  }

  // ====================================================================
  // 3. TAG MANAGEMENT
  // ====================================================================

  void _loadTagsFromStorage() async {
    await storage.ready;
    var storedTags = storage.getItem('tags');
    if (storedTags != null) {
      _tags = List<Tag>.from(
        (storedTags as List).map((item) => Tag.fromJson(item)),
      );
      notifyListeners();
    }
  }

  void _saveTagsToStorage() {
    storage.setItem('tags', _tags.map((t) => t.toJson()).toList());
  }

  void addTag(Tag tag) {
    _tags.add(tag);
    _saveTagsToStorage();
    notifyListeners();
  }

  void removeTag(String id) {
    _tags.removeWhere((tag) => tag.id == id);
    _saveTagsToStorage();
    notifyListeners();
  }
}