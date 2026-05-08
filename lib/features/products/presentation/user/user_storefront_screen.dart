import 'package:ecommerce/features/categories/logic/category_provider.dart';
import 'package:ecommerce/features/products/presentation/widgets/user_product_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/logic/auth_provider.dart';
import '../../logic/cart_provider.dart';
import '../../logic/product_provider.dart';
import 'cart_screen.dart';

class UserStorefrontScreen extends StatefulWidget {
  const UserStorefrontScreen({super.key});

  @override
  State<UserStorefrontScreen> createState() => _UserStorefrontScreenState();
}
class _UserStorefrontScreenState extends State<UserStorefrontScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _searchController.addListener((){
      setState(() => _searchQuery = _searchController.text);
    });
  }

  void _loadInitialData() {
    Future.microtask(() {
      final auth = context.read<AuthProvider>();
      context.read<ProductProvider>().fetchProducts(auth);
      context.read<CategoryProvider>().fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background makes cards "pop"
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: () => productProvider.fetchProducts(context.read<AuthProvider>()),
        child: Column(
            children: [
              _buildFilterRow(),
              _buildSearchBar(),
              Expanded(child: _buildBody(productProvider)),
            ],
        ),
      ),
    );
  }

  // --- UI Components ---

  Widget _buildFilterRow() {
    return Consumer2<ProductProvider, CategoryProvider>(
      builder: (context, productProd, catProd, child) {
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // 2. Mirrored Search Bar
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search products...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(icon: const Icon(Icons.clear), onPressed: () => _searchController.clear())
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  // 3. Updated Body with Search Filtering
  Widget _buildBody(ProductProvider provider) {
    if (provider.isLoading && provider.products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Apply search query filter
    final filteredList = provider.filteredProducts
        .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    if (filteredList.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        return UserProductCard(product: filteredList[index]);
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
        onPressed: () => _showLogoutDialog(context),
      ),
      title: const Text(
          "E-commerce",
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2
          )
      ),
      actions: [
        Consumer<CartProvider>(
          builder: (context, cart, child) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0, top: 8.0),
              child: Badge(
                label: Text(cart.itemCount.toString()),
                isLabelVisible: cart.itemCount > 0,
                backgroundColor: Colors.purpleAccent,
                child: IconButton(
                  icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CartScreen()),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              // 1. Call the logout logic from your Provider
              context.read<AuthProvider>().logout();

              // 2. Close the dialog
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        const Center(
          child: Text("No product available yet. Stay tuned!",
              style: TextStyle(color: Colors.grey, fontSize: 16)),
        ),
      ],
    );
  }
}