import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _payeeController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String? _selectedCategoryId;
  String? _selectedTag;

  @override
  void dispose() {
    _amountController.dispose();
    _payeeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveExpense(BuildContext context) {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fix the errors in the form'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final expense = Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: double.parse(_amountController.text),
      categoryId: _selectedCategoryId ?? '',
      payee: _payeeController.text,
      note: _noteController.text,
      date: _selectedDate,
      tag: _selectedTag ?? '',
    );

    Provider.of<ExpenseProvider>(context, listen: false).addExpense(expense);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Expense added successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Expense'),
        elevation: 2,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            // Amount Field
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount',
                hintText: '0.00',
                prefixText: '\$ ',
                helperText: 'Enter the expense amount',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid positive amount';
                }
                return null;
              },
            ),
            SizedBox(height: 20),

            // Payee Field
            TextFormField(
              controller: _payeeController,
              decoration: InputDecoration(
                labelText: 'Payee',
                hintText: 'Who did you pay?',
                helperText: 'Enter the recipient or merchant name',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
                prefixIcon: Icon(Icons.person),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a payee';
                }
                return null;
              },
            ),
            SizedBox(height: 20),

            // Category Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategoryId,
              decoration: InputDecoration(
                labelText: 'Category',
                helperText: provider.categories.isEmpty
                    ? 'Add categories in settings'
                    : 'Select a category for this expense',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
                prefixIcon: Icon(Icons.category),
              ),
              hint: Text('Select Category'),
              items: provider.categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category.id,
                  child: Text(category.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategoryId = value;
                });
              },
              validator: (value) {
                if (provider.categories.isNotEmpty && (value == null || value.isEmpty)) {
                  return 'Please select a category';
                }
                return null;
              },
            ),
            SizedBox(height: 20),

            // Tag Dropdown
            DropdownButtonFormField<String>(
              value: _selectedTag,
              decoration: InputDecoration(
                labelText: 'Tag (Optional)',
                helperText: provider.tags.isEmpty
                    ? 'Add tags in settings'
                    : 'Optionally add a tag for filtering',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
                prefixIcon: Icon(Icons.label),
              ),
              hint: Text('Select Tag'),
              items: provider.tags.map((tag) {
                return DropdownMenuItem<String>(
                  value: tag.name,
                  child: Text(tag.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTag = value;
                });
              },
            ),
            SizedBox(height: 20),

            // Date Picker
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Date',
                  helperText: 'Tap to select a date',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[50],
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  DateFormat('MMMM dd, yyyy').format(_selectedDate),
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Note Field
            TextFormField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: 'Note (Optional)',
                hintText: 'Add any additional details',
                helperText: 'Optional memo or description',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            SizedBox(height: 30),

            // Save Button
            ElevatedButton(
              onPressed: () => _saveExpense(context),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Save Expense',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
