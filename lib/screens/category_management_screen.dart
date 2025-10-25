import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Note: Changed to the correct model name from Step 2
import '../models/category.dart'; 
import '../providers/expense_provider.dart';

class CategoryManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Categories'),
      ),
      // Use Consumer to listen for updates to the ExpenseProvider
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          // If no categories exist, display a friendly message!
          if (provider.categories.isEmpty) {
            return Center(child: Text('No categories added yet!'));
          }

          return ListView.builder(
            itemCount: provider.categories.length,
            itemBuilder: (context, index) {
              final category = provider.categories[index];
              return ListTile(
                title: Text(category.name),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // Call the new removeCategory method in the provider
                    provider.removeCategory(category.id);
                  },
                ),
              );
            },
          );
        },
      ),
      
      // Floating Action Button to add new categories
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddCategoryDialog(context);
        },
        child: Icon(Icons.add),
        tooltip: 'Add Category',
      ),
    );
  }

  // Helper function to show the Add Category Dialog
  void _showAddCategoryDialog(BuildContext context) {
    final TextEditingController _categoryNameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Category'),
          content: TextField(
            controller: _categoryNameController,
            decoration: InputDecoration(labelText: 'Category Name'),
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
                final categoryName = _categoryNameController.text.trim();
                
                if (categoryName.isNotEmpty) {
                    final category = Category( // Use the correct Category class
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: categoryName,
                    );
                    
                    // Add the category using the provider (listen: false)
                    Provider.of<ExpenseProvider>(context, listen: false).addCategory(category);
                    
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
    // Remember to dispose the controller if it was created outside the AlertDialog
    // However, since it's created inside this helper function, it will be garbage collected
  }
}