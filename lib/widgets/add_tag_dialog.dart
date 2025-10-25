import 'package:flutter/material.dart';

class AddTagDialog extends StatefulWidget {
  @override
  _AddTagDialogState createState() => _AddTagDialogState();
}

class _AddTagDialogState extends State<AddTagDialog> {
  // Controller to capture the user's input for the tag name
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Tag'),
      content: TextField(
        controller: _nameController,
        autofocus: true,
        decoration: InputDecoration(labelText: 'Tag Name'),
      ),
      actions: <Widget>[
        // Cancel button
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        // Add button
        ElevatedButton(
          onPressed: () {
            final tagName = _nameController.text;
            if (tagName.isNotEmpty) {
              // Close the dialog and return the entered text
              Navigator.of(context).pop(tagName);
            }
          },
          child: Text('Add'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    // Dispose of the controller!
    _nameController.dispose();
    super.dispose();
  }
}