import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../models/expense_filter_options.dart';
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

  void _showSortMenu(BuildContext context, ExpenseProvider provider) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(1000, 80, 0, 0),
      items: [
        PopupMenuItem(
          value: SortBy.dateNewest,
          child: Row(
            children: [
              Icon(
                provider.sortBy == SortBy.dateNewest ? Icons.check : Icons.check_box_outline_blank,
                color: provider.sortBy == SortBy.dateNewest ? Theme.of(context).colorScheme.primary : Colors.transparent,
              ),
              SizedBox(width: 8),
              Text('Newest First'),
            ],
          ),
        ),
        PopupMenuItem(
          value: SortBy.dateOldest,
          child: Row(
            children: [
              Icon(
                provider.sortBy == SortBy.dateOldest ? Icons.check : Icons.check_box_outline_blank,
                color: provider.sortBy == SortBy.dateOldest ? Theme.of(context).colorScheme.primary : Colors.transparent,
              ),
              SizedBox(width: 8),
              Text('Oldest First'),
            ],
          ),
        ),
        PopupMenuItem(
          value: SortBy.amountHighest,
          child: Row(
            children: [
              Icon(
                provider.sortBy == SortBy.amountHighest ? Icons.check : Icons.check_box_outline_blank,
                color: provider.sortBy == SortBy.amountHighest ? Theme.of(context).colorScheme.primary : Colors.transparent,
              ),
              SizedBox(width: 8),
              Text('Highest Amount'),
            ],
          ),
        ),
        PopupMenuItem(
          value: SortBy.amountLowest,
          child: Row(
            children: [
              Icon(
                provider.sortBy == SortBy.amountLowest ? Icons.check : Icons.check_box_outline_blank,
                color: provider.sortBy == SortBy.amountLowest ? Theme.of(context).colorScheme.primary : Colors.transparent,
              ),
              SizedBox(width: 8),
              Text('Lowest Amount'),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value != null) {
        provider.setSortBy(value);
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Expense Manager',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            elevation: 2,
            actions: [
              IconButton(
                icon: Icon(Icons.sort),
                onPressed: () => _showSortMenu(context, provider),
                tooltip: 'Sort',
              ),
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
          body: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: provider.sortedExpenses.isEmpty
                ? _buildEmptyState(context)
                : TabBarView(
                    key: ValueKey('expenses'),
                    controller: _tabController,
                    children: [
                      _buildByDateTab(provider.sortedExpenses, provider),
                      _buildByCategoryTab(provider.sortedExpenses, provider.categories),
                    ],
                  ),
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
      },
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
    // Expenses are already sorted by the provider
    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
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
      String categoryName;
      if (expense.categoryId.isEmpty) {
        categoryName = 'Uncategorized';
      } else {
        try {
          final category = categories.firstWhere(
            (cat) => cat.id == expense.categoryId,
          );
          categoryName = category.name;
        } catch (e) {
          categoryName = 'Unknown Category';
        }
      }

      if (!expensesByCategory.containsKey(categoryName)) {
        expensesByCategory[categoryName] = [];
      }
      expensesByCategory[categoryName]!.add(expense);
    }

    return ListView(
      padding: EdgeInsets.all(8),
      children: expensesByCategory.entries.map((entry) {
        final categoryName = entry.key;
        final categoryExpenses = entry.value;
        final totalAmount = categoryExpenses.fold(0.0, (sum, exp) => sum + exp.amount);

        return Card(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ExpansionTile(
            leading: CircleAvatar(
              child: Icon(Icons.category),
            ),
            title: Text(
              categoryName,
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
