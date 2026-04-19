import 'package:ecommerce/features/products/presentation/widgets/admin_product_card.dart';
import 'package:ecommerce/features/products/presentation/widgets/user_product_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/product_provider.dart';
import '../../auth/logic/auth_provider.dart';

class UserStorefrontScreen extends StatefulWidget {
  const UserStorefrontScreen({super.key});

  @override
  State<UserStorefrontScreen> createState() => _UserStorefrontScreenState();
}
class _UserStorefrontScreenState extends State<UserStorefrontScreen> {
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    Future.microtask(() {
      final auth = context.read<AuthProvider>();
      context.read<ProductProvider>().fetchProducts(auth);
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
        child: _buildBody(productProvider),
      ),
    );
  }

  // --- UI Components ---

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
        onPressed: () => _showLogoutDialog(context),
      ),
      title: const Text(
          "E-commerce",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: 1.2)
      ),
      centerTitle: true,
      actions: [
        IconButton(icon: const Icon(Icons.search, color: Colors.black), onPressed: () {}),
        IconButton(icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black), onPressed: () {}),
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
  Widget _buildBody(ProductProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.products.isEmpty) {
      return _buildEmptyState();
    }

    return _buildProductGrid(provider);
  }

  Widget _buildProductGrid(ProductProvider provider) {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: provider.products.length,
      itemBuilder: (context, index) {
        return UserProductCard(product: provider.products[index]);
      },
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