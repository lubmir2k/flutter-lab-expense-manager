import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tag.dart';
import '../providers/expense_provider.dart';

class AddTagDialog extends StatefulWidget {
  @override
  _AddTagDialogState createState() => _AddTagDialogState();
}

class _AddTagDialogState extends State<AddTagDialog> {
  final TextEditingController _nameController = TextEditingController();

  void _saveTag(BuildContext context) {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a tag name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final tag = Tag(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
    );

    Provider.of<ExpenseProvider>(context, listen: false).addTag(tag);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Tag'),
      content: TextField(
        controller: _nameController,
        decoration: InputDecoration(labelText: 'Tag Name'),
        autofocus: true,
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () => _saveTag(context),
          child: Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
