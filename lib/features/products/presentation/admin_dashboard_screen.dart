import 'package:ecommerce/core/theme/app_theme.dart';
import 'package:ecommerce/features/categories/presentation/category_manager_screen.dart';
import 'package:ecommerce/features/categories/logic/category_provider.dart';

import '../../auth/logic/auth_provider.dart';
import 'admin_product_form_screen.dart';
import 'package:flutter/material.dart';
import '../logic/product_provider.dart';
import 'package:provider/provider.dart';
import 'widgets/admin_product_card.dart';

class AdminDashboardScreen extends StatefulWidget{
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState()=>_AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    // Fetch data immediately when screen loads
    Future.microtask(() {
      if(mounted){
        // 1. Get the AuthProvider instance
        final auth = Provider.of<AuthProvider>(context, listen: false);

        // 2. Pass it to fetchProducts to handle potential 403 errors
        Provider.of<ProductProvider>(context, listen: false).fetchProducts(auth);
        Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
      }
    });

    // Clear the cache once to remove all "failed" image markers
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      // Pull-to-refresh logic
      body: RefreshIndicator(
        onRefresh: () =>
            Provider
                .of<ProductProvider>(context, listen: false)
                .fetchProducts(context.read<AuthProvider>()),
        child: Column(
          children: [
            _buildDashboard(), // Summary cards
            _buildFilterRow(),
            _buildSearchBar(), // Search input
            const SizedBox(height: 8),
            _buildProductList(), // The dynamic list
          ],
        ),
      ),
      floatingActionButton: _buildFab(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
          'Product Inventory', style: TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: Theme
          .of(context)
          .colorScheme
          .primaryContainer,
      actions: [
        // Category Manager Button
        IconButton(
          onPressed: () =>
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CategoryManagerScreen()),
              ),
          icon: const Icon(Icons.category_outlined),
        ),
        // Logout Button
        IconButton(
          onPressed: () => _showLogoutDialog(context),
          icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
          tooltip: "Logout",
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to sign out of the admin panel?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.pop(context); // Close dialog
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) =>
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                _buildSummaryCard("In Stock", "${provider.totalItems}",
                    Icons.inventory_2_outlined, Colors.blue),
                const SizedBox(width: 12),
                _buildSummaryCard("Low Stock", "${provider.lowStockCount}",
                    Icons.priority_high_rounded, Colors.orange),
              ],
            ),
          ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon,
      Color color) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          final provider = Provider.of<ProductProvider>(context, listen: false);
          // If user taps the Low Stock card, filter for Low Stock. Otherwise, show All.
          if (title == "Low Stock") {
            provider.setFilter("Low Stock");
          } else {
            provider.setFilter("All");
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: TextStyle(
                      color: color, fontWeight: FontWeight.bold, fontSize: 12)),
                  Text(value, style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search products...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(icon: const Icon(Icons.clear),
              onPressed: () => _searchController.clear())
              : null,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadius)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }

  Widget _buildProductList() {
    return Expanded(
      child: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredList = provider.filteredProducts
              .where((p) =>
              p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
              .toList();

          if (filteredList.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredList.length,
            itemBuilder: (context, index) =>
                AdminProductCard(
                  key: ValueKey(filteredList[index].id),
                  product: filteredList[index],
                ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("No results for '$_searchQuery'",
              style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildFab() {
    return FloatingActionButton.extended(
      onPressed: () =>
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminProductFormScreen()),
          ),
      label: const Text('Add Product'),
      icon: const Icon(Icons.add),
    );
  }

  Widget _buildFilterRow() {
    return Consumer2<ProductProvider, CategoryProvider>(
      builder: (context, productProd, catProd, child) {
        // Combine hardcoded filters with dynamic categories
        final filters = ['All', 'A-Z', 'Price', ...catProd.categories.map((c) => c.name)];

        return SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: filters.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final filter = filters[index];
              final isSelected = productProd.selectedFilter == filter;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  selected: isSelected,
                  label: Text(filter),
                  onSelected: (bool selected) {
                    productProd.setFilter(filter);
                  },
                  selectedColor: Theme.of(context).colorScheme.primaryContainer,
                  checkmarkColor: Theme.of(context).colorScheme.primary,
                ),
              );
            },
          ),
        );
      },
    );
  }
}