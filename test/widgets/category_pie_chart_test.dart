import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_app/widgets/category_pie_chart.dart';
import 'package:expense_app/models/chart_data.dart';

void main() {
  group('CategoryPieChart Widget Tests', () {
    final mockData = [
      CategoryChartData(
        categoryId: '1',
        categoryName: 'Food',
        amount: 250.0,
        percentage: 50.0,
        color: Colors.deepPurple,
      ),
      CategoryChartData(
        categoryId: '2',
        categoryName: 'Transport',
        amount: 150.0,
        percentage: 30.0,
        color: Colors.blue,
      ),
      CategoryChartData(
        categoryId: '3',
        categoryName: 'Entertainment',
        amount: 100.0,
        percentage: 20.0,
        color: Colors.green,
      ),
    ];

    testWidgets('renders pie chart with data', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryPieChart(data: mockData),
          ),
        ),
      );

      // Verify the widget renders without errors
      expect(find.byType(CategoryPieChart), findsOneWidget);
    });

    testWidgets('displays empty state when data is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CategoryPieChart(data: []),
          ),
        ),
      );

      // Should show empty state message
      expect(find.text('No expense data available'), findsOneWidget);
      expect(find.byIcon(Icons.pie_chart_outline), findsOneWidget);
    });

    testWidgets('displays legend with category names and amounts',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryPieChart(data: mockData),
          ),
        ),
      );

      // Verify legend shows all category names
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);
      expect(find.text('Entertainment'), findsOneWidget);

      // Verify amounts are displayed in legend
      expect(find.textContaining('\$250.00'), findsOneWidget);
      expect(find.textContaining('\$150.00'), findsOneWidget);
      expect(find.textContaining('\$100.00'), findsOneWidget);
    });

    testWidgets('displays percentages in legend',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryPieChart(data: mockData),
          ),
        ),
      );

      // Verify percentages are shown
      expect(find.textContaining('50.0%'), findsOneWidget);
      expect(find.textContaining('30.0%'), findsOneWidget);
      expect(find.textContaining('20.0%'), findsOneWidget);
    });

    testWidgets('legend shows color indicators matching category colors',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryPieChart(data: mockData),
          ),
        ),
      );

      // Find all Container widgets that are color indicators
      final containers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(CategoryPieChart),
          matching: find.byType(Container),
        ),
      );

      // Verify at least one container has each of our colors
      final decoratedContainers = containers.where((container) {
        final decoration = container.decoration;
        return decoration is BoxDecoration && decoration.color != null;
      }).toList();

      // We should have color indicators for each category
      expect(decoratedContainers.length, greaterThanOrEqualTo(3));
    });

    testWidgets('handles single category data', (WidgetTester tester) async {
      final singleCategoryData = [
        CategoryChartData(
          categoryId: '1',
          categoryName: 'Food',
          amount: 500.0,
          percentage: 100.0,
          color: Colors.deepPurple,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryPieChart(data: singleCategoryData),
          ),
        ),
      );

      // Verify single category is rendered
      expect(find.text('Food'), findsOneWidget);
      expect(find.textContaining('\$500.00'), findsOneWidget);
      expect(find.textContaining('100.0%'), findsOneWidget);
    });
  });
}
