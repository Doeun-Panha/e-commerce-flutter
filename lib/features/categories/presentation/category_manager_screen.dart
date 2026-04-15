import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/Category.dart';
import '../logic/category_provider.dart';
import '../../products/logic/product_provider.dart';

class CategoryManagerScreen extends StatelessWidget {
  const CategoryManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Categories"),
        centerTitle: true,
      ),
      floatingActionButton: _buildFAB(context),
      body: Consumer<CategoryProvider>(
        builder: (context, provider, _) {
          if (provider.categories.isEmpty) return _buildEmptyState();

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.categories.length,
            separatorBuilder: (_, __) => const Divider(height: 1,),
            itemBuilder: (context, index) => _buildCategoryTile(
                context,
                provider.categories[index]
            ),
          );
        },
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showAddDialog(context),
      label: const Text("Add Category"),
      icon: const Icon(Icons.add_rounded),
    );
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

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text("No categories yet. Add one to start!",
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildCategoryTile(BuildContext context, Category category) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      title: Text(
        category.name,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.blue),
            onPressed: () => _showUpdateDialog(context, category),
            tooltip: 'Rename',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
            onPressed: () => _confirmDelete(context, category),
            tooltip: 'Delete',
          ),
        ],
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
}