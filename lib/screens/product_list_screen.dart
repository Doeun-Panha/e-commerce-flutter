import 'package:ecommerce/screens/category_manager_screen.dart';

import 'product_form_screen.dart';
import 'package:flutter/material.dart';
import '../providers/product_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/product_card.dart';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ProductListScreen extends StatefulWidget{
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState()=>_ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen>{
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState(){
    super.initState();
    // Clear the cache once to remove all "failed" image markers
    DefaultCacheManager().emptyCache();
    _searchController.addListener((){
      setState(() => _searchQuery=_searchController.text);
    });

  }

  @override
  void dispose(){
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Management', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        elevation: 0,
        actions: [
          IconButton(
              onPressed: ()=>Navigator.push(
                context,
                MaterialPageRoute(builder: (context)=>const CategoryManagerScreen())
              ), icon: const Icon(Icons.category))
        ],
      ),
      body: Column(
        children: [
          //1. Dashboard summary (Listens to Provider)
          Consumer<ProductProvider>(
            builder: (context, provider, child){
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    _buildSummaryCard("Total Items", provider.totalItems.toString(), Colors.blue),
                    const SizedBox(width: 12),
                    _buildSummaryCard("Low Stock", provider.lowStockCount.toString(), Colors.orange),
                  ],
                ),
              );
            },
          ),

          //2. Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),

          //3. The Product List (Listens to Provider)
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, provider,child){
                if(provider.isLoading)
                  return const Center(child: CircularProgressIndicator());

                final filteredList = provider.products
                  .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
                  .toList();

                if(filteredList.isEmpty) {
                  return const Center(child: Text('No products found'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  cacheExtent: 1000,
                  itemCount: filteredList.length,
                  itemBuilder: (context, index){
                    return ProductCard(
                      key: ValueKey(filteredList[index].id),
                      product: filteredList[index],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProductFormScreen())
        ),
        label: const Text('Add Product'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}