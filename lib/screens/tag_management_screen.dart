import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tag.dart';
import '../providers/expense_provider.dart';

class TagManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Tags'),
      ),
      // Use Consumer to react to changes in the tags list
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          // Display a message if the list is empty
          if (provider.tags.isEmpty) {
            return Center(child: Text('No tags added yet! Get tagging!'));
          }
          
          return ListView.builder(
            itemCount: provider.tags.length,
            itemBuilder: (context, index) {
              final tag = provider.tags[index];
              return ListTile(
                title: Text(tag.name),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // Call the removeTag method on the provider
                    provider.removeTag(tag.id);
                  },
                ),
              );
            },
          );
        },
      ),
      
      // Floating Action Button to trigger the add tag dialog
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTagDialog(context);
        },
        child: Icon(Icons.add),
        tooltip: 'Add Tag',
      ),
    );
  }

  // Helper function to show the Add Tag Dialog
  void _showAddTagDialog(BuildContext context) {
    final TextEditingController _tagNameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Tag'),
          content: TextField(
            controller: _tagNameController,
            decoration: InputDecoration(labelText: 'Tag Name'),
            autofocus: true,
          ),
          actions: <Widget>[
            // Cancel Button
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            // Add Button
            TextButton(
              onPressed: () {
                final tagName = _tagNameController.text.trim();
                
                if (tagName.isNotEmpty) {
                    final tag = Tag(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: tagName,
                    );
                    
                    // Add the tag using the provider
                    Provider.of<ExpenseProvider>(context, listen: false).addTag(tag);
                    
                    // Close the dialog
                    Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}