import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
// Note: We'll assume the next step defines a screen capable of both adding and editing
import 'add_or_edit_expense_screen.dart'; 
// Assuming you created a unified screen, let's call it AddOrEditExpenseScreen

class HomeScreen extends StatelessWidget {
  // Constants for navigation
  static const String routeName = '/home'; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense List'),
        // You might add buttons here for managing Categories/Tags later!
      ),
      // Consumer listens for changes to the ExpenseProvider
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          
          // === Handling the "No Expenses" State ===
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
          
          // === Handling the Expense List State ===
          // The instructions mention 'By Date' and 'By Category' tabs, 
          // but for this step, we implement the simple list view as given.
          return ListView.builder(
            itemCount: provider.expenses.length,
            itemBuilder: (context, index) {
              final expense = provider.expenses[index];
              return ListTile(
                // Display the main information
                title: Text(
                  '${expense.payee} - \$${expense.amount.toStringAsFixed(2)}', // Format amount
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                // Display category and date
                subtitle: Text(
                  'Category ID: ${expense.categoryId} | Date: ${expense.date.toIso8601String().substring(0, 10)}', // Format date
                ),
                // Tap to navigate to the Edit screen
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // Pass the existing expense object for editing
                      builder: (context) => AddOrEditExpenseScreen(expense: expense), 
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      
      // Floating Action Button to Add a New Expense
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              // Navigate to the screen without an expense object to signal 'Add New'
              builder: (context) => AddOrEditExpenseScreen(), 
            ),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Add Expense',
      ),
    );
  }
}