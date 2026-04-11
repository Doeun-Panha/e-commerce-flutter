import 'package:ecommerce/views/product_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce/models/Product.dart';
import 'package:ecommerce/services/api_service.dart';

class ProductListScreen extends StatefulWidget{
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState()=>_ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen>{
  final ApiService _apiService=ApiService();
  late Future<List<Product>> _productsFuture;
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState(){
    super.initState();
    _refreshProducts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose(){
    _searchController.dispose();
    super.dispose();
  }

  void _refreshProducts(){
    setState(() {
      _productsFuture=_apiService.getProducts();
    });
  }

  void _onSearchChanged(){
    setState(() {
      _filteredProducts=_allProducts
          .where((product)=>product.name
            .toLowerCase()
            .contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  Future<void> _deleteProduct(int id) async{
    final confirmed = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this product?'),
          actions: [
            TextButton(
                onPressed: ()=>Navigator.pop(context,false),
                child: const Text('Cancel'),
            ),
            TextButton(
                onPressed: ()=>Navigator.pop(context,true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                )
            )
          ],
        )
    );

    if(confirmed==true){
      try{
        await _apiService.deleteProduct(id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content:Text('Product deleted successfully'))
        );
        _refreshProducts();
      }catch(e){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleteing product:$e'))
        );
      }
    }
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
          if (_allProducts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  _buildSummaryCard(
                      "Total Items",
                      _allProducts.length.toString(),
                      Colors.blue
                  ),
                  const SizedBox(width: 12),
                  _buildSummaryCard(
                      "Low Stock",
                      _allProducts.where((p) => p.stockQuantity < 5).length.toString(),
                      Colors.orange
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsetsGeometry.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot){
                if(snapshot.connectionState==ConnectionState.waiting){
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }else if(snapshot.hasError){
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }else if(!snapshot.hasData||snapshot.data!.isEmpty){
                  return const Center(
                    child: Text('No products found.'),
                  );
                }

                _allProducts=snapshot.data!;

                if(_searchController.text.isEmpty){
                  _filteredProducts=_allProducts;
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredProducts.length,
                  itemBuilder: (context, index){
                    final product = _filteredProducts[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom:12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusDirectional.circular(15),
                      ),
                      elevation: 2,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(product.imageUrl.isNotEmpty
                                  ? product.imageUrl
                                  : 'https://via.placeholder.com/150'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        title: Text(
                          product.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('\$${product.price.toStringAsFixed(2)}'),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: product.stockQuantity < 5
                                    ? Colors.red.withOpacity(0.1)
                                    : Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'In Stock: ${product.stockQuantity}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: product.stockQuantity < 5 ? Colors.red : Colors.green[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.blue,),
                              onPressed: ()async{
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductFormScreen(product: product,)
                                  )
                                );

                                if(result==true){
                                  _refreshProducts();
                                }
                              }
                            ),
                            IconButton(
                                onPressed: ()=>_deleteProduct(product.id),
                                icon: const Icon(Icons.delete, color: Colors.red)
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            )
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async{
          final result=await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context)=> const ProductFormScreen(),
            )
          );

          if(result==true){
            _refreshProducts();
          }
        },
        label: const Text('Add Product'),
        icon: const Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
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