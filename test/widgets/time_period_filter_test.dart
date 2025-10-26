import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_app/widgets/time_period_filter.dart';
import 'package:expense_app/models/chart_data.dart';

void main() {
  group('TimePeriodFilter Widget Tests', () {
    testWidgets('renders all time period options', (WidgetTester tester) async {
      ChartTimePeriod? selectedPeriod;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimePeriodFilter(
              selectedPeriod: ChartTimePeriod.last3Months,
              onPeriodChanged: (period) {
                selectedPeriod = period;
              },
            ),
          ),
        ),
      );

      // Verify all 4 options are rendered
      expect(find.text('3M'), findsOneWidget);
      expect(find.text('6M'), findsOneWidget);
      expect(find.text('12M'), findsOneWidget);
      expect(find.text('ALL'), findsOneWidget);
    });

    testWidgets('highlights the selected period', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimePeriodFilter(
              selectedPeriod: ChartTimePeriod.last6Months,
              onPeriodChanged: (_) {},
            ),
          ),
        ),
      );

      // SegmentedButton should show the correct selected value
      final segmentedButton = tester.widget<SegmentedButton<ChartTimePeriod>>(
        find.byType(SegmentedButton<ChartTimePeriod>),
      );

      expect(segmentedButton.selected, equals({ChartTimePeriod.last6Months}));
    });

    testWidgets('calls onPeriodChanged when option is tapped',
        (WidgetTester tester) async {
      ChartTimePeriod? selectedPeriod;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimePeriodFilter(
              selectedPeriod: ChartTimePeriod.last3Months,
              onPeriodChanged: (period) {
                selectedPeriod = period;
              },
            ),
          ),
        ),
      );

      // Tap on the "12M" option
      await tester.tap(find.text('12M'));
      await tester.pumpAndSettle();

      // Verify callback was called with correct period
      expect(selectedPeriod, equals(ChartTimePeriod.last12Months));
    });

    testWidgets('updates visual state when selection changes',
        (WidgetTester tester) async {
      ChartTimePeriod currentPeriod = ChartTimePeriod.last3Months;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: TimePeriodFilter(
                  selectedPeriod: currentPeriod,
                  onPeriodChanged: (period) {
                    setState(() {
                      currentPeriod = period;
                    });
                  },
                ),
              );
            },
          ),
        ),
      );

      // Initial state should have 3M selected
      var segmentedButton = tester.widget<SegmentedButton<ChartTimePeriod>>(
        find.byType(SegmentedButton<ChartTimePeriod>),
      );
      expect(segmentedButton.selected, equals({ChartTimePeriod.last3Months}));

      // Tap on ALL option
      await tester.tap(find.text('ALL'));
      await tester.pumpAndSettle();

      // State should update to show ALL selected
      segmentedButton = tester.widget<SegmentedButton<ChartTimePeriod>>(
        find.byType(SegmentedButton<ChartTimePeriod>),
      );
      expect(segmentedButton.selected, equals({ChartTimePeriod.allTime}));
    });

    testWidgets('handles all period transitions correctly',
        (WidgetTester tester) async {
      final periods = <ChartTimePeriod>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimePeriodFilter(
              selectedPeriod: ChartTimePeriod.last3Months,
              onPeriodChanged: (period) {
                periods.add(period);
              },
            ),
          ),
        ),
      );

      // Test tapping each option
      await tester.tap(find.text('6M'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('12M'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('ALL'));
      await tester.pumpAndSettle();

      // Verify all callbacks were fired in order
      expect(periods, equals([
        ChartTimePeriod.last6Months,
        ChartTimePeriod.last12Months,
        ChartTimePeriod.allTime,
      ]));
    });
  });
}
