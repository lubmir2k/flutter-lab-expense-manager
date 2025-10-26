import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:localstorage/localstorage.dart';
import 'package:expense_app/providers/expense_provider.dart';

// This will generate the mock class
@GenerateMocks([LocalStorage])
import 'expense_provider_test.mocks.dart';

void main() {
  group('ExpenseProvider Storage Tests', () {
    late MockLocalStorage mockStorage;

    setUp(() {
      mockStorage = MockLocalStorage();
    });

    test('should only remove expenses key when data is corrupted, not clear all storage', () {
      // Arrange: Set up corrupted data (string instead of list)
      when(mockStorage.getItem('expenses')).thenReturn('corrupted_string_data');

      // Act: Create provider (which will try to load from storage)
      final provider = ExpenseProvider(mockStorage);

      // Assert: Verify that removeItem('expenses') was called, NOT clear()
      verify(mockStorage.removeItem('expenses')).called(1);
      verifyNever(mockStorage.clear());

      // Verify expenses list is empty after handling corruption
      expect(provider.expenses, isEmpty);
    });

    test('should load valid expenses without calling removeItem or clear', () {
      // Arrange: Set up valid data (LocalStorage v5.0.0 returns JSON string)
      final validData = [
        {
          'id': '1',
          'payee': 'Test Store',
          'amount': 50.0,
          'date': DateTime.now().toIso8601String(),
          'categoryId': '1',
          'tag': 'Test',
          'note': 'Test note'
        }
      ];
      when(mockStorage.getItem('expenses')).thenReturn(jsonEncode(validData));

      // Act: Create provider
      final provider = ExpenseProvider(mockStorage);

      // Assert: No storage modification should occur with valid data
      verifyNever(mockStorage.removeItem(any));
      verifyNever(mockStorage.clear());

      // Verify expenses were loaded
      expect(provider.expenses, hasLength(1));
    });

    test('should not call removeItem or clear when no stored data exists', () {
      // Arrange: No stored data
      when(mockStorage.getItem('expenses')).thenReturn(null);

      // Act: Create provider
      final provider = ExpenseProvider(mockStorage);

      // Assert: No storage modification
      verifyNever(mockStorage.removeItem(any));
      verifyNever(mockStorage.clear());

      // Verify expenses is empty
      expect(provider.expenses, isEmpty);
    });
  });
}
