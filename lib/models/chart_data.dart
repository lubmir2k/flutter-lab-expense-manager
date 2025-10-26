import 'package:flutter/material.dart';

/// Enum for time period selection in charts
enum ChartTimePeriod {
  last3Months,
  last6Months,
  last12Months,
  allTime;

  String get displayName {
    switch (this) {
      case ChartTimePeriod.last3Months:
        return '3M';
      case ChartTimePeriod.last6Months:
        return '6M';
      case ChartTimePeriod.last12Months:
        return '12M';
      case ChartTimePeriod.allTime:
        return 'ALL';
    }
  }

  int? get months {
    switch (this) {
      case ChartTimePeriod.last3Months:
        return 3;
      case ChartTimePeriod.last6Months:
        return 6;
      case ChartTimePeriod.last12Months:
        return 12;
      case ChartTimePeriod.allTime:
        return null; // null means all time
    }
  }
}

/// Data model for category-based charts (pie chart and bar chart)
class CategoryChartData {
  final String categoryId;
  final String categoryName;
  final double amount;
  final double percentage;
  final Color color;

  const CategoryChartData({
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.percentage,
    required this.color,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryChartData &&
          runtimeType == other.runtimeType &&
          categoryId == other.categoryId &&
          categoryName == other.categoryName &&
          amount == other.amount &&
          percentage == other.percentage &&
          color == other.color;

  @override
  int get hashCode =>
      categoryId.hashCode ^
      categoryName.hashCode ^
      amount.hashCode ^
      percentage.hashCode ^
      color.hashCode;

  @override
  String toString() {
    return 'CategoryChartData{categoryId: $categoryId, categoryName: $categoryName, '
        'amount: \$${amount.toStringAsFixed(2)}, percentage: ${percentage.toStringAsFixed(1)}%}';
  }
}

/// Data model for monthly spending (line chart)
class MonthlyChartData {
  final DateTime month;
  final double amount;

  /// Month abbreviations (shared across getters)
  static const _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  const MonthlyChartData({
    required this.month,
    required this.amount,
  });

  /// Get month label in format "Jan 2024"
  String get monthLabel {
    return '${_monthNames[month.month - 1]} ${month.year}';
  }

  /// Get short month label in format "Jan"
  String get shortMonthLabel {
    return _monthNames[month.month - 1];
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthlyChartData &&
          runtimeType == other.runtimeType &&
          month == other.month &&
          amount == other.amount;

  @override
  int get hashCode => month.hashCode ^ amount.hashCode;

  @override
  String toString() {
    return 'MonthlyChartData{month: $monthLabel, amount: \$${amount.toStringAsFixed(2)}}';
  }
}
