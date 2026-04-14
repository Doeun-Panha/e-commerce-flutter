import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/Category.dart';
import '../providers/category_provider.dart';
import '../providers/product_provider.dart';

class CategoryManagerScreen extends StatelessWidget {
  const CategoryManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Categories")),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: ()=>_showAddDialog(context),
        label: const Text("Add Category"),
        icon: const Icon(Icons.add),
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, provider, child) {
          return ListView.builder(
            itemCount: provider.categories.length,
            itemBuilder: (context, index) {
              final category = provider.categories[index];
              return ListTile(
                title: Text(category.name), // Uses name from Category model
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showUpdateDialog(context, category),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(context, category),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showUpdateDialog(BuildContext context, Category category) {
    final controller = TextEditingController(text: category.name);
    // Capture the provider while we still have the screen's context
    final catProvider = Provider.of<CategoryProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Rename Category"),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              debugPrint("Attempting to update category: ${category.id}");

              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                // Use the catProvider we captured outside the dialog
                final success = await catProvider.updateCategory(category.id, newName);
                if (success && context.mounted) {
                  Navigator.pop(dialogContext);
                }
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Category category) async {
    final catProvider = Provider.of<CategoryProvider>(context, listen: false);
    final prodProvider = Provider.of<ProductProvider>(context, listen: false);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Delete Category?"),
        content: Text("Warning: Products assigned to '${category.name}' will lose their category label."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await catProvider.deleteCategory(category.id);
      if (success) {
        // Sync local products immediately
        prodProvider.syncProductsAfterCategoryDeletion(category.id);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Category deleted successfully")),
          );
        }
      }
    }
  }

  // The Dialog for Adding a Category
  void _showAddDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Category"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Enter name"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await context.read<CategoryProvider>().addCategory(controller.text.trim());
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }
}