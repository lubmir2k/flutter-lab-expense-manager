import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Note: You might need to adjust these imports based on your exact file structure
import '../models/expense.dart';
import '../providers/expense_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  // Part 1: Initialize form controllers for all input fields
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _categoryIdController = TextEditingController();
  final TextEditingController _payeeController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();

  // Part 3: Implement the save function
  void _saveExpense(BuildContext context) {
    // Basic input validation: check if amount is a valid double and not empty
    if (_amountController.text.isEmpty || double.tryParse(_amountController.text) == null) {
      // In a real app, you'd show an error message here (e.g., using a SnackBar)
      return; 
    }
    
    // Create a new Expense object from the controller data
    final expense = Expense(
      // Use a unique ID based on the current timestamp
      id: DateTime.now().millisecondsSinceEpoch.toString(), 
      // Parse the text inputs to their required types
      amount: double.parse(_amountController.text),
      categoryId: _categoryIdController.text,
      payee: _payeeController.text,
      note: _noteController.text,
      // Note: This relies on the user inputting a valid date format 
      // (e.g., '2023-10-25'). A date picker would be better!
      date: DateTime.parse(_dateController.text), 
      tag: _tagController.text,
    );
    
    // Get the ExpenseProvider and call addExpense. 
    // listen: false is used because we are only calling a method, not reading data.
    Provider.of<ExpenseProvider>(context, listen: false).addExpense(expense);
    
    // Pop the current screen to return to the previous one
    Navigator.pop(context);
  }

  // Part 2: Build the UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // Use SingleChildScrollView to prevent overflow
          child: Column(
            // Use a list of form fields for the expense details
            children: <Widget>[
              // Amount Field
              TextField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
              // Category ID Field (Later, this will be a dropdown!)
              TextField(
                controller: _categoryIdController,
                decoration: InputDecoration(labelText: 'Category ID'),
              ),
              // Payee Field
              TextField(
                controller: _payeeController,
                decoration: InputDecoration(labelText: 'Payee'),
              ),
              // Note Field
              TextField(
                controller: _noteController,
                decoration: InputDecoration(labelText: 'Note'),
              ),
              // Date Field (Again, awaiting a proper date picker!)
              TextField(
                controller: _dateController,
                decoration: InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                keyboardType: TextInputType.datetime,
              ),
              // Tag Field
              TextField(
                controller: _tagController,
                decoration: InputDecoration(labelText: 'Tag'),
              ),
              
              SizedBox(height: 30), // Extra space before the button
              
              // Save Button
              ElevatedButton(
                // Use the defined method to save the data
                onPressed: () => _saveExpense(context),
                child: Text('Save Expense'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Part 3: Dispose controllers
  @override
  void dispose() {
    // It's vital to dispose of ALL controllers when the widget is destroyed!
    _amountController.dispose();
    _categoryIdController.dispose();
    _payeeController.dispose();
    _noteController.dispose();
    _dateController.dispose();
    _tagController.dispose();
    super.dispose();
  }
}