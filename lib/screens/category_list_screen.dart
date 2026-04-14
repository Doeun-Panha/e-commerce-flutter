import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/Category.dart';
import '../providers/category_provider.dart';
import '../providers/product_provider.dart';

class CategoryListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Categories")),
      body: Consumer<CategoryProvider>(
        builder: (context, provider, child) {
          return ListView.builder(
            itemCount: provider.categories.length,
            itemBuilder: (context, index) {
              final category = provider.categories[index];
              return ListTile(
                title: Text(category.name),
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
    TextEditingController controller = TextEditingController(text: category.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Update Category"),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final success = await context.read<CategoryProvider>()
                  .updateCategory(category.id, controller.text.trim());
              if (success && context.mounted) Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Category?"),
        content: Text("Products in ${category.name} will be marked as 'None'."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await context.read<CategoryProvider>().deleteCategory(category.id);
      if (success && context.mounted) {
        // CRITICAL: Sync the product list so UI stays consistent
        context.read<ProductProvider>().syncProductsAfterCategoryDeletion(category.id);
      }
    }
  }
}