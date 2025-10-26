import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../models/chart_data.dart';
import '../widgets/time_period_filter.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/monthly_line_chart.dart';

/// Analytics screen displaying expense data through various chart types
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ChartTimePeriod _selectedPeriod = ChartTimePeriod.last3Months;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    // Generate Material Design color palette from theme
    final themeColors = [
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
      Colors.deepPurple,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.teal,
      Colors.pink,
    ];

    // Get chart data based on selected period
    final categoryData = provider.getCategoryChartData(
      _selectedPeriod,
      colors: themeColors,
    );
    final monthlyData = provider.getMonthlyChartData(_selectedPeriod);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: colorScheme.onPrimary,
          labelColor: colorScheme.onPrimary,
          unselectedLabelColor: colorScheme.onPrimary.withValues(alpha: 0.7),
          tabs: const [
            Tab(text: 'Pie'),
            Tab(text: 'Line'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Time period filter
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TimePeriodFilter(
              selectedPeriod: _selectedPeriod,
              onPeriodChanged: (period) {
                setState(() {
                  _selectedPeriod = period;
                });
              },
            ),
          ),
          // Chart tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Pie Chart Tab
                CategoryPieChart(data: categoryData),
                // Line Chart Tab
                MonthlyLineChart(data: monthlyData),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
