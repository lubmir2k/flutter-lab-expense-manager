import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../models/tag.dart';

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  List<Category> _categories = [];
  List<Tag> _tags = [];

  List<Expense> get expenses => _expenses;
  List<Category> get categories => _categories;
  List<Tag> get tags => _tags;

  ExpenseProvider() {
    _loadExpensesFromStorage();
    _loadCategoriesFromStorage();
    _loadTagsFromStorage();
  }

  // EXPENSE MANAGEMENT
  void _loadExpensesFromStorage() {
    var storedExpenses = localStorage.getItem('expenses');
    if (storedExpenses != null) {
      try {
        _expenses = List<Expense>.from(
          (jsonDecode(storedExpenses) as List).map((item) => Expense.fromJson(item)),
        );
        notifyListeners();
      } catch (e) {
        _expenses = [];
      }
    }
  }

  void _saveExpensesToStorage() {
    localStorage.setItem('expenses', jsonEncode(_expenses.map((e) => e.toJson()).toList()));
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

  // CATEGORY MANAGEMENT
  void _loadCategoriesFromStorage() {
    var storedCategories = localStorage.getItem('categories');
    if (storedCategories != null) {
      try {
        _categories = List<Category>.from(
          (jsonDecode(storedCategories) as List).map((item) => Category.fromJson(item)),
        );
        notifyListeners();
      } catch (e) {
        _categories = [];
      }
    }
  }

  void _saveCategoriesToStorage() {
    localStorage.setItem('categories', jsonEncode(_categories.map((c) => c.toJson()).toList()));
  }

  void addCategory(Category category) {
    _categories.add(category);
    _saveCategoriesToStorage();
    notifyListeners();
  }

  void removeCategory(String id) {
    _categories.removeWhere((category) => category.id == id);
    _saveCategoriesToStorage();
    notifyListeners();
  }

  // TAG MANAGEMENT
  void _loadTagsFromStorage() {
    var storedTags = localStorage.getItem('tags');
    if (storedTags != null) {
      try {
        _tags = List<Tag>.from(
          (jsonDecode(storedTags) as List).map((item) => Tag.fromJson(item)),
        );
        notifyListeners();
      } catch (e) {
        _tags = [];
      }
    }
  }

  void _saveTagsToStorage() {
    localStorage.setItem('tags', jsonEncode(_tags.map((t) => t.toJson()).toList()));
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
