import 'package:flutter/material.dart';

class AddCategoryDialog extends StatefulWidget {
  @override
  _AddCategoryDialogState createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  // Controller to capture the user's input from the TextField
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Category'),
      content: TextField(
        controller: _nameController, // Link the controller to the text field
        autofocus: true, // Automatically focus the text field when the dialog opens
        decoration: InputDecoration(labelText: 'Category Name'),
      ),
      actions: <Widget>[
        // Cancel button: simply closes the dialog
        TextButton(
          onPressed: () {
            // Dismiss the dialog without returning a value (or returning null)
            Navigator.of(context).pop(); 
          },
          child: Text('Cancel'),
        ),
        // Add button: validates input and returns the category name
        ElevatedButton(
          onPressed: () {
            final categoryName = _nameController.text;
            if (categoryName.isNotEmpty) {
              // Close the dialog and pass the entered text back to the caller
              Navigator.of(context).pop(categoryName); 
            }
          },
          child: Text('Add'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    // Crucial: dispose of the TextEditingController to prevent memory leaks!
    _nameController.dispose();
    super.dispose();
  }
}