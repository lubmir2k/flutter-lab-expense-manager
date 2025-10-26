import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../screens/add_expense_screen.dart';
import '../screens/category_management_screen.dart';
import '../screens/tag_management_screen.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/expense_filter_options.dart';
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
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
                color: provider.sortBy == SortBy.dateNewest ? Colors.deepPurple : Colors.transparent,
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
                color: provider.sortBy == SortBy.dateOldest ? Colors.deepPurple : Colors.transparent,
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
                color: provider.sortBy == SortBy.amountHighest ? Colors.deepPurple : Colors.transparent,
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
                color: provider.sortBy == SortBy.amountLowest ? Colors.deepPurple : Colors.transparent,
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
    final provider = Provider.of<ExpenseProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Expense Tracker"),
        backgroundColor: Colors.deepPurple[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: () => _showSortMenu(context, provider),
            tooltip: 'Sort',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: "By Date"),
            Tab(text: "By Category"),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text('Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: Icon(Icons.category, color: Colors.deepPurple),
              title: Text('Manage Categories'),
              onTap: () {
                Navigator.pop(context); // This closes the drawer
                Navigator.pushNamed(context, '/manage_categories');
              },
            ),
            ListTile(
              leading: Icon(Icons.tag, color: Colors.deepPurple),
              title: Text('Manage Tags'),
              onTap: () {
                Navigator.pop(context); // This closes the drawer
                Navigator.pushNamed(context, '/manage_tags');
              },
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildExpensesByDate(context),
          buildExpensesByCategory(context),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => AddExpenseScreen())),
        tooltip: 'Add Expense',
        child: Icon(Icons.add),
      ),
    );
  }
  Widget buildExpensesByDate(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        if (provider.sortedExpenses.isEmpty) {
          return Center(
            child: Text("Click the + button to record expenses.",
                style: TextStyle(color: Colors.grey[600], fontSize: 18)),
          );
        }
        return ListView.builder(
          itemCount: provider.sortedExpenses.length,
          itemBuilder: (context, index) {
            final expense = provider.sortedExpenses[index];
            String formattedDate =
                DateFormat('MMM dd, yyyy').format(expense.date);
            return Dismissible(
              key: Key(expense.id),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                provider.removeExpense(expense.id);
              },
              background: Container(
                color: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.centerRight,
                child: Icon(Icons.delete, color: Colors.white),
              ),
              child: Card(
                color: Colors.purple[50],
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                child: ListTile(
                  title: Text(
                      "${expense.payee} - \$${expense.amount.toStringAsFixed(2)}"),
                  subtitle: Text(
                      "$formattedDate - Category: ${getCategoryNameById(context, expense.categoryId)}"),
                  isThreeLine: true,
                ),
              ),
            );
          },
        );
      },
    );
  }
  Widget buildExpensesByCategory(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        if (provider.sortedExpenses.isEmpty) {
          return Center(
            child: Text("Click the + button to record expenses.",
                style: TextStyle(color: Colors.grey[600], fontSize: 18)),
          );
        }
        // Grouping expenses by category
        var grouped = groupBy(provider.sortedExpenses, (Expense e) => e.categoryId);
        return ListView(
          children: grouped.entries.map((entry) {
            String categoryName = getCategoryNameById(
                context, entry.key); // Ensure you implement this function
            double total = entry.value.fold(
                0.0, (double prev, Expense element) => prev + element.amount);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "$categoryName - Total: \$${total.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
                ListView.builder(
                  physics:
                      NeverScrollableScrollPhysics(), // to disable scrolling within the inner list view
                  shrinkWrap:
                      true, // necessary to integrate a ListView within another ListView
                  itemCount: entry.value.length,
                  itemBuilder: (context, index) {
                    Expense expense = entry.value[index];
                    return ListTile(
                      leading:
                          Icon(Icons.monetization_on, color: Colors.deepPurple),
                      title: Text(
                          "${expense.payee} - \$${expense.amount.toStringAsFixed(2)}"),
                      subtitle: Text(DateFormat('MMM dd, yyyy')
                          .format(expense.date)),
                    );
                  },
                ),
              ],
            );
          }).toList(),
        );
      },
    );
  }
  // home_screen.dart
  String getCategoryNameById(BuildContext context, String categoryId) {
    var category = Provider.of<ExpenseProvider>(context, listen: false)
        .categories
        .firstWhere((cat) => cat.id == categoryId);
    return category.name;
  }
}