import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_app/widgets/monthly_line_chart.dart';
import 'package:expense_app/models/chart_data.dart';

void main() {
  group('MonthlyLineChart Widget Tests', () {
    final mockData = [
      MonthlyChartData(
        month: DateTime(2025, 1, 1),
        amount: 250.0,
      ),
      MonthlyChartData(
        month: DateTime(2025, 2, 1),
        amount: 350.0,
      ),
      MonthlyChartData(
        month: DateTime(2025, 3, 1),
        amount: 200.0,
      ),
    ];

    testWidgets('renders line chart with data', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthlyLineChart(data: mockData),
          ),
        ),
      );

      // Verify the widget renders without errors
      expect(find.byType(MonthlyLineChart), findsOneWidget);
    });

    testWidgets('displays empty state when data is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MonthlyLineChart(data: []),
          ),
        ),
      );

      // Should show empty state message
      expect(find.text('No expense data available'), findsOneWidget);
      expect(find.byIcon(Icons.show_chart), findsOneWidget);
    });

    testWidgets('handles single month data', (WidgetTester tester) async {
      final singleMonthData = [
        MonthlyChartData(
          month: DateTime(2025, 1, 1),
          amount: 500.0,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthlyLineChart(data: singleMonthData),
          ),
        ),
      );

      // Verify single month is rendered (widget builds successfully)
      expect(find.byType(MonthlyLineChart), findsOneWidget);
    });

    testWidgets('renders chart with multiple data points',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthlyLineChart(data: mockData),
          ),
        ),
      );

      // Verify the widget renders - fl_chart renders custom widgets
      expect(find.byType(MonthlyLineChart), findsOneWidget);
    });

    testWidgets('builds successfully with varying amounts',
        (WidgetTester tester) async {
      final varyingData = [
        MonthlyChartData(month: DateTime(2025, 1, 1), amount: 100.0),
        MonthlyChartData(month: DateTime(2025, 2, 1), amount: 500.0),
        MonthlyChartData(month: DateTime(2025, 3, 1), amount: 50.0),
        MonthlyChartData(month: DateTime(2025, 4, 1), amount: 400.0),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthlyLineChart(data: varyingData),
          ),
        ),
      );

      // Verify widget handles varying amounts
      expect(find.byType(MonthlyLineChart), findsOneWidget);
    });
  });
}
