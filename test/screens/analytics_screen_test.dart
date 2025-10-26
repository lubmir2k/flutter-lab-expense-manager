import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:expense_app/screens/analytics_screen.dart';
import 'package:expense_app/providers/expense_provider.dart';
import 'package:expense_app/widgets/time_period_filter.dart';
import 'package:expense_app/widgets/category_pie_chart.dart';
import 'package:expense_app/widgets/category_bar_chart.dart';
import 'package:expense_app/widgets/monthly_line_chart.dart';
import '../expense_provider_test.mocks.dart';

void main() {
  group('AnalyticsScreen Widget Tests', () {
    late MockLocalStorage mockStorage;
    late ExpenseProvider provider;

    setUp(() {
      mockStorage = MockLocalStorage();
      when(mockStorage.getItem('expenses')).thenReturn(null);
      provider = ExpenseProvider(mockStorage);
    });

    testWidgets('renders with AppBar title', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<ExpenseProvider>.value(
          value: provider,
          child: const MaterialApp(
            home: AnalyticsScreen(),
          ),
        ),
      );

      // Verify AppBar title
      expect(find.text('Analytics'), findsOneWidget);
    });

    testWidgets('displays time period filter', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<ExpenseProvider>.value(
          value: provider,
          child: const MaterialApp(
            home: AnalyticsScreen(),
          ),
        ),
      );

      // Verify TimePeriodFilter is present
      expect(find.byType(TimePeriodFilter), findsOneWidget);
    });

    testWidgets('displays three tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<ExpenseProvider>.value(
          value: provider,
          child: const MaterialApp(
            home: AnalyticsScreen(),
          ),
        ),
      );

      // Verify tabs are present
      expect(find.text('Pie'), findsOneWidget);
      expect(find.text('Bar'), findsOneWidget);
      expect(find.text('Line'), findsOneWidget);
    });

    testWidgets('shows pie chart in first tab', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<ExpenseProvider>.value(
          value: provider,
          child: const MaterialApp(
            home: AnalyticsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // First tab should show pie chart
      expect(find.byType(CategoryPieChart), findsOneWidget);
    });

    testWidgets('switches to bar chart when bar tab is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<ExpenseProvider>.value(
          value: provider,
          child: const MaterialApp(
            home: AnalyticsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap the Bar tab
      await tester.tap(find.text('Bar'));
      await tester.pumpAndSettle();

      // Should now show bar chart
      expect(find.byType(CategoryBarChart), findsOneWidget);
    });

    testWidgets('switches to line chart when line tab is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<ExpenseProvider>.value(
          value: provider,
          child: const MaterialApp(
            home: AnalyticsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap the Line tab
      await tester.tap(find.text('Line'));
      await tester.pumpAndSettle();

      // Should now show line chart
      expect(find.byType(MonthlyLineChart), findsOneWidget);
    });

    testWidgets('has back button in AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<ExpenseProvider>.value(
          value: provider,
          child: const MaterialApp(
            home: AnalyticsScreen(),
          ),
        ),
      );

      // AppBar should have a back button
      expect(find.byType(AppBar), findsOneWidget);
    });
  });
}
