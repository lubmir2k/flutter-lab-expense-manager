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

  Future<bool> _confirmDelete(BuildContext context, Expense expense) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Expense'),
        content: Text('Are you sure you want to delete this expense to ${expense.payee}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Expense Manager',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 2,
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
            Tab(
              icon: Icon(Icons.calendar_today),
              text: 'By Date',
            ),
            Tab(
              icon: Icon(Icons.category),
              text: 'By Category',
            ),
          ],
        ),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          return AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: provider.expenses.isEmpty
                ? _buildEmptyState(context)
                : TabBarView(
                    key: ValueKey('expenses'),
                    controller: _tabController,
                    children: [
                      _buildByDateTab(provider.expenses, provider),
                      _buildByCategoryTab(provider.expenses, provider.categories),
                    ],
                  ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddExpenseScreen()),
          );
        },
        icon: Icon(Icons.add),
        label: Text('Add Expense'),
        tooltip: 'Add Expense',
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      key: ValueKey('empty'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          SizedBox(height: 24),
          Text(
            'No expenses yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Start tracking your spending by\nadding your first expense',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddExpenseScreen()),
              );
            },
            icon: Icon(Icons.add),
            label: Text('Add First Expense'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildByDateTab(List<Expense> expenses, ExpenseProvider provider) {
    final sortedExpenses = List<Expense>.from(expenses)
      ..sort((a, b) => b.date.compareTo(a.date));

    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: sortedExpenses.length,
      itemBuilder: (context, index) {
        final expense = sortedExpenses[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                '\$',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            title: Text(
              expense.payee,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Text(
                  'Category: ${expense.categoryId.isEmpty ? "None" : expense.categoryId}',
                  style: TextStyle(fontSize: 13),
                ),
                Text(
                  'Date: ${expense.date.toIso8601String().substring(0, 10)}',
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${expense.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final confirmed = await _confirmDelete(context, expense);
                    if (confirmed) {
                      provider.removeExpense(expense.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Expense deleted'),
                          backgroundColor: Colors.orange,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildByCategoryTab(List<Expense> expenses, categories) {
    final Map<String, List<Expense>> expensesByCategory = {};

    for (var expense in expenses) {
      final categoryKey = expense.categoryId.isEmpty ? 'Uncategorized' : expense.categoryId;
      if (!expensesByCategory.containsKey(categoryKey)) {
        expensesByCategory[categoryKey] = [];
      }
      expensesByCategory[categoryKey]!.add(expense);
    }

    return ListView(
      padding: EdgeInsets.all(8),
      children: expensesByCategory.entries.map((entry) {
        final categoryId = entry.key;
        final categoryExpenses = entry.value;
        final totalAmount = categoryExpenses.fold(0.0, (sum, exp) => sum + exp.amount);

        return Card(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ExpansionTile(
            leading: CircleAvatar(
              child: Icon(Icons.category),
            ),
            title: Text(
              categoryId,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              '${categoryExpenses.length} expense${categoryExpenses.length == 1 ? "" : "s"}',
              style: TextStyle(fontSize: 13),
            ),
            trailing: Text(
              '\$${totalAmount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            children: categoryExpenses.map((expense) {
              return ListTile(
                contentPadding: EdgeInsets.only(left: 72, right: 16, top: 4, bottom: 4),
                title: Text(
                  expense.payee,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  'Date: ${expense.date.toIso8601String().substring(0, 10)}',
                  style: TextStyle(fontSize: 13),
                ),
                trailing: Text(
                  '\$${expense.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}
