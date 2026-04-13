import 'package:flutter/foundation.dart';

import 'product_form_screen.dart';
import 'package:flutter/material.dart';
import '../models/Product.dart';
import '../providers/product_provider.dart';
import 'package:provider/provider.dart';

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
                  return const Center(child: Text('No products founds'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index){
                    final product=filteredList[index];
                    return _buildProductCard(context, product, provider);
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

  Widget _buildProductCard(BuildContext context, Product product, ProductProvider provider){
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias, // Ensures the InkWell ripple matches card corners
      child: InkWell(
        onTap: ()=>Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProductFormScreen(product: product)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  _isValidUrl(product.imageUrl) ? product.imageUrl : 'https://via.placeholder.com/150',
                  width: 70, height: 70, fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 70),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                    const SizedBox(height: 4,),
                    Text('\$${product.price}', style: const TextStyle(color: Colors.blueGrey),),
                    Text('Stock: ${product.stockQuantity}',
                        style: TextStyle(color: product.stockQuantity <5 ? Colors.red : Colors.green)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey,),
            ],
          ),
        ),
      )
    );
  }

  bool _isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    final uri = Uri.tryParse(url);
    return uri != null && uri.hasAbsolutePath && (uri.isScheme('http') || uri.isScheme('https'));
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