import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import 'add_expense_screen.dart';
import 'category_management_screen.dart';
import 'tag_management_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Manager'),
        actions: [
          IconButton(
            icon: Icon(Icons.category),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CategoryManagementScreen()),
              );
            },
            tooltip: 'Manage Categories',
          ),
          IconButton(
            icon: Icon(Icons.label),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TagManagementScreen()),
              );
            },
            tooltip: 'Manage Tags',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'By Date'),
            Tab(text: 'By Category'),
          ],
        ),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          if (provider.expenses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.money_off, size: 80, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    'Add your first expense',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildByDateTab(provider.expenses),
              _buildByCategoryTab(provider.expenses, provider.categories),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddExpenseScreen()),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Add Expense',
      ),
    );
  }

  Widget _buildByDateTab(List<Expense> expenses) {
    final sortedExpenses = List<Expense>.from(expenses)
      ..sort((a, b) => b.date.compareTo(a.date));

    return ListView.builder(
      itemCount: sortedExpenses.length,
      itemBuilder: (context, index) {
        final expense = sortedExpenses[index];
        return ListTile(
          title: Text(
            '${expense.payee} - \$${expense.amount.toStringAsFixed(2)}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'Category: ${expense.categoryId} | Date: ${expense.date.toIso8601String().substring(0, 10)}',
          ),
        );
      },
    );
  }

  Widget _buildByCategoryTab(List<Expense> expenses, categories) {
    final Map<String, List<Expense>> expensesByCategory = {};

    for (var expense in expenses) {
      if (!expensesByCategory.containsKey(expense.categoryId)) {
        expensesByCategory[expense.categoryId] = [];
      }
      expensesByCategory[expense.categoryId]!.add(expense);
    }

    return ListView(
      children: expensesByCategory.entries.map((entry) {
        final categoryId = entry.key;
        final categoryExpenses = entry.value;
        final totalAmount = categoryExpenses.fold(0.0, (sum, exp) => sum + exp.amount);

        return ExpansionTile(
          title: Text(
            '$categoryId (\$${totalAmount.toStringAsFixed(2)})',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          children: categoryExpenses.map((expense) {
            return ListTile(
              contentPadding: EdgeInsets.only(left: 32, right: 16),
              title: Text('${expense.payee} - \$${expense.amount.toStringAsFixed(2)}'),
              subtitle: Text('Date: ${expense.date.toIso8601String().substring(0, 10)}'),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
