import 'package:flutter/material.dart';
import '../models/chart_data.dart';

/// A segmented button widget for selecting time periods for chart filtering
class TimePeriodFilter extends StatelessWidget {
  final ChartTimePeriod selectedPeriod;
  final Function(ChartTimePeriod) onPeriodChanged;

  const TimePeriodFilter({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SegmentedButton<ChartTimePeriod>(
        segments: ChartTimePeriod.values.map((period) {
          return ButtonSegment<ChartTimePeriod>(
            value: period,
            label: Text(period.displayName),
          );
        }).toList(),
        selected: {selectedPeriod},
        onSelectionChanged: (Set<ChartTimePeriod> newSelection) {
          // SegmentedButton can only have one selection for our use case
          if (newSelection.isNotEmpty) {
            onPeriodChanged(newSelection.first);
          }
        },
      ),
    );
  }
}
