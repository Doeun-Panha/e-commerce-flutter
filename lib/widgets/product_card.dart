import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/Product.dart';
import '../screens/product_form_screen.dart';

class ProductCard extends StatelessWidget{
  final Product product;

  const ProductCard({super.key, required this.product});



  @override
  Widget build(BuildContext context) {
    const String imageServerUrl = "http://10.0.2.2:8080";
    String finalImageUrl = product.imageUrl;

    if (!finalImageUrl.startsWith('http')) {
      // Ensure there is exactly one slash between host and path
      final String cleanPath = finalImageUrl.startsWith('/')
          ? finalImageUrl
          : '/$finalImageUrl';
      finalImageUrl = '$imageServerUrl$cleanPath';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias, // Ensures the InkWell ripple matches card corners
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProductFormScreen(product: product,)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              //1. Image with rounded corners
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  finalImageUrl,
                  headers: const {
                    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36',
                  },
                  fit: BoxFit.cover,
                  width: 70,
                  height: 70,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint("❌ Standard Image.network failed: $error");
                    return const Icon(Icons.broken_image, color: Colors.red);
                  },
                )
              ),

              const SizedBox(width: 16,),

              // 2. Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 4),

                    _buildStockStatus(context),
                  ],
                ),
              ),

              // 3. Navigation Hint
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStockStatus(BuildContext context) {
    final bool isLowStock = product.stockQuantity <= product.lowStockThreshold;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isLowStock ? Colors.red[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Stock: ${product.stockQuantity}',
        style: TextStyle(
          color: isLowStock ? Colors.red[700] : Colors.green[700],
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}